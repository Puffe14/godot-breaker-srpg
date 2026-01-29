class_name MainGUI extends Node2D

@export var map: MapNode = null
@export var game: Game = null
var popup_text: PackedScene = preload("res://nodes/popup_text.tscn")
var pre_button_menu = preload("res://nodes/menus/button_menu.tscn")
@export var hud_node: Control = null
@export var menu_node: Control = null
@export var unit_container: UnitContainer = null
@export var tile_container: TileContainer = null

func _ready() -> void:
	map.move.connect(move)
	game.currentMap = map.field_map
	game.update.connect(on_game_update)
	map.draw_tiles(map.direction)
	draw_and_set_tiles()
	
var set = false
func _process(_delta):
	game.currentMap = map.field_map
	if !game.update.is_connected(on_game_update):
		game.update.connect(on_game_update)
	#if !set:
	#	set = true
	map.set_tiles_in_nodes()
	connect_tile_nodes()
	show_movement_range()
	if game.queue.is_empty(): return
	var current_action: Action = game.queue.pop_front()
	current_action.animate.connect(animate)
	current_action.move.connect(move)
	await current_action.stop

### UNIT NODE HANDLING ###

func animate(animation: String, unit: Units, delay: float, msg: String = ""):
	for u in get_tree().get_nodes_in_group("unit"):
		if u.unit == unit:
			u.play_animation(animation, delay, msg)

func move(pos: Vector2, unit: Units, index: int, delay: float):
	for u in get_tree().get_nodes_in_group("unit"):
		if u.unit == unit:
			u.play_move(pos, index, delay)

func move_to_tile(location: Tile, unit: Units, delay: float):
	var pos = map.tile_translated_to_v2(location)
	move(pos, unit, location.position.z, delay)

### TILE NODE HANDING ###

func tile_sent_selected(tile: Tile):
	game.selectTile(tile)
	tile_container._ready(tile)

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

func draw_and_set_tiles():
	map.draw_tiles(map.direction)
	map.set_tiles_in_nodes()

func on_game_update():
	draw_and_set_tiles()
	unit_container._ready(game.acting)
	free_children(menu_node)
	if game.acting == game.target:
		var menu = pre_button_menu.instantiate()
		menu.game = game
		menu.new_menu([game.acting])
		menu_node.add_child(menu)
	elif game.target:
		var menu = pre_button_menu.instantiate()
		menu.game = game
		menu.user = game.acting
		menu.new_menu(game.availableActions(game.acting))
		menu_node.add_child(menu)

func free_children(node) -> void:
	for child in node.get_children():
		child.queue_free()
