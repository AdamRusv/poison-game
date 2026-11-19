extends Node

var settingsJSON : SettingsJSON = SettingsJSON.new()

signal togglefullscreen

var canToggleFullscreen : bool = true

func _ready() -> void:
	randomize()
	settingsJSON._load_settings()
	togglefullscreen.connect(_toggle_fullscreen)
	_update_fullscreen()
	_update_audio()

func _update_audio():
	SoundManager._set_bus_volume("Master", settingsJSON.masterVolume)
	SoundManager._set_bus_volume("Music", settingsJSON.musicVolume)
	SoundManager._set_bus_volume("SFX", settingsJSON.sfxVolume)

func _manage_master(change : int = 0):
	if settingsJSON.masterVolume == 5 && change > 0:
		return
	elif settingsJSON.masterVolume == 0 && change < 0:
		return
	
	settingsJSON.masterVolume += change
	SoundManager._set_bus_volume("Master", settingsJSON.masterVolume)

func _manage_music(change : int = 0):
	if settingsJSON.musicVolume == 5 && change > 0:
		return
	elif settingsJSON.musicVolume == 0 && change < 0:
		return
	
	settingsJSON.musicVolume += change
	SoundManager._set_bus_volume("Music", settingsJSON.musicVolume)

func _manage_sfx(change : int = 0):
	if settingsJSON.sfxVolume == 5 && change > 0:
		return
	elif settingsJSON.sfxVolume == 0 && change < 0:
		return
	
	settingsJSON.sfxVolume += change
	SoundManager._set_bus_volume("SFX", settingsJSON.sfxVolume)

#---------------------------------------------------------
func _update_fullscreen():
	if settingsJSON.fullscreen == false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	settingsJSON._save_settings()

func _toggle_fullscreen():
	if canToggleFullscreen == true:
		settingsJSON.fullscreen = !settingsJSON.fullscreen
		_update_fullscreen()
