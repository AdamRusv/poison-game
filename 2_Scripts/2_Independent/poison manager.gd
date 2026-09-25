extends Control

class_name PoisonManager

@export_category("References")
@export var gameplayManager : GameplayManager
@export var poisonTexture : TextureRect
@export var poisonButton : Button

const NEUTRAL_POISON : Rect2 = Rect2(0, 0, 209, 64)
const HOVERED_POISON : Rect2 = Rect2(209, 0, 209, 64)
const GRABBED_POISON : Rect2 = Rect2(418, 0, 209, 64)

func _ready() -> void:
	gameplayManager.poisonManager = self
	_set_connections()
func _set_connections():
	poisonButton.mouse_entered.connect(_on_enter)
	poisonButton.mouse_exited.connect(_on_exit)
	poisonButton.button_down.connect(_on_down)
	poisonButton.button_up.connect(_on_up)

#- - -
func _on_enter():
	if gameplayManager.holdingPoison == true:
		return
	_set_poison_texture_to(HOVERED_POISON)

func _on_exit():
	if gameplayManager.holdingPoison == true:
		return
	_set_poison_texture_to(NEUTRAL_POISON)

func _on_down():
	gameplayManager.holdingPoison = true
	_set_poison_texture_to(GRABBED_POISON)
	GlobalReferences.cursor._swap_cursor_to(GlobalReferences.cursor.poisonVileCursor)
	
func _on_up():
	if _is_mouse_over_poison_button() == true:
		_set_poison_texture_to(HOVERED_POISON)
	
	else:
		_set_poison_texture_to(NEUTRAL_POISON)
	
	GlobalReferences.cursor._swap_cursor_to(GlobalReferences.cursor.defaultCursor)
	gameplayManager.holdingPoison = false

#--------------------------
func _set_poison_texture_to(newRect : Rect2):
	var atlasTexture : AtlasTexture = poisonTexture.texture
	atlasTexture.region = newRect

#-
func _is_mouse_over_poison_button() -> bool:
	var mousePos : Vector2 = get_global_mouse_position()
	return poisonButton.get_global_rect().has_point(mousePos)
