extends Control

class_name ClickDrag

@export_category("References")
@export var parentNode : Control
@export var detectionArea : Button

var mouseOffset : Vector2 = Vector2.ZERO
var isHeld : bool = false

func _ready() -> void:
	_set_connections()

func _set_connections():
	detectionArea.mouse_entered.connect(_on_enter)
	detectionArea.mouse_exited.connect(_on_exit)
	detectionArea.button_up.connect(_on_up)
	detectionArea.button_down.connect(_on_down)

func _process(delta: float):
	if isHeld == true:
		parentNode.position = get_global_mouse_position() + mouseOffset
		parentNode.position = floor(parentNode.position)

#---------------------------

func _on_enter():
	pass

func _on_exit():
	pass

func _on_up():
	isHeld = false

func _on_down():
	mouseOffset = parentNode.position - get_global_mouse_position()
	isHeld = true
