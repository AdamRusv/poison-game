extends Node

var transitionEncounterRef : PackedScene = preload("res://1_Scenes/0_Screens/transition encounter.tscn")
var transitionEncounter : TransitionEncounter = null

enum TransitionStates{
	blank,
	retry,
	restarting,
	traveling,
	mainMenuTraveling
}

func _create_transition(state : TransitionStates = TransitionStates.blank):
	if TransitionManager.transitionEncounter != null:
		TransitionManager.transitionEncounter.queue_free()
	
	transitionEncounter = transitionEncounterRef.instantiate()
	add_child(transitionEncounter)
	
	await transitionEncounter._start_transition(state)
