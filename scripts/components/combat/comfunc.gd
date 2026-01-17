class_name ComFunc extends Resource

var callable: Callable
var attacker: Units
var defender: Units

func _init(_combat: Combat, _function: String, _a: Units, _b: Units) -> void:
	callable = Callable(_combat, _function)
	attacker = _a
	defender = _b

func resolve() -> void:
	callable.call(attacker, defender)
