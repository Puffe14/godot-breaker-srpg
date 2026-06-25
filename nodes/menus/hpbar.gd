class_name HpBar extends VBoxContainer
@export var portrait_node: Sprite2D = null
@export var progress_node: TextureProgressBar = null
@export var text_label: Label = null


func set_portrait(portrait):
	if portrait:
		portrait_node.texture = portrait
	else:
		print("set portrait foiled")

func change_value(hp: int, mhp: int):
	var hpb = progress_node
	hpb.set_value_no_signal(hp)
	hpb.max_value = mhp
	if text_label:
		text_label.text = "HP: "+str(hp)+"/"+str(mhp)

func show_bar(x: bool):
	visible = x
