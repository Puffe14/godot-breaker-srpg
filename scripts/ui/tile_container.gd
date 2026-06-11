class_name TileContainer extends MarginContainer

@export var title: Label = null
@export var stat_container: Container = null
@export var tile: Tile = null

func _ready(new_tile = null) -> void:
	tile = new_tile
	set_stat()

func set_visibility() -> bool:
	if !(tile) or tile.tile_name == "":
		visible = false
	else: visible = true
	return visible

func set_stat():
	if !set_visibility(): return # stop if not visible
	
	title.text = tile.tile_name
	# remove the previous text labels
	for child_node in stat_container.get_children():
		child_node.queue_free()
	var stat_labels = []
	if tile.occupiable:
		var occ = tile.occupiable
		stat_labels = [
		#	" Atk: "+str(unit.AT()),
		#	" Crit: "+str(unit.CR()),
		#	" Hit: "+str(unit.HI()),
		#	" Speed: "+str(unit.AS()),
		#	" Skill: "+str(unit.SK()),
			" PhysDef: "+str(occ.physical),
		#	" MagicRes: "+str(unit.MD()),
			" Avoid: "+str(occ.avoid),
		#	" CritAvo: "+str(unit.CA())
		]

		#"\n",
		#"stn: "+str(unit.stn()),
		#"mag: "+str(unit.mag()),
		#"skl: "+str(unit.skl()),
		#"spd: "+str(unit.spd()),
		#"def: "+str(unit.dfn()),
		#"res: "+str(unit.res()),
		#"move: "+str(unit.MOVE()),
		#"jump: "+str(unit.JUMP())
	for label_text in stat_labels:
		var new_label: Label = Label.new()
		new_label.text = label_text
		stat_container.add_child(new_label)

#class StatLabel:
#	func _init() -> void:
#		
