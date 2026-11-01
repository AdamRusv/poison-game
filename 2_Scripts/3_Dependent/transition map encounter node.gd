extends Control

class_name TransitionMapEncounterNode

@export_category("References")
@export var holder : Control
@export var iconVisual : TextureRect
@export var regionEncounterLabel : RichTextLabel

func _ready() -> void:
	iconVisual.offset_transform_enabled = true
	regionEncounterLabel.offset_transform_enabled = true

#-
func _set_region_encounter_label(region : int, encounter : int):
	regionEncounterLabel.text = str(region) + " - " + str(encounter)

func _hide():
	iconVisual.offset_transform_scale = Vector2.ZERO
	regionEncounterLabel.offset_transform_scale = Vector2.ZERO

#- - -
func _get_global_icon_center() -> Vector2:
	var center : Vector2 = Vector2.ZERO
	
	center = iconVisual.get_global_rect().get_center()
	
	return center
