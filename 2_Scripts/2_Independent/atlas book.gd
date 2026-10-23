extends Paper

class_name AtlasBook

@export_category("References")
@export var mapPageSprite : TextureRect
@export var atlasFullPageSprite : TextureRect
@export var atlasSinglePageSprite : TextureRect
@export var leftDetectionZone : Button
@export var rightDetectionZone : Button

var pageFlipMaterial : ShaderMaterial = null

func _init() -> void:
	canBePacket = false
func _ready() -> void:
	super._ready()
	pageFlipMaterial = atlasSinglePageSprite.material
func _set_connections():
	super._set_connections()
	leftDetectionZone.mouse_entered.connect(_on_enter_next_page.bind(true))
	leftDetectionZone.mouse_exited.connect(_on_exit_next_page)
	leftDetectionZone.button_down.connect(_on_page_down)
	leftDetectionZone.pressed.connect(_go_to_next_left_page)

	rightDetectionZone.mouse_entered.connect(_on_enter_next_page.bind(false))
	rightDetectionZone.mouse_exited.connect(_on_exit_next_page)
	rightDetectionZone.button_down.connect(_on_page_down)
	rightDetectionZone.pressed.connect(_go_to_next_right_page)


#- - -
func _on_enter_next_page(isLeftPage : bool):
	GlobalReferences.cursor._swap_cursor_to(GlobalReferences.cursor.atlasPageTurnCursor)
	
	if isLeftPage == true:
		GlobalReferences.cursor.imageNode.flip_h = true

func _on_exit_next_page():
	GlobalReferences.cursor.imageNode.flip_h = false
	GlobalReferences.cursor._swap_cursor_to(GlobalReferences.cursor.defaultCursor)

func _on_page_down():
	GlobalReferences.cursor.imageNode.frame = 1

func _go_to_next_left_page():
	GlobalReferences.cursor.imageNode.frame = 0
	_animate_left_to_right_page_turn()

func _go_to_next_right_page():
	GlobalReferences.cursor.imageNode.frame = 0
	_animate_right_to_left_page_turn()

#- - -
func _animate_right_to_left_page_turn():
	var newTween : Tween = create_tween()

	newTween.tween_method(_set_page_progress, 0.0, 1.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _animate_left_to_right_page_turn():
	var newTween: Tween = create_tween()

	newTween.tween_method(_set_page_progress, 1.0, 0.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

#--------------
func _set_page_progress(value : float):
	pageFlipMaterial.set_shader_parameter("progress", value)