extends Control

@export_category("References")
@export var playButton : DefaultButton
@export var settingsButton : DefaultButton
@export var quitButton : DefaultButton

@export_category("Delete Later (For testing)")
@export var tutorialRegion : RegionInfo

func _ready() -> void:
	_set_connections()
func _set_connections():
	playButton.onClicked.connect(_play)
	settingsButton.onClicked.connect(_settings)
	quitButton.onClicked.connect(_quit)

#- - - - - -
var gameplayScenePath : String = "res://1_Scenes/0_Screens/gameplay.tscn"

func _play():
	var gameplaySceneInstance : PackedScene = load(gameplayScenePath)
	var gameplayScene : GameplayManager = gameplaySceneInstance.instantiate()
	
	gameplayScene.currentRegion = tutorialRegion
	
	get_tree().change_scene_to_node(gameplayScene)

func _settings():
	pass

func _quit():
	get_tree().quit()
