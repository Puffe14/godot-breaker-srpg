class_name Game extends Resource

# Map in question
var currentMapNumber: int = 1
var currentMap: FieldMap = null
var midBattle: bool = false
var changeMap: bool = false
# Who is doing what to whom?
var turnOf: Units.Team = Units.Team.Player
var player: Organisation = null
var acting: Units = null
var target: Units = null
#var inspected: Units = null
#var deepInspect = false
var bout: Combat = null
var forecast: Forecast = null
var part: Constants.BodyPart = Constants.BodyPart.Head
var stack: Array[Action] = []

signal selected(thing)
signal inspected(thing)
signal update

## Decides what happens when a tile is selected. */
func selectTile(tile: Tile) -> void:
	var occupiable = tile.occupiable
	var occupant = null
	if occupiable:
		if occupiable.occupant: occupant = occupiable.occupant
	
	# If the character is selected again and it's not their turn
	if occupiable and acting and acting.team!=turnOf:
		acting = null
	# If the character is selected again during the turn
	elif occupiable and acting and acting == occupant:
		selected.emit(acting)
	# Beat-em-up with current weapon
		#case o: Occupiable if target.nonEmpty && !acting.forall(_.turnOver) && targetInRangeOfActor =>
		#attack()
	# Select target
	elif occupiable and occupant and acting:
		target = occupant
	# Move acting unit to given tile
	elif occupiable and acting:
		#unitToTile(o)
		currentMap.moveTo(acting, tile)
		update.emit()
	# Select a new acting unit
	elif occupiable:
		acting = occupant
		inspected.emit(null)
