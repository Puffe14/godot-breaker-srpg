class_name Dialogue extends Resource
var line: String
var pic: Texture2D

func _init(_line, _pic = null):
	line = _line
	pic = _pic

func _to_string() -> String:
	return line
