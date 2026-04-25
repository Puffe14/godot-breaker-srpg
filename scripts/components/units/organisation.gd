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
	addMember(unit)
	deployed.push_back(unit)

## Removes a new unit from the deployed team.
func removeDeployed(unit: Units):
	deployed.erase(unit)

## Removes all dead characters from an organization
func clearDead():
	members = members.filter(func(u:Units): u.isDead())
