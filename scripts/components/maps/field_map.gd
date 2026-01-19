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

func tickTurn():
	turnNumber += 1

func eventCheck() -> Array[Action]:
	var actions: Array[Action] = []
	for event in events:
		actions.append_array(event.trigger(self))
	return actions

func setLeaders():
	var leadGroups = enemies
	for group in leadGroups:
		group.setLeader()

func isCleared() -> bool:
	return clearCondition.met(self)

func isLost() -> bool:
	var lost = false
	for condition in loseConditions:
		lost = condition.met(self)
	return lost

## TODO BONUSES


### UNIT & GROUP HANDLING

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
		if former.occupiable:
			former.occupiable.removeOccupant()
		# add to new target tile
		target.occupiable.addOccupant(unit)
		if target.occupiable.containsSoul && unit.canTakeSouls():
			target.occupiable.spendSoul()
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
func all_units() -> Array[Units]:
	return grid.unitsFromTiles(grid.tiles)

## Array of units on given team
func unitsOnTeam(team: Units.Team) -> Array[Units]:
	return all_units().filter(func(u:Units): return u.team==team)

## all groups on field
func groups() -> Array[Group]:
	var groups_found = enemies
	groups_found.append_array(allies)
	groups_found.push_back(player.group)
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
	var deployed = player.deployed.slice(tiles.size)
	for unit in unitsOnTeam(Units.Team.Player): # Get any "player" team characters on map
		addUnitToPlayerDeployed(unit)        	# and add them to the player deployds.
	for i in range(0, deployed.size()):
		tiles[i].addOccupant(deployed[i])   	# Add the characters chosen to be deployed onto the
		deployed[i].setTeam(Units.Team.Player)  # deployment map and set their team to player.


### MOVEMENT HANDLING

func tileOf(unit: Units) -> Tile:
	var list_of_tiles = grid.tilesWithUnits()
	var index = list_of_tiles.find(func(t:Tile): return unit==t.occupiable.occupant)
	if index == -1: return null
	return list_of_tiles[index]

