class_name Forecast extends Resource
## MISSING EFECTIVENSS AND ADVANTAGE
var a: Units
var b: Units
var aAtkNum: int
var bAtkNum: int
var skillDif: int
var speedDif: int
var hitPenalty: int

var rules = Rules.new()

# Provides all calculated results for outside use.
func _init(_a: Units, _b: Units, _aAtkNum: int, _bAtkNum: int, _skillDif: int, _speedDif: int, _hitPenalty: int = 1) -> void:
	a = _a
	b = _b
	aAtkNum = _aAtkNum
	bAtkNum = _bAtkNum
	skillDif = _skillDif
	speedDif = _speedDif
	hitPenalty = _hitPenalty
	# predicted dmg
	aDmg = predictDmg(a, b)
	bDmg = predictDmg(b, a)
	# total hit and crit rate
	aHitCrit = predictHitCrit(a, b)
	aHit = aHitCrit.x
	aCrit = aHitCrit.y
	bHitCrit = predictHitCrit(b, a)
	bHit = bHitCrit.x
	bCrit = bHitCrit.y
	# the number of attacks including quick doubles
	aAtks = predictAtks(a)
	bAtks = predictAtks(b)
	# TOTAL dmg
	aTotal = aDmg * aAtks
	bTotal = bDmg * bAtks
	# Hidden expected varue calculation, for AI (Let players make decisions, no value judgements)
	aEV = EV(aDmg, aHit, aCrit, aAtks)
	bEV = EV(bDmg, bHit, bCrit, bAtks)


# predicted dmg
var aDmg = 0
var bDmg = 0
# total hit and crit rate
var aHitCrit = 0
var aHit = 0
var aCrit = 0
var bHitCrit = 0
var bHit = 0
var bCrit = 0
# the number of attacks including quick doubles
var aAtks = 0
var bAtks = 0
# TOTAL dmg
var aTotal = 0
var bTotal = 0
# Hidden expected varue calculation, for AI (Let players make decisions, no value judgements)
var aEV = 0
var bEV = 0

# the direction of attacks
func arrow() -> String:
	if skillDif < -rules.vantageDiff && bAtkNum > 0:
		return "<-"
	elif speedDif > rules.alacrityDiff:
		return "->->"
	else:
		return "->"

## Estimated value for attacks. dmg is already calculated
func EV(dmg: int, hit: int, crit: int, times: int) -> float:
	var total = 0.0
	var dhit = hit/100.0
	var dcrit = crit/100.0
	var notcrit = 1 - dcrit
	# not critting possibilities
	total += notcrit*dmg
	# critting
	total += dcrit*dmg * rules.critMultiplier
	# hitting
	total *= dhit
	# damage hits or crits * chance for either * times executed
	return total*times

func predictAtks(unit: Units):
	var strikes = 0
	if unit.isQuick(): strikes = 2
	else: strikes = 1
	if unit == a:
		return aAtkNum*strikes
	elif unit == b:
		return bAtkNum*strikes
	else: return 0

func predictDmg(attacker: Units, defender: Units) -> int:
	var damage = 0
	var weapon = attacker.inventory.equippedWeapon()
	if weapon:
		# if the attackers weapon has an effectiveness against defenders type
		var isEffective = false #defender.types.has(weapon.effective.has(_))
		## TODO EFFECTIVENESS
		if weapon.weapon.dmgType == Weapon.DamageType.Force:
			damage = maxi(attacker.AT() - defender.PD(), 0)
		elif weapon.weapon.dmgType == Weapon.DamageType.Magic:
			damage = maxi(attacker.AT() - defender.MD(), 0)
		if isEffective: damage *= rules.effectiveMultipllier
	return damage

func predictHitCrit(attacker: Units, defender: Units) -> Vector2i:
	var hit = 0
	var crit = 0
	# only penalize hit for being a skill if its unit-a being predicted
	var penalizedHit: int = 0
	if hitPenalty!=1 and attacker == a:
		@warning_ignore("integer_division")
		penalizedHit = attacker.HI() / hitPenalty
	else: penalizedHit = attacker.HI()
	## TODO advantage
	hit  = mini(maxi(penalizedHit - defender.AV(), 0), 100) ##+ advantage(attacker, defender), 0), 100)
	crit = mini(maxi(attacker.CR() - defender.CA(), 0), 100)
	
	return Vector2i(hit, crit)
