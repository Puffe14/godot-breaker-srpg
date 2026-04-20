class_name Combat extends Action

static func roll100() -> int:
	return randi()%100

var selected: Units = null
var targeted: Units = null
var act_range: int = 0
var speed_diff: int = 0
var skill_diff: int = 0
var forecast: Forecast = null
var events: Array[ComFunc] = []
var time_passed: float = 0

@export var select_attacks_start = -1
@export var target_attacks_start = -1
var select_attacks = -1
var target_attacks = -1
@export var no_counter = false
@export var override_vantage = false
@export var hit_penalty_factor = 1
@export var cost = 1
@export var target_part: Constants.BodyPart = Constants.BodyPart.Head
var body_part_text: String = ""

# which methods should be called?
enum Type {Attack, Heal, Treat, Break, Wound}
@export var combat_type: Type
var type_dict = {
	Type.Attack: "attack",
	Type.Heal:  "heal",
	Type.Treat: "treat",
	Type.Break: "shatter",
	Type.Wound: "wound"
}

func copy() -> Combat:
	var new_copy = self.duplicate()
	return new_copy

func recreate(_a: Units = null, _b: Units = null, _act_range: int = 1, _part = Constants.BodyPart.Head) -> Combat:
	var new_copy = copy()
	new_copy._init(_a, _b, _act_range, _part)
	return new_copy

func everyoneLived() -> bool:
	return selected.isAlive() && targeted.isAlive()
func inCounterRange() -> bool:
	var t_wep: Item = targeted.equippedWeapon()
	if t_wep:
		var t_wrange = t_wep.weapon.wrange
		# true only if target's current weapon range includes given range
		return t_wrange.x >= act_range and t_wrange.y <= act_range
	return false

## calculate how many attacks in combat for select
func selectedAttacks() -> int:
	if speed_diff > Rules.doubleDiff: return 2
	else: return 1
## calculate how many attacks in combat for target
func targetedAttacks() -> int:
	if no_counter || !targeted.isArmed(): return 0
	elif speed_diff < -Rules.doubleDiff: return 2
	else: return 1

func _init(_a: Units = null, _b: Units = null, _act_range: int = 1, _part = Constants.BodyPart.Head) -> void:
	if !animate.is_connected(on_animate_sent):
		animate.connect(on_animate_sent)
	time_passed = 0
	selected = _a
	targeted = _b
	act_range = _act_range
	if selected:
		precalculate()

func renit(_a: Units, _b: Units, _act_range: int) -> void:
	selected = _a
	targeted = _b
	act_range = _act_range
	precalculate()

func precalculate() -> void:
	skill_diff = selected.SK() - targeted.SK()
	speed_diff = selected.AS() - targeted.AS()
	select_attacks = select_attacks_start
	target_attacks = target_attacks_start
	if select_attacks==-1: select_attacks = selectedAttacks()
	if target_attacks==-1: target_attacks = targetedAttacks()
	forecast = Forecast.new(selected, targeted, select_attacks, target_attacks, hit_penalty_factor)
	body_part_text = Constants.body_part_to_text(target_part)

func selectedStrikes():
	if !selected.isArmed():
		select_attacks = 0
	else:
		select_attacks -= 1
		events.push_back(ComFunc.new(self, type_dict[combat_type], selected, targeted))
func targetedStrikes():
	if !targeted.isArmed():
		target_attacks = 0
	else:
		target_attacks -= 1
		events.push_back(ComFunc.new(self, type_dict[Type.Attack], targeted, selected))


func play() -> Explain:
	print(selected, " ", type_dict.get(combat_type))
	if !override_vantage and target_attacks > 0 and skill_diff < -Rules.vantageDiff:
		targetedStrikes()
	else:
		selectedStrikes()
	# now continue
	while !events.is_empty():
		var current = events.pop_front()
		current.resolve()
		if !everyoneLived():
			print("death")
			break
		while (select_attacks > 0 || target_attacks > 0):
			if select_attacks > target_attacks:
				selectedStrikes()
			else:
				targetedStrikes()
	stop.emit()
	update.emit(selected, time_passed+1, true)
	update.emit(targeted, time_passed+1, false)
	selected.endTurn()
	return Explain.new("")


## method for the performing attacks
func attack(attacker: Units, defender: Units):
	# if the attack hits
	var hitXcritY = forecast.predictHitCrit(attacker, defender)
	var isHit: bool = roll100() < hitXcritY.x
	emit_signal("animate", "strike", attacker, time_passed)
	if isHit:
		# if a critical hit is rolled
		var isCritical: bool = roll100() < hitXcritY.y
		var damage = forecast.predictDmg(attacker, defender)
		if isCritical: damage *= Rules.critMultiplier
		defender.takeDamage(damage)
		attacker.inventory.equippedWeapon().spend(1)
		emit_signal("animate", "hurt", defender, time_passed+0.5, num_to_str(damage))
		print(defender.character.myName," bam, ",damage,"!")
	else:
		emit_signal("animate", "evade", defender, time_passed+0.5, "Miss!")
		print("miss.")

## method for healing with medkits
func heal(attacker: Units, defender: Units):
	# heal based on HL and medkit.heal
	var healing = attacker.HL() + attacker.inventory.equippedMedkit().medkit.heal
	defender.takeDamage(healing)
	attacker.inventory.equippedWeapon().spend(1)
	print(defender.character.myName," heals, ",healing,"!")

## method for healing with medkits
func treat(attacker: Units, defender: Units):
	# heal the wound
	defender.healWound(target_part)
	attacker.inventory.equippedWeapon().spend(cost)
	print(defender.character.myName," treats, ",target_part,"!")

## method for break attacks
func shatter(attacker: Units, defender: Units):
	# if the break is a success
	var hitXcritY = forecast.predictHitCrit(attacker, defender)
	var isHit: bool = roll100() < hitXcritY.x
	attacker.inventory.equippedWeapon().spend(cost)
	emit_signal("animate", "strike", attacker, time_passed)
	if isHit:
		defender.breakPiece(target_part)
		print(defender.character.myName," breaks ", target_part,"!")
		emit_signal("animate", "hurt", defender, time_passed+0.5, body_part_text+" armor shattered")
	else:
		emit_signal("animate", "evade", defender, time_passed+0.5, "Miss!")
		print("miss.")

## method for break attacks
func wound(attacker: Units, defender: Units):
	# if the break is a success
	var hitXcritY = forecast.predictHitCrit(attacker, defender)
	var isHit: bool = roll100() < hitXcritY.x
	attacker.inventory.equippedWeapon().spend(cost)
	if isHit:
		defender.takeWound(target_part)
		print(defender.character.myName," wounds ", target_part,"!")
		emit_signal("animate", "hurt", defender, time_passed+0.5, body_part_text+" wounded")
	else:
		print("miss.")
		emit_signal("animate", "evade", defender, time_passed+0.5, "Miss!")

func on_animate_sent(_anim: String, _unit: Units, _delay: float, _msg: String = ""):
	time_passed += 1
	actLength = time_passed

func num_to_str(num: int) -> String:
	var msg = ""
	if num < 0: msg += "-"
	else: msg += "-"
	msg += str(num)
	return msg

func sensible() -> bool:
	match combat_type:
		Type.Attack:
			return selected.team != targeted.team
		Type.Heal:
			return selected.team == targeted.team
		Type.Break:
			return selected.team != targeted.team
		Type.Wound:
			return selected.team != targeted.team
		Type.Treat:
			return selected.team == targeted.team
		_:
			return true

func _to_string() -> String:
	return type_dict[combat_type] + ": " + selected.character.myName + "->" + targeted.character.myName
