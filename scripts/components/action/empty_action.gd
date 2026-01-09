class_name EmptyAction extends Action
func _init():
    explain = Explain.new("Empty Action")
func play() -> Explain:
    return explain