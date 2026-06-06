class_name Survive extends Condition

var turn_limit = 0

func _init(_turn_limit: Array) -> void:
	turn_limit = _turn_limit

## Survive until a particular turn
func met(fieldMap: FieldMap) -> bool:
	return fieldMap.turnNumber > turn_limit

func description() -> String:
	return "Survive past turn " + turn_limit