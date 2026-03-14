class_name Move extends Action

var unit: Units
var field_map: FieldMap

func _init(_unit: Units, _field_map: FieldMap, _location: Tile) -> void:
	unit = _unit
	field_map = _field_map
	location = _location

func play() -> Explain:
	field_map.moveTo(unit, location)
	move.emit(location, unit, 0)
	update.emit(unit, 0, false)
	print(unit," moves to ",location.position)
	return explain
