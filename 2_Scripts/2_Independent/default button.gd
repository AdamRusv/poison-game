extends Control

class_name DefaultButton

@export_category("Reference")
@export var buttonSelf : Button
##must be a nineslice or texturerect!!
@export var visual : Control
@export_group("Base NineSlice Region")
@export var NEUTRAL_STATE : Rect2i = Rect2i(0, 0, 20, 20)
@export var HOVERED_STATE : Rect2i = Rect2i(20, 0, 20, 20)
@export var PRESSED_STATE : Rect2i = Rect2i(20, 0, 20, 20)

func _ready() -> void:
	visual.texture = visual.texture.duplicate(true)
	_set_connections()
func _set_connections():
	buttonSelf.mouse_entered.connect(_on_enter)
	buttonSelf.mouse_exited.connect(_on_exit)
	buttonSelf.button_down.connect(_on_down)
	buttonSelf.button_up.connect(_on_up)
	buttonSelf.pressed.connect(_clicked)

#- - -
signal onEnter
signal onExit
signal onUp
signal onDown
signal onClicked

func _on_enter():
	_change_atlasTexture(HOVERED_STATE)
	onEnter.emit()

func _on_exit():
	_change_atlasTexture(NEUTRAL_STATE)
	onExit.emit()

func _on_down():
	_change_atlasTexture(PRESSED_STATE)
	onDown.emit()

func _on_up():
	if _is_mouse_over_poison_button() == true:
		_change_atlasTexture(HOVERED_STATE)
	else:
		_change_atlasTexture(NEUTRAL_STATE)
	onUp.emit()

func _clicked():
	onClicked.emit()
	
#- - -
func _change_atlasTexture(state : Rect2i):
	visual.texture.region = state

#----------------------------
func _is_mouse_over_poison_button() -> bool:
	if get_viewport() == null:
		return false
	
	var mousePos : Vector2 = get_global_mouse_position()
	return buttonSelf.get_global_rect().has_point(mousePos)
