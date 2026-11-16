extends Control

class_name CutsceneManager

@export_category("References")
@export var gameplayManager : GameplayManager
@export var playerWalkingManager : PlayingWalkingManager

func _ready() -> void:
	_set_connections()
	_cutscene_finished() #NOTE: remove
func _set_connections():
	pass


#- -
func _cutscene_finished():
	await TransitionManager.transitionEncounter.transitionCutscene.finishedAnimating
	gameplayManager.cutsceneFinished.emit()
