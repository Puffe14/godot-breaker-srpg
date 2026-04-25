class_name Discard extends Action

@export var user: Units = null
@export var item: Item = null

func _init(_user: Units, _item: Item) -> void:
	user = _user
	item = _item

func play() -> Explain:
	user.inventory.remove(item)
	return explain

func _to_string() -> String:
	return "Discard"
