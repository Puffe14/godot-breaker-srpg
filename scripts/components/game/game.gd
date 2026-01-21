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
var queue: Array[Action] = []

@export var regular_combat: Combat
@export var wound_combat: Combat
@export var break_combat: Combat


signal selected(thing)
signal inspected(thing)
signal update


## Decides what happens when a tile is selected.
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
		selected.emit(availableActions(acting))
	# Beat-em-up with current weapon
		#case o: Occupiable if target.nonEmpty && !acting.forall(_.turnOver) && targetInRangeOfActor =>
		#attack()
	# Select target
	elif occupiable and occupant and acting:
		target = occupant
	# Move acting unit to given tile
	elif occupiable and acting:
		#unitToTile(o)
		move_to(acting, tile)
		update.emit()
	# Select a new acting unit
	elif occupiable:
		acting = occupant

### ACTIONS INTO STACK ###

func move_to(unit: Units, tile: Tile):
	queue.push_back(Move.new(unit, currentMap, tile))

### ACTION AVAILABILITY ###

func availableActions(unit: Units, moves: bool = false) -> Array[Action]:
	if !currentMap: return []
	var total: Array[Action] = []
	var fm = currentMap
	var possibleWeaponsOrNone = unit.usable_weapons()
	#possibleWeaponsOrNone.push_back(null)
	var areaOfMovement = [fm.tileOf(unit)]
	if moves: areaOfMovement = fm.movementRangeTiles(unit)
	var combats = []
	for tile in areaOfMovement:
		for weapon in possibleWeaponsOrNone: # Weapons that the character could use
			unit.equip(weapon)
			var targets = fm.unitsInRangeAt(unit,tile,unit.Range()) # Who can be attacked? --(who, from)
			# all available unit, distance, tile combinations
			for utr in targets:
				var newActions: Array[Combat] = []
				#  possible breaks
				if unit.canBreak():
					for b in utr.unit.breakableParts():
						combats.push_back(break_combat.recreate(unit, utr.unit, utr.dist, b))
				#  possible wounds
				if unit.canWound():
					for b in utr.unit.woundableParts():
						combats.push_back(wound_combat.recreate(unit, utr.unit, utr.dist, b))
				#  combine all of them with basic Combat
				combats.push_back(regular_combat.recreate(unit, utr.unit, utr.dist))
				for na in newActions:
					# Sets where these actions are happening so that a correct Move is made.
					na.location = utr.tile
					# Sets the weapon used when the actions happen
					na.weapon = weapon
  
		var heals = [] #(for medkit <- unit.usableMedkits yield # Medkits that the character could use
#fm.movementRangeTiles(unit) # On movement range tiles --Tiles
#.flatMap(tile=>(fm.attackRangeUnitsAt(unit,tile,medkit.range)))
#.toSet# Who can be attacked? --(who, from)
#.map((targetable, distance, currentTile) =>  # all available unit, distance, tile combinations
#  val newActions: Vector[Combat] =
#    #  possible treats
#    val treats = for b <- targetable.wounds yield
#      Treat(unit, targetable, distance, medkit, b)
#    treats.toVector.appended(Heal(unit, targetable, distance, medkit))
#  newActions.foreach(_.location = Some(currentTile))
#  newActions
#).toVector
#).flatten
# all possible item uses for character
		var uses = []
		for c in unit.inventory.consumables():
			uses.push_back(Use.new(unit,c)) # use action for each item
		total.append_array(combats)
		heals.append_array(combats)
		uses.append_array(combats)
	return total
