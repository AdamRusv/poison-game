extends Control
class_name CustomCursor

@export var imageNode : AnimatedSprite2D
var hotspot : Vector2 = Vector2.ZERO
var followWhenHidden : bool = true		# if false, will auto-hide this when OS cursor is shown (e.g., alt-tab)

var wasHiddenByUs : bool = false

func _ready() -> void:
	z_index = 4096
	top_level = true
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	pivot_offset = Vector2.ZERO
	
	_hide_os_cursor()
	_update_cursor_position()

func _process(_delta : float) -> void:
	_update_cursor_position()
	
	if not _is_os_cursor_hidden():
		if followWhenHidden:
			visible = false
		else:
			_hide_os_cursor()
			visible = true
	else:
		visible = true
	
	if Input.is_action_just_pressed("left click"):
		imageNode.frame = 1
	
	if Input.is_action_just_released("left click"):
		imageNode.frame = 0

func _update_cursor_position() -> void:
	var mousePos : Vector2 = get_viewport().get_mouse_position()
	var newPos = mousePos - hotspot
	global_position = floor(newPos)

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			_show_os_cursor()
		NOTIFICATION_APPLICATION_FOCUS_IN:
			_hide_os_cursor()
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_PREDELETE, NOTIFICATION_EXIT_TREE:
			_show_os_cursor()

func _hide_os_cursor() -> void:
	if not _is_os_cursor_hidden():
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		wasHiddenByUs = true

func _show_os_cursor() -> void:
	if wasHiddenByUs and _is_os_cursor_hidden():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		wasHiddenByUs = false

func _is_os_cursor_hidden() -> bool:
	return Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN
