extends Control

class_name PlaymatManager

@export_category("References")
@export var gameplayManager : GameplayManager
@export var paperHolder : Control
@export var spawnLocations : Control

var paperSavestateJSON : PapersavestateJSON = PapersavestateJSON.new()
var papersByRole : Dictionary = {}
var savedPaperPositions : Dictionary = {}

var mainTraitSheet : PaperInfo
var characterSheet : EncounterInfo

#var testPaperRef : PackedScene = load("res://1_Scenes/1_Objects/paper.tscn") #TODO: Make actual papers, replace variable
var testPaperRef : PackedScene = load("res://1_Scenes/1_Objects/test_paper.tscn")
var testAtlasRef : PackedScene = load("res://1_Scenes/1_Objects/atlas.tscn")
var notebookRef : PackedScene = load("res://1_Scenes/1_Objects/notebook.tscn")

var papers : Array[Paper]

func _ready() -> void:
	gameplayManager.playmatManager = self

func _add_main_papers():
	savedPaperPositions = paperSavestateJSON._load_paper_positions()

	if mainTraitSheet != null:
		_create_paper(testPaperRef, mainTraitSheet, "traitSheet")
	
	if characterSheet != null:
		_create_paper(testPaperRef, characterSheet, "characterSheet")
	
	if gameplayManager.atlasHolder != null && gameplayManager.currentRegion.maxCountryCount > 0:
		_create_atlas(testAtlasRef, gameplayManager.atlasHolder, gameplayManager.currentRegion)
	
	if gameplayManager.currentRegion.noteSheet == true:
		_create_notebook()

#-----------------------

func _create_paper(paperRef : PackedScene, paperInfo : PaperInfo, paperRole : String):
	var paperInstance : Paper = paperRef.instantiate()

	paperInstance._setup_paper(paperInfo)

	paperInstance.playmat = self

	papersByRole[paperRole] = paperInstance
	paperInstance.paperRole	= paperRole
	paperHolder.add_child(paperInstance)

func _create_atlas(atlasRef : PackedScene, atlasHolder : AtlasHolder, regionInfo : RegionInfo):
	var atlasInstance : AtlasBook = atlasRef.instantiate()

	atlasInstance._setup_atlas(atlasHolder, regionInfo)

	atlasInstance.playmat = self

	papersByRole["atlas"] = atlasInstance
	atlasInstance.paperRole = "atlas"
	paperHolder.add_child(atlasInstance)

func _create_notebook():
	var notebookInstance : Notebook = notebookRef.instantiate()

	notebookInstance.playmat = self

	papersByRole["notebook"] = notebookInstance
	notebookInstance.paperRole = "notebook"
	paperHolder.add_child(notebookInstance)

#----------------------
func _get_random_paper_spawn_location() -> Vector2:
	var xPoint : int = randi_range(spawnLocations.position.x, spawnLocations.size.x)
	var yPoint : int = randi_range(spawnLocations.position.y, spawnLocations.size.y)
	return Vector2(xPoint, yPoint)

func _get_paper_spawn_location(paperRole : String) -> Vector2:
	if savedPaperPositions.has(paperRole):
		return savedPaperPositions[paperRole]

	return _get_random_paper_spawn_location()

func _save_paper_positions():
	if papersByRole.is_empty():
		return
	
	var paperPositions : Dictionary = {}

	for paperRole in papersByRole:
		var paper : Paper = papersByRole[paperRole]

		if !is_instance_valid(paper):
			return
		
		paperPositions[paperRole] = paper.parentNode.position

	paperSavestateJSON._save_paper_positions(paperPositions)
