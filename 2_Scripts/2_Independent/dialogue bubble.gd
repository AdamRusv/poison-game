extends Control

class_name DialogueBubble

@export_category("References")
@export var visualHolder : Control
@export var texture : NinePatchRect
@export var labelHolder : MarginContainer
@export var dialogueLabel : RichTextLabel

var speaker : Dialogue.Speaker = Dialogue.Speaker.opponent

var dialogueSize : Vector2 = Vector2.ZERO


func _set_length_size():
	dialogueSize = visualHolder.size
	visualHolder.custom_minimum_size.y = dialogueSize.y

func _hide_label():
	dialogueLabel.visible_characters = 0
	dialogueLabel.visible = false

func _show_label():
	dialogueLabel.visible = true
