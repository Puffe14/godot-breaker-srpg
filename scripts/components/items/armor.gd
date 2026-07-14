class_name Armor extends Resource

@export var stats: CombatBonus
@export var part: Constants.BodyPart
@export var broken: bool = false

func shatter():
	broken = true
