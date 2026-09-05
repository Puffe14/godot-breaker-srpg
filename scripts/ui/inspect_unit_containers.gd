class_name InspectUnitContainer extends Control

@export var character_stat_block: ColumnContainer = null
@export var class_stat_block: ColumnContainer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update(null)

func update(unit: Units) -> void:
	if not unit:
		visible = false
		return
	else:
		visible = true
	# update class and chararcter containers
	character_stat_block.set_map_and_title(unit.character_info_dict(), unit.character.myName + " " + unit.lvlExp())
	class_stat_block.set_map_and_title(unit.class_info_dict(), unit.character.myClass.className)
	# then set the labels
	character_stat_block.set_labels()
	class_stat_block.set_labels()
