class_name UnitNode extends Node2D

@export var unit: Units
@export var texture: Texture2D
@export var frames: SpriteFrames = null
@export var shader: Shader = null
@export var hp_node: HpBar = null
@export var flip: bool = false
@export var portrait: Texture = null

var timer: Timer = Timer.new()
var popup_text: PackedScene = preload("res://nodes/popup_text.tscn")
var status_icon: PackedScene = preload("res://nodes/status_icon.tscn")
@export var icon_control: Control = null
signal dead

func set_node(new_unit: Units):
	unit = new_unit
	if unit:
		frames = load("res://resources/images/animation/"+unit.character.picture_name+".tres")
		portrait = load("res://resources/images/portraits/"+unit.character.picture_name+".png")

func list_status_icons():
	if not unit: return
	if icon_control:
		icon_control.set_icons(unit.status)
		icon_control.set_wounds(unit)

func on_update(delay: float, _dim: bool = true) -> void:
	# wait for delay
	await get_tree().create_timer(delay).timeout
	# update hp_bar
	if unit:
		hp_node.change_value(unit.HP(), unit.MaxHP())
	# update status icon
	list_status_icons()
	# dimming
	if unit and unit.acted:
		dim()
		$AnimatedSprite2D.stop()
	else:
		undim()

##TODO: more component like design for hp hover

func _on_area_2d_mouse_entered() -> void:
	show_child_hp(true)

func _on_area_2d_mouse_exited() -> void:
	show_child_hp(false)

func show_child_hp(should: bool):
	hp_node.show_bar(should)
	if unit:
		var team_color = "red"
		match(unit.team):
			Units.Team.Enemy: team_color = "red"
			Units.Team.Player: team_color = "blue"
			Units.Team.Ally: team_color = "green"
		hp_node.change_value(unit.HP(), unit.MaxHP())
		hp_node.set_color(team_color)
	if portrait:
		hp_node.set_portrait(portrait)

func _ready() -> void:
	list_status_icons()
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
	# handle death
	if anim_name == "dead":
		$Control.queue_free()
		await get_tree().create_timer(delay).timeout
		dead.emit()
		queue_free()

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
		
func is_dim() -> bool:
	return frames and !$AnimatedSprite2D.material.shader
