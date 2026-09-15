extends Node


func _scale_tween(control : Control, targetSize : Vector2, duration : float, \
transitionType : Tween.TransitionType = Tween.TransitionType.TRANS_QUAD, \
easeType : Tween.EaseType = Tween.EaseType.EASE_OUT) -> Tween:
	control.offset_transform_enabled = true
	
	var newTween : Tween = create_tween()
	
	newTween.tween_property(control, "offset_transform_scale", targetSize, duration)\
	.set_trans(transitionType).set_ease(easeType)
	
	return newTween
