extends Control

class_name TransitionCutscene

@export_category("References")
@export var transitionEncounter : TransitionEncounter
@export var gameTimeline : GameTimeline
@export_group("Header")
@export var travelingLabel : RichTextLabel
@export_group("Visual")
@export var playerIcon : TextureRect
@export var playerShadow : TextureRect
@export var visualMapHolder : HBoxContainer
@export var lineHolder : SubViewportContainer
@export var line : Line2D
@export_group("Additional Info")
@export var additionalInfoHeaderLabel : RichTextLabel
@export var additionalInfoDescriptionLabel : RichTextLabel
@export var additionalInfoData : TransitionAdditionalInfoData

const PLAYER_ICON_Y_OFFSET : int = -18
const FADE_IN_Y_OFFSET : int = 10

var gamestateJSON : GamestateJSON = GamestateJSON.new()

var upperMapEncounterNodeRef : PackedScene = preload("res://1_Scenes/1_Objects/upper map encounter node.tscn")
var lowerMapEncounterNodeRef : PackedScene = preload("res://1_Scenes/1_Objects/lower map encounter node.tscn")

var mapEncounterNodes : Array[TransitionMapEncounterNode]
var linePoints : Array[Vector2]

func _ready() -> void:
	gamestateJSON._load_gamestate()
	
	_hide_and_setup_all()
	
	await get_tree().process_frame #waits for transitionState to be set
	_set_visuals()
	
	await transitionEncounter.fullyClosed
	
	match transitionEncounter.transitionState:
		TransitionManager.TransitionStates.blank:
			await get_tree().create_timer(0.3).timeout
			transitionEncounter._end_transition()
			return
		TransitionManager.TransitionStates.retry:
			travelingLabel.text = _get_new_traveling_text("Retry...")
		TransitionManager.TransitionStates.restarting:
			travelingLabel.text = _get_new_traveling_text("Restarting...")
	
	await get_tree().create_timer(0.3).timeout
	await _trigger_show_animations()
	await get_tree().create_timer(1).timeout
	await _trigger_hide_animations()
	finishedAnimating.emit()
	transitionEncounter._end_transition()
func _hide_and_setup_all():
	travelingLabel.offset_transform_enabled = true
	travelingLabel.offset_transform_position.y = FADE_IN_Y_OFFSET
	additionalInfoHeaderLabel.offset_transform_enabled = true
	additionalInfoHeaderLabel.offset_transform_position.y = FADE_IN_Y_OFFSET
	additionalInfoDescriptionLabel.offset_transform_enabled = true
	additionalInfoDescriptionLabel.offset_transform_position.y = FADE_IN_Y_OFFSET
	
	travelingLabel.self_modulate.a = 0
	
	visualMapHolder.offset_transform_enabled = true
	lineHolder.offset_transform_enabled = true
	
	playerIcon.offset_transform_enabled = true
	playerIcon.offset_transform_position.y = -350.0
	playerShadow.offset_transform_enabled = true
	playerShadow.offset_transform_scale = Vector2.ZERO
	
	additionalInfoHeaderLabel.self_modulate.a = 0
	additionalInfoDescriptionLabel.self_modulate.a = 0
func _set_visuals():
	var totalEncounters : int = _get_total_encounters_for_current_region()
	var regionNumber : int = _get_region_number()
	var currentEncounterNumber : int = _get_current_encounter_number()
	
	_set_map_nodes(totalEncounters, regionNumber)
	_set_player_pos(currentEncounterNumber)
	_set_line(totalEncounters)
	_set_additional_info()
func _set_map_nodes(totalEncounters : int, regionNumber : int):
	for i in range(0, totalEncounters):
		var mapEncounterNode : TransitionMapEncounterNode = null
		if i % 2 == 0: #even
			mapEncounterNode = upperMapEncounterNodeRef.instantiate()
		else: #odd
			mapEncounterNode = lowerMapEncounterNodeRef.instantiate()
		mapEncounterNode._set_region_encounter_label(regionNumber, i + 1)
		mapEncounterNode._hide()
		
		mapEncounterNodes.append(mapEncounterNode)
		visualMapHolder.add_child(mapEncounterNode)
func _set_player_pos(currentEncounterNumber : int):
	if transitionEncounter.transitionState == TransitionManager.TransitionStates.mainMenuTraveling && currentEncounterNumber > 1:
		currentEncounterNumber -= 1
	await get_tree().process_frame
	var playerPos : Vector2 = Vector2.ZERO
	playerPos = mapEncounterNodes[currentEncounterNumber - 1]._get_global_icon_center()
	playerPos -= playerIcon.size / 2
	playerPos.y += PLAYER_ICON_Y_OFFSET
	playerIcon.global_position = playerPos
	playerShadow.global_position = playerPos
func _set_line(totalEncounters : int):
	await get_tree().process_frame
	for i in range(0, totalEncounters):
		var nextNodePosition : Vector2 = mapEncounterNodes[i]._get_global_icon_center()
		linePoints.append(nextNodePosition)
	
	line.add_point(linePoints[0])
func _set_additional_info():
	var isTip : bool = true
	if randi_range(0, 1) == 1:
		isTip = false
	
	var randomInfo : String = ""
	if isTip == true:
		additionalInfoHeaderLabel.text = "Tip:"
		randomInfo = additionalInfoData.tips[randi_range(0, additionalInfoData.tips.size() - 1)]
	else:
		additionalInfoHeaderLabel.text = "Did you know?"
		randomInfo = additionalInfoData.didYouKnows[randi_range(0, additionalInfoData.didYouKnows.size() - 1)]
	
	additionalInfoDescriptionLabel.text = randomInfo

#- - -
func _get_region_number() -> int:
	var regionNumber : int = -1
	for i in range(0, gameTimeline.timeline.size()):
		var region : RegionInfo = gameTimeline.timeline[i]
		if i > gamestateJSON.timelineIndex:
			break
		
		if region.increaseRegion == true:
			regionNumber += 1
	return regionNumber

func _get_total_encounters_for_current_region() -> int:
	var totalEncounters : int = 1
	
	for i in range(_get_timeline_index_of_current_region_start() + 1, gameTimeline.timeline.size()):
		var region : RegionInfo = gameTimeline.timeline[i]
		if region.increaseRegion == true:
			break
		
		totalEncounters += 1
		
	return totalEncounters

func _get_current_encounter_number() -> int:
	var initalEncounterNumber : int = 0
	for i in range(0, gameTimeline.timeline.size()):
		var region : RegionInfo = gameTimeline.timeline[i]
		if i > gamestateJSON.timelineIndex:
			break
		
		if region.increaseRegion == true:
			initalEncounterNumber = 1
		else:
			initalEncounterNumber += 1
		
	var encounterNumber : int = initalEncounterNumber + gamestateJSON.currentRegionEncounterCount - 1
	
	return encounterNumber

func _get_timeline_index_of_current_region_start() -> int:
	var currentIndex : int = gamestateJSON.timelineIndex
	for i in range(currentIndex, -1, -1):
		var region : RegionInfo = gameTimeline.timeline[i]
		if region.increaseRegion == true:
			return i
		
	return -1


#----------------------ANIMATIONS----------------------
signal finishedAnimating

const MAP_NODE_DELAY : float = 0.25
const LINE_TRAVEL_TIME : float = 0.35
const PLAYER_INTRO_DURATION : float = 1.0
const LABEL_FADE_IN_DURATION : float = 0.2
const PLAYER_WALK_BETWEEN_MAP_NODES_DURATION : float = 0.35

func _trigger_show_animations():
	await _show_visual()
	await _animate_line()
	
	await _intro_player()
	
	await _show_traveling()
	
	await _show_additional_info_header()
	await _show_additional_info_description()
	
	await get_tree().create_timer(0.2).timeout
	
	
	await _move_player(_set_player_ending_pos())

func _show_visual():
	for i in range(0, mapEncounterNodes.size()):
		mapEncounterNodes[i]._animate_show()
		await get_tree().create_timer(MAP_NODE_DELAY).timeout
func _animate_line():
	var currentEncounterNumber : int = _get_current_encounter_number()
	if transitionEncounter.transitionState == TransitionManager.TransitionStates.mainMenuTraveling && currentEncounterNumber > 1:
		currentEncounterNumber -= 1
	for i in range(0, currentEncounterNumber - 1):
		await _animate_line_point(i + 1)
func _animate_line_point(i : int):
	if i > linePoints.size() - 1:
		return
	
	line.add_point(linePoints[i - 1])
	
	var newTween : Tween = create_tween()
	
	newTween.tween_method(_set_point_position.bind(i), linePoints[i - 1], linePoints[i], LINE_TRAVEL_TIME)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await newTween.finished
func _set_point_position(newPosition : Vector2, index : int):
	line.set_point_position(index, newPosition)
func _intro_player():
	var newTween : Tween = create_tween().set_parallel()
	
	newTween.tween_property(playerShadow, "offset_transform_scale", Vector2.ONE, PLAYER_INTRO_DURATION)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	newTween.tween_property(playerIcon, "offset_transform_position:y", 0.0, PLAYER_INTRO_DURATION)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await newTween.finished

func _show_traveling():
	var newTween : Tween = create_tween().set_parallel()
	
	newTween.tween_property(travelingLabel, "self_modulate:a", 1, LABEL_FADE_IN_DURATION)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	newTween.tween_property(travelingLabel, "offset_transform_position:y", 0.0, LABEL_FADE_IN_DURATION * 2)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await newTween.finished

func _show_additional_info_header():
	var newTween : Tween = create_tween().set_parallel()
	
	newTween.tween_property(additionalInfoHeaderLabel, "self_modulate:a", 1, LABEL_FADE_IN_DURATION)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	newTween.tween_property(additionalInfoHeaderLabel, "offset_transform_position:y", 0.0, LABEL_FADE_IN_DURATION * 2)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await newTween.finished
func _show_additional_info_description():
	var newTween : Tween = create_tween().set_parallel()
	
	newTween.tween_property(additionalInfoDescriptionLabel, "self_modulate:a", 1, LABEL_FADE_IN_DURATION)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	newTween.tween_property(additionalInfoDescriptionLabel, "offset_transform_position:y", 0.0, LABEL_FADE_IN_DURATION * 2)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await newTween.finished

#-
func _trigger_hide_animations():
	await _hide_visual()
	await _hide_labels()

func _hide_visual():
	for mapNodes in mapEncounterNodes:
		mapNodes._animate_hide()
	_fade_out(lineHolder)
	_fade_out(playerIcon)
	_fade_out(playerShadow)
	await _fade_out(visualMapHolder)

func _hide_labels():
	_fade_out(travelingLabel, true)
	_fade_out(additionalInfoHeaderLabel)
	await _fade_out(additionalInfoDescriptionLabel)

#--
func _move_player(endingMapNodePos : int):
	var currentEncounterNumber : int = _get_current_encounter_number()
	var totalNodes : int = endingMapNodePos - currentEncounterNumber
	if totalNodes == 0:
		return
	
	for i in range(currentEncounterNumber, endingMapNodePos):
		if i == currentEncounterNumber:
			continue
		var newTween : Tween = create_tween()
		
		newTween.tween_property(playerIcon, "offset_transform_position", mapEncounterNodes[i]._get_global_icon_center(), PLAYER_WALK_BETWEEN_MAP_NODES_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		newTween.tween_property(playerShadow, "offset_transform_position", mapEncounterNodes[i]._get_global_icon_center(), PLAYER_WALK_BETWEEN_MAP_NODES_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		await newTween.finished

#- - -
func _fade_in(targetNode : Control):
	var newTween : Tween = create_tween().set_parallel()
	
	newTween.tween_property(targetNode, "self_modulate:a", 1, LABEL_FADE_IN_DURATION)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	newTween.tween_property(targetNode, "offset_transform_position:y", 0.0, LABEL_FADE_IN_DURATION * 2)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await newTween.finished

func _fade_out(targetNode : Control, up : bool = false):
	var newTween : Tween = create_tween().set_parallel()
	
	newTween.tween_property(targetNode, "self_modulate:a", 0, LABEL_FADE_IN_DURATION)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if up == false:
		newTween.tween_property(targetNode, "offset_transform_position:y", FADE_IN_Y_OFFSET, LABEL_FADE_IN_DURATION * 2)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		newTween.tween_property(targetNode, "offset_transform_position:y", -FADE_IN_Y_OFFSET, LABEL_FADE_IN_DURATION * 2)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await newTween.finished

func _get_new_traveling_text(newText : String) -> String:
	return "[wave amp=25.0 freq=3.0 connected=1]" + newText + "[/wave]"

func _set_player_ending_pos() -> int:
	var currentEncounterNumber : int = _get_current_encounter_number()
	match transitionEncounter.transitionState:
		TransitionManager.TransitionStates.retry:
			return currentEncounterNumber
		TransitionManager.TransitionStates.restarting:
			return 0
		TransitionManager.TransitionStates.traveling:
			return currentEncounterNumber + 1
		TransitionManager.TransitionStates.mainMenuTraveling:
			return currentEncounterNumber
		
	return -1
