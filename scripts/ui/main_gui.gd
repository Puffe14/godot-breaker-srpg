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
@export var tip_label: Label = null

@export var unit_container: Container = null
@export var tile_container: TileContainer = null
@export var inspect_container: InspectUnitContainer = null
@export var dialogue_container: DialogueContainer = null
var file_loader: FileLoader = FileLoader.new()

## constants
var tip_timer: float = 3.0

func load_game_component_data() -> void:
	file_loader.read_items()
	file_loader.read_classes()
	file_loader.read_characters()
	file_loader.read_tiles()
	file_loader.read_inventories()
func _init() -> void:
	print("main gui - init called, does nothing")
	#load_game_component_data()
	#continue_process = false
	
func _ready() -> void:
	# reset text and lists
	if tip_label:
		tip_label.text = ""
	if map_info_label:
		map_info_label.text = ""
	# Dont start again while drawing nodes
	if continue_process:
		continue_process = false
	else:
		return
	free_children(unit_list_node)
	load_game_component_data()
	if not map.field_map:
		print("field_map of Map node empty, creating empty field_map")
		map.change_field_map(FieldMap.new())
	#reset player for map and take it from game
	map.field_map.player = null
	game.currentMap = map.field_map
	game.acting = null
	if !map.move.is_connected(move):
		map.move.connect(move)
	#map.field_map.player = game.player
	file_loader.reread_map(map.field_map, str(game.currentMapNumber))
	# connect tiles and draw the map
	game.update.connect(on_game_update)
	map.reset_direction()
	draw_and_set_tiles()
	#await map.done_drawing_nodes
	continue_process = true
	repaint_unit_shaders()
	on_game_update()
	
var continue_process = true

func _process(_delta):
	if Input.is_action_just_pressed("debug"):
		draw_and_set_tiles()
	if Input.is_action_just_pressed("retry"):
		_ready()
	if not game or not game.currentMap:
		await get_tree().create_timer(1).timeout
		print("game or map missing")
		if not game or not game.currentMap:
			_ready()
		return
	spin_map()
	if not continue_process: return
	if Input.is_action_just_pressed("quick_end_turn"):
		game.skip_player()
	if Input.is_action_just_pressed("deselect"):
		game.deSelect()
		inspect_container.update(null)
		free_children(menu_node)
	game.currentMap = map.field_map
	var player_check = game.player
	if !game.update.is_connected(on_game_update):
		game.update.connect(on_game_update)
	if !game.change_turn.is_connected(on_change_turn):
		game.change_turn.connect(on_change_turn)
	if !game.selected.is_connected(on_selected):
		game.selected.connect(on_selected)
	if !game.inspected.is_connected(on_inspected):
		game.inspected.connect(on_inspected)
	if !game.send_tip.is_connected(on_game_tip):
		game.send_tip.connect(on_game_tip)
	# set the nodes and tiles
	connect_tile_nodes()
	map.set_tiles_in_nodes()
	#make_unit_nodes()
	show_movement_range(game.acting == null)
	show_reach_range(game.acting)
	if game.queue.is_empty():
		#print("turn of ",game.turn_of_dict[game.turnOf], " (",game.turnOf,")")
		game.handle_turn()
		return
	var current_action: Action = game.queue.pop_front()
	if current_action:
		inspect_container.update(null)
		current_action.animate.connect(animate)
		current_action.move.connect(move_to_tile)
		current_action.update.connect(update_unit_node)
		# play the action and read any dialogue
		var expl = current_action.play()
		dialogue_container.explain = expl
		continue_process = false
		while expl and expl.dialogueNotOver():
			print(expl.dialogue())
			dialogue_container.set_dialogue(expl.dialogue())
			await dialogue_container.progress
			expl.advanceDialogue()
		dialogue_container.set_dialogue(null)
		dialogue_container.explain = null
		#hide move range
		game.deSelect()
		show_movement_range(true)
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
	var target_tile_node = map.get_child_at_v3(location.position)
	var new_z_index = location.position.z
	## TODO fix z_index
	#if target_tile_node:
	#	new_z_index = target_tile_node.z_index + 0.2 * pos.y
	move(pos, unit, new_z_index, delay)

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
		var node: TileNode = map.get_child_at_v3(i.position)
		if node:
			if !node.selected_tile.is_connected(tile_sent_selected):
				node.selected_tile.connect(tile_sent_selected)
				node.hovered_tile.connect(tile_sent_hovered)
			node.show_move_sprite(false, true, game.acting)
			if node.tile.occupiable and node.tile.occupiable.occupant:
				pass
				# TODO create new unit node or somsin.ce
	#print("Connected tiles to signal function")

func show_movement_range(reset_display: bool = false):
	# hide movement area
	if reset_display:
		map.reset_movement_display()
		return
	# display movement area
	for i: Tile in map.field_map.movementRangeTiles(game.acting):
		var node = map.get_child_at_v3(i.position)
		if node:
			node.show_move_sprite(true, !game.acting.moved)

func show_reach_range(unit: Units):
	if not unit: return
	# display reach area
	if unit.inventory.equippedWeapon():
		for i: Tile in map.field_map.tilesInRangeFor(unit, unit.Range()):
			var node = map.get_child_at_v3(i.position)
			if node:
				node.show_reach_sprite("wep")
	if unit.inventory.equippedMedkit():
		for i: Tile in map.field_map.tilesInRangeFor(unit, unit.MedRange()):
			var node = map.get_child_at_v3(i.position)
			if node:
				node.show_reach_sprite("med")
	map.get_child_at_v3(map.field_map.tileOf(unit).position).show_reach_sprite("self")

func draw_and_set_tiles():
	map.draw_tiles(map.direction)
	connect_tile_nodes()
	map.set_tiles_in_nodes()
	make_unit_nodes()
	#on_game_update()

func on_game_update():
	map.set_tiles_in_nodes()
	make_unit_nodes()
	#var bruh = map.get_tiles_in_tree()
	#bruh
	#draw_and_set_tiles()
	update_unit_container(game.acting)
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

func on_game_tip(tip_string: String) -> void:
	tip_label.text = tip_string
	print("tip: "+tip_string)
	tip_label.show()
	await get_tree().create_timer(tip_timer).timeout
	tip_label.hide()

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
			print("make_unit_nodes added "+new_unit_node.unit.character.myName)
	#print("make_unit_nodes added missing unit nodes")

## set all current unit_node shaders to null
func repaint_unit_shaders() -> void:
	var node_list = get_tree().get_nodes_in_group("unit")
	for next_unit_node: UnitNode in node_list:
		next_unit_node.undim()

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
	draw_and_set_tiles()

func on_selected(thing):
	#draw_and_set_tiles()
	if not continue_process:
		return # dont let the player select anything when process not continuing
	update_unit_container(null)
	tile_container._ready(null)
	free_children(menu_node)
	if game.acting:
		var menu = pre_button_menu.instantiate()
		menu.game = game
		menu.user = game.acting
		menu.new_menu(thing)
		show_movement_range()
		show_reach_range(game.acting)
		menu_node.add_child(menu)
		print("made menu", thing)

func on_inspected(thing):
	#draw_and_set_tiles()
	if not continue_process:
		return # dont let the player select anything when process not continuing
	free_children(menu_node)
	inspect_container.update(game.acting)

func on_lose():
	var msg: String = ""
	if game:
		msg = "The heroes have fallen."
	var msg_node = fade_msg.instantiate()
	msg_node.create(msg)
	hud_node.add_child(msg_node)
	await get_tree().create_timer(2).timeout
	_ready()

var map_rotation: int = 0
func spin_map():
	var spin_change = 0
	if Input.is_action_just_pressed("rotate_left"):
		spin_change += 1
	if Input.is_action_just_pressed("rotate_right"):
		spin_change -= 1
	if spin_change != 0:
		map_rotation = (4+(map_rotation+spin_change)%4)%4 
		#map._on_spin_box_value_changed(map_rotation)
		map.direction = map_rotation
		draw_and_set_tiles()

func update_unit_container(unit: Units):
	#unit_container._ready(game.acting)
	if unit:
		unit_container.set_map_and_title(unit.combat_info_dict(), unit.shortInfo())
		unit_container.visible = true
	else:
		#unit_container.set_map_and_title({}, "")
		unit_container.visible = false
	unit_container.set_labels()
