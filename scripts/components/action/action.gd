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
# closes menu node when processed
var closes_menu = true

var delay = 0

# universal signals
signal move(location: Tile, unit: Units, delay: float)
signal animate(anim: String, unit: Units, delay: float)
signal update(unit: Units, delay: float, dim: bool)
signal stop

## play out the effects of the given function
@abstract
func play() -> Explain

## False for actions that are directly detrimental.
## Example: attack other team -> true, attack self -> false
func sensible() -> bool:
	return true
