class_name Speech extends Event

var lines: Array[String]
var titles: Array[String]
var pic_titles: Array[String]

func _init(_conditions: Array[Condition], _lines: Array[String], _titles: Array[String] = [], _pic_titles: Array[String] = []) -> void:
	lines = _lines
	conditions = _conditions
	titles = _titles
	pic_titles = _pic_titles


func effect(fieldMap: FieldMap) -> Action:
	var speech_act = EmptyAction.new()
	for i in range(lines.size()):
		speech_act.explain.addDialogue(lines.get(i),titles.get(i),pic_titles.get(i))
	return speech_act
