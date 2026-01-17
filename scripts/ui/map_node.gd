class_name MapNode extends Node2D

@export var field_map: FieldMap = null
@export var layer_count = 3
@export var tile_height = 16
@export var tile_width = 32
var layer_node = preload("res://nodes/maps/default_map_layer.tscn")
# direction handling
enum Direction {UP, RIGHT, DOWN, LEFT}
var direction: Direction = Direction.UP
# signals
signal move(pos: Vector2, unit: Units, delay: float)

func _ready() -> void:
	# create layers
	for i in range(0, layer_count):
		var new_layer_node = layer_node.instantiate()
		add_child(new_layer_node)
		new_layer_node.position.y -= i*(tile_height/2)
		new_layer_node.z_index = i
	# create tiles
	draw_tiles(direction)

func layers() -> Array:
	return get_children()

func set_tiles_in_nodes():
	var joku = get_tree().get_nodes_in_group("tile")
	for i: int in range(0,joku.size()):
		joku[i].tile = field_map.grid.tiles[i]
		joku[i]._ready()

func draw_tiles(dir: Direction = Direction.UP):
	var translated: Vector2i = Vector2i(1,1)
	if !field_map: return
	# clear all the layers
	for l: TileMapLayer in layers():
		l.clear()
		#l.set_cell()
		#l.map_to_local()
		#l.local_to_map()
	# set a cell in their positions
	for tile in field_map.grid.tiles:
		var pos_x = tile.position.x
		var pos_y = tile.position.y
		var pos_z = tile.position.y
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


func _on_spin_box_value_changed(value: float) -> void:
	draw_tiles(round(value) as Direction)


func _on_update_button_pressed() -> void:
	set_tiles_in_nodes()
