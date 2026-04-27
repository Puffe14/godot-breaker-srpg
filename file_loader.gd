class_name FileLoader extends Node

var tile_dict: Dictionary = {
	"gray_field":preload("res://resources/data/tiles/gray_field.tres"),
	"sand_field":preload("res://resources/data/tiles/sand_field.tres")
	}

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
	map.grid = Grid.new()
	var map_json = load("res://resources/data/maps/test_map.json").data
	# boundaries
	map.grid.row = map_json["grid"]["row"]
	map.grid.column = map_json["grid"]["column"]
	# create the tiles
	var index: int = 0
	for tile_name in map_json["grid"]["tiles"]:
		# TODO
		var new_tile: Tile = tile_dict[tile_name].copy()
		var heights = map_json["grid"]["elevation"]
		@warning_ignore("integer_division")
		new_tile.position = Vector3i(index%map.grid.row, index/map.grid.column, heights[index])
		map.grid.tiles.append(new_tile)
		index+=1
