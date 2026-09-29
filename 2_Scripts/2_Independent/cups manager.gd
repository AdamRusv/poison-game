extends Control

class_name CupsManager

@export_category("References")
@export var gameplayManager : GameplayManager
##0 is opponent, 1 is player
@export var detectionZones : Array[Control]
##0 is opponent, 1 is player
@export var visualIndicators : Array[AnimatedSprite2D]

func _ready() -> void:
	gameplayManager.cupsManager = self
	_set_connections()
	_setup_indicators()
func _set_connections():
	for i in range(0, detectionZones.size()):
		detectionZones[i].mouse_entered.connect(_enter_poison_over_cup.bind(i))
		detectionZones[i].mouse_exited.connect(_exit_poison_over_cup.bind(i))
	
	gameplayManager.poisonGrabbed.connect(_reveal_indicators)
	gameplayManager.poisonReleased.connect(_remove_indicators)
func _setup_indicators():
	for indicator in visualIndicators:
		indicator.self_modulate.a = 0
		indicator.play()

#- - -
func _enter_poison_over_cup(cupIndex : int):
	if gameplayManager.holdingPoison == false:
		return
	GlobalReferences.cursor.imageNode.frame = 0
	
	_set_indicator_to_poison(visualIndicators[cupIndex])
	
	if cupIndex == 0: ##for classic only
		gameplayManager.currentPoisonCup = GameplayManager.CurrentPoisonCup.opponent
	elif cupIndex == 1: ##for classic only
		gameplayManager.currentPoisonCup = GameplayManager.CurrentPoisonCup.player

func _exit_poison_over_cup(cupIndex : int):
	if gameplayManager.holdingPoison == false:
		return
	GlobalReferences.cursor.imageNode.frame = 1
	
	_set_indicator_to_neutral(visualIndicators[cupIndex])
	
	gameplayManager.currentPoisonCup = GameplayManager.CurrentPoisonCup.none

#--------------INDICATORS--------------
var indicatorTweens : Array[Tween]
var fadeSpeed : float = 0.4
func _reset_tweens():
	if indicatorTweens.size() >= gameplayManager.cupCount:
		for tween in indicatorTweens:
			tween.kill()
		indicatorTweens.clear()

func _hide_indicator(indicator : AnimatedSprite2D):
	_reset_tweens()
	
	var newTween : Tween = create_tween()
	indicatorTweens.append(newTween)
	var normalizedDuration : float = indicator.self_modulate.a * fadeSpeed
	
	newTween.tween_property(indicator, "self_modulate:a", 0, normalizedDuration)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
func _show_indicator(indicator : AnimatedSprite2D):
	_reset_tweens()
	
	var newTween : Tween = create_tween()
	indicatorTweens.append(newTween)
	var normalizedDuration : float = fadeSpeed - indicator.self_modulate.a
	
	newTween.tween_property(indicator, "self_modulate:a", 1, normalizedDuration)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _remove_indicators():
	for indicator in visualIndicators:
		_hide_indicator(indicator)
func _reveal_indicators():
	for indicator in visualIndicators:
		_show_indicator(indicator)

func _set_indicator_to_poison(indicator : AnimatedSprite2D):
	indicator.self_modulate = Color("b65c5f")
func _set_indicator_to_neutral(indicator : AnimatedSprite2D):
	indicator.self_modulate = Color("bda583")
