extends Control

class_name DialogueManager

@export_category("Reference")
@export var gameplayManager : GameplayManager
@export var scrollContainer : ScrollContainer
@export var content : VBoxContainer


func _ready() -> void:
	gameplayManager.dialogueManager = self

func _process(delta: float) -> void:
	_manage_scroll()
	
	if Input.is_action_just_pressed("spacebar"):
		_trigger_dialogue_branch()

#---------------
func _trigger_dialogue_branch():
	canScroll = false
	
	var encounterDialogue : DialogueTree = gameplayManager.playmatManager.characterSheet.dialogueTree
	encounterDialogue._setup_branches(gameplayManager)
	
	var newDialogue : Dialogue = encounterDialogue._get_newest_dialogue()
	if newDialogue == null:
		canScroll = true
		return
	
	if encounterDialogue._get_current_branch().newestDialogueIndex >= encounterDialogue._get_current_branch().dialogue.size() - 1:
		encounterDialogue._get_current_branch().hasBeenShown = true
		canScroll = true
		return
	
	await _create_dialogue_bubble()
	await get_tree().create_timer(0.8).timeout ##TODO: replace with bubble tween
	_trigger_dialogue_branch()

func _set_dialogue_view_to_bottom():
	await get_tree().process_frame
	var maxScrollValue : float = scrollContainer.get_v_scroll_bar().max_value - scrollContainer.get_v_scroll_bar().page
	scrollContainer.scroll_vertical = maxScrollValue 

#- - -
var playerDialogueBubbleRef : PackedScene = preload("res://1_Scenes/1_Objects/player dialogue bubble.tscn")
var opponenetDialogueBubbleRef : PackedScene = preload("res://1_Scenes/1_Objects/opponent dialogue bubble.tscn")
var separatorRef : PackedScene = preload("res://1_Scenes/1_Objects/different speaker separator.tscn")
var bubbles : Array[DialogueBubble]

func _create_dialogue_bubble() -> Tween:
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
	
	dialogueBubble._set_length_size()
	dialogueBubble._hide_label()
	
	_set_dialogue_view_to_bottom()
	await _animate_new_dialogue_bubble(dialogueBubble).finished
	return 

func _animate_new_dialogue_bubble(dialogueBubble : DialogueBubble) -> Tween:
	var newTween : Tween = create_tween()
	
	newTween.tween_property(dialogueBubble.texture, "custom_minimum_size:x", dialogueBubble.dialogueSize.x, 0.5)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	newTween.tween_callback(dialogueBubble._show_label)
	
	var dialogueCharacterCount : int = dialogueBubble.dialogueLabel.text.length()
	var normalizedCharacterVisibilityDuration : float = dialogueCharacterCount * 0.04
	newTween.tween_property(dialogueBubble.dialogueLabel, "visible_characters", dialogueCharacterCount, normalizedCharacterVisibilityDuration)
	
	return newTween

#---------------SCROLL---------------
var isScrolling : bool = false
var startMousePos : Vector2 = Vector2.ZERO
var startScrollPos : float
var canScroll : bool = false

func _manage_scroll():
	if canScroll == false:
		isScrolling = false
		return
	
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

func _enable_scroll():
	canScroll = true

func _disable_scroll():
	canScroll = true

#- - -
func _is_cursor_within_scroll_zone() -> bool:
	var mousePos : Vector2 = get_global_mouse_position()
	return scrollContainer.get_global_rect().has_point(mousePos)
