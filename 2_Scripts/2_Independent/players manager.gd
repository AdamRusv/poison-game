extends Control

class_name PlayersManager

@export_category("References")
@export var gameplayManager : GameplayManager
@export var playersParent : Control
##0 is opponent, 1 is player
@export var players : Array[AnimatedSprite2D]

#vector 2 is range of start and end
const SAFE_CLOSE_CUP : Vector2i = Vector2i(0, 12)
const SAFE_FAR_CUP : Vector2i = Vector2i(42, 55)
const DEATH_CLOSE_CUP : Vector2i = Vector2i(13, 26)
const DEATH_FAR_CUP : Vector2i = Vector2i(27, 41)

var opponentRange : Vector2i = Vector2i.ZERO
var playerRange : Vector2i = Vector2i.ZERO
var isAnimating : bool = false

func _ready() -> void:
	gameplayManager.cupHasBeenPoisoned.connect(_trigger_drink_animations)
func _trigger_drink_animations():
	_set_players_layering()
	opponentRange = _get_player_animation_range(0)
	playerRange = _get_player_animation_range(1)
	
	players[0].frame = opponentRange.x
	players[1].frame = playerRange.x
	players[0].play()
	players[1].play()
	
	isAnimating = true

func _process(delta: float) -> void:
	if isAnimating == false:
		return
	
	if players[0].frame == opponentRange.y:
		_stop_player_drink_animation(0)
	
	if players[1].frame == playerRange.y:
		_stop_player_drink_animation(1)
func _stop_player_drink_animation(playerIndex : int):
	isAnimating = false
	players[playerIndex].pause()
	
	await get_tree().create_timer(1).timeout
	gameplayManager.newEncounter.emit()

#-
##makes sure that the sprite with poison is behind
func _set_players_layering():
	var currentPoisonCup : GameplayManager.CurrentPoisonCup = gameplayManager.currentPoisonCup
	
	match currentPoisonCup:
		GameplayManager.CurrentPoisonCup.opponent:
			playersParent.move_child(players[1], 0)
		GameplayManager.CurrentPoisonCup.player:
			playersParent.move_child(players[1], 1)

#-----------
func _get_player_animation_range(player : int) -> Vector2i:
	var currentPoisonCup : GameplayManager.CurrentPoisonCup = gameplayManager.currentPoisonCup
	var answerCup : EncounterInfo.CupAnswer = gameplayManager.playmatManager.characterSheet.cupAnswer
	
	#based off opponent's perspective
	if player == 0:
		if answerCup == EncounterInfo.CupAnswer.opponentCup\
		&& currentPoisonCup == GameplayManager.CurrentPoisonCup.opponent:
			return DEATH_CLOSE_CUP
		elif answerCup == EncounterInfo.CupAnswer.opponentCup\
		&& currentPoisonCup == GameplayManager.CurrentPoisonCup.player:
			return SAFE_CLOSE_CUP
		
		if answerCup == EncounterInfo.CupAnswer.playerCup\
		&& currentPoisonCup == GameplayManager.CurrentPoisonCup.player:
			return DEATH_FAR_CUP
		elif answerCup == EncounterInfo.CupAnswer.playerCup\
		&& currentPoisonCup == GameplayManager.CurrentPoisonCup.opponent:
			return SAFE_FAR_CUP
	#based off player's perspective
	elif player == 1:
		if answerCup == EncounterInfo.CupAnswer.opponentCup\
		&& currentPoisonCup == GameplayManager.CurrentPoisonCup.opponent:
			return SAFE_CLOSE_CUP
		elif answerCup == EncounterInfo.CupAnswer.opponentCup\
		&& currentPoisonCup == GameplayManager.CurrentPoisonCup.player:
			return DEATH_CLOSE_CUP
		
		if answerCup == EncounterInfo.CupAnswer.playerCup\
		&& currentPoisonCup == GameplayManager.CurrentPoisonCup.player:
			return SAFE_FAR_CUP
		elif answerCup == EncounterInfo.CupAnswer.playerCup\
		&& currentPoisonCup == GameplayManager.CurrentPoisonCup.opponent:
			return DEATH_FAR_CUP
	return Vector2i.ZERO
