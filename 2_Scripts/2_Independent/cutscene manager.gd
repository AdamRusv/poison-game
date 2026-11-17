extends Control

class_name CutsceneManager

@export_category("References")
@export var gameplayManager : GameplayManager
@export var playerWalkingManager : PlayingWalkingManager

var currentCutscene : Cutscene

func _ready() -> void:
	_set_connections()
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_start_cutscene()
func _set_connections():
	pass
func _start_cutscene():
	await TransitionManager.transitionEncounter.transitionCutscene.finishedAnimating
	if _is_cutscene_on_this_encounter() == false:
		_cutscene_finished()
		return
	
	var currentTimelineIndex : int = gameplayManager.gamestateJSON.timelineIndex
	currentCutscene = gameplayManager.gameTimeline.timeline[currentTimelineIndex].cutscene
	if currentCutscene is PassPaperCutscene:
		playerWalkingManager._pass_paper_cutscene(currentCutscene, currentCutscene.walkDirection)
	
	
	await playerWalkingManager.finishedMovement
	_cutscene_finished()

#- -
func _cutscene_finished():
	gameplayManager.cutsceneFinished.emit()

#---------------
func _is_cutscene_on_this_encounter() -> bool:
	var currentTimelineIndex : int = gameplayManager.gamestateJSON.timelineIndex
	var currentRegionEncounter : int = gameplayManager.gamestateJSON.currentRegionEncounterCount
	var currentEncounterCutscene : Cutscene = gameplayManager.gameTimeline.timeline[currentTimelineIndex].cutscene
	if currentEncounterCutscene != null:
		if currentEncounterCutscene.showAtRegionEncounter == currentRegionEncounter:
			return true
	return false
