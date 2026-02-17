class_name UnitNode extends Node2D

@export var unit: Units
@export var texture: Texture2D
@export var frames: SpriteFrames = null
@export var shader: Shader = null
@export var flip: bool = false
var timer: Timer = Timer.new()
var popup_text: PackedScene = preload("res://nodes/popup_text.tscn")

func set_node(unit: Units):
	pass

func on_update(delay: float, _dim: bool = false) -> void:
	# wait for delay
	await get_tree().create_timer(delay).timeout
	# dimming
	if _dim and unit and unit.acted:
		dim()
	else:
		undim()

func _ready() -> void:
	if frames:
		$Sprite2D.visible = false
		$AnimatedSprite2D.flip_h = flip
		$AnimatedSprite2D.sprite_frames = frames
		$AnimatedSprite2D.play("default")
	else:
		$Sprite2D.visible = true
		$Sprite2D.flip_h = flip
		$Sprite2D.texture = texture

func play_animation(anim_name: String, delay: float, msg: String = "") -> void:
	# wait for delay
	await get_tree().create_timer(delay).timeout
	# if animations have been given
	if frames:
		$AnimatedSprite2D.play(anim_name)
	# if a popup text should be made
	if msg != "":
		var msg_node = popup_text.instantiate()
		msg_node.create(msg)
		add_child(msg_node)

func play_move(pos: Vector2, index: int, delay: float) -> void:
	# wait for delay
	await get_tree().create_timer(delay).timeout
	z_index = index+1
	position = pos

func strike():
	$AnimatedSprite2D.play("strike")

func dim():
	if frames:
		$AnimatedSprite2D.material.shader = load("res://resources/shaders/gray.gdshader")

func undim():
	if frames:
		$AnimatedSprite2D.material.shader = null
