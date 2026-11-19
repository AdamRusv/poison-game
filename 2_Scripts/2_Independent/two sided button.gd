extends DefaultButton

class_name TwoSidedButton

@export_category("Reference")
##dont fill buttonSelf
@export var leftButton : Button
##dont fill buttonSelf
@export var rightButton : Button

func _set_connections():
	leftButton.mouse_entered.connect(_on_enter.bind(false))
	leftButton.mouse_exited.connect(_on_exit.bind(false))
	leftButton.button_down.connect(_on_down.bind(false))
	leftButton.button_up.connect(_on_up.bind(false))
	leftButton.pressed.connect(_clicked.bind(false))
	
	rightButton.mouse_entered.connect(_on_enter)
	rightButton.mouse_exited.connect(_on_exit)
	rightButton.button_down.connect(_on_down)
	rightButton.button_up.connect(_on_up)
	rightButton.pressed.connect(_clicked)

#- - -
signal onLeftEnter
signal onRightEnter

signal onLeftExit
signal onRightExit

signal onLeftUp
signal onRightUp

signal onLeftDown
signal onRightDown

signal onLeftClicked
signal onRightClicked

func _on_enter(isRight : bool = true):
	if isRight == true:
		_change_cursor_to_arrow()
		onRightEnter.emit()
	else:
		_change_cursor_to_arrow(false)
		onLeftEnter.emit()

func _on_exit(isRight : bool = true):
	_reset_cursor_to_default()
	
	if isRight == true:
		onRightExit.emit()
	else:
		onLeftExit.emit()

func _on_down(isRight : bool = true):
	GlobalReferences.cursor.imageNode.frame = 1
	
	if isRight == true:
		onRightDown.emit()
	else:
		onLeftDown.emit()

func _on_up(isRight : bool = true):
	GlobalReferences.cursor.imageNode.frame = 0
	
	if isRight == true:
		onRightUp.emit()
	else:
		onLeftUp.emit()

func _clicked(isRight : bool = true):
	if isRight == true:
		onRightClicked.emit()
	else:
		onLeftClicked.emit()

#- - -
func _change_atlasTexture(state : Rect2i):
	return

func _change_cursor_to_arrow(isRight : bool = true):
	GlobalReferences.cursor._swap_cursor_to(GlobalReferences.cursor.atlasPageTurnCursor)
	if isRight == true:
		GlobalReferences.cursor.imageNode.flip_h = false
	else:
		GlobalReferences.cursor.imageNode.flip_h = true

func _reset_cursor_to_default():
	GlobalReferences.cursor.imageNode.flip_h = false
	GlobalReferences.cursor._swap_cursor_to(GlobalReferences.cursor.defaultCursor)

#-------------------
func _is_mouse_over_left_button() -> bool:
	if get_viewport() == null:
		return false
	
	var mousePos : Vector2 = get_global_mouse_position()
	return leftButton.get_global_rect().has_point(mousePos)
func _is_mouse_over_right_button() -> bool:
	if get_viewport() == null:
		return false
	
	var mousePos : Vector2 = get_global_mouse_position()
	return leftButton.get_global_rect().has_point(mousePos)
