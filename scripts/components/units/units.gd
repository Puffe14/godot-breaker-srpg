class_name Units extends Resource

enum Team {Player, Ally, Enemy}

@export var character: Character = null
@export var inventory: Inventory = Inventory.new(6)

@export var leader: Units = null
@export var damageTaken: int = 0
@export var wounds: Array[Constants.BodyPart] = [] # Array[Part]
@export var status: Array[Constants.Status] = [] # Array[Status]
@export var location_bonus: CombatBonus = CombatBonus.new()
@export var temporaryStats: Stats = Stats.new()
@export var nearbyBonuses: Stats = Stats.new()
@export var team: Team = Team.Player

@export var moved = false
@export var acted = false

func _to_string() -> String:
	return character.myName + " " + hpMhp()

# whether or not a unit has particular abilities
func canHeal() -> bool:
	return character.myClass.classType.has("healer")
func canBreak() -> bool:
	return character.myClass.classType.has("breaker")
func canWound() -> bool:
	return character.myClass.classType.has("wounder")
func canFlies() -> bool:
	return character.myClass.classType.has("flier")
func canTakeSouls() -> bool:
	return character.myClass.classType.has("mystic")

# setters
func _init(_character: Character, _inventory):
	character = _character
	inventory = _inventory
func setTeam(newTeam: Team): team = newTeam
func setLeader(newLeader: Units): leader = newLeader

func copy() -> Units:
	return Units.new(character.duplicate(true), inventory.duplicate(true))

## Check if the unit has been killed.
func isDead(): return !isAlive()
func isAlive(): return HP() > 0

func giveExp(gained:int) -> String:
	var msg = ""
	for string in character.expTrack(gained):
		msg += string
	return msg

# turn handling #
func endTurn():
	moved = true
	acted = true
func cancelMove():
	moved = false
func moves():
	moved = true
func refresh():
	moved = false
	acted = false
func turnOver() -> bool: return acted
func moveOver() -> bool: return moved

func canMove() -> bool: return !status.has(Constants.Status.Stunned)
func stun(): takeStatus(Constants.Status.Stunned)
func unstun(): healStatus(Constants.Status.Stunned)

# Hurt or Heal #

func takeDamage(amount: int, lethal: bool = true):
	damageTaken += amount
	limitHP(lethal)

func healDamage(amount: int):
	damageTaken -= amount
	limitHP()

func limitHP(lethal: bool = true):
	if damageTaken > MaxHP():
		if lethal:
			damageTaken = MaxHP()
		else:
			damageTaken = MaxHP() - 1
	if damageTaken < 0:
		damageTaken = 0

func breakArmor(piece: Item):
	piece.armor.shatter()
	inventory.clean()

func breakPiece(part: Constants.BodyPart):
	for item in inventory.equippedArmors():
		if item.armor.part == part:
			breakArmor(item)

func reduceTemporary():
	## TODO
	pass

func woundableParts() -> Array:
	var total: Array = []
	var breaks = breakableParts()
	for part in Constants.parts:
		if !breaks.has(part) and !wounds.has(part):
			total.push_back(part)
	return total
func breakableParts() -> Array:
	return inventory.armors().map(func(a): return a.armor.part)
func takeWound(wound: Constants.BodyPart):
	wounds.push_back(wound)
func healWound(wound: Constants.BodyPart):
	wounds.erase(wound)

func takeStatus(effect: Constants.Status):
	status.push_back(effect)
func healStatus(effect: Constants.Status):
	status.erase(effect)
func hasStatus(effect: Constants.Status) -> bool:
	return status.has(effect)


# item and loot interactions #

func useItem(item: Item):
	item.consumable.use(self)
	if item.durability:
		item.spend(1)
	inventory.clean()

func equip(item: Item, toggle = false):
	if item.weapon:
		inventory.equipWeapon(item, toggle)
	elif item.medkit:
		inventory.equipMedkit(item, toggle)
	elif item.armor:
		inventory.equipArmor(item, toggle)

func toggleEquip(item: Item):
	equip(item, true)

func equipFirst():
	for item: Item in inventory.slots:
		if item != null:
			equip(item)

func discard(item: Item):
	inventory.remove(item)

func loot() -> Inventory:
	if !inventory.empty():
		return inventory.toLoot()
	else:
		return null

func usable_weapons() -> Array:
	return inventory.weapons().filter(func(item:Item):
		return true
		#TODO item.weapon.rankLetter
	)

func usable_medkits() -> Array:
	return inventory.medkits().filter(func(item:Item):
		return true
		#TODO item.weapon.rankLetter
	)

## Totals together all bonuses given to a particular stat.
func bonus(_stat: String) -> int:
	var total = 0
	for item: Item in inventory.slots:
		if item and item.equipped():
			if item.weapon and item.weapon.stats:
				total += item.weapon.stats.get_a_val(_stat)
			if item.armor and item.armor.stats:
				total += item.armor.stats.get_a_val(_stat)
	total += location_bonus.get_a_val(_stat)
	total += temporaryStats.get_a_val(_stat)
	total += nearbyBonuses.get_a_val(_stat)
	return total

# effective stats totals
func hp():
	return character.stats.maxHp + character.myClass.stats.maxHp + bonus("hitpoints")
func stn():
	return character.stats.stn + character.myClass.stats.stn + bonus("strength")
func mag(): 
	return character.stats.mag + character.myClass.stats.mag + bonus("magic")
func skl(): 
	return character.stats.skl + character.myClass.stats.skl + bonus("skill")
func spd(): 
	return character.stats.spd + character.myClass.stats.spd + bonus("speed")
func dfn(): 
	return character.stats.dfn + character.myClass.stats.dfn + bonus("defence")
func res(): 
	return character.stats.res + character.myClass.stats.res + bonus("resistance")


# Unit combat stats #
 # Current and max HP
func MaxHP() -> int: return hp()
func HP() -> int: return MaxHP() - damageTaken

# Move
func MOVE() -> int:
	var penalty = 1
	if wounds.has(Constants.BodyPart.Legs): penalty = 3
	return (character.myClass.stats.move + bonus("move")) / penalty
# Jump
func JUMP() -> int:
	var penalty = 1
	if wounds.has(Constants.BodyPart.Legs): penalty = 3
	return (character.myClass.stats.jump + bonus("jump")) / penalty
# Range
func Range() -> Vector2i:
	var bonusRange = 0 ##TODO bonus range feature
	if inventory.equippedWeapon():
		var wrange = inventory.equippedWeapon().weapon.wrange
		return Vector2i(wrange.x, wrange.y + bonusRange)
	else: return Vector2i(0,0)
func MedRange() -> Vector2i:
	var bonusRange = 0 ##TODO bonus range feature
	if inventory.equippedMedkit():
		var wrange = inventory.equippedMedkit().medkit.wrange
		return Vector2i(wrange.x, wrange.y + bonusRange)
	else: return Vector2i(0,0)

## Attack depends on if weapon is magical or physical
func AT() -> int:
	var wep = inventory.equippedWeapon()
	if !wep: return 0
	if wep.weapon.dmgType == Weapon.DamageType.Magic:
		return wep.weapon.power + mag() + bonus("AT")
	elif wep.weapon.dmgType == Weapon.DamageType.Force:
		var penalty = 1
		if wounds.has(Constants.BodyPart.Arms): penalty = 2
		return (wep.weapon.power + stn() + bonus("AT")) / penalty
	else: return 0

## Rate of critical hits
func CR() -> int:
	var wep = inventory.equippedWeapon()
	if !wep: return 0
	else: return round(wep.weapon.crit + skl() * 0.5) + bonus("CR")

## Attack speed: Total speed - weight
func AS() -> int:
	var wep = inventory.equippedWeapon()
	if !wep: return 0
	else: return spd() - wep.weapon.weight + bonus("AS")

## Combat skill
func SK() -> int:
	var wep = inventory.equippedWeapon()
	if !wep: return 0
	else: return skl() - wep.weapon.weight/3 + bonus("SK")

## Physical funcence
func PD() -> int:
	var penalty = 1
	if wounds.has(Constants.BodyPart.Torso): penalty = 2
	return round(dfn() + bonus("PD")) / penalty

## Magical funcence
func MD() -> int:
	var penalty = 1
	if wounds.has(Constants.BodyPart.Torso): penalty = 2
	return round(res() + bonus("MD")) / penalty

## Hit rate
func HI() -> int:
	var wep = inventory.equippedWeapon()
	if !wep: return 0
	var penalty = 1
	if wounds.has(Constants.BodyPart.Head): penalty = 2
	return round(wep.weapon.hit + (skl() + spd()*0.5) + bonus("HI")) / penalty

## Rate of avoiding attacks
func AV() -> int:
	var penalty = 1
	if wounds.has(Constants.BodyPart.Legs): penalty = 2
	return (round(spd() + skl()*0.5) + bonus("AV")) / penalty

## Rate of avoiding critical hits
func CA() -> int:
	var wep = inventory.equippedWeapon()
	if !wep: return 0
	return 10 - wep.weapon.weight + bonus("CA")

## Amount of healing given
func HL() -> int:
	return mag()/2 + skl()/2

func isQuick() -> bool:
	var w: Item = inventory.equippedWeapon()
	if w and w.weapon.isQuick():
		return true
	else: return false

func isArmed() -> bool:
	return inventory.equippedWeapon() != null and inventory.equippedWeapon().intact()

func shortInfo() -> String:
	var wpn_text = "none"
	if inventory.equippedWeapon():
		wpn_text = inventory.equippedWeapon().name
	return character.myName + " " + str(HP())+"/"+str(MaxHP())+"\n" + " Weapon: "+ wpn_text

func hpMhp() -> String: return str(HP())+"/"+str(MaxHP())
func lvl() -> int: return character.level
func xp() -> int: return character.xp
func lvlExp() -> String: return "LVL: "+str(lvl())+", EXP: "+str(xp())
