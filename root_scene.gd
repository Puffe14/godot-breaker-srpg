extends Node2D

@export var title_menu: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#for child_scene in get_children():
	#	child_scene._ready()
	#	print("waiting - readying scene: "+child_scene.name)
	#	await child_scene.ready
	#	print("success - readied scene: "+child_scene.name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_new_game():
	print("start game")
	$TitleMenu.visible = false
	$MainGUI.visible = true
	$MainGUI.started = true
	$MainGUI._ready()


func _on_title_menu_start_new_game(level: int) -> void:
	start_new_game()
