extends Control

class_name GameplayManager

@export var gameTimeline : GameTimeline
@export var temporaryRegionNumber : TextureRect

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
signal playerDied

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
	_temportary_set_region_number()
	_set_connections()
	_start_new_encounter()
func _set_connections():
	newEncounter.connect(_set_next_encounter)
	restartEncounter.connect(_restart_current_encounter)
func _temportary_set_region_number():
	match gamestateJSON.timelineIndex:
		0:
			temporaryRegionNumber.texture.region = Rect2i(0, 0, 55, 30)
		1:
			temporaryRegionNumber.texture.region = Rect2i(55, 0, 55, 30)
		2:
			temporaryRegionNumber.texture.region = Rect2i(55 * 2, 0, 55, 30)
		3:
			temporaryRegionNumber.texture.region = Rect2i(55 * 3, 0, 55, 30)

func _start_new_encounter():
	TransitionManager._create_transition()
	TransitionManager.transitionEncounter._end_transition()
	
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
	TransitionManager._create_transition()
	await TransitionManager.transitionEncounter._start_transition().finished
	
	await get_tree().create_timer(0.6).timeout
	get_tree().reload_current_scene()

func _set_next_encounter():
	TransitionManager._create_transition()
	await TransitionManager.transitionEncounter._start_transition().finished
	
	if gamestateJSON.timelineIndex >= gameTimeline.timeline.size() - 1:
		return
	if gamestateJSON.currentRegionEncounterCount >= currentRegion.totalEncounters:
		gamestateJSON.timelineIndex += 1
		gamestateJSON.currentRegionEncounterCount = 1
	else:
		gamestateJSON.currentRegionEncounterCount += 1
	
	gamestateJSON._save_gamestate()
	
	await get_tree().create_timer(0.6).timeout
	get_tree().reload_current_scene()

#- - -
func _get_next_encounter_index() -> int:
	#TODO: make random
	return 0
