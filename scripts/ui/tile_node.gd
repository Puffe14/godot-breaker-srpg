class_name TileNode extends Node2D

@export var tile = null
@export var texture = "field_bluegrass"
var unit_node = preload("res://nodes/unit_node.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = load("res://resources/images/tiles/"+texture+".png")
	if tile and tile.occupiable and tile.occupiable.occupant:
		var new_unit_node = unit_node.instantiate()
		new_unit_node.position += Vector2(8,-8)
		new_unit_node.unit = tile.occupiable.occupant
		new_unit_node.frames = load("res://resources/images/animation/cylna.tres")
		add_child(new_unit_node)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	$TopSprite.visible = true


func _on_area_2d_mouse_exited() -> void:
	$TopSprite.visible = false
