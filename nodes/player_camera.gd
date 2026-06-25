extends Camera2D

@export var view_width = 1000
@export var view_height = 600
@export var horizontal_speed = 2
@export var vertical_speed = 2
@export var menu_control: Control = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# don't move camera if there are menus in view
	## TODO: More elegant solution not based on size > 1
	if menu_control:
		var kids = menu_control.get_children(true)
		if not kids.is_empty() and not kids[0].get_children().is_empty(): return
	# move camera up or down based mouse compared to margin positions
	var cursor_position = get_viewport().get_mouse_position()
	if cursor_position.x < drag_left_margin*view_width:
		offset.x -= horizontal_speed
	if cursor_position.x > (1-drag_right_margin)*view_width:
		offset.x += horizontal_speed
	if cursor_position.y < drag_top_margin*view_height:
		offset.y -= vertical_speed
	if cursor_position.y > (1-drag_bottom_margin)*view_height:
		offset.y += vertical_speed
