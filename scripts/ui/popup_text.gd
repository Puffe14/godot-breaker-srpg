class_name PopupText extends Control

var text: String = ""

func _on_timer_timeout() -> void:
	queue_free()

func create(new_text: String) -> void:
	text = new_text
	$MarginContainer/Label.text = text
	if text.length() > 10:
		$Timer.wait_time = 1 + text.length() * 0.05
