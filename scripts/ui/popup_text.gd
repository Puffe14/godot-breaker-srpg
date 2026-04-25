class_name PopupText extends Control

var text: String = ""

func _on_timer_timeout() -> void:
	queue_free()

func create(new_text: String) -> void:
	text = new_text
	$MarginContainer/Label.text = text
