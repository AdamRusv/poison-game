extends Resource

class_name DialogueBranch

@export var dialogue : Array[Dialogue]

var gameplayManager : GameplayManager

var hasBeenShown : bool = false
var newestDialogueIndex : int = -1

func _check_condition() -> bool:
	if hasBeenShown == true:
		return false
	return true
