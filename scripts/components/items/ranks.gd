class_name Ranks extends Resource

enum Letter {None, E, D, C, B, A}

@export var Sharp: Letter = Letter.None
@export var Blunt: Letter = Letter.None
@export var Long: Letter = Letter.None
@export var Ranged: Letter = Letter.None

func info_dict() -> Dictionary:
	var dict = {
		"Sharp " + Constants.letter_to_string[Sharp]: "",
		"Blunt " + Constants.letter_to_string[Blunt]: "",
		"Long " + Constants.letter_to_string[Sharp]: "",
		"Ranged " + Constants.letter_to_string[Blunt]: ""
	}
	return dict
