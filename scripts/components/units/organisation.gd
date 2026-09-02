class_name Organisation extends Resource

@export var members: Array[Units]
@export var deployed: Array[Units]
@export var inventory: Inventory
@export var side: Units.Team
@export var group: Group

func re_group() -> void:
	group = Group.new()
	group.set_new(deployed,Group.Behaviour.Control,side)

## Adds a new unit to the organization.
func addMember(unit: Units):
	members.push_back(unit)

## Removes a new unit from the organization.
func removeMember(unit: Units):
	members.erase(unit)

## Adds a new unit to the deployed team.
func addDeployed(unit: Units):
	deployed.push_back(unit)

## Adds missing units to the members of the org.
func addMissingToMembers(units: Array):
	for unit in units:
		if not members.has(unit):
			addMember(unit)

## Adds missing units to the members of the org.
func addMissingToDeployed(units: Array):
	for unit in units:
		if not deployed.has(unit):
			addDeployed(unit)


## Removes a new unit from the deployed team.
func removeDeployed(unit: Units):
	deployed.erase(unit)

## Removes all dead characters from an organization
func clearDead():
	members = members.filter(func(u:Units) -> bool: return not u.isDead())
	deployed = deployed.filter(func(u:Units) -> bool: return not u.isDead())
	pass

func refresh_acts_for_members() -> void:
	for memb in members:
		memb.refresh()

func clearDeployed():
	deployed = []
