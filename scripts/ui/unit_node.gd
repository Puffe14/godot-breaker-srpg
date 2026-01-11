class_name UnitNode extends Node2D

@export var unit: Units
@export var texture: Texture2D
@export var frames: SpriteFrames = null
@export var flip: bool = false

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

func strike() -> void:
	if frames:
		$AnimatedSprite2D.play("strike")
