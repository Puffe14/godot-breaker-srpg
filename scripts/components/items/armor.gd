class_name Armor extends Resource

@export var stats: Stats
@export var part: Constants.BodyPart
@export var broken: bool = false

func shatter():
	broken = true
