extends MarginContainer

@export var title: Label = null
@export var stat_container: HFlowContainer = null
@export var stats: Stats = null

func _ready(new_stat: Stats = null) -> void:
	if new_stat:
		stats = new_stat
	set_stat()

func set_stat():
	for child_node in stat_container.get_children():
		child_node.queue_free()
	var stat_labels = [
		"stn: "+str(stats.stn),
		"mag: "+str(stats.mag),
		"skl: "+str(stats.skl),
		"spd: "+str(stats.spd),
		"def: "+str(stats.dfn),
		"res: "+str(stats.res),
		"move: "+str(stats.move),
		"jump: "+str(stats.jump)
	]
	for label_text in stat_labels:
		var new_label: Label = Label.new()
		new_label.text = label_text
		stat_container.add_child(new_label)

#class StatLabel:
#	func _init() -> void:
#		
