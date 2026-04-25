class_name Durability extends Resource

@export var maximum: int = 0
@export var spent: int = 0

func intact() -> bool:
	return maximum > spent

func _to_string() -> String:
	return str(maximum-spent)+"/"+str(maximum)
