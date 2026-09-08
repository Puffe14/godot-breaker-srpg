class_name TileNode extends Node2D

@export var tile: Tile = null
@export var texture = "field_bluegrass"
@export var shader: Shader = preload("res://resources/shaders/gray.gdshader")
var unit_node = preload("res://nodes/unit_node.tscn")
var ally_texture = preload("res://resources/images/tiles/field_cursor_ally.png")
var enemy_texture = preload("res://resources/images/tiles/field_cursor_enemy.png")
var player_texture = preload("res://resources/images/tiles/field_cursor_player.png")

signal selected_tile(t:Tile)
signal hovered_tile(t:Tile)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if tile:
		texture = tile.photo_name
	$Sprite2D.texture = load("res://resources/images/tiles/"+texture+".png")
	#if tile and tile.occupiable and tile.occupiable.occupant:
	#	var new_unit_node = unit_node.instantiate()
	#	new_unit_node.position += Vector2(8,-8)
	#	new_unit_node.unit = tile.occupiable.occupant
	#	new_unit_node.frames = load("res://resources/images/animation/cylna.tres")
	#	add_child(new_unit_node)
	#if tile:
	#	tile.show_move.connect(show_move_sprite)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if tile and tile.occupiable:
		$LootSprite.visible = tile.containsLoot()
		if tile.containsLoot():
			$LootSprite.tooltip_text = tile.interactible.loot_string()

func _on_area_2d_mouse_entered() -> void:
	$TopSprite.visible = true
	hovered_tile.emit(tile)


func _on_area_2d_mouse_exited() -> void:
	$TopSprite.visible = false
	hovered_tile.emit(null)

func show_reach_sprite(reach_type, hide_reach = false):
	if hide_reach:
		$MedkitReachSprite.visible = false
		$WeaponReachSprite.visible = false
		$SelfSprite.visible = false
		return
	match reach_type:
		"med":
			$MedkitReachSprite.visible = true
		"wep":
			$WeaponReachSprite.visible = true
		"self":
			$SelfSprite.visible = true
		_:
			pass

func show_move_sprite(move_visibility: bool, can_move: bool = true, actor: Units = null):
	if !tile or !tile.occupiable:
		return
	if actor and actor.canTakeSouls():
		$SoulSprite.visible = tile.containsSoul()
	else:
		$SoulSprite.visible = false
	# elsewise, change the move sprite or teamsprite visibility
	$MoveSprite.visible = move_visibility
	$TeamSprite.visible = !move_visibility
	# show as gray via shader if the actor can't move this turn
	if !can_move:
		$MoveSprite.material.shader = shader
	else:
		$MoveSprite.material.shader = null
	if !move_visibility and actor and tile.occupiable and tile.occupiable.occupant:
		match tile.occupiable.occupant.team:
			Units.Team.Player:
				$TeamSprite.texture = player_texture
			Units.Team.Enemy:
				$TeamSprite.texture = enemy_texture
			Units.Team.Ally:
				$TeamSprite.texture = ally_texture
			_:
				$TeamSprite.texture = null
				print("no team found???")
	else:
		$TeamSprite.texture = null

func hide_move_and_team():
	$MoveSprite.visible = false
	$TeamSprite.visible = false

func on_selected():
	selected_tile.emit(tile)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# if hovered
	if $TopSprite.visible:
		hovered_tile.emit(tile)
	# if clicked
	if Input.is_action_just_pressed('select'):
		if tile:
			print('clicked!'+str(tile.position))
			if tile.occupiable:
				print("  occupant ", tile.occupiable.occupant)
				if tile.occupiable.occupant:
					print(" (",tile.occupiable.occupant.team,")")
		else:
			print('not connected!')
		on_selected()

## TODO: somehow show hp for units but unit node not in TileNode
#func show_child_hp(should: bool):
#	for node in get_children():
#		if node.is_in_group("hp"):
#			node.hp_bar.show_bar(should)
#			node.hp_bar.change_value()
