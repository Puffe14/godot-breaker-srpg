extends Control

@export var vbox: Container = null
@export var icon_rect: PackedScene = null

func set_icons(status_list: Array):
	for child in vbox.get_children():
		child.queue_free()
	for status in status_list:
		var new_icon = icon_rect.instantiate()
		new_icon.set_icon(status)
		vbox.add_child(new_icon)

func set_wounds(unit: Units):
	var b_list = unit.breakableParts()
	var w_list = unit.wounds.duplicate()
	for status in b_list:
		var thing = Constants.body_part_dict[status].to_lower()
		var new_icon = icon_rect.instantiate()
		new_icon.texture = load("res://resources/images/status/armor "+thing+".png")
		vbox.add_child(new_icon)
	for status in w_list:
		var thing = Constants.body_part_dict[status].to_lower()
		var new_icon = icon_rect.instantiate()
		new_icon.texture = load("res://resources/images/status/wound "+thing+".png")
		vbox.add_child(new_icon)
