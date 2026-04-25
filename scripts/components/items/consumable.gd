class_name Consumable extends Resource

@export var heal: int = 0
@export var effects: Stats
@export var permanent: bool

func use(_unit: Units) -> void:
	if heal != 0:
		_unit.healDamage(heal)
	if permanent:
		pass#_unit..addUp(effects)
