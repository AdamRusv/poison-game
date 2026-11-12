extends Control

class_name GameplayManager

@export var gameTimelineRef : GameTimeline
@export var atlasHolder : AtlasHolder
@export var timelineCounterLabel : RichTextLabel

var playmatManager : PlaymatManager
var poisonManager : PoisonManager
var cupsManager : CupsManager
var dialogueManager : DialogueManager
var hintSystemManager : HintSystemManager

var gameTimeline : GameTimeline = GameTimeline.new()

var cupCount : int = 2 #NOTE: change for other gamemodes

#gameplay sequence
var gameplayStarted : bool = false
signal cutsceneFinished
signal opponentSatDown
signal papersGiven

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
	_set_timeline()
	currentRegion = gameTimeline.timeline[gamestateJSON.timelineIndex]
	SoundManager._set_region_music(currentRegion.music, _get_encounter_number())
	_update_timeline_counter()
	_set_connections()
	_start_new_encounter()
func _set_timeline():
	for regionInfo in gameTimelineRef.timeline:
		gameTimeline.timeline.append(regionInfo.duplicate(true))
func _set_connections():
	newEncounter.connect(_set_next_encounter)
	restartEncounter.connect(_restart_current_encounter)
	cupHasBeenPoisoned.connect(_check_if_cup_choice_is_correct)

func _start_new_encounter():
	_setup_encounter_papers()
	
	await TransitionManager.transitionEncounter.transitionCutscene.finishedAnimating
	
	playmatManager._add_main_papers()
	
	await get_tree().create_timer(1).timeout
	dialogueManager._start_dialogue()

func _get_encounter_number():
	var initialEncounterNumber : int = 0
	for i in range(0, gamestateJSON.timelineIndex + 1):
		if gameTimeline.timeline[i].increaseRegion == true:
			initialEncounterNumber = 1
		else:
			initialEncounterNumber += 1
	return initialEncounterNumber + gamestateJSON.currentRegionEncounterCount - 1

func _update_timeline_counter():
	var regionNumber : int = -1
	for i in range(0, gamestateJSON.timelineIndex + 1):
		if gameTimeline.timeline[i].increaseRegion == true:
			regionNumber += 1
		
	timelineCounterLabel.text = str(regionNumber) + " - " + str(_get_encounter_number())

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
	playmatManager._save_paper_positions()

	await TransitionManager._create_transition(TransitionManager.TransitionStates.restarting)
	_reset_gamestate_to_start_of_current_region()
	await get_tree().create_timer(0.6).timeout
	get_tree().reload_current_scene()
func _reset_gamestate_to_start_of_current_region():
	gamestateJSON._load_gamestate()
	
	gamestateJSON.completedCharacters.clear()
	gamestateJSON.currentCharacterIndex = 0
	gamestateJSON.currentRegionEncounterCount = 1
	gamestateJSON.timelineIndex = gameTimeline._get_timeline_index_of_current_region_start()
	
	gamestateJSON._save_gamestate()

func _set_next_encounter():
	playmatManager._save_paper_positions()

	await TransitionManager._create_transition(TransitionManager.TransitionStates.traveling)
	
	if gamestateJSON.timelineIndex >= gameTimeline.timeline.size() - 1 && gamestateJSON.currentRegionEncounterCount >= currentRegion.totalEncounters:
		return
	if gamestateJSON.currentRegionEncounterCount >= currentRegion.encounterDialogueTrees.size():
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
