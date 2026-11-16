extends Node

class_name GamestateJSON

const GAMESTATE_PATH : String = "user://gamestate.json"

var timelineIndex : int = 0
var currentRegionEncounterCount : int = 1
##per pool (indexed by timelineIndex) for the current region. wiped on the region's second death and when entering a new region
var completedCharacters : Array[Array] = []
##deaths in the current region, resets with completedCharacters
var regionDeathCount : int = 0
var currentCharacterIndex : int = 0

func _save_gamestate() -> void:
	var gamestateData : Dictionary = {
		"timelineIndex": timelineIndex,
		"currentRegionEncounter": currentRegionEncounterCount,
		"completedCharacters": completedCharacters,
		"regionDeathCount": regionDeathCount,
		"currentCharacterIndex": currentCharacterIndex
	}
	
	var file : FileAccess = FileAccess.open(GAMESTATE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open GamestateData file for saving.")
		return
	
	file.store_string(JSON.stringify(gamestateData, "\t"))
	file.close()

func _load_gamestate() -> void:
	if not FileAccess.file_exists(GAMESTATE_PATH):
		_save_gamestate()
		return
	
	var file : FileAccess = FileAccess.open(GAMESTATE_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open gamestate file for loading.")
		return
	
	var jsonText : String = file.get_as_text()
	file.close()
	
	var gamestateData : Variant = JSON.parse_string(jsonText)
	if not gamestateData is Dictionary:
		push_error("GamestateData file contains invalid JSON data.")
		return
	
	timelineIndex = int(gamestateData.get("timelineIndex", timelineIndex))
	currentRegionEncounterCount = int(gamestateData.get("currentRegionEncounter", currentRegionEncounterCount))
	currentCharacterIndex = int(gamestateData.get("currentCharacterIndex", currentCharacterIndex))
	regionDeathCount = int(gamestateData.get("regionDeathCount", regionDeathCount))
	
	completedCharacters.clear()
	var loadedPools : Variant = gamestateData.get("completedCharacters", [])
	if loadedPools is Array:
		for loadedPool in loadedPools:
			#old flat saves hold plain numbers instead of arrays, so discard them
			if not loadedPool is Array:
				completedCharacters.clear()
				break
			var pool : Array = []
			for value in loadedPool:
				pool.append(int(value))
			completedCharacters.append(pool)

#--------
func _get_completed_for_pool(poolIndex : int) -> Array:
	while completedCharacters.size() <= poolIndex:
		completedCharacters.append([])
	return completedCharacters[poolIndex]

func _add_completed_character(poolIndex : int, characterIndex : int):
	var pool : Array = _get_completed_for_pool(poolIndex)
	if !pool.has(characterIndex):
		pool.append(characterIndex)

func _clear_all_completed() -> void:
	completedCharacters.clear()
	regionDeathCount = 0

func _reset_gamestate(): #NOTE: have an option to call this for reoccuring players in playtest 3
	_clear_all_completed()
	currentCharacterIndex = 0
	currentRegionEncounterCount = 1
	timelineIndex = 0
	
	_save_gamestate()
