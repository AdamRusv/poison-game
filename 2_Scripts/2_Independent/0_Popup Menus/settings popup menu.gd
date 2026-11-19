extends BasePopupMenu

class_name SettingsMenuManager

@export_category("Reference")
@export var fullscreen : DefaultButton
@export var master : TwoSidedButton
@export var music : TwoSidedButton
@export var sfx : TwoSidedButton
@export var reset : DefaultButton

var gamestateJSON : GamestateJSON = GamestateJSON.new()

func _ready() -> void:
	gamestateJSON._load_gamestate()
	_set_connections()
func _set_connections():
	fullscreen.onClicked.connect(Settings._toggle_fullscreen)
	
	master.onLeftClicked.connect(Settings._manage_master.bind(-1))
	master.onRightClicked.connect(Settings._manage_master.bind(1))
	
	music.onLeftClicked.connect(Settings._manage_music.bind(-1))
	music.onRightClicked.connect(Settings._manage_music.bind(1))
	
	sfx.onLeftClicked.connect(Settings._manage_sfx.bind(-1))
	sfx.onRightClicked.connect(Settings._manage_sfx.bind(1))
	
	reset.onClicked.connect(_reset_save)

func _process(delta: float) -> void:
	_update_labels()

#-
func _update_labels():
	if Settings.settingsJSON.fullscreen == true:
		fullscreen.label.text = "Fullscreen: On"
	else:
		fullscreen.label.text = "Fullscreen: Off"
	
	master.label.text = "Master Volume: " + str(Settings.settingsJSON.masterVolume)
	music.label.text = "Music: " + str(Settings.settingsJSON.musicVolume)
	sfx.label.text = "SFX: " + str(Settings.settingsJSON.sfxVolume)

#- - -
func _reset_save():
	gamestateJSON._reset_gamestate()
	reset.label.text = "Your save has been reset!"
