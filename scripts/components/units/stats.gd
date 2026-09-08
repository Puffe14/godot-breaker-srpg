class_name Stats extends Resource

@export var maxHp: int = 0
@export var stn: int = 0
@export var mag: int = 0
@export var skl: int = 0
@export var spd: int = 0
@export var dfn: int =  0
@export var res: int = 0
@export var move: int = 0
@export var jump:int = 0

static var level_up_keys = [
"hitpoints",
"strength",
"magic",
"skill",
"speed",
"defence",
"resistance",
]

static var stat_keys = [
	"maxHp",
	"stn",
	"mag",
	"skl",
	"spd",
	"dfn",
	"res",
	"move",
    "jump"
]

func addUp(other: Stats) -> void:
	# don't add up null
	if !other: return
	# add all to previous
	maxHp += other.maxHp
	stn += other.stn
	mag += other.mag
	skl += other.skl
	spd += other.spd
	dfn += other.dfn
	res += other.res
	move += other.move
	jump += other.jump

func get_a_val(stat: String) -> int:
	match stat:
		"hitpoints": return maxHp
		"strength": return stn
		"magic": return mag
		"skill": return skl
		"speed": return spd
		"defence": return dfn
		"resistance": return res
		"jump": return jump
		"move": return move
		_: return 0

func add_a_val(stat: String, plus: int) -> void:
	match stat:
		"hitpoints": maxHp += plus
		"strength": stn += plus
		"magic":  mag += plus
		"skill":  skl += plus
		"speed":  spd += plus
		"defence":  dfn += plus
		"resistance": res += plus
		"jump":  jump += plus
		"move": move += plus
		_: pass

func _init(
	_maxHp: int = 0,
	_stn: int = 0,
	_mag: int = 0,
	_skl: int = 0,
	_spd: int = 0,
	_dfn: int = 0,
	_res: int = 0,
	_move: int = 0,
	_jump:int = 0
) -> void:
	maxHp = _maxHp
	stn = _stn
	mag = _mag
	skl = _skl
	spd = _spd
	dfn =  _dfn
	res = _res
	move = _move
	jump = _jump

static func new_val_from_dict(sl: Dictionary) -> Stats:
	return Stats.new(
	sl.get("hitpoints",0),
	sl.get("strength",0),
	sl.get("magic",0),
	sl.get("skill",0),
	sl.get("speed",0),
	sl.get("defence",0),
	sl.get("resistance",0),
	sl.get("movement",0),
	sl.get("jump",0))

func all_at_none() -> bool:
	return stat_keys.all( func(s):
		var is_0 = self[s] == 0
		return is_0
	)

func _to_string() -> String:
	if all_at_none():
		return "no effects"
	return "max hp: " + str(maxHp) + " stn: " + str(stn) + " mag: " + str(mag) + " skl: " + str(skl) + " spd: " + str(spd) + " dfn: " + str(dfn) + " res: " + str(res) + " move: " + str(move) + " jump: " + str(jump)
