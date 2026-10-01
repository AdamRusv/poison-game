extends Control

class_name DefaultButton

@export_category("Reference")
@export var buttonSelf : Button
@export var baseNineSlice : NinePatchRect
@export_group("Base NineSlice Region")
@export var NEUTRAL_STATE : Rect2i = Rect2i(0, 0, 20, 20)
@export var HOVERED_STATE : Rect2i = Rect2i(20, 0, 20, 20)
@export var PRESSED_STATE : Rect2i = Rect2i(20, 0, 20, 20)

func _ready() -> void:
	baseNineSlice.texture = baseNineSlice.texture.duplicate(true)
	_set_connections()
func _set_connections():
	buttonSelf.mouse_entered.connect(_on_enter)
	buttonSelf.mouse_exited.connect(_on_exit)
	buttonSelf.pressed.connect(_clicked)

#- - -
signal onEnter
signal onExit
signal onClicked

func _on_enter():
	_change_texture(baseNineSlice.texture, HOVERED_STATE)
	onEnter.emit()

func _on_exit():
	_change_texture(baseNineSlice.texture, NEUTRAL_STATE)
	onExit.emit()

func _clicked():
	_change_texture(baseNineSlice.texture, PRESSED_STATE)
	onClicked.emit()

#----------------------------
func _change_texture(atlasToChange : AtlasTexture, state : Rect2i):
	atlasToChange.region = state
