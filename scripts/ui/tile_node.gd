class_name TileNode extends Node2D

@export var tile: Tile = null
@export var texture = "field_bluegrass"
@export var shader: Shader = preload("res://resources/shaders/gray.gdshader")
var unit_node = preload("res://nodes/unit_node.tscn")

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
func _process(delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	$TopSprite.visible = true
	hovered_tile.emit(tile)


func _on_area_2d_mouse_exited() -> void:
	$TopSprite.visible = false
	hovered_tile.emit(null)

func show_move_sprite(move_visibility: bool, can_move: bool = true):
	$MoveSprite.visible = move_visibility
	if !can_move:
		$MoveSprite.material.shader = shader
	else:
		$MoveSprite.material.shader = null

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
