@abstract
class_name Event extends Resource

var conditions: Array[Condition]

##triggers when the conditions are met
func trigger(fieldMap: FieldMap) -> Array[Action]:
	# check if a condition was met
	var triggered = conditions.any(func(con: Condition):
		return con.met(fieldMap)
	)
	if triggered:
		# removes the met condition
		conditions = conditions.filter(func(con: Condition): return !con.met(fieldMap))
		return [effect(fieldMap)]
	else:
		return []

@abstract
## return an effect on the fieldmap
func effect(fieldMap: FieldMap) -> Action
