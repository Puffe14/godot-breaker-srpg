class_name ButtonOption extends Button

## any item stored within the button
@export var item = null
@export var user: Units = null
var game: Game = null
signal next_options(array: Array)

static var wpnTypeDict: Dictionary = {
	Weapon.WeaponType.Blunt: preload("res://resources/images/items/wpn_blunt.png"),
	Weapon.WeaponType.Long: preload("res://resources/images/items/wpn_long.png"),
	Weapon.WeaponType.Sharp: preload("res://resources/images/items/wpn_sharp.png"),
	Weapon.WeaponType.Spell: preload("res://resources/images/items/wpn_spell.png"),
	Weapon.WeaponType.Ranged: preload("res://resources/images/items/wpn_ranged.png")
}
static var armorTypeDict: Dictionary = {
	Constants.BodyPart.Head: preload("res://resources/images/status/armor head.png"),
	Constants.BodyPart.Legs: preload("res://resources/images/status/armor legs.png"),
	Constants.BodyPart.Arms: preload("res://resources/images/status/armor arms.png"),
	Constants.BodyPart.Torso: preload("res://resources/images/status/armor torso.png")
}

func _init(_game: Game, _item = null, _user = null) -> void:
	text = str(_item)
	game = _game
	if item == null:
		item = _item
	if user == null:
		user = _user
	if item:
		if "consumable" in item and item.consumable:
			icon = load("res://resources/images/items/itm_consumable.png")
		if "weapon" in item and "equipment" in item and item.weapon:
			icon = wpnTypeDict[item.weapon.wpnType]
		if "armor" in item and item.armor:
			icon = armorTypeDict[item.armor.part]

func pressed_option() -> Array:
	var options: Array = []
	# if the options is an action, play it instead
	if item and item.has_method("play"):
		game.add_to_queue(item, user)
		return []
	## create sub menu options
	# if the item has an inventory
	if "inventory" in item:
		options.push_back(item.inventory)
		options.push_back(Wait.new(user))
	# if the item has an inventory
	if "slots" in item:
		for it in item.slots:
			options.push_back(it)
	# if the item can be equipped
	if "equipment" in item and item.equipment:
		options.push_back(Equip.new(user,item,true))
	# if the item is consumable
	if "consumable" in item and item.consumable:
		if item.intact():
			options.push_back(Use.new(user,item))
		icon = load("res://resources/images/items/itm_consumable.png")
	# if the item can be thrown away
	if "discardable" in item and item.discardable:
		options.push_back(Discard.new(user,item))
	# check if should skip giving options (one option, not playable)
	if options.size() == 1 and options[0] != null and options[0]:
		item = options[1]
		return pressed_option()
	return options
	# send it to the menu for creating the sub menu
#	emit_signal("next_options", options)
