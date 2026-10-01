class_name OrganisationMenu extends Control

@export var tabs: TabContainer = null
@export var org: Organisation = null
@export var deploy_list: Node = null
@export var deploy_button_scene: PackedScene = null

signal start_pressed

func _ready() -> void:
	MainGUI.free_children(deploy_list)
	for unit in org.members:
		var icon_path = "res://resources/images/portraits/" + unit.character.picture_name + ".png"
		var sprite = deploy_button_scene.instantiate()
		sprite.setup(icon_path, unit.character.name())
		deploy_list.add_child(sprite)


func _on_start_button_pressed() -> void:
	start_pressed.emit()
