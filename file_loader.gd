class_name FileLoader extends Node

var tile_dict: Dictionary = {
	"gray_field":preload("res://resources/data/tiles/gray_field.tres"),
	"sand_field":preload("res://resources/data/tiles/sand_field.tres")
	}

var unit_dict: Dictionary = {
	"Cylna":preload("res://resources/data/units/test_unit_c.tres"),
	"BossLairaea":preload("res://resources/data/units/test_unit_l.tres"),
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
	# deployment
	map.deployment = []
	for location in map_json["deploy"]:
		map.deployment.append(Vector2i(location[0], location[1]))
	## units onto map
	map.enemies = []
	map.allies = []
	var joining = map_json["joining"]
	for joiner in joining:
		var unit: Units = unit_dict[joiner[0]]
		unit.takeDamage(joiner[1])
		var location = joiner[2]
		map.grid.addUnitAt(unit, Vector2i(location[0], location[1]))
		map.addUnitToPlayerDeployed(unit)
		unit.setTeam(Units.Team.Player)
	var enemies = map_json["enemies"]
	for grouping in enemies:
		var group: Group = Group.new()
		group.side = Units.Team.Enemy
		for enemy in grouping:
			var unit: Units = unit_dict[enemy[0]]
			group.members.append(unit)
			unit.takeDamage(enemy[1])
			var location = enemy[2]
			map.grid.addUnitAt(unit, Vector2i(location[0], location[1]))
		map.enemies.append(group)
	var allies = map_json["allies"]
	for grouping in allies:
		var group: Group = Group.new()
		group.side = Units.Team.Enemy
		for ally in grouping:
			var unit: Units = unit_dict[ally[0]]
			group.members.append(unit)
			unit.takeDamage(ally[1])
			var location = ally[2]
			map.grid.addUnitAt(unit, Vector2i(location[0], location[1]))
		map.allies.append(group)
