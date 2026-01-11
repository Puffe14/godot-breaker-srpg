extends Node
@export var timer: Timer = null


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
	var forecast: Forecast = Forecast.new(a.unit, b.unit, 2, 1, -15, 15)
	print(forecast.aEV, forecast.arrow(), forecast.bEV)
