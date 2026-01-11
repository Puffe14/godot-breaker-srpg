extends Control
var unit_node_dict: Dictionary = {}
var units: Array = []

func refresh():
	units = get_tree().get_nodes_in_group("unit")
	$MarginContainer/HBoxContainer/AttackerButton.clear()
	$MarginContainer/HBoxContainer/DefenderButton.clear()
	for unit in units:
		var title: String = unit.unit.character.myName+": "+unit.name
		unit_node_dict[title] = unit
		$MarginContainer/HBoxContainer/AttackerButton.add_item(title)
		$MarginContainer/HBoxContainer/DefenderButton.add_item(title)

func unitA() -> UnitNode:
	if unit_node_dict.is_empty(): return null
	return unit_node_dict[$MarginContainer/HBoxContainer/AttackerButton.text]

func unitB() -> UnitNode:
	if unit_node_dict.is_empty(): return null
	return unit_node_dict[$MarginContainer/HBoxContainer/DefenderButton.text]
