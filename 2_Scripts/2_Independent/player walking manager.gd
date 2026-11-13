extends Control

class_name PlayingWalkingManager

@export_category("References")
@export var gameplayManager : GameplayManager
@export var opponent : AnimatedSprite2D

const WALKING_ANIMATION_BOUNDS : Vector2 = Vector2(0, 3)

const OVER_CHAIR_POS : float = 58.5
const OFF_SCREEN_LEFT_POS : float = -22.5
const OFF_SCREEN_RIGHT_POS : float = 230.5

var currentOrientation : PlayerOrientation = PlayerOrientation.facingLeft
enum PlayerOrientation{
	facingRight,
	facingLeft
}

func _ready() -> void:
	opponent.play()
	_walk_to_chair()

func _process(delta: float) -> void:
	pass

#-
func _walk_to_chair():
	var startingPos : float = 0
	var endingPos : float = OVER_CHAIR_POS
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
	
	newTween.tween_property(opponent, "position:x", endingPos, duration)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
