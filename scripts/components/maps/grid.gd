class_name Grid extends Resource

@export var tiles: Array[Tile] = []
@export var row: int
@export var column: int

func get_tile(x: int, y: int) -> Tile:
	var atPos = x + y*row
	if x>=0 && y>=0 && x < row && y < column:
		return tiles[atPos]
	else:
		return null

func get_tile_v(v: Vector2i) -> Tile:
	#return get_tile(v.x, v.y)
	var found = null
	for t in tiles:
		if t.position.x == v.x and t.position.y == v.y:
			found = t
	return found


#func tileAt(x: Int, y: Int): Option[Tile] =
#    val atPos = x + y*row
#    if x>=0 && y>=0 && x < row && y < column then
#     Some(tiles(atPos))
#    else None

#func givePositionToTiles()
#    var i = 0
#    if tiles.size == elevation.size then
#      while i < row*column do
#        tiles(i).setPos(i%row, i/row, elevation(i))
#        i+=1
#    else
#      println("Incorrect size of elevation vector.")

func occupiables() -> Array[Tile]:
	return tiles.filter(func(t: Tile): return t.occupiable!=null)

## array of tiles with non null occupiables
func tilesWithUnits() -> Array[Tile]:
	return occupiables().filter(func(t:Tile): return t.occupiable.occupant!=null)
	
func unitsOnTiles() -> Array[Units]:
	return tilesWithUnits().map(func(t:Tile): return t.occupiable.occupant)

func unitsFromTiles(tileList: Array[Tile]) -> Array:#[Units]:
	var temp = tileList.filter(func(t: Tile): return t.occupiable!=null)
	temp = temp.filter(func(t:Tile): return t.occupiable.occupant!=null)
	return temp.map(func(t:Tile): return t.occupiable.occupant)

func addUnitAt(unit: Units, coords: Vector2i):
	var tile = get_tile_v(coords)
	var o = tile.occupiable
	if o: o.addOccupant(unit)
	else: print("cannot be occupied")

func neighbor(v: Vector2i, nv: Vector2i) -> bool:
	return (v == nv+Vector2i.UP or
	 v == nv+Vector2i.DOWN or
	 v == nv+Vector2i.RIGHT or
	 v == nv+Vector2i.LEFT)

func neighbors(chosenTile: Tile) -> Array[Tile]:
	var x = chosenTile.position.x
	var y = chosenTile.position.y
	var total = tiles.filter(func(n):
		var trueness: bool = neighbor(Vector2i(x,y), Vector2i(n.position.x, n.position.y))
		return trueness
		)
	return total

#func visibleTiles(direction: int) -> Array[Tile] =
#    tiles.filter(func(t: Tile): tileHidden(t, direction))

#func tileInFront(tile: Tile, dir: Int): Option[Tile] =
#    val (x, y, z) = tile.pos
#         if dir == 0 then tileAt(x+1, y+1)
#    else if dir == 1 then tileAt(x+1, y-1)
#    else if dir == 2 then tileAt(x-1, y-1)
#    else if dir == 3 then tileAt(x-1, y+1)
#    else None

#func tileHidden(tile: Tile, dir: Int): Boolean =
#    tileInFront(tile, dir).forall(
#      t => t.pos(2) > tile.pos(2) + 2
#    )

## positive means that it requires JUMP, negative might be used for something
func elevationDifference(elevation: int, tile: Tile) -> int:
	return tile.position.z - elevation

func tile_elevation_difference(tile_one: Tile, tile_two: Tile) -> int:
	return elevationDifference(tile_one.position.z, tile_two)

## distance of tiles a to b based on their x and y
func tileDistance(a: Tile, b: Tile) -> int:
	return (abs(a.position.x-b.position.x)+abs(a.position.y-b.position.y))

func tileInRangeFrom(tile: Tile, trange: int, ignore_elevation: bool = false) -> Array[Tile]:
	return tiles.filter(func(t:Tile):
		var is_elevation_ok = ignore_elevation
		# no need to check appropriate elevation if it can be ignored
		if not ignore_elevation:
			var elevation_diff = 0
			elevation_diff = tile_elevation_difference(tile, t)
			is_elevation_ok = elevation_diff <= Rules.attack_height_up_max and elevation_diff >= -Rules.attack_height_down_max
		return tileDistance(t,tile)==trange and is_elevation_ok
	)
	
