extends Control

class_name TransitionMapEncounterNode

@export_category("References")
@export var holder : Control
@export var iconVisual : TextureRect
@export var regionEncounterLabel : RichTextLabel

var SCALE_DURATION : float = 0.3

func _ready() -> void:
	iconVisual.offset_transform_enabled = true
	regionEncounterLabel.offset_transform_enabled = true

#-
func _set_region_encounter_label(region : int, encounter : int):
	regionEncounterLabel.text = str(region) + " - " + str(encounter)

func _hide():
	iconVisual.offset_transform_scale = Vector2.ZERO
	regionEncounterLabel.offset_transform_scale = Vector2.ZERO

func _show():
	var newTween : Tween = create_tween()
	
	newTween.tween_property(iconVisual, "offset_transform_scale", Vector2(1, 1), SCALE_DURATION)\
	.set_trans(Tween.TRANS_BACK). set_ease(Tween.EASE_OUT)
	newTween.tween_property(regionEncounterLabel, "offset_transform_scale", Vector2(1, 1), SCALE_DURATION)\
	.set_trans(Tween.TRANS_BACK). set_ease(Tween.EASE_OUT)
	
	await newTween.finished

#- - -
func _get_global_icon_center() -> Vector2:
	var center : Vector2 = Vector2.ZERO
	
	center = iconVisual.get_global_rect().get_center()
	
	return center
