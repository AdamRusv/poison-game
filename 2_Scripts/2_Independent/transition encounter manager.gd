extends Control

class_name TransitionEncounter

@export_category("References")
@export var circleTransition : Sprite2D

var duration : float = 0.7

func _start_transition() -> Tween:
	var newTween : Tween = create_tween()
	newTween.tween_method(_tween_circle_transition, 1.0, 0.0, duration)
	
	return newTween

func _end_transition() -> Tween:
	var newTween : Tween = create_tween()
	newTween.tween_method(_tween_circle_transition, 0.0, 1.0, duration)
	
	newTween.finished.connect(queue_free)
	
	return newTween

#-
func _tween_circle_transition(newValue : float):
	var gradient : GradientTexture2D = circleTransition.texture
	gradient.gradient.set_offset(1, newValue)
