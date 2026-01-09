class_name MapWon extends Action
func _init():
    explain = Explain.new("Game Over")
func play() -> Explain:
    explain.addDialogue("You've Won!")
    return explain