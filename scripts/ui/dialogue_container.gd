class_name DialogueContainer extends MarginContainer

@export var title: Label = null
@export var dia_text: RichTextLabel = null
@export var dia_pic: Sprite2D = null
@export var explain: Explain = null
@export var dialogue: Dialogue = null
var default_pic = load("res://resources/images/portraits/default.png")

signal progress
signal skip

func _ready(new_dialogue = null) -> void:
	set_dialogue(new_dialogue)

func _process(_delta: float) -> void:
	if explain != null:
		if Input.is_action_pressed("dialogue_continue") or Input.is_action_just_released("select"):
			progress.emit()
			dialogue = null
		if Input.is_action_pressed("dialogue_skip") or Input.is_action_just_released("deselect"):
			explain.skipDialogue()
			skip.emit()
			progress.emit()
			dialogue = null

func set_visibility() -> bool:
	if !(dialogue):
		visible = false
	else: visible = true
	return visible

func set_dialogue(new_dialogue: Dialogue):
	dialogue = new_dialogue
	if dialogue:
		dia_text.text = dialogue._to_string()
		if dialogue.pic:
			dia_pic.texture = dialogue.pic
		else:
			dialogue.pic = default_pic
	set_visibility()
