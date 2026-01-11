class_name Combat extends Resource

static func roll100() -> int:
    return randi()%100

var selected: Units = null
var targeted: Units = null
var forecast: Forecast = null

func _init(_a: Units, _b: Units) -> void:
    selected = _a
    targeted = _b
    Forecast.new(selected, targeted, 1, 1)