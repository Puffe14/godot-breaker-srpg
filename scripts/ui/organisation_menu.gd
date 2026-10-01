class_name OrganisationMenu extends Control

@export var tabs: TabContainer = null
@export var org: Organisation = null
@export var deploy_list: Node = null
@export var deploy_button_scene: PackedScene = null

signal start_pressed

func _ready() -> void:
	MainGUI.free_children(deploy_list)
	for unit in org.members:
		var already_deployed = org.is_unit_deployed(unit)
		var icon_path = "res://resources/images/portraits/" + unit.character.picture_name + ".png"
		var sprite = deploy_button_scene.instantiate()
		sprite.setup(icon_path, unit.character.name(), already_deployed)
		sprite.unit = unit
		sprite.deploy_toggled.connect(on_deploy_toggled)
		deploy_list.add_child(sprite)


func _on_start_button_pressed() -> void:
	start_pressed.emit()

## deploy / remove character
func on_deploy_toggled(unit: Units, add_to_deployed: bool):
	if add_to_deployed:
		org.addDeployed(unit)
	else:
		org.removeDeployed(unit)
