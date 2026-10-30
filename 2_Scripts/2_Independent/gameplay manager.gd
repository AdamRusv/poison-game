extends Control

class_name GameplayManager

@export var gameTimeline : GameTimeline
@export var atlasHolder : AtlasHolder
@export var timelineCounterLabel : RichTextLabel

var playmatManager : PlaymatManager
var poisonManager : PoisonManager
var cupsManager : CupsManager
var dialogueManager : DialogueManager
var hintSystemManager : HintSystemManager

var cupCount : int = 2 #NOTE: change for other gamemodes

var holdingPoison : bool = false
signal poisonGrabbed
signal poisonReleased

var cupIsPoisoned : bool = false
signal cupHasBeenPoisoned
var correctCupChosen : bool = false

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
	_update_timeline_counter()
	_set_connections()
	_start_new_encounter()
func _set_connections():
	newEncounter.connect(_set_next_encounter)
	restartEncounter.connect(_restart_current_encounter)
	#cupHasBeenPoisoned.connect(dialogueManager._trigger_dialogue_branch)
	cupHasBeenPoisoned.connect(_check_if_cup_choice_is_correct)

func _start_new_encounter():
	#TransitionManager._create_transition()
	TransitionManager.transitionEncounter._end_transition()
	
	_setup_encounter_papers()
	playmatManager._add_main_papers()
	
	await get_tree().create_timer(1).timeout
	dialogueManager._start_dialogue()

func _update_timeline_counter():
	var counterText : String = ""
	
	var regionNumber : int = 0
	var initalEncounterNumber : int = 0
	for i in range(0, gameTimeline.timeline.size()):
		var region : RegionInfo = gameTimeline.timeline[i]
		if i > gamestateJSON.timelineIndex:
			break
		
		if region.increaseRegion == true:
			regionNumber += 1
			initalEncounterNumber = 1
		else:
			initalEncounterNumber += 1
		
	var encounterNumber : int = initalEncounterNumber + gamestateJSON.currentRegionEncounterCount - 1
	counterText = str(regionNumber) + " - " + str(encounterNumber)
	timelineCounterLabel.text = counterText

#- - -
func _setup_encounter_papers():
	var nextEncounterIndex : int = gamestateJSON.currentCharacterIndex
	
	playmatManager.mainTraitSheet = currentRegion.traitSheet
	playmatManager.characterSheet = currentRegion.characterSheets[nextEncounterIndex].duplicate(true)
	
	gamestateJSON.currentCharacterIndex = nextEncounterIndex
	gamestateJSON._save_gamestate()

#
func _check_if_cup_choice_is_correct():
	var answerCup : EncounterInfo.CupAnswer = playmatManager.characterSheet.cupAnswer
	if currentPoisonCup == CurrentPoisonCup.opponent && answerCup == EncounterInfo.CupAnswer.opponentCup:
		correctCupChosen = true
	elif currentPoisonCup == CurrentPoisonCup.player && answerCup == EncounterInfo.CupAnswer.playerCup:
		correctCupChosen = true

func _restart_current_encounter():
	TransitionManager._create_transition()
	await TransitionManager.transitionEncounter._start_transition().finished
	
	await get_tree().create_timer(0.6).timeout
	get_tree().reload_current_scene()

func _set_next_encounter():
	TransitionManager._create_transition()
	await TransitionManager.transitionEncounter._start_transition().finished
	
	if gamestateJSON.timelineIndex >= gameTimeline.timeline.size() - 1 && gamestateJSON.currentRegionEncounterCount >= currentRegion.totalEncounters:
		return
	if gamestateJSON.currentRegionEncounterCount >= currentRegion.totalEncounters:
		gamestateJSON.timelineIndex += 1
		gamestateJSON.currentRegionEncounterCount = 1
		gamestateJSON.completedCharacters.clear()
	else:
		gamestateJSON.currentRegionEncounterCount += 1
		gamestateJSON.completedCharacters.append(gamestateJSON.currentCharacterIndex)
	
	gamestateJSON.currentCharacterIndex = _get_next_encounter_index()
	
	gamestateJSON._save_gamestate()
	
	await get_tree().create_timer(0.6).timeout
	get_tree().reload_current_scene()

#- - -
func _get_next_encounter_index() -> int:
	var nextRegion : RegionInfo = gameTimeline.timeline[gamestateJSON.timelineIndex]
	
	var completedCharacters : Array = gamestateJSON.completedCharacters
	var allCharacters : Array = nextRegion.characterSheets
	var uncompletedCharacters : Array = []
	for i in range(0, allCharacters.size()):
		var isCompleted : bool = false
		for completedCharacter in completedCharacters:
			if i == completedCharacter:
				isCompleted = true
				break
		if isCompleted == false:
			uncompletedCharacters.append(i)
	
	var randomIndex : int = randi_range(0, uncompletedCharacters.size() - 1)
	return uncompletedCharacters[randomIndex]
