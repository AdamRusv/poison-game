extends Control

@export_category("References")
@export var playButton : DefaultButton
@export var settingsButton : DefaultButton
@export var quitButton : DefaultButton

var gamestateJSON : GamestateJSON = GamestateJSON.new()

func _ready() -> void:
	gamestateJSON._load_gamestate()
	_set_connections()
func _set_connections():
	playButton.onClicked.connect(_play)
	settingsButton.onClicked.connect(_settings)
	quitButton.onClicked.connect(_quit)

#- - - - - -
var gameplayScenePath : String = "res://1_Scenes/0_Screens/gameplay.tscn"

var playTriggered : bool = false
func _play():
	if playTriggered == true:
		return
	playTriggered = true
	await get_tree().create_timer(0.3).timeout
	
	var gameplaySceneInstance : PackedScene = load(gameplayScenePath)
	var gameplayScene : GameplayManager = gameplaySceneInstance.instantiate()
	
	if gamestateJSON.timelineIndex == 0:
		await TransitionManager._create_transition(TransitionManager.TransitionStates.blank)
	else:
		await TransitionManager._create_transition(TransitionManager.TransitionStates.mainMenuTraveling)
	
	await get_tree().create_timer(0.6).timeout
	get_tree().change_scene_to_node(gameplayScene)

func _settings():
	pass

func _quit():
	get_tree().quit()
