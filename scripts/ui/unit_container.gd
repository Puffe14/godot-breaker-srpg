class_name UnitContainer extends MarginContainer

@export var title: Label = null
@export var stat_container: Container = null
@export var unit: Units = null

func _ready(new_unit = null) -> void:
	unit = new_unit
	set_stat()

func set_visibility() -> bool:
	if !(unit):
		visible = false
	else: visible = true
	return visible

func set_stat():
	if !set_visibility(): return # stop if not visible
	
	title.text = unit.shortInfo()
	for child_node in stat_container.get_children():
		child_node.queue_free()
	var stat_labels = [
		" Atk: "+str(unit.AT()),
		" Crit: "+str(unit.CR()),
		" Hit: "+str(unit.HI()),
		" Speed: "+str(unit.AS()),
		" Skill: "+str(unit.SK()),
		" PhysDef: "+str(unit.PD()),
		" MagicRes: "+str(unit.MD()),
		" Avoid: "+str(unit.AV()),
		" CritAvo: "+str(unit.CA()),
		" Move: "+str(unit.MOVE()),
		" Jump: "+str(unit.JUMP())
	]
		#"\n",
		#"stn: "+str(unit.stn()),
		#"mag: "+str(unit.mag()),
		#"skl: "+str(unit.skl()),
		#"spd: "+str(unit.spd()),
		#"def: "+str(unit.dfn()),
		#"res: "+str(unit.res()),
		#move: "+str(unit.move()),
		#jump: "+str(unit.jump())
	for label_text in stat_labels:
		var new_label: Label = Label.new()
		new_label.text = label_text
		stat_container.add_child(new_label)

#class StatLabel:
#	func _init() -> void:
#		
