class_name Equip extends Action

@export var user: Units = null
@export var item: Item = null
@export var toggle: bool = true

func _init(_user: Units, _item: Item, _toggle: bool) -> void:
	user = _user
	item = _item
	toggle = _toggle

func play() -> Explain:
	user.equip(item, toggle)
	return explain

func _to_string() -> String:
	return "Equip"
