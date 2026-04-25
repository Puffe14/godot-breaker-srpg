class_name Act extends Resource

var unit: Units
var animation: int # AnimationState
var start: int
var end: int
var msg: String = ""

func _init(_unit: Units, _animation: int, _start: int, _end: int, _msg: String = "") -> void:
    unit = _unit
    animation = _animation
    start = _start
    end = _end
    msg = _msg

func actor(): return unit
func frame(): return animation
func done(time: int) -> bool: return time > end
func show(time: int) -> bool: return time > start
#  override func toString = unit.name + ": " + animation.toString + " at " + end
