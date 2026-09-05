class_name HpBar extends Control
@export var portrait_node: Sprite2D = null
@export var weapon_icon_node: Sprite2D = null
@export var progress_node: TextureProgressBar = null
@export var text_label: Label = null
@export var weapon_label: Label = null
@export var exp_label: Label = null
@export var shader: Shader = null

func set_portrait(portrait):
	if portrait:
		portrait_node.texture = portrait
	else:
		print("set portrait foiled")

func set_weapon_icon(weapon_icon: Texture, msg: String = ""):
	if weapon_icon:
		weapon_icon_node.texture = weapon_icon
		weapon_label.text = "    "+msg
	else:
		weapon_label.text = ""
		print("set weapon_icon foiled, msg: "+msg)

func set_exp_text(msg: String = ""):
	exp_label.text = msg

func set_color(color: String):
	if color:
		progress_node.texture_progress = load("res://resources/images/ui/slim bar "+color+".png")

func change_value(hp: int, mhp: int):
	var hpb = progress_node
	hpb.set_value_no_signal(hp)
	hpb.max_value = mhp
	if text_label:
		text_label.text = "HP: "+str(hp)+"/"+str(mhp)

func show_bar(x: bool):
	visible = x
