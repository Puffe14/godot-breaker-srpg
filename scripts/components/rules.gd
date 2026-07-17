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
# limits for difference based activations in combat
static var vantageDiff = 9
static var alacrityDiff = 9
static var doubleDiff = 4
# bonus
@export var skillBonusHitRateForEffective = 20
@export var skillHitRatePenaltyRatio = 2
@export var wpnTypeAdvantageBonus = 15
@export var statusAuraRange = Vector2i(1,2)

static func kill_exp_formula(attacker: Units, defender: Units) -> int:
    var level_diff_multiplier = max(defender.character.level - defender.character.level + 2, 0)
    return level_diff_multiplier * 15