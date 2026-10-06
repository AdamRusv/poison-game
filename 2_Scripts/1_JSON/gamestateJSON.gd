extends Node

class_name GamestateJSON

const GAMESTATE_PATH : String = "user://gamestate.json"

var timelineIndex : int = 0
var currentRegionEncounterCount : int = 1

func _save_gamestate() -> void:
	var gamestateData : Dictionary = {
		"timelineIndex": timelineIndex,
		"currentRegionEncounter": currentRegionEncounterCount
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
	currentRegionEncounterCount = int(gamestateData.get("musicVolume", currentRegionEncounterCount))
	
