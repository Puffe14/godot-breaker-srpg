class_name MapNode extends Node2D

@export var field_map: FieldMap = null
@export var layer_count = 9
@export var tile_height = 16
@export var tile_width = 32
var layer_node = preload("res://nodes/maps/default_map_layer.tscn")
# direction handling
enum Direction {UP, RIGHT, DOWN, LEFT}
var direction: Direction = Direction.UP
# signals
signal move(pos: Vector2, unit: Units, delay: float)
signal done_drawing_nodes

func _ready() -> void:
	# create layers
	for i in range(0, layer_count):
		var new_layer_node = layer_node.instantiate()
		add_child(new_layer_node)
		@warning_ignore("integer_division")
		new_layer_node.position.y -= i*(tile_height/2)
		new_layer_node.z_index = i
	# create tiles
	if field_map && field_map.grid:
		draw_tiles(direction)

func layers() -> Array:
	return get_children()

## Set the tile data into each node in the layers
func set_tiles_in_nodes():
	var joku = get_tree().get_nodes_in_group("tile")
	for jokin in joku:
		var tile_node: TileNode = jokin
		tile_node._ready()
		var pos_z = tile_node.z_index
		var pos = layers()[pos_z].local_to_map(tile_node.position)
		# rotate pos back to 0 rotation
		pos = translate_back_dir(pos)
		var tile: Tile = field_map.grid.get_tile_v(pos)
		tile_node.tile = tile
		if tile && !tile.show_move.is_connected(tile_node.show_move_sprite):
			tile.show_move.connect(tile_node.show_move_sprite)
	#joku.sort_custom(sort_tiles_pos_x_y)
	#for i: int in range(0,joku.size()):
		#var tile_node: TileNode = joku[i]
		#var tile: Tile = field_map.grid.tiles[i]
		#tile_node.tile = tile
		#tile.show_move.connect(tile_node.show_move_sprite)
		#tile_node._ready()
	pass

## Clear the layers and create tile nodes into cells
func draw_tiles(dir: Direction = Direction.UP):
	var translated: Vector2i = Vector2i(1,1)
	direction = dir
	if !field_map: return
	# clear all the layers
	for l: TileMapLayer in layers():
		l.clear()
	# sort tiles
	var tiles_sorted = field_map.grid.tiles
	#tiles_sorted.sort_custom(sort_tiles_pos_x_y)
	# set a cell in their positions
	for tile in tiles_sorted:
		var pos_x = tile.position.x
		var pos_y = tile.position.y
		var pos_z = tile.position.z
		# translate to rotation
		match dir:
			Direction.UP: translated = Vector2i(pos_x,pos_y)
			Direction.RIGHT: translated = Vector2i(-pos_y,pos_x)
			Direction.DOWN: translated = Vector2i(-pos_x,-pos_y)
			Direction.LEFT: translated = Vector2i(pos_y,-pos_x)
		layers()[pos_z].set_cell(translated,0,Vector2i(0,0),1)
		# draw unit
		if tile and tile.occupiable and tile.occupiable.occupant:
			var real_pos = layers()[pos_z].map_to_local(translated)
			emit_signal("move", position+real_pos*scale+Vector2(0,-tile_height*(pos_z+2)), tile.occupiable.occupant, pos_z, 0)
		# draw bottoms
		for z in range(0, pos_z):
			layers()[z].set_cell(translated,0,Vector2i(0,0),2)
	done_drawing_nodes.emit()


func _on_spin_box_value_changed(value: float) -> void:
	draw_tiles(round(value) as Direction)


func _on_update_button_pressed() -> void:
	set_tiles_in_nodes()

func sort_tiles_pos_x_y(a, b) -> bool:
	return a.position.y < b.position.y or a.position.x < b.position.x

func get_child_at_v3(vec: Vector3i) -> Node:
	var children = get_tree().get_nodes_in_group("tile")
	var found = null
	for tn in children:
		if tn.tile and tn.tile.position == vec:
			found = tn
	return found

func tile_translated_to_v2(tile: Tile) -> Vector2:
	var pos_x = tile.position.x
	var pos_y = tile.position.y
	var pos_z = tile.position.z
	var translated: Vector2
	# translate to rotation
	match direction:
		Direction.UP: translated = Vector2i(pos_x,pos_y)
		Direction.RIGHT: translated = Vector2i(-pos_y,pos_x)
		Direction.DOWN: translated = Vector2i(-pos_x,-pos_y)
		Direction.LEFT: translated = Vector2i(pos_y,-pos_x)
	layers()[pos_z].set_cell(translated,0,Vector2i(0,0),1)
	# draw unit
	var real_pos = layers()[pos_z].map_to_local(translated)
	return position+real_pos*scale+Vector2(0,-tile_height*(pos_z+2))

func translate_back_dir(v: Vector2i):
	var pos_x = v.x
	var pos_y = v.y
	var translated: Vector2i
	# translate to rotation
	match direction:
		Direction.UP: translated = Vector2i(pos_x,pos_y)
		Direction.RIGHT: translated = Vector2i(pos_y,-pos_x)
		Direction.DOWN: translated = Vector2i(-pos_x,-pos_y)
		Direction.LEFT: translated = Vector2i(-pos_y,pos_x)
	return translated

func reset_movement_display():
	var children = get_tree().get_nodes_in_group("tile")
	for tn: TileNode in children:
		tn.hide_move_and_team()
