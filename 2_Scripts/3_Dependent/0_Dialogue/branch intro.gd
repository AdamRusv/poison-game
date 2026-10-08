extends DialogueBranch

class_name DialogueBranchIntro

func _check_condition() -> bool:
	if gameplayManager.cupIsPoisoned == true:
		return false
	return true
