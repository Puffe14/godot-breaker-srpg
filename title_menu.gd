extends Node2D

signal start_new_game(level: int)



func _on_menu_button_button_down() -> void:
	start_new_game.emit(0)
