class_name Durability extends Resource

@export var maximum = 0
@export var spent = 0

func intact() -> bool:
    return maximum > spent