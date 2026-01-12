extends Node
@export var timer: Timer = null
@export var combat: Combat = null

func _process(_delta: float) -> void:
	for u in $FightSelector.units:
		u.visible = false
	var a = $FightSelector.unitA()
	var b = $FightSelector.unitB()
	a.visible = true
	b.visible = true

func _ready() -> void:
	$FightSelector.refresh()

func _on_test_timer_timeout() -> void:
	var a = $FightSelector.unitA()
	var b = $FightSelector.unitB()
	if a: a.strike()
	if b: b.strike()
	a.unit.damageTaken = 0
	b.unit.damageTaken = 0
	combat.renit(a.unit, b.unit, 1)
	var forecast = combat.forecast
	print(forecast.aEV, forecast.arrow(), forecast.bEV)
	combat.play()
