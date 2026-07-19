class_name Rules extends Resource

# inventory handling
@export var inventory_limit: int = 6
@export var lootDurabilityCost = 2
@export var playerStorageLimit = 50
# combat
@export var effectiveMultiplier = 3
static var critMultiplier = 3
@export var diff = 3
@export var advantages = [Weapon.WeaponType.Blunt, Weapon.WeaponType.Ranged, Weapon.WeaponType.Sharp, Weapon.WeaponType.Blunt]
static var attack_height_up_max = 1
static var attack_height_down_max = 2
static var ignore_height_weapontypes = [Weapon.WeaponType.Ranged]
# limits for difference based activations in combat
static var vantageDiff = 9
static var alacrityDiff = 9
static var doubleDiff = 4
# bonus
@export var skillBonusHitRateForEffective = 20
@export var skillHitRatePenaltyRatio = 2
@export var wpnTypeAdvantageBonus = 15
@export var statusAuraRange = Vector2i(1,2)

static func ignore_elevation(wtype: Weapon.WeaponType) -> bool:
    if ignore_height_weapontypes.has(wtype):
        return true
    else:
        return false

static func kill_exp_formula(attacker: Units, defender: Units) -> int:
    var level_diff_multiplier = max(defender.character.level - attacker.character.level + 2, 0)
    return level_diff_multiplier * 15