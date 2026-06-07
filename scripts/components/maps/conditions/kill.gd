class_name Kill extends Condition

var targets: Array = []

func _init(_targets: Array) -> void:
	targets = _targets

## Met when the characters with target names are dead
func met(fieldMap: FieldMap) -> bool:
	return targets.all(func(name):
		return fieldMap.all_units().all(func(c: Units):
			return c.character.myName!=name))

func description() -> String:
	var txt = ""
	for i in range(targets.size()):
		if i > 0:
			txt += ", "
		txt += targets[i]
	return "Kill " + txt
