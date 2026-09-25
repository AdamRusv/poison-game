extends Control

class_name DialogueManager

@export_category("Reference")
@export var gameplayManager : GameplayManager
@export var scrollContainer : ScrollContainer
@export var content : VBoxContainer

var isScrolling : bool = false
var startMousePos : Vector2 = Vector2.ZERO
var startScrollPos : float


func _ready() -> void:
	gameplayManager.dialogueManager = self
	
	await get_tree().process_frame
	_create_dialogue_bubble()
	_create_dialogue_bubble()
	_create_dialogue_bubble()
	_create_dialogue_bubble()
	_create_dialogue_bubble()
	_create_dialogue_bubble()
	_create_dialogue_bubble()

func _process(delta: float) -> void:
	_manage_scroll()

#---------------
var playerDialogueBubbleRef : PackedScene = preload("res://1_Scenes/1_Objects/player dialogue bubble.tscn")
var opponenetDialogueBubbleRef : PackedScene = preload("res://1_Scenes/1_Objects/opponent dialogue bubble.tscn")
var separatorRef : PackedScene = preload("res://1_Scenes/1_Objects/different speaker separator.tscn")
var bubbles : Array[DialogueBubble]

func _create_dialogue_bubble():
	var encounterDialogue : DialogueTree = gameplayManager.playmatManager.characterSheet.dialogueTree
	var newDialogue : Dialogue = encounterDialogue._get_new_dialogue()

	var dialogueBubble : DialogueBubble = null
	if newDialogue.speaker == Dialogue.Speaker.opponent:
		dialogueBubble = opponenetDialogueBubbleRef.instantiate()
		dialogueBubble.speaker = Dialogue.Speaker.opponent
	else:
		dialogueBubble = playerDialogueBubbleRef.instantiate()
		dialogueBubble.speaker = Dialogue.Speaker.player
	
	dialogueBubble.dialogueLabel.text = newDialogue.dialogue
	
	var separator : Control = null
	if bubbles.size() > 0:
		if newDialogue.speaker == Dialogue.Speaker.opponent:
			if bubbles[bubbles.size() - 1].speaker == Dialogue.Speaker.player:
				separator = separatorRef.instantiate()
		else:
			if bubbles[bubbles.size() - 1].speaker == Dialogue.Speaker.opponent:
				separator = separatorRef.instantiate()
	if separator != null:
		content.add_child(separator)
	
	bubbles.append(dialogueBubble)
	content.add_child(dialogueBubble)


#---------------
func _manage_scroll():
	if Input.is_action_just_pressed("left click"):
		if _is_cursor_within_scroll_zone() == true:
			startMousePos = get_global_mouse_position()
			startScrollPos = scrollContainer.scroll_vertical
			isScrolling = true
	if Input.is_action_just_released("left click"):
		isScrolling = false
	
	if isScrolling == true:
		var newScrollPos : float = startMousePos.y - get_global_mouse_position().y + startScrollPos
		
		var maxScrollValue : float = scrollContainer.get_v_scroll_bar().max_value - scrollContainer.get_v_scroll_bar().page
		var finalValue : float = clamp(newScrollPos, 0, maxScrollValue)
		
		scrollContainer.scroll_vertical = finalValue

#- - -
func _is_cursor_within_scroll_zone() -> bool:
	var mousePos : Vector2 = get_global_mouse_position()
	return scrollContainer.get_global_rect().has_point(mousePos)
