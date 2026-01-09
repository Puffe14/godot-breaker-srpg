class_name GameOver extends Action
func _init():
    explain = Explain.new("Game Over")
func play() -> Explain:
    explain.addDialogue("You've lost.")
    return explain