class_name Use extends Action

@export var user: Units = null
@export var item: Item = null

func _init(_user: Units, _item: Item) -> void:
	user = _user
	item = _item

func play() -> Explain:
	user.useItem(item)
	explain.addDialogue(user.character.myName+" used "+item.name)
	explain.addDialogue("")
	return explain

func _to_string() -> String:
	return "Use"
