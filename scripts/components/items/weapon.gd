class_name Weapon extends Resource

enum WeaponType {Sharp, Blunt, Long, Ranged, Spell}
enum DamageType {Magic, Force}

# Info on weapon.
@export var quick: bool
@export var wpnType: WeaponType
@export var dmgType: DamageType
@export var rankLetter: Ranks.Letter
@export var stats: Stats

# Direct combat stats.
@export var power: int
@export var hit: int
@export var crit: int
@export var wrange: Vector2i
@export var weight: int

# Effective against these types
var effectiveAgainst: Effective

# If true, the weapon always doubles (2x or 4x attacks)
func isQuick() -> bool:
    return quick