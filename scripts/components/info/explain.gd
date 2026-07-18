class_name Explain extends Resource

var series: Array = [] # Vector[AniSeries]
var acts: Array = [] # Vector[Act]
var lines: Array = [] # Vector[Dialogue]
var lineNumber: int = 0
var totalTime = 0
var name: String

func _init(_name: String):
	name = _name

## Create a new act and add it to the list
## without/with a message
func addAnimation(unit: Units, animation: AnimationState, time: int, message: String = "") -> void:
	var start = totalTime
	totalTime += time
	acts.push_back(Act.new(unit, animation, start, totalTime, message))

## Create a new dialogue and add it to the list
func addDialogue(line: String = "", title: String = "", pic_title: String = "") -> void: # , face: Image) -> void:
	lines.push_front(Dialogue.new(line, title, pic_title))

## returns the current dialogue
func dialogue() -> Dialogue:
	return lines[lineNumber]

## Advance dialogue if there is some left. Return false if not.
func advanceDialogue() -> bool:
	# only increase the linen number if there are lines left to see
	if dialogueNotOver():
		lineNumber += 1
		return true
	else:
		return false

func dialogueNotOver() -> bool:
	return !lines.is_empty() && lineNumber < lines.size()

func skipDialogue() -> void:
	lineNumber = lines.size()


############



#class AniSeries(val unit: Units):
#  val animations: Vector[AnimationState] = Vector()
#  override func toString = unit.name + ": " + animations.mkString(", ")

enum AnimationState {
  Attack, Critical, Evade, Miss, Hurt, Idle, Stance
}
