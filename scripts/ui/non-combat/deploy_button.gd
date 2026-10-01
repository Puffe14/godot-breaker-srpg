class_name DeployButton extends Button

var selected = false
var unit: Units = null
signal deploy_toggled

func setup(pic_path: String = "", bottom_text: String = "", _toggle: bool = false) -> void:
	selected = _toggle
	$BottomLabel.text = bottom_text
	$ColorRect.visible = selected
	var pic = load(pic_path)
	if pic:
		$Picture.texture = pic
	else:
		$Picture.texture = load("res://resources/images/portraits/default.png")

func _on_pressed() -> void:
	selected = not selected
	$ColorRect.visible = selected
	deploy_toggled.emit(unit, selected)
