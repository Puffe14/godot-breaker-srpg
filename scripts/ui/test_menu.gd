extends Node
@export var timer: Timer = null
@export var combat: Combat = null
var popup_text: PackedScene = preload("res://nodes/popup_text.tscn")

func _process(_delta: float) -> void:
	for u in $FightSelector.units:
		u.visible = false
	var a = $FightSelector.unitA()
	var b = $FightSelector.unitB()
	a.visible = true
	b.visible = true

func _ready() -> void:
	$FightSelector.refresh()
	combat.animate.connect(animate)

func _on_test_timer_timeout() -> void:
	var a = $FightSelector.unitA()
	var b = $FightSelector.unitB()
	#if a: a.strike()
	#if b: b.strike()
	a.unit.damageTaken = 0
	b.unit.damageTaken = 0
	combat.renit(a.unit, b.unit, 1)
	var forecast = combat.forecast
	print(forecast.aEV, forecast.arrow(), forecast.bEV)
	combat.play()

func animate(animation: String, unit: Units, delay: float, msg: String = ""):
	for u in get_tree().get_nodes_in_group("unit"):
		if u.unit == unit:
			u.play_animation(animation, delay, msg)
	
