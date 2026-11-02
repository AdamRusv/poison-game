extends Control

class_name TransitionEncounter

@export_category("References")
@export var transitionBackground : TextureRect
@export var transitionCutscene : TransitionCutscene

var duration : float = 0.7

signal fullyClosed

func _start_transition():
	var newTween : Tween = create_tween()
	newTween.tween_method(_tween_circle_transition, 1.0, 0.0, duration)
	
	await newTween.finished
	fullyClosed.emit()

func _end_transition():
	var newTween : Tween = create_tween()
	newTween.tween_method(_tween_circle_transition, 0.0, 1.0, duration)
	
	newTween.finished.connect(queue_free)
	await newTween.finished

#-
func _tween_circle_transition(newValue : float):
	var gradient : GradientTexture2D = transitionBackground.texture
	gradient.gradient.set_offset(1, newValue)
