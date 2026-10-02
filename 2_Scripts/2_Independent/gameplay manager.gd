extends Control

class_name GameplayManager

@export var gameTimeline : GameTimeline

var playmatManager : PlaymatManager
var poisonManager : PoisonManager
var cupsManager : CupsManager
var dialogueManager : DialogueManager

var cupCount : int = 2 #NOTE: change for other gamemodes

var holdingPoison : bool = false
signal poisonGrabbed
signal poisonReleased
var cupIsPoisoned : bool = false
signal cupHasBeenPoisoned
var playerIsDead : bool = false
signal newEncounter
signal restartEncounter

var currentPoisonCup : CurrentPoisonCup = CurrentPoisonCup.none
enum CurrentPoisonCup{
	none,
	opponent,
	player
}

var currentRegion : RegionInfo = null
var gamestateJSON : GamestateJSON = GamestateJSON.new()

func _ready() -> void:
	gamestateJSON._load_gamestate()
	currentRegion = gameTimeline.timeline[gamestateJSON.timelineIndex]
	
	_set_connections()
	_start_new_encounter()
func _set_connections():
	newEncounter.connect(_set_next_encounter)
	restartEncounter.connect(_restart_current_encounter)

func _start_new_encounter():
	_setup_encounter_papers()
	playmatManager._add_main_papers()
	
	await get_tree().create_timer(1).timeout
	dialogueManager._start_dialogue()

#- - -
func _setup_encounter_papers():
	playmatManager.mainTraitSheet = currentRegion.traitSheet
	playmatManager.characterSheet = currentRegion.characterSheets[_get_next_encounter_index()].duplicate(true)
	playmatManager.atlasRegionSheet = currentRegion.atlas

#
func _restart_current_encounter():
	get_tree().reload_current_scene()

func _set_next_encounter():
	if gamestateJSON.timelineIndex >= gameTimeline.timeline.size() - 1:
		return
	if gamestateJSON.currentRegionEncounterCount >= currentRegion.totalEncounters:
		gamestateJSON.timelineIndex += 1
		gamestateJSON.currentRegionEncounterCount = 1
	else:
		gamestateJSON.currentRegionEncounterCount += 1
	
	gamestateJSON._save_gamestate()
	get_tree().reload_current_scene()

#- - -
func _get_next_encounter_index() -> int:
	#TODO: make random
	return 0
