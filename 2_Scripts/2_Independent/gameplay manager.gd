extends Control

class_name GameplayManager

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

var currentPoisonCup : CurrentPoisonCup = CurrentPoisonCup.none
enum CurrentPoisonCup{
	none,
	opponent,
	player
}

var currentRegion : RegionInfo = null

func _ready() -> void:
	_start_new_encounter(currentRegion)

func _start_new_encounter(newRegion : RegionInfo):
	_setup_encounter_papers(newRegion)
	playmatManager._add_main_papers()
	
	await get_tree().create_timer(1).timeout
	dialogueManager._trigger_dialogue_branch()

#- - -
func _setup_encounter_papers(newRegion : RegionInfo):
	playmatManager.mainTraitSheet = newRegion.traitSheet
	playmatManager.characterSheet = newRegion.characterSheets[0]
	playmatManager.atlasRegionSheet = newRegion.atlas
