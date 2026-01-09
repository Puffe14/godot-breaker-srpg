class_name Item extends Resource

@export var consumable: Consumable = null
@export var armor: Armor = null
@export var weapon: Weapon = null
@export var medkit: Medkit = null
@export var equipment: Equipment = null

@export var name: String
@export var description: String
@export var durability: Durability

## text intended as full item information
func describe() -> String:
    return name +": " + description

## True if the item is not broken.
func intact() -> bool:
    if durability:
        return durability.intact()
    else:
        return true

## Cause the weapon to lose durability by increasing the amount spent.
func spend(durabilityLoss: int) -> void:
    if durability:
        durability.spent += durabilityLoss
## Decrease the spent number to a maximum of zeo
func fix(durabilityGain: int) -> void:
    if durability:
        durability.spent -= durabilityGain
        if durability.spent < 0: durability.spent = 0