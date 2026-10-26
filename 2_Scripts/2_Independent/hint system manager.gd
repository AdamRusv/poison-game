extends Control

class_name HintSystemManager

@export_category("Reference")
@export var gameplayManager : GameplayManager
@export var closedDetectionZone : Control
@export var openDetectionZone : Control

@export_group("Hint Box")
@export var hintBox : Control
@export var hintLabels : Array[RichTextLabel]
@export var hintButtons : Array[Button]
@export var hoveredLabelBackgrounds : Array[ColorRect]
@export var hoveredHintLabels : Array[RichTextLabel]

var usedHints : Array[int] = []

func _ready() -> void:
	gameplayManager.hintSystemManager = self
	hintBox.visible = false
	closedDetectionZone.visible = false
	openDetectionZone.visible = false
	
	_hide_all_hovers()
	
	_set_connections()
	
	await get_tree().process_frame
	_setup_hint_box()
func _set_connections():
	closedDetectionZone.mouse_entered.connect(_closed_detection_enter)
	
	for i in range(0, hintButtons.size()):
		hintButtons[i].mouse_entered.connect(_hint_enter.bind(i))
		hintButtons[i].mouse_exited.connect(_hint_exit.bind(i))
		hintButtons[i].button_down.connect(_hint_exit.bind(i))
		hintButtons[i].button_up.connect(_hint_enter.bind(i))
		hintButtons[i].pressed.connect(_trigger_hint.bind(i))

func _process(delta: float) -> void:
	if _is_inside_open_detection_zone() == false && openDetectionZone.visible == true:
		openDetectionZone.visible = false
		hintBox.visible = false

#- - -
func _closed_detection_enter():
	if gameplayManager.cupIsPoisoned == true:
		return
	
	openDetectionZone.visible = true
	hintBox.visible = true

#-----------
var hints : DialogueTree = null
func _setup_hint_box():
	hints = gameplayManager.playmatManager.characterSheet.hints
	if hints != null:
		closedDetectionZone.visible = true
	else:
		return
	hints._setup_branches(gameplayManager)
	
	for hint in hintLabels:
		hint.get_parent().visible = false
	
	for i in range(0, hints.branches.size()):
		hintLabels[i].get_parent().visible = true
		hintLabels[i].text = hints.branches[i].dialogue[0].dialogue
		hoveredHintLabels[i].text = hints.branches[i].dialogue[0].dialogue

#
func _hint_enter(i : int):
	if usedHints.has(i):
		return
	
	hoveredLabelBackgrounds[i].visible = true
	hoveredHintLabels[i].visible = true

func _hint_exit(i : int):
	_hide_all_hovers()

func _trigger_hint(currentBranch : int):
	if usedHints.has(currentBranch):
		return
	
	usedHints.append(currentBranch)
	_disable_used_hints()
	
	var dialogueManager : DialogueManager = gameplayManager.dialogueManager
	dialogueManager._create_new_dialogue_branch_separator()
	await dialogueManager._create_dialogue_bubble(hints.branches[currentBranch], 0)
	for i in range(1, hints.branches[currentBranch].dialogue.size()): #ignore first index since its always player dialogue
		await dialogueManager._create_dialogue_bubble(hints.branches[currentBranch], i)

#---------------------------
func _hide_all_hovers():
	for i in range(0, hintButtons.size()):
		hoveredLabelBackgrounds[i].visible = false
		hoveredHintLabels[i].visible = false

func _disable_used_hints():
	for i in range(0, hintButtons.size()):
		for usedHint in usedHints:
			if i == usedHint:
				hintLabels[i].self_modulate.a = 0.4
				break

#
func _is_inside_open_detection_zone() -> bool:
	var mousePos : Vector2 = get_global_mouse_position()
	return openDetectionZone.get_global_rect().has_point(mousePos)
