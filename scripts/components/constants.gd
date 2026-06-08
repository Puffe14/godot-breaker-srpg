class_name Constants

enum Status {Stunned}
enum BodyPart {Head, Arms, Legs, Torso}
static var body_part_dict = {
	BodyPart.Head: "Head",
	BodyPart.Arms: "Arms",
	BodyPart.Legs: "Legs",
	BodyPart.Torso: "Torso"
}
static var team_of_dict = {
	Units.Team.Player: "player",
	Units.Team.Enemy: "enemy",
	Units.Team.Ally: "ally"
}
static var string_to_team = {
	"player": Units.Team.Player,
	"enemy": Units.Team.Enemy,
	"ally": Units.Team.Ally
}

static var parts = [BodyPart.Head, BodyPart.Arms, BodyPart.Legs, BodyPart.Torso]

static func body_part_to_text(part: BodyPart) -> String:
	return body_part_dict[part]
