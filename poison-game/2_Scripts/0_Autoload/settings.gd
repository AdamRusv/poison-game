extends Node

var settingsJSON : SettingsJSON = SettingsJSON.new()

signal togglefullscreen

func _ready() -> void:
	settingsJSON._load_settings()
	togglefullscreen.connect(_toggle_fullscreen)
	_update_fullscreen()
	#_toggle_fullscreen()
	_update_audio()

func _update_audio():
	SoundManager._set_bus_volume("Master", settingsJSON.masterVolume)
	SoundManager._set_bus_volume("Music", settingsJSON.musicVolume)
	SoundManager._set_bus_volume("SFX", settingsJSON.sfxVolume)

func _increase_master():
	if settingsJSON.masterVolume == 5:
		settingsJSON.masterVolume = 0
	else:
		settingsJSON.masterVolume += 1
	SoundManager._set_bus_volume("Master", settingsJSON.masterVolume)

func _increase_music():
	if settingsJSON.musicVolume == 5:
		settingsJSON.musicVolume = 0
	else:
		settingsJSON.musicVolume += 1
	SoundManager._set_bus_volume("Music", settingsJSON.musicVolume)

func _increase_sfx():
	if settingsJSON.sfxVolume == 5:
		settingsJSON.sfxVolume = 0
	else:
		settingsJSON.sfxVolume += 1
	SoundManager._set_bus_volume("SFX", settingsJSON.sfxVolume)

#---------------------------------------------------------
func _update_fullscreen():
	if settingsJSON.fullscreen == false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	settingsJSON._save_settings()

func _toggle_fullscreen():
	settingsJSON.fullscreen = !settingsJSON.fullscreen
	_update_fullscreen()
