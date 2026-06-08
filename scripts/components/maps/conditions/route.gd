## Remove ALL characters on a particular team on map.
class_name Route extends Condition

var target_team: Units.Team = Units.Team.Enemy

var turn_of_dict = {
	Units.Team.Player: "player",
	Units.Team.Enemy: "enemy",
	Units.Team.Ally: "ally"
}

func _init(_target_team: Units.Team) -> void:
	target_team = _target_team

## Remove ALL characters on a particular team on map.
func met(fieldMap: FieldMap) -> bool:
	return fieldMap.unitsOnTeam(target_team).is_empty()

func description() -> String:
	return "Route " + turn_of_dict[target_team]
