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
@export var line : Line2D
@export_group("Additional Info")
@export var additionalInfoHeaderLabel : RichTextLabel
@export var additionalInfoDescriptionLabel : RichTextLabel
@export var additionalInfoData : TransitionAdditionalInfoData

const PLAYER_ICON_Y_OFFSET : int = -18

var gamestateJSON : GamestateJSON = GamestateJSON.new()

var upperMapEncounterNodeRef : PackedScene = preload("res://1_Scenes/1_Objects/upper map encounter node.tscn")
var lowerMapEncounterNodeRef : PackedScene = preload("res://1_Scenes/1_Objects/lower map encounter node.tscn")

var mapEncounterNodes : Array[TransitionMapEncounterNode]
var linePoints : Array[Vector2]

func _ready() -> void:
	gamestateJSON._load_gamestate()
	
	_hide_all()
	_set_visuals()
func _hide_all():
	travelingLabel.visible = false
	playerIcon.visible = false
	playerShadow.visible = false
	line.visible = false
	additionalInfoHeaderLabel.visible = false
	additionalInfoDescriptionLabel.visible = false
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
