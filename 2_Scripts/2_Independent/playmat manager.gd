extends Control

class_name PlaymatManager

@export_category("References")
@export var gameplayManager : GameplayManager
@export var paperHolder : Control
@export var spawnLocations : Control

var mainTraitSheet : PaperInfo
var characterSheet : EncounterInfo

#var testPaperRef : PackedScene = load("res://1_Scenes/1_Objects/paper.tscn") #TODO: Make actual papers, replace variable
var testPaperRef : PackedScene = load("res://1_Scenes/1_Objects/paper.tscn")
var testAtlasRef : PackedScene = load("res://1_Scenes/1_Objects/atlas.tscn")

var papers : Array[Paper]

func _ready() -> void:
	gameplayManager.playmatManager = self

func _add_main_papers():
	if mainTraitSheet != null:
		_create_paper(testPaperRef, mainTraitSheet)
	
	if characterSheet != null:
		_create_paper(testPaperRef, characterSheet)
	
	if gameplayManager.atlasHolder != null:
		_create_atlas(testAtlasRef, gameplayManager.atlasHolder, gameplayManager.currentRegion)


#-----------------------

func _create_paper(paperRef : PackedScene, paperInfo : PaperInfo):
	var paperInstance : Paper = paperRef.instantiate()

	paperInstance._setup_paper(paperInfo)

	paperInstance.playmat = self
	
	paperHolder.add_child(paperInstance)

func _create_atlas(atlasRef : PackedScene, atlasHolder : AtlasHolder, regionInfo : RegionInfo):
	var atlasInstance : AtlasBook = atlasRef.instantiate()

	atlasInstance._setup_atlas(atlasHolder, regionInfo)

	atlasInstance.playmat = self


	paperHolder.add_child(atlasInstance)

#----------------------
func _get_random_paper_spawn_location() -> Vector2:
	var xPoint : int = randi_range(spawnLocations.position.x, spawnLocations.size.x)
	var yPoint : int = randi_range(spawnLocations.position.y, spawnLocations.size.y)
	return Vector2(xPoint, yPoint)
