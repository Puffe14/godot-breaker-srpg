class_name Reach extends Condition

var targets: Array = []
var team: Units.Team = Units.Team.Enemy

func _init(_targets: Array, _team: Units.Team) -> void:
	targets = _targets
	team = _team

## Met when the characters with target team are on target tiles
func met(fieldMap: FieldMap) -> bool:
	return targets.all(func(target_tile):
		var t = fieldMap.grid.get_tile(target_tile[0],target_tile[1])
		return t and t.occupiable and t.occupiable.occupant and t.occupiable.occupant.team == team
	)

func description() -> String:
	var txt = ""
	for i in range(targets.size()):
		if i > 0:
			txt += ", "
		txt += str(targets[i])
	return Constants.team_of_dict[team] + " reach " + txt
