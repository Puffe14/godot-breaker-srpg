class_name Wait extends Action

@export var unit: Units

func _init(_unit: Units) -> void:
	unit = _unit

func play() -> Explain:
	unit.endTurn()
	animate.emit("still",unit,0,"Wait")
	update.emit(unit,true)
	stop.emit()
	print(unit," wait")
	return explain

func _to_string() -> String:
	return "Wait"
