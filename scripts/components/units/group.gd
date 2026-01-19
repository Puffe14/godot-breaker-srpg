class_name Group extends Resource

enum Behaviour {Agressive, Stand, OnSight, Reach, Control, Erratic}
@export var members: Array[Units]
@export var behaviour: Behaviour
@export var side: Units.Team
@export var condition_met: bool = false

func _init(_members: Array[Units], _behaviour: Behaviour, _side: Units.Team, _condition: bool = false):
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


## true if all members are done
func doneActing() -> bool:
	return haveNotActed().is_empty()

func changeSide(newSide: Units.Team):
	side = newSide

func changeBehaviour(newBehaviour: Behaviour):
	behaviour = newBehaviour

func setLeader():
	var lm = living_members()
	lm.sort_custom(higherLevel)
	var leader = lm.front()
	for m: Units in lm:
		m.setLeader(leader)
		m.unstun()

func higherLevel(a,b) -> bool:
	return a.lvl() > b.lvl()
