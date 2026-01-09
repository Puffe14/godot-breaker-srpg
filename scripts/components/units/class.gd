class_name Class extends Resource

# Parameters needed to form a class.
@export var className: String
@export var requiredLevel: int
@export var classType: Array
@export var classGrowth: Stats
@export var classStats: Stats
@export var classBuffs: Stats
@export var classDebuffs: Stats
@export var classRanks: Ranks

func name(): return className
func stats(): return classStats