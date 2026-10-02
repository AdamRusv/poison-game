extends Control

class_name PlaymatManager

@export_category("References")
@export var gameplayManager : GameplayManager
@export var paperHolder : Control

var mainTraitSheet : PaperInfo
var characterSheet : EncounterInfo
var atlasRegionSheet : PaperInfo

var testPaperRef : PackedScene = load("res://1_Scenes/1_Objects/paper.tscn") #TODO: Make actual papers, replace variable

var papers : Array[Paper]

func _ready() -> void:
	gameplayManager.playmatManager = self

func _add_main_papers():
	if mainTraitSheet != null:
		_create_paper(testPaperRef, Color("4b3d44"), mainTraitSheet)
	
	if characterSheet != null:
		_create_paper(testPaperRef, Color("4b3d44"), characterSheet)
	
	if atlasRegionSheet != null:
		_create_paper(testPaperRef, Color("4b3d44"), atlasRegionSheet)


#-----------------------

func _create_paper(paperRef : PackedScene, paperColor : Color, paperInfo : PaperInfo):
	var paperInstance : Paper = paperRef.instantiate()

	paperInstance._setup_paper(paperInfo)
	
	paperInstance.self_modulate = paperColor
	paperInstance.playmat = self
	
	paperHolder.add_child(paperInstance)
