class_name Game extends Resource

# Map in question
var currentMapNumber: int = 1
@export var currentMap: FieldMap = null
var midBattle: bool = true
var changeMap: bool = false
var currentTurn: int = 0
# Who is doing what to whom?
var turnOf: Units.Team = Units.Team.Player
@export var player: Organisation = null
var acting: Units = null
var target: Units = null
#var inspected: Units = null
#var deepInspect = false
var bout: Combat = null
var forecast: Forecast = null
var part: Constants.BodyPart = Constants.BodyPart.Head
var queue: Array[Action] = []
var ai = AI.new()

var turn_of_dict = {
	Units.Team.Player: "player",
	Units.Team.Enemy: "enemy",
	Units.Team.Ally: "ally"
}

@export var regular_combat: Combat
@export var wound_combat: Combat
@export var break_combat: Combat
@export var heal_combat: Combat
@export var treat_combat: Combat


signal selected(thing)
signal inspected(thing)
signal update
signal change_turn

## Decides what happens when a tile is selected.
func selectTile(tile: Tile) -> void:
	var occupiable = tile.occupiable
	var occupant = null
	if occupiable:
		if occupiable.occupant:
			occupant = occupiable.occupant
	
	# If the character is selected again and it's not their turn
	if occupiable and acting and acting.team!=turnOf and false:
		acting = null
	# If the character is selected again during the turn
	elif occupiable and acting and acting == occupant:
		selected.emit([acting])
	# Beat-em-up with current weapon
		#case o: Occupiable if target.nonEmpty && !acting.forall(_.turnOver) && targetInRangeOfActor =>
		#attack()
	# Select target
	elif occupiable and occupant and acting:
		target = occupant
		#if target == acting:
		selected.emit(availableActions(acting, !acting.moved))
	# Move acting unit to given tile
	elif occupiable and acting:
		if currentMap.movementRangeTiles(acting).has(tile):
			if !acting.moved:
				move_to(acting, tile)
			else:
				print("cant move again!!!")
		else:
			print("out of range, cant move!!!")

	# Select a new acting unit
	elif occupiable:
		acting = occupant
		selected.emit([acting])
	else:
		acting = null
		target = null
	currentMap.giveBonuses(false)
	update.emit()

func deSelect():
	acting = null
	target = null
	currentMap.giveBonuses(false)
	update.emit()

### ACTIONS INTO STACK ###

func move_to(unit: Units, tile: Tile):
	queue.push_back(Move.new(unit, currentMap, tile))
	currentMap.giveBonuses(false)

func add_to_queue(action: Action, unit: Units = null):
	if unit and action.location:
		move_to(unit, action.location)
	queue.push_back(action)

func add_array_to_queue(array: Array[Action]):
	for action in array:
		add_to_queue(action)

### ACTION AVAILABILITY ###

func availableActions(unit: Units, moves: bool = false) -> Array[Action]:
	if !currentMap or ! unit: return []
	var total: Array[Action] = []
	var fm = currentMap
	var possibleWeaponsOrNone = unit.usable_weapons()
	var possibleMedkitsOrNone = unit.usable_medkits()
	var areaOfMovement = [fm.tileOf(unit)]
	if moves: areaOfMovement = fm.movementRangeTiles(unit)
	var combats = []
	for tile in areaOfMovement:
		for weapon in possibleWeaponsOrNone: # Weapons that the character could use
			unit.equip(weapon)
			var targets = fm.unitsInRangeAt(unit,tile,unit.Range()) # Who can be attacked? --(who, from)
			if target:
				targets = targets.filter(func(u):
					print(u.unit," & ")
					print(target)
					return u.unit == target)
			# all available unit, distance, tile combinations
			for utr in targets:
				var newActions: Array[Combat] = []
				#  possible breaks
				if unit.canBreak():
					for b in utr.unit.breakableParts():
						newActions.push_back(break_combat.recreate(unit, utr.unit, utr.dist, b))
				#  possible wounds
				if unit.canWound():
					for b in utr.unit.woundableParts():
						newActions.push_back(wound_combat.recreate(unit, utr.unit, utr.dist, b))
				#  combine all of them with basic Combat
				newActions.push_back(regular_combat.recreate(unit, utr.unit, utr.dist))
				for na in newActions:
					# Sets where these actions are happening so that a correct Move is made.
					na.location = tile
					# Sets the weapon used when the actions happen
					na.weapon = weapon
				combats.append_array(newActions)
		var heals = []
		for medkit in possibleMedkitsOrNone: # Weapons that the character could use
			unit.equip(medkit)
			var targets = fm.unitsInRangeAt(unit,tile,unit.MedRange()) # Who can be healed? --(who, from)
			if target:
				targets = targets.filter(func(u):
					print(u.unit," & ")
					print(target)
					return u.unit == target)
			# all available unit, distance, tile combinations
			for utr in targets:
				var newActions: Array[Combat] = []
				#  possible treats
				for b in utr.unit.wounds:
					newActions.push_back(treat_combat.recreate(unit, utr.unit, utr.dist, b))
				#  possible heal
				newActions.push_back(heal_combat.recreate(unit, utr.unit, utr.dist))
				for na in newActions:
					# Sets where these actions are happening so that a correct Move is made.
					na.location = tile
					# Sets the weapon used when the actions happen
					na.weapon = medkit
				heals.append_array(newActions)
	# all possible item uses for character
		var uses = []
		for c in unit.inventory.consumables():
			# use action for each item
			uses.push_back(Use.new(unit,c))
		total.append_array(combats)
		total.append_array(heals)
		#total.append_array(uses)
	if !target:
		total.push_back(Wait.new(unit))
	return total


### TURN HANDLING ###

func place_player() -> void:
	if player:
		player.re_group()
		currentMap.setPlayer(player)
		currentMap.deployPlayer()
		currentMap.setLeaders()

func nextMap():
	# TODO
	# Advance to next map
	if currentMapNumber<2:
		currentMapNumber+=1
	turnOf = Units.Team.Player
	currentMap = null #DataLibrary.maps.get(currentMapNumber.toString)

func turnCountUp():
	if currentMap:
		currentMap.tickTurn()
		add_array_to_queue(currentMap.eventCheck())

func refreshAll():
	if currentMap: 
		for unit in currentMap.all_units():
			unit.refresh()

func isBattleOver() -> bool:
	var over = !midBattle
	if currentMap:
		if currentMap.isLost():
			over = true
			add_to_queue(GameOver.new())
		if currentMap.isCleared():
			over = true
			add_to_queue(MapWon.new())
	return over

## Called when the turn is continuing.
func handle_turn() -> void:
	# Next map if everything is over.
	if changeMap && queue.is_empty():
		print("Next Map!")
		nextMap()
		changeMap = false
		return
	# all groups on a particular side on the current map
	var groupsWithTurn: Array[Group] = []
	if currentMap:
		if currentMap.player != player:
			place_player()
			change_turn.emit()
		currentMap.clearDead()
		currentTurn = currentMap.turnNumber
		add_array_to_queue(currentMap.eventCheck())
	groupsWithTurn = currentMap.groups().filter(func(n): return n.side==turnOf)
	for g in groupsWithTurn: g.changeSide(turnOf)

	# If the AI has no groups to control yet, give them all to the AI so it can handle them
	if queue.is_empty() and turnOf!=Units.Team.Player:
		var groupsLeft = groupsWithTurn.filter(func(g: Group): return !g.doneActing())
		if !ai.currentGroup and !groupsLeft.is_empty():
			ai.game = self
			ai.groupsLeft = groupsLeft
			ai.currentGroup = groupsLeft.pop_front()
		if ai.currentGroup:
			ai.play()

	# if the turn of the current team is over: change to the next teams turn.
	if groupsWithTurn.is_empty() or (groupsWithTurn.all(func(n): return n.doneActing())):
		refreshAll()
		match(turnOf):
			Units.Team.Player:
				turnOf = Units.Team.Enemy
			Units.Team.Enemy:
				turnOf = Units.Team.Ally
			Units.Team.Ally:
				turnCountUp()
				turnOf = Units.Team.Player
		print("turn "+str(currentTurn)+", turn of "+turn_of_dict[turnOf])
		deSelect()
		# handle leader business
		for group in groupsWithTurn: group.handleLeader()
		# reduce temporary status effects
		for group in groupsWithTurn: group.reduceTemporary() 
		# hurt or heal tile effects and bonuses
		currentMap.giveBonuses(true)
		change_turn.emit()
	# stun all non player groups if their leader dies
	for group in currentMap.groups():
		group.stunLeaderless()
	# change maps if the battle is over
	if !changeMap:
		changeMap = isBattleOver()
	#update.emit()
