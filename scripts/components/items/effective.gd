class_name Effective extends Resource

@export var flying = false
@export var mounted = false
@export var infantry = false

func to(unit: Units) -> bool:
	var types = unit.character.myClass.classType
	return (flying and types.has("flying")) || (mounted and types.has("mounted")) || (infantry and types.has("infantry"))
