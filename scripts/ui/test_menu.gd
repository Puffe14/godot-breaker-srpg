extends Node
@export var timer: Timer = null
@export var combat: Combat = null
@export var map: MapNode = null
@export var game: Game = null
var popup_text: PackedScene = preload("res://nodes/popup_text.tscn")
var pre_button_menu = preload("res://nodes/menus/button_menu.tscn")
var current_action = null

func _process(_delta: float) -> void:
	if !game.queue.is_empty():
		current_action = game.queue.pop_front()
		if current_action:# and !current_action.animate.is_connected(animate):
			current_action.animate.connect(animate)
			current_action.move.connect(move_to_tile)
			current_action.update.connect(update_unit_node)
		# now play
		#await get_tree().create_timer(1).timeout
		if current_action:
			current_action.play()
	$Control/TurnLabel.text = game.turn_of_dict[game.turnOf]


func _ready() -> void:
	pass
	#$FightSelector.refresh()
	#combat.animate.connect(animate)
	#game.animate.connect(animate)
	#game.move.connect(move_to_tile)

func _on_test_timer_timeout_figth_select() -> void:
	var a = $FightSelector.unitA()
	var b = $FightSelector.unitB()
	a.unit.damageTaken = 0
	b.unit.damageTaken = 0
	combat.renit(a.unit, b.unit, 1)
	var forecast = combat.forecast
	print(forecast.aEV, forecast.arrow(), forecast.bEV)
	#combat.play()

func _on_test_timer_timeout() -> void:
	#game.selected.connect(on_selected_tile)
	#game.currentMap = map.field_map
	if !game.update.is_connected(on_game_update):
		game.update.connect(on_game_update)
	if !game.change_turn.is_connected(on_change_turn):
		game.change_turn.connect(on_change_turn)
	connect_tile_nodes()
	show_movement_range()
	for u in game.currentMap.all_units():
		u.damageTaken = 0
	if game.queue.is_empty():
		if game.currentMap:
			game.handle_turn()

func connect_tile_nodes():
	for i: Tile in game.currentMap.grid.tiles:
		var node = map.get_child_at_v3(i.position)
		if node:
			if !node.selected_tile.is_connected(tile_sent_selected):
				node.selected_tile.connect(tile_sent_selected)
			node.show_move_sprite(false)

func show_movement_range():
	# display movement area
	for i: Tile in map.field_map.movementRangeTiles(game.acting):
		var node = map.get_child_at_v3(i.position)
		if node:
			node.show_move_sprite(true)

func update_unit_node(unit: Units, delay: float, dim: bool):
	for u in get_tree().get_nodes_in_group("unit"):
		if u.unit == unit:
			u.on_update(delay, dim)


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

func tile_sent_selected(tile: Tile):
	game.selectTile(tile)
	$Control/Label.text = str(tile)

func on_game_update():
	connect_tile_nodes()
	show_movement_range()
	#map.draw_tiles(map.direction)
	#menu.new_menu([game.acting])
	var menu = pre_button_menu.instantiate()
	menu.game = game
	menu.user = game.acting
	print("show menus for ", menu.user)
	menu.new_menu(game.availableActions(game.acting, true))
	$Control/Label.text = str(game.acting)
	for i in $Control/MenuControl.get_children():
		i.queue_free()
	$Control/MenuControl.add_child(menu)

func on_change_turn():
	for u: UnitNode in get_tree().get_nodes_in_group("unit"):
		u.on_update(1, true)

func cancel_pressed():
	game.acting = null
