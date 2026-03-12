class_name AI extends Resource

var game: Game = null
var currentGroup: Group = null
var groupsLeft: Array[Group] = []
var currentUnit: Units = null

func set_game(_game: Game = null) -> void:
	game = _game

## Called to make the AI act and continue going through groups*/
func play():
	#if (currentGroup and currentGroup.doneActing) and !groupsLeft.is_empty():
	#	currentGroup = nextGroup()
	#if currentGroup and currentGroup.doneActing():
	#	currentGroup = null
	if currentGroup.haveNotActed().size() < 1:
		print("no have not acted in group")
		currentGroup = null
	if currentGroup:                                       
		continue_group(currentGroup)
	print("ai out")

  ## Gives a random item [T] from a collection.*/
#func randomFrom[T, C[T] <: collection.Seq[T]](thingCollection: C[T]): T =
#    var number = Random().nextInt(thingCollection.length)
#    thingCollection(number)

  ## The AI finds the best possible actions for the members of the current group*/
#func bestMemberActions(g: Group): Vector[Action] =
#    for m <- g.haveNotActed yield
#      unitBestAction(m)

  ## Selects best action of the entire group*/
#func selectNextAction(g: Group): Option[Action] =
#    var find: Option[Action] = None
#    val actions = bestMemberActions(g)
#    val combats = actions.collect { case a: Combat => a }
#    val breaks = actions.collect { case a: Break => a }
#    val wounds = actions.collect { case a: Wound => a }
#    val treats = actions.collect { case a: Treat => a }
#    # PRIORITIZE SKILLS
#    # wound if available
#    find = wounds.maxByOption(c=>c.forecast.aHit)
#    # break if available
#    find = breaks.maxByOption(c=>c.forecast.aHit)
#    # treat the one with most wounds
#    find = treats.maxByOption(c=>c.target.wounds.size)
#    # otherwise pick a high value attack
#    if find.nonEmpty && combats.nonEmpty:
#      find = Some(combats.maxBy(c=>c.forecast.aEV))
#    # or just whatever that is left
#    else find = actions.headOption
#    find


  ## Adds Groups next action to the action queue of the game.*/
func continue_group(g: Group):
	var actAndGo: Array[Action] = []
	#match selectNextAction(g):
	#  case Some(c: Combat) =>
	#    game.move(c.select) match
	#      #  In case the character needs to move
	#      case Some(move) =>
	#        move.location = c.location
	#        Vector(move, c)
	#      #  If no movement takes place
	#      case _ => Vector(c)
	#  case Some(a: Action) =>
	#    Vector(a)
	#  case _ => Vector()
	var actor = g.haveNotActed().pop_front()
	actAndGo.push_back(unitBestAction(actor))
	addToQueue(actAndGo, actor)

  

# !!! could I add a way to track action priority based on if hp is critical or so on?
### Checks the best action for a unit*/
func unitBestAction(u: Units) -> Action:
	return game.availableActions(u, true).filter(func(n): return n.sensible()).pop_front()
#    var chosen: Vector[Action] = Vector()
#    #  equip the first weapon&medkit, all armor in inventory
#    u.equipFirst()
#    val canMove = currentGroup.forall(_.behaviour!=Stand) && u.canMove
#    val availableActions = game.availableActions(u, canMove)
#    # all possible combat scenarios
#    val combats = availableActions
#                      .collect { case a: Combat => a }
#    # attacks on enemies
#    val attacks = combats.filterNot(_.isInstanceOf[Heal]).filterNot(_.isInstanceOf[Treat])
#                      .filter(_.target.team != u.team)
#                      .filter(u.team!=Team.Ally || _.target.team != Team.Player)
#    # healing teammates
#    val heals =    combats.collect { case a: Heal => a }
#                      .filter(_.target.team == u.team)
#                      .filter(_.target.damageTaken!=0)
#    # treating teammates
#    val treats = availableActions.collect { case a: Treat => a }
#                      .filter(_.target.team == u.team)
#    # use items on self
#    val uses = availableActions.collect { case a: Use => a }
#    # wound an enemy
#    val wounds = attacks.collect { case a: Wound => a }
#      .filter(_.target.wounds.isEmpty) # if the target doesn't have any wounds
#      .filter(_.target.lvl>u.lvl)       # only attack dangerous enemies
#    # break enemy armor
#    val breaks = attacks.collect { case a: Break => a }
#    # combine actions to a total vector of actions
#    val sensibleActions = attacks ++ heals ++ uses
#
#    # Select a random sensible action
#    val action =
#      if currentGroup.forall(_.behaviour == Behaviour.Erratic):
#        randomFrom(sensibleActions)
#      # Treat the highest level member of the group
#      elif treats.nonEmpty:
#        treats.maxBy(_.target.lvl)
#      # Select the best break attack by hitrate
#      elif breaks.nonEmpty:
#        breaks.maxBy(_.forecast.aHit)
#      # or the best wound attack by hitrate
#      elif wounds.nonEmpty:
#        wounds.maxBy(_.forecast.aHit)
#      # the attacks the one that will deal the most damage
#      elif attacks.nonEmpty:
#        attacks.maxBy(n => n.forecast.aEV*3 - n.forecast.bEV)
#      # the heals the one who is most hurt
#      elif heals.nonEmpty:
#        heals.maxBy(_.select.damageTaken)
#      # consume an item if hurt !!!(doesn't consider if it heals or not)
#      elif uses.nonEmpty && u.damageTaken != 0:
#        uses.head
#      # Nothing to do? End turn and wait.
#      else
#        Wait(u)
#    # Equip the necessary item for the action
#    action.weapon.foreach(u.equip(_))
#    action
#
  ##  Add action to the stack of the game. */
func addToQueue(actions: Array[Action], actor: Units):
	for act in actions:
		game.add_to_queue(act, actor)


func nextGroup():
	currentGroup = groupsLeft.pop_back()

#func checkGroupCondition() = ()
#
#func bStand = currentGroup.forall(_.behaviour==Stand)
#func bOnSight = currentGroup.forall(_.behaviour==OnSight)
