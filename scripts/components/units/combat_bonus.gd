class_name CombatBonus extends Resource

# AT: attack
# CR: crit
# AS: attack speed
# SK: skill
# PD: physical defence
# MD: magical defence
# HI: hitrate
# AV: avoid
# CA: crit avoid

@export var AT: int = 0
@export var CR: int = 0
@export var AS: int = 0
@export var SK: int = 0
@export var PD: int = 0
@export var MD: int =  0
@export var HI: int = 0
@export var AV: int = 0
@export var CA: int = 0

static var stat_names = ["AT","CR","AS","SK","PD","MD","HI","AV","CA"]

func addUp(other: CombatBonus) -> void:
	# don't add up null
	if !other: return
	# add all to previous
	AT += other.AT
	CR += other.CR
	AS += other.AS
	SK += other.SK
	PD += other.PD
	MD += other.MD
	HI += other.HI
	AV += other.AV
	CA += other.CA

func get_a_val(stat: String) -> int:
	match stat:
		"AT": return AT
		"CR": return CR
		"AS": return AS
		"SK": return SK
		"PD": return PD
		"MD": return MD
		"HI": return HI
		"AV": return AV
		"CA": return CA
		_: return 0

func _init(
	_AT: int = 0,
	_CR: int = 0,
	_AS: int = 0,
	_SK: int = 0,
	_PD: int = 0,
	_MD: int = 0,
	_HI: int = 0,
	_AV: int = 0,
	_CA:int = 0
) -> void:
	AT = _AT
	CR = _CR
	AS = _AS
	SK = _SK
	PD = _PD
	MD = _MD
	HI = _HI
	AV = _AV
	CA = _CA

static func new_val_from_dict(sl: Dictionary) -> CombatBonus:
	return CombatBonus.new(
	sl.get("AT",0),
	sl.get("CR",0),
	sl.get("AS",0),
	sl.get("SK",0),
	sl.get("PD",0),
	sl.get("MD",0),
	sl.get("HI",0),
	sl.get("AV",0),
	sl.get("CA",0))
	

func combat_bonus_info_dict(extra_string: String = "") -> Dictionary:
	var info_dict = {}
	for stat_name in stat_names:
		info_dict.merge(string_bonus_or_empty(stat_name, extra_string))
	return info_dict

func string_bonus_or_empty(stat_name: String, extra_string: String = ""):
	if self[stat_name] != 0:
		return {extra_string + stat_name + " " + str(self[stat_name]): ""}
	else:
		return {}
