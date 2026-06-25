class_name MainGUI extends Node2D

@export var map: MapNode = null
@export var game: Game = null
var popup_text: PackedScene = preload("res://nodes/popup_text.tscn")
var fade_msg: PackedScene = preload("res://nodes/fade_popup.tscn")
var pre_button_menu = preload("res://nodes/menus/button_menu.tscn")
var unit_node: PackedScene = preload("res://nodes/unit_node.tscn")
@export var hud_node: Control = null
@export var menu_node: Control = null
@export var unit_list_node: Node = null
@export var map_info_label: Label = null

@export var unit_container: UnitContainer = null
@export var tile_container: TileContainer = null
var file_loader: FileLoader = FileLoader.new()

func _ready() -> void:
	file_loader.read_classes()
	file_loader.read_characters()
	file_loader.read_tiles()
	file_loader.reread_map(map.field_map, str(game.currentMapNumber))
	map.move.connect(move)
	map.field_map.player = null
	game.currentMap = map.field_map
	game.update.connect(on_game_update)
	map.draw_tiles(map.direction)
	draw_and_set_tiles()
	
var continue_process = true

func _process(_delta):
	map.set_tiles_in_nodes()
	if Input.is_action_just_pressed("retry"):
		_ready()
	if not continue_process: return
	if Input.is_action_just_pressed("deselect"):
		game.deSelect()
		free_children(menu_node)
	game.currentMap = map.field_map
	if !game.update.is_connected(on_game_update):
		game.update.connect(on_game_update)
	if !game.change_turn.is_connected(on_change_turn):
		game.change_turn.connect(on_change_turn)
	if !game.selected.is_connected(on_selected):
		game.selected.connect(on_selected)
	# set the nodes and tiles
	connect_tile_nodes()
	show_movement_range()
	make_unit_nodes()
	if game.queue.is_empty():
		#print("turn of ",game.turn_of_dict[game.turnOf], " (",game.turnOf,")")
		game.handle_turn()
		return
	var current_action: Action = game.queue.pop_front()
	if current_action:
		current_action.animate.connect(animate)
		current_action.move.connect(move_to_tile)
		current_action.update.connect(update_unit_node)
		current_action.play()
		#hide move range
		game.deSelect()
		show_movement_range()
		continue_process = false
		if current_action.closes_menu:
			free_children(menu_node)
		await get_tree().create_timer(current_action.actLength).timeout
		if current_action.get("over"): on_lose()
		continue_process = true

### UNIT NODE HANDLING ###

func animate(animation: String, unit: Units, delay: float, msg: String = ""):
	if msg=="Wait":
		update_unit_node(unit, delay, true)
	for u in get_tree().get_nodes_in_group("unit"):
		if u.unit == unit:
			u.play_animation(animation, delay, msg)

func move(pos: Vector2, unit: Units, index: int, delay: float):
	for u in get_tree().get_nodes_in_group("unit"):
		if u.unit == unit:
			u.play_move(pos, index, delay)

func move_to_tile(location: Tile, unit: Units, delay: float):
	var pos = map.tile_translated_to_v2(location)
	print("moving to tile "+str(location.position))
	move(pos, unit, location.position.z, delay)

func update_unit_node(unit: Units, delay: float, dim: bool):
	for u in get_tree().get_nodes_in_group("unit"):
		if u.unit == unit:
			u.on_update(delay, dim)

### TILE NODE HANDING ###

func tile_sent_selected(tile: Tile):
	game.selectTile(tile)
	tile_container._ready(tile)

func tile_sent_hovered(tile: Tile):
	tile_container._ready(tile)

func connect_tile_nodes():
	for i: Tile in game.currentMap.grid.tiles:
		var node = map.get_child_at_v3(i.position)
		if node:
			if !node.selected_tile.is_connected(tile_sent_selected):
				node.selected_tile.connect(tile_sent_selected)
				node.hovered_tile.connect(tile_sent_hovered)
			node.show_move_sprite(false, true, game.acting)
			if node.tile.occupiable and node.tile.occupiable.occupant:
				pass
				# TODO create new unit node or somsin.ce

func show_movement_range():
	# display movement area
	for i: Tile in map.field_map.movementRangeTiles(game.acting):
		var node = map.get_child_at_v3(i.position)
		if node:
			node.show_move_sprite(true, !game.acting.moved)

func draw_and_set_tiles():
	map.draw_tiles(map.direction)
	map.set_tiles_in_nodes()

func on_game_update():
	draw_and_set_tiles()
	unit_container._ready(game.acting)
	tile_container._ready(null)
	#free_children(menu_node)
	#if game.acting == game.target:
	#	var menu = pre_button_menu.instantiate()
	#	menu.game = game
	#	menu.user = game.acting
	#	menu.new_menu([game.acting])
	#	show_movement_range()
	#	menu_node.add_child(menu)
	#elif game.target:
	#	var menu = pre_button_menu.instantiate()
	#	menu.game = game
	#	menu.user = game.acting
	#	
	#	menu.new_menu([game.acting])
	#	menu_node.add_child(menu)

func free_children(node) -> void:
	for child in node.get_children():
		child.queue_free()

func make_unit_nodes() -> void:
	if !(game and game.currentMap): return
	var unit_list = game.currentMap.all_units()
	var node_list = get_tree().get_nodes_in_group("unit")
	for unit in unit_list:
		# if no matching reference is found in nodes
		if node_list.all(func(n): return n.unit != unit):
			var new_unit_node = unit_node.instantiate()
			new_unit_node.unit = unit
			new_unit_node.set_node(unit)
			new_unit_node._ready()
			unit_list_node.add_child(new_unit_node)

func on_change_turn():
	for u: UnitNode in get_tree().get_nodes_in_group("unit"):
		u.on_update(1, true)
		if u.unit and u.unit.team == game.turnOf:
			u.play_animation("default",1)
		else:
			u.play_animation("still",1)
	# turn number, cleaar condition
	map_info_label.text = str(game.currentMap.turnNumber) + "\nVictory:\n " + game.currentMap.clearCondition.description()
	map_info_label.text += "\nLoss: "
	for lose: Condition in game.currentMap.loseConditions:
		map_info_label.text += "\n " + lose.description()
	# inform whose turn it is now
	var msg: String = ""
	if game:
		msg = "Now " + game.turn_of_dict[game.turnOf]
	var msg_node = fade_msg.instantiate()
	msg_node.create(msg)
	hud_node.add_child(msg_node)

func on_selected(thing):
	draw_and_set_tiles()
	unit_container._ready(game.acting)
	tile_container._ready(null)
	free_children(menu_node)
	if game.acting:
		var menu = pre_button_menu.instantiate()
		menu.game = game
		menu.user = game.acting
		menu.new_menu(thing)
		show_movement_range()
		menu_node.add_child(menu)
		print("made menu", thing)

func on_lose():
	var msg: String = ""
	if game:
		msg = "The heroes have fallen."
	var msg_node = fade_msg.instantiate()
	msg_node.create(msg)
	hud_node.add_child(msg_node)
	await get_tree().create_timer(2).timeout
	_ready()
