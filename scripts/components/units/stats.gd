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
        "strength": return stn
        "magic": return mag
        "skill": return skl
        "speed": return spd
        "defence": return dfn
        "resistance": return res
        _: return 0