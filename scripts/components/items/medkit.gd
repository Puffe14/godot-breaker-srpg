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
