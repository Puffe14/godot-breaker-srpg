class_name Reinforcement extends Event

## the group of units and their positions
var bunch: Array[FieldMap.UV2] = []
@export var team: Units.Team = Units.Team.Enemy
@export var turns: Array[int] = []


func _init(_bunch: Array[FieldMap.UV2], _team: Units.Team, _turns: Array[int]) -> void:
	bunch = _bunch
	team = _team
	turns = _turns
	# create a survive condition for each turn in the turns vector
	conditions = []
	for turn_num in turns:
		conditions.push_back(Survive.new(turn_num))


func effect(fieldMap: FieldMap) -> Action:
	#make new copies of units
	var pickings: Array = bunch.map(
		func(uv2: FieldMap.UV2) -> FieldMap.UV2: return FieldMap.UV2.new(uv2.unit.copy(), uv2.pos)
	)
		
	var units: Array[Units] = []
	for uv2 in pickings:
		units.push_back(uv2.unit)
	var names = units.map((func(u): return u.character.myName + " "))
	var names_string = ""
	for i in range(names.size()):
		names_string += names[i]
		if i < names.size():
			names_string + ", "

	# Place units on map
	for uv2 in pickings:
		fieldMap.grid.addUnitAt(uv2.unit,  uv2.pos)
		uv2.unit.equipFirst()
	# then based on the team
	match(team):
		Units.Team.Player:
			# add them to deployed
			fieldMap.addUnitListToDeployed(units)
		Units.Team.Enemy:
			# add them to additional groups
			fieldMap.enemies.append(Group.new(units, Group.Behaviour.Agressive, team))
		Units.Team.Ally:
			# add them to additional groups
			fieldMap.allies.append(Group.new(units, Group.Behaviour.Agressive, team))

	var act = EmptyAction.new()
	act.explain.addDialogue(names_string + " join(s) " + Constants.team_of_dict[team])
	return act
	# if failed???
	#  case _ =>
	#    val act = EmptyAction()
	#    act.explain.addDialogue(s"$names of $team blocked")
	#    act
