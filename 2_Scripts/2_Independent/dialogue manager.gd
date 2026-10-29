extends Control

class_name DialogueManager

@export_category("Reference")
@export var gameplayManager : GameplayManager
@export var scrollContainer : ScrollContainer
@export var content : VBoxContainer

signal branchFinished(branch : DialogueBranch)

func _ready() -> void:
	gameplayManager.dialogueManager = self
func _process(delta: float) -> void:
	_manage_scroll()

#---------------
func _start_dialogue():
	var encounterDialogue : DialogueTree = gameplayManager.playmatManager.characterSheet.dialogueTree
	encounterDialogue._setup_branches(gameplayManager)
	
	_trigger_dialogue_branch()

var currentBranch : DialogueBranch = null
var newBranchSeparatorRef : PackedScene = preload("res://1_Scenes/1_Objects/new branch separator.tscn")
var queueDialogue : bool = false
func _trigger_dialogue_branch():
	queueDialogue = true
	var encounterDialogue : DialogueTree = gameplayManager.playmatManager.characterSheet.dialogueTree
	
	var newCurrentBranch : DialogueBranch = encounterDialogue._get_current_branch()
	if newCurrentBranch.newestDialogueIndex >= newCurrentBranch.dialogue.size() - 1:
		newCurrentBranch.hasBeenShown = true
		branchFinished.emit(newCurrentBranch)
		return
	
	var newDialogue : Dialogue = encounterDialogue._get_new_dialogue()
	if newDialogue == null:
		return
	
	if currentBranch != null && currentBranch != newCurrentBranch:
		await _create_new_dialogue_branch_separator()
	currentBranch = newCurrentBranch
	
	queueDialogue = false
	await _create_dialogue_bubble(newCurrentBranch, currentBranch.newestDialogueIndex)
	await get_tree().create_timer(0.6).timeout
	
	if queueDialogue == true:
		return
	_trigger_dialogue_branch()

func _set_dialogue_view_to_bottom():
	if isScrolling == true:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var maxScrollValue : float = scrollContainer.get_v_scroll_bar().max_value - scrollContainer.get_v_scroll_bar().page
	scrollContainer.scroll_vertical = maxScrollValue

#- - -
var playerDialogueBubbleRef : PackedScene = preload("res://1_Scenes/1_Objects/player dialogue bubble.tscn")
var opponenetDialogueBubbleRef : PackedScene = preload("res://1_Scenes/1_Objects/opponent dialogue bubble.tscn")
var separatorRef : PackedScene = preload("res://1_Scenes/1_Objects/different speaker separator.tscn")
var bubbles : Array[DialogueBubble]

func _create_dialogue_bubble(dialogueBranch : DialogueBranch, dialogueIndex : int):
	var newDialogue : Dialogue = dialogueBranch.dialogue[dialogueIndex]
	
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
	await _animate_new_dialogue_bubble(dialogueBubble)

#
var currentAnimatingDialogueBubble : DialogueBubble = null
var currentDialogueBubbleTween : Tween = null
func _create_new_dialogue_branch_separator():
	bubbles.clear()
	var newBranchSeparator : Control = newBranchSeparatorRef.instantiate()
	var separator = separatorRef.instantiate()
	content.add_child(newBranchSeparator)
	content.add_child(separator)
	_animate_new_branch_separator(newBranchSeparator)
	await get_tree().create_timer(0.4).timeout

func _animate_new_dialogue_bubble(dialogueBubble : DialogueBubble):
	if currentAnimatingDialogueBubble != null && currentDialogueBubbleTween != null:
		if currentAnimatingDialogueBubble.finishedTween == false:
			currentDialogueBubbleTween.pause()
			currentAnimatingDialogueBubble._add_cutoff()
	
	currentAnimatingDialogueBubble = dialogueBubble
	
	var dialogueBubbleExpandTween : Tween = create_tween()
	dialogueBubbleExpandTween.tween_property(currentAnimatingDialogueBubble.texture, "custom_minimum_size:x", currentAnimatingDialogueBubble.dialogueSize.x, 0.5)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	dialogueBubbleExpandTween.tween_callback(currentAnimatingDialogueBubble._show_label)
	
	await dialogueBubbleExpandTween.finished
	currentDialogueBubbleTween = create_tween()
	var dialogueCharacterCount : int = currentAnimatingDialogueBubble.dialogueLabel.text.length()
	var normalizedCharacterVisibilityDuration : float = dialogueCharacterCount * 0.04
	currentDialogueBubbleTween.tween_property(currentAnimatingDialogueBubble.dialogueLabel, "visible_characters", dialogueCharacterCount, normalizedCharacterVisibilityDuration)
	
	await currentDialogueBubbleTween.finished
	currentAnimatingDialogueBubble.finishedTween = true

#- - - - - -
func _animate_new_branch_separator(newSeparator : HSeparator):
	await _set_dialogue_view_to_bottom()
	var newTween : Tween = create_tween().set_parallel()
	
	var line : StyleBoxLine = newSeparator.get_theme_stylebox("separator", )
	newTween.tween_property(line, "grow_begin", 13, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	newTween.tween_property(line, "grow_end", 13, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

#---------------SCROLL---------------
var isScrolling : bool = false
var isSkipping : bool = false
var startMousePos : Vector2 = Vector2.ZERO
var startScrollPos : float

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
