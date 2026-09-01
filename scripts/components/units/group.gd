class_name Group extends Resource

enum Behaviour {Agressive, Stand, OnSight, Reach, Control, Erratic}
@export var members: Array[Units]
@export var behaviour: Behaviour
@export var side: Units.Team
@export var condition_met: bool = false

func set_new(_members: Array[Units], _behaviour: Behaviour, _side: Units.Team, _condition: bool = false):
	members = _members
	behaviour = _behaviour
	side = _side
	condition_met = _condition
	for m: Units in members:
		m.setTeam(side)

func _init(_members: Array[Units] = [], _behaviour: Behaviour = Behaviour.Agressive, _side: Units.Team = Units.Team.Enemy, _condition: bool = false) -> void:
	members = _members
	behaviour = _behaviour
	side = _side
	condition_met = _condition
	for m: Units in members:
		m.setTeam(side)

## array of members that have not acted
func haveNotActed() -> Array:
	return members.filter(func(m:Units): return !(m.turnOver()||m.isDead()))

func living_members() -> Array:
	return members.filter(func(m:Units): return m.isAlive())

func add_unit(unit: Units):
	members.append(unit)
	unit.setTeam(side)

## true if all members are done
func doneActing() -> bool:
	var all_done = haveNotActed().is_empty()
	return all_done

func changeSide(newSide: Units.Team):
	side = newSide

func changeBehaviour(newBehaviour: Behaviour):
	behaviour = newBehaviour

func setLeader():
	var lm = living_members()
	if lm.size() < 1:
		print("empty group, can't set leader")
		return
	lm.sort_custom(higherLevel)
	var leader = lm.front()
	for m: Units in lm:
		m.setLeader(leader)
		m.unstun()

func handleLeader():
	if side == Units.Team.Player: return
	# else set leader
	setLeader()

func higherLevel(a,b) -> bool:
	return a.lvl() > b.lvl()

func stunLeaderless():
	for unit in living_members():
		pass ##TODO

func reduceTemporary():
	for m in members:
		m.reduceTemporary()
