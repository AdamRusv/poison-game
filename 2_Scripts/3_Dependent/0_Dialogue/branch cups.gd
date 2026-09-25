extends DialogueBranch

class_name DialogueBranchCups

@export var cupPlacement : GameplayManager.CurrentPoisonCup = GameplayManager.CurrentPoisonCup.opponent

func _check_condition() -> bool:
	if gameplayManager.currentPoisonCup == cupPlacement:
		return true
	return false
