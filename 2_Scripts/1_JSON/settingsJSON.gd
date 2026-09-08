extends Node

class_name SettingsJSON

const SETTINGS_PATH : String = "user://settings.json"

var fullscreen : bool = false
var masterVolume : int = 5
var musicVolume : int = 2
var sfxVolume : int = 3

func _save_settings() -> void:
	var settingsData : Dictionary = {
		"fullscreen": fullscreen,
		"masterVolume": masterVolume,
		"musicVolume": musicVolume,
		"sfxVolume": sfxVolume
	}
	
	var file : FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open settings file for saving.")
		return
	
	file.store_string(JSON.stringify(settingsData, "\t"))
	file.close()

func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		_save_settings()
		return
	
	var file : FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open settings file for loading.")
		return
	
	var jsonText : String = file.get_as_text()
	file.close()
	
	var settingsData : Variant = JSON.parse_string(jsonText)
	if not settingsData is Dictionary:
		push_error("Settings file contains invalid JSON data.")
		return
	
	fullscreen = bool(settingsData.get("fullscreen", fullscreen))
	masterVolume = int(settingsData.get("masterVolume", masterVolume))
	musicVolume = int(settingsData.get("musicVolume", musicVolume))
	sfxVolume = int(settingsData.get("sfxVolume", sfxVolume))
	
