class_name Inventory extends Resource

## Creates the slots for the inventory, filled with None. */
@export var slotCount: int = 6
@export var slots: Array
@export var dontReset: bool = false

func _init(_slotCount: int = 6) -> void:
	if dontReset: return
	slotCount = _slotCount
	slots.resize(slotCount)
	slots.fill(null)

## Adds an item to the inventory. Returns false if there are no slots to fill. */
func add(item: Item) -> bool:
	if slots.has(null):
		slots[slots.find(null)] = item
		definedToTop()
		return true
	else:
		return false

## Removes an item from the inventory. */
func remove(item: Item) -> Item:
	if item && slots.has(item):
		slots[slots.find(item)] = null
		definedToTop()
		return item
	return null

## remove everything from the inventory
func removeAll() -> Array:
	var _removed = []
	for item in slots:
		_removed.push_back(remove(item))
	return _removed 

## Swaps two items in their slots between inventories. */
func swap(other: Inventory, index: int, otherIndex: int):
	if !(other == self && index == otherIndex):
		var otherThing = other.remove(other.slots[otherIndex])
		var thisThing = self.remove(self.slots[index])
		# add the removed items
		if otherIndex > index:
			self.add(otherThing)
			other.add(thisThing)
		else:
			other.add(thisThing)
			self.add(otherThing)

## remove broken/used up items from inventory
func clean() -> void:
	for item in slots:
		if item and !item.intact():
			remove(item)

## move non null back to top
func definedToTop():
	slots.sort_custom(slot_sort)

## slots should be sorted so that nulls are last
func slot_sort(a, _b):
	return a != null

# a given item is equipped
func isEquipped(item): return item.equipped()

# different item groups
func armors() -> Array:
	return slots.filter(
		func(item: Item):
		return item && item.armor != null
	)
func weapons() -> Array:
	return slots.filter(
		func(item: Item):
		return item && item.weapon != null
	)
func medkits() -> Array:
	return slots.filter(
		func(item: Item):
		return item && item.medkit != null
	)
func consumables() -> Array:
	return slots.filter(
		func(item: Item):
		return item && item.consumable != null
	)

# return equipped items
func equippedArmors() -> Array:
	return armors().filter(isEquipped)
func equippedWeapon() -> Item:
	var weps = weapons().filter(isEquipped)
	if weps.size() > 0: return weps[0]
	else: return null
func equippedMedkit() -> Item:
	var meds = medkits().filter(isEquipped)
	if meds.size() > 0: return meds[0]
	else: return null

# equip the items
func equipWeapon(weapon: Item, toggle: bool):
	var w = equippedWeapon()
	if w and w!=weapon:
		w.equipment.unequip()
	if toggle: weapon.equipment.toggleEquip()
	else: weapon.equipment.equip()
func equipMedkit(medkit: Item, toggle: bool):
	var m = equippedMedkit()
	if m and m!=medkit:
		m.equipment.unequip()
	if toggle: medkit.equipment.toggleEquip()
	else: medkit.equipment.equip()
func equipArmor(armor: Item, toggle: bool):
	# unequips any armor piece that fits on the same part of the body
	for a in equippedArmors():
		if a.armor.bodyPart == armor.armor.bodyPart and a!=armor:
			a.equipment.unequip()
	if toggle: armor.equipment.toggleEquip()
	else: armor.equipment.equip()

## array of strings describing every slot
func listItems() -> Array:
	return slots.map(func(item):
		if item:
			return item.name
		else:
			return "empty"
	)

# When someone is killed, their inventory is lootified
func toLoot() -> Inventory:
	for i: Item in slots:
		if i.durability:
			@warning_ignore("integer_division")
			i.spend(i.durability.maximum/2)
		i.equipment.unequip()
	return self

func empty() -> bool:
	return !slots.all(func(i): return i==null)

func _to_string() -> String:
	return "Inventory"

##TODO redo equipment handling to  being handled and tracked only in Inventory
