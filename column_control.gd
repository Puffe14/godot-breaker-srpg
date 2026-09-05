class_name ColumnContainer extends Control

@export var title: Label = null
@export var label_container: Container = null
@export var column_num: int = 2
@export var label_tip_map = {}
@export var container_title: String = ""

func _ready() -> void: #new_label_map) -> void:
#	label_tip_map = new_label_map
	set_labels()

func set_visibility() -> bool:
	if !(label_tip_map.is_empty()):
		visible = false
	else: visible = true
	return visible

func set_map_and_title(new_label_tip_map: Dictionary, new_title: String) -> void:
	label_tip_map = new_label_tip_map
	container_title = new_title

func set_labels():
	#if !set_visibility() or not tile: return # stop if not visible
	
	title.text = container_title
	# remove the previous text labels
	for child_node in label_container.get_children():
		child_node.queue_free()
	label_container.columns = column_num
	for label_text in label_tip_map.keys():
		var new_label: Label = Label.new()
		new_label.text = label_text
		new_label.tooltip_text = label_tip_map[label_text]
		new_label.mouse_filter = Control.MOUSE_FILTER_PASS
		label_container.add_child(new_label)
