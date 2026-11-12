extends Control

@export_category("References")
@export var playButton : DefaultButton
@export var settingsButton : DefaultButton
@export var quitButton : DefaultButton
@export var creditsButton : DefaultButton

var gamestateJSON : GamestateJSON = GamestateJSON.new()

func _ready() -> void:
	gamestateJSON._load_gamestate()
	_set_connections()
func _set_connections():
	playButton.onClicked.connect(_play)
	settingsButton.onClicked.connect(_settings)
	quitButton.onClicked.connect(_quit)
	
	creditsButton.onClicked.connect(_open_credits)

#- - - - - -
var gameplaySceneRef : PackedScene = preload("res://1_Scenes/0_Screens/gameplay.tscn")

var playTriggered : bool = false
func _play():
	if playTriggered == true:
		return
	playTriggered = true
	await get_tree().create_timer(0.3).timeout
	
	var gameplayScene : GameplayManager = gameplaySceneRef.instantiate()
	
	#NOTE: SWAP FOR REAL VERSION
	#if gamestateJSON.timelineIndex == 0:
		#await TransitionManager._create_transition(TransitionManager.TransitionStates.blank)
	#else:
		#await TransitionManager._create_transition(TransitionManager.TransitionStates.mainMenuTraveling)
	await TransitionManager._create_transition(TransitionManager.TransitionStates.blank) #just while testing to save time
	
	await get_tree().create_timer(0.6).timeout
	get_tree().change_scene_to_node(gameplayScene)

func _settings():
	pass

func _quit():
	get_tree().quit()

#
func _open_credits():
	PopupMenuManager._create_credits_menu()
