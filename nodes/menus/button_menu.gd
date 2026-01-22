class_name ButtonMenu extends Control

var pre_button_menu = preload("res://nodes/menus/button_menu.tscn")
@export var button_list_container: VBoxContainer
@export var menu_h_container: HBoxContainer
@export var hider_rect: ColorRect
@export var title: Label
@export var user: Units = null
var childed = false
var game: Game = null
signal closed

func _ready() -> void:
	connect_buttons()

func connect_buttons() -> void:
	var button_list = button_list_container.get_children()
	for b in button_list:
		b.pressed.connect(option_pressed.bind(b))

func option_pressed(button):
	new_menu(button.pressed_option())

func new_menu(options: Array) -> void:
	if options.is_empty():
		close_this_menu()
	if !childed:
		var new_button_menu = pre_button_menu.instantiate()
		new_button_menu.game = game
		menu_h_container.add_child(new_button_menu)
		new_button_menu.closed.connect(reopen_parent_menu)
		childed = true
		hider_rect.visible = true
		# give correct buttons to submenu
		for option in options:
			var button_option = ButtonOption.new(game, option, user)
			new_button_menu.button_list_container.add_child(button_option)
		new_button_menu.connect_buttons()

func close_this_menu():
	emit_signal("closed")
	queue_free()

func reopen_parent_menu():
	childed = false
	hider_rect.visible = false
	update_options()

func update_options():
	var button_list = button_list_container.get_children()
	for b: ButtonOption in button_list:
		b._init(game, b.item, b.user)
