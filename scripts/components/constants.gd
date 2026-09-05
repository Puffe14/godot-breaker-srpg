class_name Constants

enum Status {Stunned}
enum BodyPart {Head, Arms, Legs, Torso}
static var body_part_dict = {
	BodyPart.Head: "Head",
	BodyPart.Arms: "Arms",
	BodyPart.Legs: "Legs",
	BodyPart.Torso: "Torso"
}
static var string_to_part = {
	"Head": BodyPart.Head,
	"Arms": BodyPart.Arms,
	"Legs": BodyPart.Legs,
	"Torso": BodyPart.Torso
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
static var string_to_dmgtype = {
	"force": Weapon.DamageType.Force,
	"magic": Weapon.DamageType.Magic
}
static var string_to_wpntype = {
	"sharp": Weapon.WeaponType.Sharp,
	"blunt": Weapon.WeaponType.Blunt,
	"long": Weapon.WeaponType.Long,
	"ranged": Weapon.WeaponType.Ranged,
	"spell": Weapon.WeaponType.Spell
}
static var string_to_letter = {
	"A": Ranks.Letter.A,
	"B": Ranks.Letter.B,
	"C": Ranks.Letter.C,
	"D": Ranks.Letter.D,
	"E": Ranks.Letter.E,
	"": Ranks.Letter.None,
	null: Ranks.Letter.None
}
static var letter_to_string = {
	Ranks.Letter.A: "A",
	Ranks.Letter.B: "B",
	Ranks.Letter.C: "C",
	Ranks.Letter.D: "D",
	Ranks.Letter.E: "E",
	Ranks.Letter.None: "None"
}

static var parts = [BodyPart.Head, BodyPart.Arms, BodyPart.Legs, BodyPart.Torso]

static func body_part_to_text(part: BodyPart) -> String:
	return body_part_dict[part]

## Turn an array of numbers into a string for a sum
static func array_to_sum_string(string_array: Array, color: bool = false) -> String:
	var text = ""
	var length = string_array.size()
	for i in range(length):
		var next = string_array[i]
		if i > 0:
			if next < 0:
				text += str(" - ") 
				if color:
					text += nps_str(next)
				else:
					text += str(abs(next))
			else:
				text += str(" + ")
				if color:
					text += nps_str(next)
				else:
					text += str(abs(next))
		else:
			text += str(next)
	return text

## negative-positive colored string for a number
static func nps_str(number, comparitor: int = 0):
	var text = ""
	if comparitor < 0:
		text += "[color=pink]" + str(abs(number)) + "[/color]"
	elif comparitor > 0:
		text += "[color=lightblue]" + str(abs(number)) + "[/color]"
	else:
		text += str(abs(number))
	return text
