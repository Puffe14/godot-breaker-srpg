extends Camera2D

@export var view_width = 1000
@export var view_height = 600
@export var horizontal_speed = 150
@export var vertical_speed = 150
@export var min_zoom = 0.7
@export var max_zoom = 4

@export var zoom_speed = Vector2(0.1,0.1)
@export var zoom_base = Vector2(1,1)
@export var menu_control: Control = null
var lock_camera = false

var not_android = false
@export var drag_speed = 0.5
@export var pinch_speed = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# lock or unlock camera movement
	if Input.is_action_just_pressed("lock"):
		toggle_camera_lock()
	if lock_camera: return
	# don't move camera if there are menus in view
	## TODO: More elegant solution not based on size > 1
	if menu_control:
		var kids = menu_control.get_children(true)
		if not kids.is_empty() and not kids[0].get_children().is_empty(): return
	# move camera up or down based mouse compared to margin positions
	var cursor_position = get_viewport().get_mouse_position()
	# requires pressing on android
	if not_android:
		if cursor_position.x < drag_left_margin*view_width:
			offset.x -= horizontal_speed * delta
		if cursor_position.x > (1-drag_right_margin)*view_width:
			offset.x += horizontal_speed * delta
		if cursor_position.y < drag_top_margin*view_height:
			offset.y -= vertical_speed * delta
		if cursor_position.y > (1-drag_bottom_margin)*view_height:
			offset.y += vertical_speed * delta
	# zoom
	if zoom.length() > min_zoom and Input.is_action_just_released("zoom_out"):
		zoom -= zoom_speed
	if zoom.length() < max_zoom and Input.is_action_just_released("zoom_in"):
		zoom += zoom_speed
	if Input.is_action_just_released("zoom_reset"):
		zoom = zoom_base

func _unhandled_input(event: InputEvent) -> void:
	var pinching: bool = false
	if event is InputEventMagnifyGesture:
		# if factor < 1, zoom_out else zoom_in
		zoom += zoom_speed * pinch_speed * (event.factor - 1)
		if zoom.length() < min_zoom:
			zoom = min_zoom
		if zoom.length() > max_zoom:
			zoom = max_zoom
		pinching = true
	if event is InputEventScreenDrag:
		# prevent pinching from moving camera unpredictably
		if not pinching:
			offset -= event.screen_relative * drag_speed


func toggle_camera_lock():
	lock_camera = not lock_camera

func camera_lock():
	lock_camera = true

func camera_unlock():
	lock_camera = false
