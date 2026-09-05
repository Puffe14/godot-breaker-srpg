class_name Ranks extends Resource

enum Letter {None, E, D, C, B, A}

@export var Sharp: Letter = Letter.None
@export var Blunt: Letter = Letter.None
@export var Long: Letter = Letter.None
@export var Ranged: Letter = Letter.None

static func new_val_from_dict(rank_dict: Dictionary):
	var new_ranks = Ranks.new()
	new_ranks.Sharp = roundi(rank_dict.get("Sharp",Letter.None))
	new_ranks.Blunt = roundi(rank_dict.get("Blunt",Letter.None))
	new_ranks.Long = roundi(rank_dict.get("Long",Letter.None))
	new_ranks.Ranged = roundi(rank_dict.get("Ranged",Letter.None))
	return new_ranks

func info_dict() -> Dictionary:
	var dict = {
		"Sharp: " + Constants.letter_to_string[Sharp]: "",
		"Blunt: " + Constants.letter_to_string[Blunt]: "",
		"Long: " + Constants.letter_to_string[Sharp]: "",
		"Ranged: " + Constants.letter_to_string[Blunt]: ""
	}
	return dict
