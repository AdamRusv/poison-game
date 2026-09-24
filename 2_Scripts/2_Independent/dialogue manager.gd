extends Control

@export_category("Reference")
@export var scrollContainer : ScrollContainer

var isScrolling : bool = false
var startMousePos : Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	_manage_scroll()
	

#---------------
func _manage_scroll():
	if Input.is_action_just_pressed("left click"):
		if _is_cursor_within_scroll_zone() == true:
			startMousePos = get_global_mouse_position()
			isScrolling = true
	if Input.is_action_just_released("left click"):
		isScrolling = false
	
	if isScrolling == true:
		var mouseRatio : float = (get_global_mouse_position().y - scrollContainer.global_position.y) / scrollContainer.size.y
		scrollContainer.get_v_scroll_bar().value = (1.0 - mouseRatio) * scrollContainer.get_v_scroll_bar().max_value

#- - -
func _is_cursor_within_scroll_zone() -> bool:
	var mousePos : Vector2 = get_global_mouse_position()
	return scrollContainer.get_global_rect().has_point(mousePos)
