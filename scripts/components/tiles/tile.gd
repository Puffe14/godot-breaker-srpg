class_name Tile extends Resource

var tile_name: String
var photo_name: String = "default"
var bottom_name: String = "field_base"
var position: Vector3i
var canFlyOver: bool
var interactible: Interactible
var occupiable: Occupiable

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