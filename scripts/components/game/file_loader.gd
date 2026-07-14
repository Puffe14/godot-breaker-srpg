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
	var unit = Units.new(character.duplicate(true),
		inventory.copy())
	unit.equipFirst()
	return unit

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

func read_items():
	var item_json = load("res://resources/data/items/items.json").data
	for next_item in item_json.values():
		var new_item: Item = Item.new()
		new_item.name = next_item["name"]
		new_item.description = next_item["description"]
		# is it durable
		if next_item.has("durability"):
			var next_durability = next_item["durability"]
			var new_durability: Durability = Durability.new()
			new_durability.spent = next_durability["spent"]
			new_durability.maximum = next_durability["durability"]
			next_item.durability = new_durability
		# is it armor
		if next_item.has("armor"):
			var next_armor = next_item["armor"]
			var new_armor: Armor = Armor.new()
			new_armor.part = Constants.string_to_part[next_armor["part"]]
			new_armor.stats = CombatBonus.new_val_from_dict(next_armor["bonus"])
			new_item.armor = new_armor
		# is it consumable
		if next_item.has("consumable"):
			var next_consumable = next_item["armor"]
			var new_consumable: Consumable = Consumable.new()
			new_consumable.permanent = next_consumable["permanent"]
			new_consumable.heal = next_consumable["heal"]
			new_consumable.effects = Stats.new_val_from_dict(next_consumable["bonus"])
			new_item.consumable = new_consumable
		# is it a weapon
		if next_item.has("weapon"):
			var next_weapon = next_item["weapon"]
			var new_weapon: Weapon = Weapon.new()
			new_weapon.dmgType = Constants.string_to_dmgtype[next_weapon["dmgtype"].to_lower()]
			new_weapon.wpnType = Constants.string_to_wpntype[next_weapon["wpntype"].to_lower()]
			new_weapon.rankLetter = Constants.string_to_letter[next_weapon["rank"]]
			new_weapon.quick = next_weapon["quick"]
			new_weapon.power = next_weapon["power"]
			new_weapon.hit = next_weapon["hit"]
			new_weapon.crit = next_weapon["crit"]
			new_weapon.weight = next_weapon["weight"]
			new_weapon.wrange = Vector2i(next_weapon["range"][0], next_weapon["range"][1])
			#new_weapon.stats = Stats.new_val_from_dict(next_weapon["bonus"])
			if not next_weapon["effective"].is_empty():
				new_weapon.effectiveAgainst = Effective.new()
				new_weapon.effectiveAgainst.flying= next_weapon["effective"].has("flier")
				new_weapon.effectiveAgainst.infantry = next_weapon["effective"].has("infantry")
				new_weapon.effectiveAgainst.mounted = next_weapon["effective"].has("rider")
			new_item.weapon = new_weapon
		# is it equipment
		if next_item.has("weapon") or next_item.has("armor"):
			new_item.equipment = Equipment.new()
		item_dict[new_item.name] = new_item


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
	
	# events
	map.events = []
	for event in map_json["events"].values():
		var new_event = make_event(event)
		if new_event:
			map.events.push_back(new_event)
		else:
			print("event reding foiled")

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
		group.side = Units.Team.Ally
		for ally in grouping:
			var unit: Units = makeUnit(ally[0])
			group.add_unit(unit)
			unit.takeDamage(ally[1])
			var location = ally[2]
			map.grid.addUnitAt(unit, Vector2i(location[0], location[1]))
		map.allies.append(group)
	for unit in map.all_units(): unit.refresh()

static func read_condition(condition_object: Dictionary) -> Condition:
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

func make_event(event_object: Dictionary) -> Event:
	var event: Event = null
	match event_object["title"]:
		"reinforcement":
			var units_coords: Array[FieldMap.UV2] = []
			for reinforcer in event_object["units"]:
				var unit: Units = makeUnit(reinforcer[0])
				## TODO waiting for unit dict to be loaded first
				unit.character.picture_name = reinforcer[0].to_lower()
				##
				var location = reinforcer[1]
				var new_uv2: FieldMap.UV2 = FieldMap.UV2.new(unit, Vector2i(location[0], location[1]))		
				units_coords.push_back(new_uv2)
			var team = Constants.string_to_team[event_object["team"].to_lower()]	
			var turns: Array[int] = []
			for i in event_object.get("turns"):
				turns.push_back(floor(i))
			return Reinforcement.new(units_coords, team, turns)
		"message":
			var lines: Array[String] = []
			for line in event_object.get("lines"):
				lines.push_back(line)
			## TODO: multi condition support
			var condition = event_object.get("when")
			var conditions: Array[Condition] = []
			if condition:
				conditions.push_back(read_condition(condition))
			event = Speech.new(conditions, lines)
		_:
			pass
			#event = Route.new(Units.Team.Enemy)
	return event
