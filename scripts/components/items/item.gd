class_name Item extends Resource

@export var consumable: Consumable = null
@export var armor: Armor = null
@export var weapon: Weapon = null
@export var medkit: Medkit = null
@export var equipment: Equipment = null

@export var name: String
@export var description: String
@export var durability: Durability
@export var discardable: bool = true

## text intended as full item information
func describe() -> String:
	return name +":\n" + description

func _to_string() -> String:
	var string: String = ""
	if equipped(): string += "*"
	string += name
	if durability: string += " " + str(durability)
	return string

## True if the item is not broken.
func intact() -> bool:
	if durability:
		return durability.intact()
	else:
		return true

## True if the item is equipped.
func equipped() -> bool:
	if equipment:
		return equipment.equipped
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
		if durability.spent < 0:
			durability.spent = 0

func fix_full() -> void:
	if durability:
		durability.spent = 0
