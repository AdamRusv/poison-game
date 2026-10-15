extends DefaultButton

class_name TravelTexture

@export_category("References")
@export var gameplayManager : GameplayManager
@export var travelTexture : TextureRect 

var travelTriggered : bool = false

func _ready() -> void:
	super._ready()
	_hide()

func _set_connections():
	super._set_connections()
	onClicked.connect(_go_to_next_encounter)
	gameplayManager.playerDied.connect(_show)

func _go_to_next_encounter():
	if travelTriggered == true:
		return
	travelTriggered = true
	await get_tree().create_timer(0.6).timeout
	if gameplayManager.playerIsDead == true:
		gameplayManager.restartEncounter.emit()
	else:
		gameplayManager.newEncounter.emit()

#- - -
func _show():
	travelTexture.visible = true
func _hide():
	travelTexture.visible = false
