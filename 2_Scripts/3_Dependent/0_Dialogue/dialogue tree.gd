extends Resource

class_name DialogueTree

@export var branches : Array[DialogueBranch]

func _get_current_branch() -> DialogueBranch:
	for branch in branches:
		if branch._check_condition() == true && branch.hasBeenShown == false:
			return branch
	return null

func _get_new_dialogue() -> Dialogue:
	var currentbranch : DialogueBranch = _get_current_branch()
	
	currentbranch.newestDialogueIndex += 1
	
	return currentbranch.dialogue[currentbranch.newestDialogueIndex]

func _get_newest_dialogue() -> Dialogue:
	var currentbranch : DialogueBranch = _get_current_branch()
	
	return currentbranch.dialogue[currentbranch.newestDialogueIndex]
