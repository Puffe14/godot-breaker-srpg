class_name Speech extends Event

var lines: Array[String]

func _init(_conditions: Array[Condition], _lines: Array[String]) -> void:
	lines = _lines
	conditions = _conditions


func effect(fieldMap: FieldMap) -> Action:
	var speech_act = EmptyAction.new()
	for line in lines:
		speech_act.explain.addDialogue(line)
	return speech_act
