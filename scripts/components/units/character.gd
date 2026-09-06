class_name Character extends Resource

@export var myName: String
@export var myClass: Class
@export var possibleClass: Array # Vector[Class]
@export var level: int = 1
@export var xp: int = 0
@export var growths: Stats
@export var stats: Stats
@export var picture_name = "guy"

func swapClass(newClass: Class):
	myClass = newClass

#!!! could be changed to an event that give message as a legible string
## Increase experience and handle if reaches lvlup
func expTrack(increase: int) -> Array:
	var message: Array = [myName + " gained "+str(increase)+" exp, now "+str(xp+increase)]
	xp += increase
	@warning_ignore("integer_division")
	var howManyLvlsUp = xp/100
	if howManyLvlsUp > 0:
		level += 1
		message.push_back(" LEVEL UP\n")
		for i in range(0, howManyLvlsUp):
			var lup = levelUp()
			for key in lup:
				message.push_back(statPointStr(key, lup[key], key == lup.keys().front()))
		xp = xp % 100
	return message

## Rolls growths for level-ups and collects them for display
func levelUp() -> Dictionary:
	var levelUpsMap = {}
	var leveled = growths
	for stat in Stats.level_up_keys:
		var currentG = leveled.get_a_val(stat)
		if roll() < currentG:
			var up = round(currentG-1)/100 + 1
			levelUpsMap[stat] = up
			addToStat(stat, up)
	return levelUpsMap

## adds int to a stat
func addToStat(which: String, amount: int):
	#Calculates the new total stat and changes stats map to reflect change
	stats.add_a_val(which,amount)
	var newTotal = stats.get_a_val(which)
	return newTotal

static func roll(): return randi()%100

static func statPointStr(k, v, first = false, seperator = ", "):
	if first:
		return str(k)+": "+str(v)
	else:
		return seperator+str(k)+": "+str(v)
