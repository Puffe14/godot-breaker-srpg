class_name Occupiable extends Resource

@export var occupant: Units = null
@export var bonus: CombatBonus = null

@export var atk: int = 0
@export var avoid:int = 0
@export var physical: int = 0
@export var magical: int = 0
@export var hpEffect: int = 0

func _init(_atk = 0, _avoid = 0, _physical = 0, _magical = 0, _hpEffect = 0) -> void:
	atk = _atk
	avoid = _avoid
	physical = _physical
	magical = _magical
	hpEffect = _hpEffect
	bonus = CombatBonus.new(atk, 0, 0, 0, physical, magical, 0, avoid, 0)

func occupied() -> bool:
	return occupant !=  null

func addOccupant(newUnit: Units) -> void:
	if occupied() and occupant != newUnit:
		print("Adding Occupant "+newUnit.character.myName+" failed. Tile already has "+occupant.character.myName)
	else:
		occupant = newUnit

func removeOccupant() -> Units:
	var tempO = occupant
	occupant = null
	return tempO

## Determine reduction to movement
#TODO
func moveReduction(classMovementType: Array) -> float:
	return 1

func effects_from_dict(sl: Dictionary) -> void:
	atk = sl.get("atk",0)
	avoid = sl.get("avoid",0)
	physical = sl.get("physical",0)
	magical = sl.get("magical",0)
	hpEffect = sl.get("hpEffect",0)

func copy() -> Occupiable:
	var new_copy = Occupiable.new()
	new_copy._init(atk, avoid, physical, magical, hpEffect)
	return new_copy
