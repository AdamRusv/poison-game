extends Control

class_name GameplayManager

var playmatManager : PlaymatManager
var poisonManager : PoisonManager
var cupsManager : CupsManager
var dialogueManager : DialogueManager

var cupCount : int = 2 #NOTE: change for other gamemodes

var holdingPoison : bool = false
signal poisonGrabbed
signal poisonReleased
var cupIsPoisoned : bool = false
signal cupHasBeenPoisoned

var currentPoisonCup : CurrentPoisonCup = CurrentPoisonCup.none
enum CurrentPoisonCup{
	none,
	opponent,
	player
}
