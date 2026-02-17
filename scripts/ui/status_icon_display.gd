extends Control

@export var vbox: Container = null
@export var icon_rect: PackedScene = null

func set_icons(status_list: Array[Status]):
	for child in vbox.get_children():
		child.queue_free()
	for status in status_list:
		var new_icon = icon_rect.instantiate()
		new_icon.set_icon(status)
