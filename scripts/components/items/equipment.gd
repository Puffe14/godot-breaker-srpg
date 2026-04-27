class_name Equipment extends Resource

@export var equipped: bool = false

func isEquipped() -> bool:
	return equipped
func equip() -> void:
	equipped = true
func unequip() -> void:
	equipped = false
func toggleEquip() -> void:
	equipped = !equipped
