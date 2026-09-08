class_name Consumable extends Resource

@export var heal: int = 0
@export var effects: Stats
@export var permanent: bool

func use(unit: Units) -> void:
	if heal != 0:
		unit.healDamage(heal)
	if permanent:
		# for adding a permanent boost to a character's stats
		unit.character.stats.addUp(effects)
	else:
		# for giving a character a temporary boost
		unit.temporaryStats.addUp(effects)

func describe() -> String:
	var text = "\nConsumable:"
	if not heal == 0:
		text += "\n Heal: " + str(heal)
	if effects:
		text += "\n effects:\n  " + str(effects._to_string())
	if permanent:
		text += "\n permanent"
	return text
