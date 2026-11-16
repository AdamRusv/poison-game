extends Control

class_name PlayingWalkingManager

@export_category("References")
@export var gameplayManager : GameplayManager
@export var parentHolder : Control
@export var opponent : AnimatedSprite2D
@export var opponentItems : TextureRect

const OVER_CHAIR_POS : float = 58.5
const OFF_SCREEN_LEFT_POS : float = -22.5
const OFF_SCREEN_RIGHT_POS : float = 230.5

var currentOrientation : PlayerOrientation = PlayerOrientation.facingRight
enum PlayerOrientation{
	facingRight,
	facingLeft
}

var endingPos : float = OVER_CHAIR_POS
var finished : bool = true

func _ready() -> void:
	_set_connections()
func _set_connections():
	gameplayManager.cutsceneFinished.connect(_start)


func _process(delta: float) -> void:
	if finished == true:
		return
	
	if currentOrientation == PlayerOrientation.facingRight:
		if opponent.position.x >= endingPos:
			finished = true
			await get_tree().create_timer(0.2).timeout
			opponent.flip_h = false
			_sit()
	else:
		if opponent.position.x <= endingPos:
			finished = true
			await get_tree().create_timer(0.2).timeout
			opponent.flip_h = false
			_sit()

#-
func _start():
	opponent.animation = "walk"
	opponent.play()
	_walk_to_chair()
	finished = false

func _walk_to_chair():
	var startingPos : float = 0
	if currentOrientation == PlayerOrientation.facingRight:
		startingPos = OFF_SCREEN_LEFT_POS
		opponent.flip_h = false
	else:
		startingPos = OFF_SCREEN_RIGHT_POS
		opponent.flip_h = true
	
	opponent.position.x = startingPos
	
	await get_tree().create_timer(1).timeout
	var newTween : Tween = create_tween()
	var duration : float = abs((endingPos - startingPos) / 30)
	
	newTween.tween_property(opponent, "position:x", endingPos, duration)
	#.set_trans(Tween.TRANS_QUAD)#.set_ease(Tween.EASE_OUT)

#- - -
func _sit():
	opponent.animation = "sit"
	await get_tree().create_timer(0.2).timeout
	_end()

func _end():
	parentHolder.visible = false
	gameplayManager.opponentSatDown.emit()
