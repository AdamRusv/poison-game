extends Control

@export_category("References")
@export var playButton : DefaultButton
@export var settingsButton : DefaultButton
@export var quitButton : DefaultButton

func _ready() -> void:
	_set_connections()
func _set_connections():
	playButton.onClicked.connect(_play)
	settingsButton.onClicked.connect(_settings)
	quitButton.onClicked.connect(_quit)

#- - - - - -
var gameplayScenePath : String = "res://1_Scenes/0_Screens/gameplay.tscn"

func _play():
	await get_tree().create_timer(0.3).timeout
	
	var gameplaySceneInstance : PackedScene = load(gameplayScenePath)
	var gameplayScene : GameplayManager = gameplaySceneInstance.instantiate()
	
	TransitionManager._create_transition()
	await TransitionManager.transitionEncounter._start_transition().finished
	
	await get_tree().create_timer(0.6).timeout
	get_tree().change_scene_to_node(gameplayScene)

func _settings():
	pass

func _quit():
	get_tree().quit()
