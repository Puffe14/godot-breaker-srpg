class_name StatusIcon extends TextureRect

func set_icons(status: Status) -> void:
	texture = status.icon
	tooltip_text = status.description
	## TODO with highlight things
	pass
