class_name Tile extends Resource

@export var tile_name: String
@export var photo_name: String = "default"
@export var bottom_name: String = "field_base"
@export var position: Vector3i
@export var canFlyOver: bool
@export var interactible: Interactible
@export var occupiable: Occupiable

signal show_move(show: bool)

func copy() -> Tile:
	var new_copy = self.duplicate()
	if interactible:
		new_copy.interactible = Interactible.new(interactible.loot, interactible.soul)
	if occupiable:
		new_copy.occupiable = occupiable.copy() ##occupiable, interactible.soul)
	return new_copy

## give new Vector3i position
func setPos(x: int, y: int, z: int) -> void:
	position = Vector3i(x, y, z)

func containsLoot() -> bool:
	return interactible && interactible.loot.nonEmpty
func containsSoul() -> bool:
	return interactible && interactible.soulLeft

## add the loot from a dead character, soul if applicable
func addCorpse(loot: Inventory, hasSoul: bool = true):
	interactible = Interactible.new(loot, hasSoul)
## remove the soul from the tile
func spendSoul():
	if interactible: interactible.consumeSoul()

func has_dead() -> bool:
	return occupiable and occupiable.occupant and occupiable.occupant.isDead()

func emit_show_move(value: bool) -> void:
	emit_signal("show_move", value)

func _to_string() -> String:
	return tile_name + ": " +str(position)
