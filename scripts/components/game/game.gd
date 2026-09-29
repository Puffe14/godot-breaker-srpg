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

var cheat_mode = false

signal selected(thing)
signal inspected(thing)
signal update
signal change_turn
signal send_tip(tip_text: String)

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
		send_tip.emit(acting.character.myName+" targeting self")
		inspected.emit([acting])
	# Beat-em-up with current weapon
		#case o: Occupiable if target.nonEmpty && !acting.forall(_.turnOver) && targetInRangeOfActor =>
		#attack()
	# Select target
	elif occupiable and occupant and acting:
		if not cheat_mode and acting.team != turnOf:
			send_tip.emit("can't act, wrong turn ("+turn_of_dict[turnOf]+")")
			return
		elif not cheat_mode and acting.acted:
			send_tip.emit("actions exhausted for this turn!")
			return
		target = occupant
		#if target == acting:
		var available_actions = []
		if cheat_mode:
			available_actions = availableActions(acting, !acting.moved)
			send_tip.emit("all actions for "+acting.character.myName)
		else:
			available_actions = availableActions(acting, false)
			send_tip.emit("actions for "+acting.character.myName)
		# send out selected actions to the gui
		selected.emit(available_actions)
		if available_actions.is_empty():
			send_tip.emit("can't find any actions from here!")
	# Move acting unit to given tile
	elif occupiable and acting:
		if currentMap.movementRangeTiles(acting).has(tile):
			if cheat_mode or !acting.moved:
				if cheat_mode or acting.team == turnOf:
					move_to(acting, tile)
				else:
					send_tip.emit("can't move, wrong turn ("+turn_of_dict[turnOf]+")")
			else:
				send_tip.emit("can't move again!!!")
		else:
			send_tip.emit("out of range, can't move!!!")

	# Select a new acting unit
	elif occupiable:
		acting = occupant
		if acting:
			if acting.acted or acting.team != turnOf:
				send_tip.emit("selected " + acting.character.myName + " (can't act)")
			else:
				send_tip.emit("selected " + acting.character.myName)
		if acting and ((acting.team == turnOf and not acting.acted) or cheat_mode):
			selected.emit([acting])
	else:
		acting = null
		target = null
	if currentMap:
		currentMap.giveBonuses(false)
	update.emit()

func deSelect():
	acting = null
	target = null
	if currentMap:
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
	var heals = []
	for tile in areaOfMovement:
		var current_weapon = unit.inventory.equippedWeapon()
		for weapon in possibleWeaponsOrNone: # Weapons that the character could use
			unit.equip(weapon)
			# Who can be attacked? --(who, from)
			var targets = fm.unitsInRangeAt(unit,tile,unit.Range(),Rules.ignore_elevation(weapon.weapon.wpnType))
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
		# set the weapon back
		if not possibleWeaponsOrNone.is_empty():
			unit.equip(current_weapon)
		# check all medkit options
		var current_medkit = unit.inventory.equippedMedkit()
		for medkit in possibleMedkitsOrNone: # Weapons that the character could use
			unit.equip(medkit)
			var targets = fm.unitsInRangeAt(unit,tile,unit.MedRange(),true) # Who can be healed? --(who, from)
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
		# set the weapon back
		if not possibleMedkitsOrNone.is_empty():
			unit.equip(current_medkit)
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
		## TODO character choice between levels
		player.clearDeployed()
		player.deployed = player.members
		player.re_group()
		currentMap.setPlayer(player)
		currentMap.deployPlayer()
		currentMap.setLeaders()

func skip_player() -> void:
	if currentMap and turnOf==player.side:
		for unit: Units in currentMap.unitsOnTeam(player.side) :
			if not unit.acted:
				queue.push_back(Wait.new(unit))
		send_tip.emit("selected wait for all player units")
	else:
		send_tip.emit("could not skip plyer turn")

func nextMap():
	# TODO
	# Advance to next map
	if currentMapNumber<3:
		currentMapNumber+=1
	player.addMissingToMembers(player.deployed)
	player.clearDead()
	player.refresh_acts_for_members()
	#player.clearDeployed()
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
		if currentMap.player:
			#player.addMissingToDeployed(currentMap.unitsOnTeam(player.side))
			player.re_group()
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
