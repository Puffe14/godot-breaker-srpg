class_name FileLoader extends Node

var tile_dict: Dictionary = {
	}

var unit_dict: Dictionary = {
	"Cylna":preload("res://resources/data/units/test_unit_c.tres"),
	"BossLairaea":preload("res://resources/data/units/test_unit_l.tres"),
	"Lairaea":preload("res://resources/data/units/test_unit_l.tres"),
	"Lochagos":preload("res://resources/data/units/dummy2_unit.tres"),
	}

var class_dict: Dictionary = {
	
}

var character_dict: Dictionary = {
	
}

var item_dict: Dictionary = {
}

var inventory_dict: Dictionary = {
	"Lairaea": preload("res://resources/data/items/test_bow_inv.tres"),
	"BossLairaea": preload("res://resources/data/items/test_bow_inv.tres"),
	"Cylna": preload("res://resources/data/items/test_club_inv.tres"),
	"Dummy": preload("res://resources/data/test_inventory.tres"),
	"Dummy2": preload("res://resources/data/test_inventory.tres"),
	"Dummy3": preload("res://resources/data/test_inventory.tres"),
	"Geblah": preload("res://resources/data/test_inventory.tres"),
	"Medic": preload("res://resources/data/test_inventory.tres"),
	"Locagos": preload("res://resources/data/test_inventory.tres"),
	"Warrior": preload("res://resources/data/test_inventory.tres"),
	"Aynia": preload("res://resources/data/test_inventory.tres")
}


var map_dict: Dictionary = {
	"1": preload("res://resources/data/maps/test_map.json"),
	"2": preload("res://resources/data/maps/map_2.json")
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

func makeUnit(unit_name: String) -> Units:
	var character: Character = character_dict.get(unit_name, load("res://resources/data/characters/dummy.tres"))
	var inventory: Inventory = inventory_dict.get(character.myName, load("res://resources/data/test_inventory.tres"))
	return Units.new(character.duplicate(true),
		inventory.duplicate(true))

func read_tiles():
	var tile_json = load("res://resources/data/tiles/tiles.json").data
	var values = tile_json.values()
	var keys = tile_json.keys()
	for i in range(values.size()):
		var next_tile = values[i]
		var new_tile: Tile = Tile.new()
		if next_tile["occupiable"]:
			new_tile.occupiable = Occupiable.new()
			new_tile.occupiable.effects_from_dict(next_tile["effect"])
		else:
			new_tile.occupiable = null
		new_tile.photo_name = next_tile["photo"]
		new_tile.tile_name = next_tile["name"]
		tile_dict[keys[i]] = new_tile
		#### MIKS NE ON SAMA ARVO OCCUISSA KUN SE RUNAA BROO

func read_classes():
	var class_json = load("res://resources/data/classes/classes.json").data
	for next_class in class_json.values():
		var new_class: Class = Class.new()
		new_class.className = next_class["name"]
		new_class.requiredLevel = next_class["level"]
		new_class.classType = next_class["type"]
		new_class.stats = Stats.new_val_from_dict(next_class["stats"])
		new_class.classGrowth = Stats.new_val_from_dict(next_class["growth"])
		new_class.classBuffs = Stats.new_val_from_dict(next_class["buffs"])
		new_class.classDebuffs = Stats.new_val_from_dict(next_class["debuffs"])
		class_dict[new_class.className] = new_class

func read_characters():
	var character_json = load("res://resources/data/characters/characters.json").data
	for next_character in character_json.values():
		var new_character: Character = Character.new()
		new_character.myName = next_character["name"]
		new_character.xp = next_character["exp"]
		new_character.level = next_character["level"]
		new_character.myClass = class_dict[next_character["class"]]
		new_character.stats = Stats.new_val_from_dict(next_character["stats"])
		new_character.growths = Stats.new_val_from_dict(next_character["growth"])
		new_character.possibleClass = next_character["classes"]
		character_dict[new_character.myName] = new_character

func reread_map(map: FieldMap, map_key: String):
	map.grid = Grid.new()
	map.turnNumber = 1
	var map_json = map_dict[map_key].data

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
		new_tile.position = Vector3i(index%map.grid.row, index/map.grid.row, heights[index])
		map.grid.tiles.append(new_tile)
		index+=1

	# deployment
	map.deployment = []
	for location in map_json["deploy"]:
		map.deployment.append(Vector2i(location[0], location[1]))

	# conditions
	map.clearCondition = read_condition(map_json["clear"])

	# TODO how will they be implemented in file?
	map.loseConditions = []
	for lose: Dictionary in map_json["lose"]:
		map.loseConditions.push_back(read_condition(lose))
	if map.loseConditions.is_empty():
		map.loseConditions = [Route.new(Units.Team.Player)]

	## units onto map
	map.enemies = []
	map.allies = []
	var joining = map_json["joining"]
	for joiner in joining:
		var unit: Units = makeUnit(joiner[0])
		## TODO waiting for unit dict to be loaded first
		unit.character.picture_name = joiner[0].to_lower()
		##
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
			var unit: Units = makeUnit(enemy[0])
			group.add_unit(unit)
			unit.takeDamage(enemy[1])
			var location = enemy[2]
			map.grid.addUnitAt(unit, Vector2i(location[0], location[1]))
		map.enemies.append(group)
	var allies = map_json["allies"]
	for grouping in allies:
		var group: Group = Group.new()
		group.side = Units.Team.Enemy
		for ally in grouping:
			var unit: Units = makeUnit(ally[0])
			group.add_unit(unit)
			unit.takeDamage(ally[1])
			var location = ally[2]
			map.grid.addUnitAt(unit, Vector2i(location[0], location[1]))
		map.allies.append(group)
	for unit in map.all_units(): unit.refresh()

func read_condition(condition_object: Dictionary) -> Condition:
	var condition: Condition = null
	match condition_object["title"]:
		"survive":
			condition = Survive.new(condition_object["limit"])
		"kill":
			condition = Kill.new(condition_object["target"])
		"route":
			condition = Route.new(Constants.string_to_team[condition_object["team"].to_lower()])
		_:
			condition = Route.new(Units.Team.Enemy)
	return condition
