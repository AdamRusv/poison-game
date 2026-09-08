extends Node

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		Settings.togglefullscreen.emit()
