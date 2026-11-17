extends Control

class_name PlayingWalkingManager

@export_category("References")
@export var gameplayManager : GameplayManager
@export var parentHolder : Control
@export var opponent : AnimatedSprite2D
@export var opponentItems : TextureRect

signal finishedMovement
var isRealOpponent : bool = true

const OVER_CHAIR_POS : float = 58.5
const OVER_TABLE_POS : float = 150
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
		if opponent.position.x >= OVER_TABLE_POS:
			_pass_paper()
		
		if opponent.position.x >= endingPos:
			finished = true
			await get_tree().create_timer(0.2).timeout
			opponent.flip_h = false
			_sit()
	else:
		if opponent.position.x <= OVER_TABLE_POS:
			_pass_paper()
		
		if opponent.position.x <= endingPos:
			finished = true
			await get_tree().create_timer(0.2).timeout
			opponent.flip_h = false
			_sit()

#-
func _start():
	opponent.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	currentOrientation = PlayerOrientation.facingRight
	endingPos = OVER_CHAIR_POS
	isRealOpponent = true
	_setup_walk()

func _setup_walk():
	parentHolder.visible = true
	opponent.animation = "walk"
	opponent.play()
	
	_walk_to_end_pos()
	
	finished = false

func _walk_to_end_pos():
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

#---
var passPaperCutscene : PassPaperCutscene = null
var triggeredPassPaper : bool = false
func _pass_paper_cutscene(cutscene : PassPaperCutscene, newOrientation : PlayerOrientation):
	opponent.self_modulate = Color("9b9b9b")
	isRealOpponent = false
	passPaperCutscene = cutscene
	currentOrientation = newOrientation
	
	match newOrientation:
		PlayerOrientation.facingRight:
			endingPos = OFF_SCREEN_RIGHT_POS
		PlayerOrientation.facingLeft:
			endingPos = OFF_SCREEN_LEFT_POS
	
	_setup_walk()
func _pass_paper():
	if triggeredPassPaper == true:
		return
	triggeredPassPaper = true
	
	var papersToPass : Array[Paper] = []
	for paper in passPaperCutscene.papersToPassToPlayer:
		var newPaperRef : PackedScene = load(paper)
		var newPaper : Paper = newPaperRef.instantiate()
		papersToPass.append(newPaper)
	
	gameplayManager.playmatManager._add_custom_papers(papersToPass)

#- - -
func _sit():
	if isRealOpponent == false:
		_non_real_opponent_end()
		return
	
	opponent.animation = "sit"
	await get_tree().create_timer(0.2).timeout
	parentHolder.visible = false
	gameplayManager.opponentSatDown.emit()

func _non_real_opponent_end():
	parentHolder.visible = false
	finishedMovement.emit()
