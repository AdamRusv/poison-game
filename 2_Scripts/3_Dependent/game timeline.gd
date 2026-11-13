extends Resource

class_name GameTimeline

@export var timeline : Array[RegionInfo]

#---------------
var gamestateJSON : GamestateJSON = GamestateJSON.new()

func _get_current_encounter_dialogue_tree() -> EncounterDialogueTree:
	var totalEncountersForCurrentRegion : int = _get_total_encounters_for_current_region()
	var currentRegionStartIndex : int = _get_timeline_index_of_current_region_start()
	var currentEncounterNumber : int = _get_current_encounter_number()
	
	var currentRegionEncounterList : Array[EncounterDialogueTree] = []
	
	for i in range(currentRegionStartIndex, timeline.size()):
		if i != currentRegionStartIndex && timeline[i].increaseRegion == true:
			break
		for ii in range(0, timeline[i].encounterDialogueTrees.size()):
			currentRegionEncounterList.append(timeline[i].encounterDialogueTrees[ii])
	
	return currentRegionEncounterList[currentEncounterNumber - 1]

#-
func _get_total_encounters_for_current_region() -> int:
	gamestateJSON._load_gamestate()
	
	var totalEncounters : int = 1
	
	for i in range(_get_timeline_index_of_current_region_start() + 1, timeline.size()):
		var region : RegionInfo = timeline[i]
		if region.increaseRegion == true:
			break
		
		totalEncounters += region.encounterDialogueTrees.size()
		
	return totalEncounters

func _get_current_encounter_number() -> int:
	gamestateJSON._load_gamestate()
	
	var initalEncounterNumber : int = 0
	for i in range(_get_timeline_index_of_current_region_start(), timeline.size()):
		var region : RegionInfo = timeline[i]
		if i >= gamestateJSON.timelineIndex:
			break
		
		initalEncounterNumber += region.encounterDialogueTrees.size()
		
	var encounterNumber : int = initalEncounterNumber + gamestateJSON.currentRegionEncounterCount
	return encounterNumber

func _get_timeline_index_of_current_region_start() -> int:
	gamestateJSON._load_gamestate()
	
	var currentIndex : int = gamestateJSON.timelineIndex
	for i in range(currentIndex, -1, -1):
		var region : RegionInfo = timeline[i]
		if region.increaseRegion == true:
			return i
		
	return -1
