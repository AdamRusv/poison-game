extends TextureRect

class_name FlutterPage

signal crossed
signal finished

@export var mainPage : Control
@export var mapPage : Control
@export var frontViewport : SubViewport
@export var frontContent : Control

@export var backViewport : SubViewport
@export var backContent : Control
@export var backTitleLabel : RichTextLabel
@export var backInfoLabel : RichTextLabel

var startsOnRight : bool = true
var hasCrossed : bool = false
var bend : float = 0.0
var shaderMaterial : ShaderMaterial = null

func _set_front_page(isMapPage : bool):
	mainPage.visible = !isMapPage
	mapPage.visible = isMapPage
	frontViewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func _set_front_content(isVisible : bool):
	frontContent.visible = isVisible
	frontViewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func _set_back_text(title : String, info : String):
	backTitleLabel.text = title
	backInfoLabel.text = info
	backContent.visible = true
	backViewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func _clear_back_text():
	backContent.visible = false
	backViewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func _play(toMain : bool, duration : float, bendMagnitude : float):
	shaderMaterial = material
	startsOnRight = toMain
	bend = -bendMagnitude if toMain else bendMagnitude
	hasCrossed = false

	var from : float = 0.0 if toMain else 1.0
	var to : float = 1.0 if toMain else 0.0
	shaderMaterial.set_shader_parameter("bend", bend)

	_step(from) # set state before unhiding so theres no harsh frame
	visible = true
	
	var tween : Tween = create_tween()
	tween.tween_method(_step, from, to, duration)
	await tween.finished

	await get_tree().create_timer(0.05).timeout

	visible = false
	finished.emit()

func _step(progress : float):
	shaderMaterial.set_shader_parameter("progress", progress)
	if hasCrossed:
		return
	
	var angle : float = progress * PI
	var thetaMid : float = angle + bend * sin(angle) * 0.5
	if (cos(thetaMid) > 0.0) != startsOnRight:
		hasCrossed = true
		crossed.emit()
