@abstract
class_name Action extends Resource
# nullable tile
var location = null
# nullable weapon
var weapon = null
# length of an action
var actLength: float = 1.0
# explain
var explain = Explain.new("")
# play out the effects of the given function
@abstract
func play() -> Explain
