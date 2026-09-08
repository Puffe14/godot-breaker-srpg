class_name Medkit extends Resource

@export var heal: int = 0
@export var wrange: Vector2i
@export var bonus: CombatBonus
@export var effects: Stats

func set_new(_heal, _wrange, _bonus, _effects) -> void:
	heal = _heal
	wrange = _wrange
	bonus = _bonus
	effects = _effects

func describe() -> String:
	var text = "\nMedkit"
	text += "\n Range: " + str(wrange.x) + " - " + str(wrange.y)
	if not heal == 0:
		text += "\n Heal " + str(heal)
	if bonus:
		var bonus_string = bonus.to_string()
		if bonus_string != "":
			text += "\n Buffs: " + bonus.to_string()
	if effects:
		var effects_string = effects.to_string()
		if effects_string != "":
			text += "\n Effects: " + effects.to_string()
	return text
