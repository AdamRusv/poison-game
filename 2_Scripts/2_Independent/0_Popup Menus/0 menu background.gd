extends ColorRect

class_name PopupMenuBackground

@export_category("References")
@export var backgroundColorRect : ColorRect
@export var closeButton : DefaultButton

func _ready() -> void:
	_set_connections()
func _set_connections():
	closeButton.onClicked.connect(PopupMenuManager._close_current_menu)
