extends Control

class_name CupsManager

@export_category("References")
@export var gameplayManager : GameplayManager
@export var opponentDetectionZone : Control
@export var playerDetectionZone : Control

func _ready() -> void:
	_set_connections()
func _set_connections():
	opponentDetectionZone.mouse_entered.connect(_on_enter_opponent_cup)
	playerDetectionZone.mouse_entered.connect(_on_enter_player_cup)
	opponentDetectionZone.mouse_exited.connect(_on_exit_opponent_cup)
	playerDetectionZone.mouse_exited.connect(_on_exit_player_cup)

#- - -
func _on_enter_opponent_cup():
	if gameplayManager.holdingPoison == false:
		return
	GlobalReferences.cursor.imageNode.frame = 0

func _on_enter_player_cup():
	if gameplayManager.holdingPoison == false:
		return
	GlobalReferences.cursor.imageNode.frame = 0

func _on_exit_opponent_cup():
	if gameplayManager.holdingPoison == false:
		return
	GlobalReferences.cursor.imageNode.frame = 1

func _on_exit_player_cup():
	if gameplayManager.holdingPoison == false:
		return
	GlobalReferences.cursor.imageNode.frame = 1
