class_name FieldMap extends Resource

@export var grid: Grid = null
@export var enemies: Array[Group]
@export var allies: Array[Group]
@export var player: Organisation
@export var clearCondition: Condition
@export var loseConditions: Array[Condition]
@export var turnNumber: int
@export var deployment: Array[Vector2i]
@export var joining: Array[Units] = []
@export var events: Array[Event] = []

func tileOf(unit: Units) -> Tile:
	var list_of_tiles = grid.tilesWithUnits()
	var index = list_of_tiles.find(func(t:Tile): return unit==t.occupiable.occupant)
	if index == -1: return null
	return list_of_tiles[index]
