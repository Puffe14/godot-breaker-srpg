class_name Class extends Resource

# Parameters needed to form a class.
@export var className: String
@export var requiredLevel: int
@export var classType: Array
@export var classGrowth: Stats
@export var stats: Stats
@export var classBuffs: CombatBonus
@export var classDebuffs: CombatBonus
@export var classRanks: Ranks

func name(): return className
