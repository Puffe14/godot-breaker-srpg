class_name Interactible extends Resource

@export var loot: Inventory = null
@export var soul: bool = false

func _init(_loot: Inventory, _hasSoul: bool) -> void:
	loot = _loot
	soul = _hasSoul

func soulLeft() -> bool:
	return soul

func consumeSoul() -> void:
	soul = false

func setLoot(newLoot: Inventory):
	loot = newLoot

func takeLoot() -> Inventory:
	var tempO = loot
	loot = null
	return tempO

func loot_string() -> String:
	return loot.to_string()
