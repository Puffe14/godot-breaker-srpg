class_name Game extends Resource

# Map in question
var currentMapNumber: int = 1
var currentMap: FieldMap = null
var midBattle: bool = false
var changeMap: bool = false
# Who is doing what to whom?
var turnOf: Units.Team = Units.Team.Player
var player: Organisation = null
var acting: Units = null
var target: Units = null
var inspected: Units = null
var deepInspect = false
var bout: Combat = null
var forecast: Forecast = null
var part: Constants.BodyPart = Constants.BodyPart.Head
var stack: Array[Action] = []
