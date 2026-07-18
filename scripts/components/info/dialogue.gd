class_name Dialogue extends Resource
var line: String
var pic: Texture2D
var title: String

func _init(_line, _title = "", _pic = ""):
	line = _line
	title = _title
	pic = load("res://resources/images/portraits/"+_pic.to_lower()+".png")

func _to_string() -> String:
	return line
