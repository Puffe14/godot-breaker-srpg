class_name Occupiable extends Resource

@export var occupant: Units = null

@export var atk: int = 0
@export var avoid:int = 0
@export var physical: int = 0
@export var magical: int = 0
@export var hpEffect: int = 0

func occupied() -> bool:
	return occupant !=  null

func addOccupant(newUnit: Units) -> void:
	if occupied():
		print("Adding Occupant "+newUnit.name+" failed. Tile already has "+occupant.name)
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
