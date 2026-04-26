class_name FileLoader extends Node

var tile_dict: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func make_tile() -> Tile:
	var tile: Tile = Tile.new()
	tile.tile_name = ""
	return tile

func reread_map(map: FieldMap):
	#map.grid = []
	var map_json = load("res://resources/data/maps/test_map.json")
	for t in map_json["grid"]["tiles"]:
		# TODO
		pass
