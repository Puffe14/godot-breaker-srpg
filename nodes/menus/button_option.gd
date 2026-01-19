class_name ButtonOption extends Button

## any item stored within the button
@export var item = null
@export var user: Units = null
signal next_options(array: Array)

func _init(_item = null, _user = null) -> void:
	text = str(_item)
	if item == null:
		item = _item
	if user == null:
		user = _user

func pressed_option() -> Array:
	var options: Array = []
	# if the options is an action, play it instead
	if item.has_method("play"):
		item.play()
		return []
	## create sub menu options
	# if the item has an inventory
	if "inventory" in item:
		options.push_back(item.inventory)
	# if the item has an inventory
	if "slots" in item:
		for it in item.slots:
			options.push_back(it)
	# if the item can be equipped
	if "equipment" in item and item.equipment:
		options.push_back(Equip.new(user,item,true))
	# if the item is consumable
	if "consumable" in item and item.consumable:
		options.push_back(Use.new(user,item))
	# if the item can be thrown away
	if "discardable" in item and item.discardable:
		options.push_back("discard")
	return options
	# send it to the menu for creating the sub menu
#	emit_signal("next_options", options)
