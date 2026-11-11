extends DialogueBranch

class_name DialogueBranchCups

@export var isSolution : bool = false

func _check_condition() -> bool:
	if gameplayManager.correctCupChosen == isSolution:
		return true
	return false
