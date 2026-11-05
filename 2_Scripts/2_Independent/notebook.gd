extends Paper

class_name Notebook

@export_category("References")
@export var textEdit : TextEdit

func _init() -> void:
	canBePacket = false
#func _validate_property(property: Dictionary) -> void: #cant use @tool with Input
	#if property.name == "paperTitleLabel":
		#property.usage = PROPERTY_USAGE_NO_EDITOR
	#if property.name == "paperInfoLabel":
		#property.usage = PROPERTY_USAGE_NO_EDITOR
	#if property.name == "packetParent":
		#property.usage = PROPERTY_USAGE_NO_EDITOR
	#if property.name == "packetBehindPaperParent":
		#property.usage = PROPERTY_USAGE_NO_EDITOR
	#if property.name == "pageFlipButton":
		#property.usage = PROPERTY_USAGE_NO_EDITOR
	#if property.name == "pageFlipTexture":
		#property.usage = PROPERTY_USAGE_NO_EDITOR

func _process(delta: float) -> void:
	super._process(delta)
	if Input.is_action_just_pressed("escape"):
		textEdit.release_focus()
	
	if textEdit.has_focus() == true:
		Settings.canToggleFullscreen = false
	else:
		Settings.canToggleFullscreen = true
