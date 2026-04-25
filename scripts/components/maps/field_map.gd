class_name FieldMap extends Resource

@export var grid: Grid = null
@export var enemies: Array[Group] = []
@export var allies: Array[Group] = []
@export var player: Organisation
@export var clearCondition: Condition
@export var loseConditions: Array[Condition]
@export var turnNumber: int
@export var deployment: Array[Vector2i]
@export var joining: Array[Units] = []
@export var events: Array[Event] = []

class UTR:
	var unit: Units
	var tile: Tile
	var dist: int
	func _init(_unit: Units, _tile: Tile, _dist: int):
		unit = _unit
		tile = _tile
		dist = _dist

func tickTurn():
	turnNumber += 1

func eventCheck() -> Array[Action]:
	var actions: Array[Action] = []
	for event in events:
		actions.append_array(event.trigger(self))
	return actions

func setPlayer(_player: Organisation):
	player = _player

func setLeaders():
	var leadGroups = enemies
	for group in leadGroups:
		group.setLeader()

func isCleared() -> bool:
	return clearCondition and clearCondition.met(self)

func isLost() -> bool:
	var lost = false
	for condition in loseConditions:
		lost = condition.met(self)
	return lost

## TODO BONUSES

func giveBonuses(boo: bool):
	pass

### UNIT & GROUP HANDLING ###

## distance of a unit to a tile
func unitDistanceFrom(tile: Tile, unit: Units) -> int:
	var found_tile = tileOf(unit)
	if found_tile:
		return grid.tileDistance(found_tile, tile)
	else: return 0

## remove unit from their tile and 
func moveTo(unit: Units, target: Tile) -> void:
	var former = tileOf(unit)
	if target.occupiable:
		# remove from previous
		if former and former.occupiable:
			former.occupiable.removeOccupant()
		# add to new target tile
		target.occupiable.addOccupant(unit)
		if target.interactible and target.interactible.soul && unit.canTakeSouls():
			target.interactible.spendSoul()
			unit.weapon.fix_full()
	else: print(target," cannot be occupied")

## remove dead units from the field, and add loot and souls
func clearDead() -> void:
	var the_dead = grid.tilesWithUnits().filter(func(t:Tile): return t.has_dead())
	for dead_tile: Tile in the_dead:
		dead_tile.addCorpse(dead_tile.occupiable.occupant.loot(), true)
		dead_tile.occupiable.removeOccupant()
	### TODO giveBonuses(false)

## Array of all units on the grid
func all_units() -> Array:
	return grid.unitsFromTiles(grid.tiles)

## Array of units on given team
func unitsOnTeam(team: Units.Team) -> Array:
	return all_units().filter(func(u:Units): return u.team==team)

## all groups on field
func groups() -> Array[Group]:
	var groups_found = enemies.duplicate()
	groups_found.append_array(allies.duplicate())
	if player: groups_found.push_back(player.group)
	return groups_found

func deploymentTiles() -> Array[Tile]:
	var collected: Array[Tile] = []
	for pos: Vector2i in deployment:
		collected.push_back(grid.get_tile_v(pos))
	return collected

## add more characters to this maps current player organization
func addUnitToPlayerDeployed(unit: Units):
	player.addDeployed(unit)


func addUnitListToDeployed(units: Array[Units]):
	for u in units:
		addUnitToPlayerDeployed(u)

## Place player characters onto the deployment tiles on the map.*/
func deployPlayer():
	var tiles = deploymentTiles()
	var deployed = player.deployed.slice(0,tiles.size())
	# Get any "player" team characters on map
	for unit in unitsOnTeam(Units.Team.Player):
		# and add them to the player deployds.
		addUnitToPlayerDeployed(unit)
		print("deployed ", unit)
	for i in range(0, deployed.size()):
		tiles[i].occupiable.addOccupant(deployed[i])   	# Add the characters chosen to be deployed onto the
		deployed[i].setTeam(Units.Team.Player)  # deployment map and set their team to player.


### MOVEMENT HANDLING ###

func tileOf(unit: Units) -> Tile:
	var list_of_tiles = grid.tilesWithUnits()
	var found = null
	for t in list_of_tiles:
		if unit_is_on_tile(unit,t):
			found = t
	return found

func unit_is_on_tile(u:Units,t:Tile) -> bool:
	return u==t.occupiable.occupant

## Method for determining the tiles accessible based on movement, current tile and class types.
## Used by movementRangeTiles to determine where a unit can move.*/
func moveCheck(moveLeft: float, tile: Tile, types: Array, team: Units.Team, elevation: int, jump: int) -> Array[Tile]:
	if moveLeft < 0:
		return []
	var reduction = 1
	var occupiable = tile.occupiable
	var occupant = null
	if occupiable:
		occupiable.moveReduction(types)
		if occupiable.occupant: occupant = occupiable.occupant
	# inner lambda
	var findSurrounding = (func(thisOneOk: bool):
		var accessibles: Array[Tile] = []
		if thisOneOk: accessibles.push_back(tile)
		var availableNeighbors = grid.neighbors(tile).filter(func(t:Tile): return grid.elevationDifference(elevation, t) <= jump)
		for n_tile in availableNeighbors:
			for new_tile: Tile in moveCheck(moveLeft-reduction, n_tile, types, team, tile.position.z, jump):
				if !accessibles.has(new_tile):
					accessibles.push_back(new_tile)
		return accessibles
	)

	# Empty if not enough move left
	if occupiable and moveLeft < reduction:
		if !occupant:
			return [tile]
		else: return []
	# In the case where the tile is occupiable
	elif !occupant:
		return findSurrounding.call(true)
	elif occupant and occupant.team == team:
		return findSurrounding.call(false)
	# If it can be flown over
	elif tile.canFlyOver and types.has("flier"):
		return findSurrounding.call(false)
	# If other checks fail
	else: return []

## Returns a set of tiles which the given unit can move to during this turn. */
func movementRangeTiles(mover: Units) -> Array[Tile]:
	if !mover: return []
	# find the location of the moving unit and find their info
	var locationTile = tileOf(mover)
	var movementRange = mover.MOVE()
	var movementType = mover.character.myClass.classType
	var tilesFound: Array[Tile] = []
	if locationTile:
		tilesFound.append_array(moveCheck(movementRange, locationTile, movementType, 
			mover.team, locationTile.position.z, mover.JUMP()))
		tilesFound.append(locationTile)
	return tilesFound

## Gives a set of who can a unit attack.
func attackRangeUnits(mover: Units) -> Array[Units]:
	# find the location of the moving unit and find their info
	var location_t = tileOf(mover)
	var a_range = mover.Range()
	var unitsFound: Array[Units] = []
	if location_t:
		for i in range(a_range.x, a_range.y):
			unitsFound.append_array(grid.unitsFromTiles(grid.tileInRangeFrom(location_t,i)))
	return unitsFound

## Gives a set of who can a unit can attack from a tile.
func unitsInRangeAt(mover: Units, tile: Tile, a_range: Vector2i) -> Array[UTR]:
	# find the location of the moving unit and find their info
	var utrFound: Array[UTR] = []
	if tile:
		for i in range(a_range.x, a_range.y+1):
			var unit_list = grid.unitsFromTiles(grid.tileInRangeFrom(tile,i))
			for unit in unit_list:
				utrFound.push_back(UTR.new(unit, tile, i))
		#if utrFound.has(mover): utrFound.erase(mover)
	return utrFound
