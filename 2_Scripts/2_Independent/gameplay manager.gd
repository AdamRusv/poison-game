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
signal newEncounter

var currentPoisonCup : CurrentPoisonCup = CurrentPoisonCup.none
enum CurrentPoisonCup{
	none,
	opponent,
	player
}

var currentRegion : RegionInfo = null

func _ready() -> void:
	_set_connections()
	_start_new_encounter(currentRegion)
func _set_connections():
	newEncounter.connect(_start_new_encounter)

func _start_new_encounter(newRegion : RegionInfo):
	currentRegion = newRegion
	_setup_encounter_papers()
	playmatManager._add_main_papers()
	
	await get_tree().create_timer(1).timeout
	dialogueManager._trigger_dialogue_branch()

#- - -
func _setup_encounter_papers():
	playmatManager.mainTraitSheet = currentRegion.traitSheet
	playmatManager.characterSheet = currentRegion.characterSheets[_get_next_encounter()]
	playmatManager.atlasRegionSheet = currentRegion.atlas

func _get_next_encounter() -> int:
	return 0
