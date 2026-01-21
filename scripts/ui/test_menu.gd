extends Node
@export var timer: Timer = null
@export var combat: Combat = null
@export var map: MapNode = null
@export var game: Game = null
var popup_text: PackedScene = preload("res://nodes/popup_text.tscn")
var pre_button_menu = preload("res://nodes/menus/button_menu.tscn")
var current_action = null

func _process(_delta: float) -> void:
	for u in $FightSelector.units:
		u.visible = false
	var a = $FightSelector.unitA()
	var b = $FightSelector.unitB()
	a.visible = true
	b.visible = true
	if !game.queue.is_empty():
		current_action = game.queue.pop_front()
		current_action.move.connect(move_to_tile)
		current_action.play()


func _ready() -> void:
	$FightSelector.refresh()
	#combat.animate.connect(animate)
	#game.animate.connect(animate)
	#game.move.connect(move_to_tile)

# M: Topic selection opens tommorow
# O: Oh fuck...

func _on_test_timer_timeout() -> void:
	var a = $FightSelector.unitA()
	var b = $FightSelector.unitB()
	a.unit.damageTaken = 0
	b.unit.damageTaken = 0
	combat.renit(a.unit, b.unit, 1)
	var forecast = combat.forecast
	print(forecast.aEV, forecast.arrow(), forecast.bEV)
	combat.play()

	#game.selected.connect(on_selected_tile)
	game.currentMap = map.field_map
	game.update.connect(on_game_update)
	
	var slup = map.field_map.movementRangeTiles(a.unit)
	print(slup)
	for i: Tile in slup:
		var node = map.get_child_at_v3(i.position)
		if node:
			node.show_move_sprite(true)
			node.selected_tile.connect(tile_sent_selected)
		#i.emit_show_move(true)

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
	print("moving to tile "+str(location.position))
	move(pos, unit, location.position.z, delay)

func tile_sent_selected(tile: Tile):
	game.selectTile(tile)
	$Control/Label.text = str(tile)

func on_game_update():
	#map.draw_tiles(map.direction)
	var menu = pre_button_menu.instantiate()
	#menu.new_menu([game.acting])
	menu.new_menu(game.availableActions(game.acting))
	$Control/Label.text = str(game.acting)
	$Control.add_child(menu)

func cancel_pressed():
	game.acting = null
