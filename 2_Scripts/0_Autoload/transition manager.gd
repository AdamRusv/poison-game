extends Node

var transitionEncounterRef : PackedScene = preload("res://1_Scenes/0_Screens/transition encounter.tscn")
var transitionEncounter : TransitionEncounter = null

func _create_transition():
	if TransitionManager.transitionEncounter != null:
		TransitionManager.transitionEncounter.queue_free()
	
	transitionEncounter = transitionEncounterRef.instantiate()
	transitionEncounter._start_transition()
	add_child(transitionEncounter)
