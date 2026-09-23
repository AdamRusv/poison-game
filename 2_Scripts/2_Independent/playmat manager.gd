extends Control

class_name PlaymatManager

@export_category("References")
@export var paperHolder : Control

@export_category("Delete Later (For testing)")
@export var mainTraitSheet : PaperInfo
@export var characterSheet : PaperInfo
@export var atlasRegionSheet : PaperInfo

var testPaperRef : PackedScene = load("res://1_Scenes/1_Objects/paper.tscn") #TODO: Make actual papers, replace variable

var papers : Array[Paper]

func _ready() -> void:
	await get_tree().process_frame
	_create_paper(testPaperRef, Color("4b3d44"), mainTraitSheet)
	_create_paper(testPaperRef, Color("4b3d44"), characterSheet)
	_create_paper(testPaperRef, Color("4b3d44"), atlasRegionSheet)
	#_create_paper(testPaperRef, Color("4b3d44"))
	#_create_paper(testPaperRef, Color("4b3d44"))


#-----------------------

func _create_paper(paperRef : PackedScene, paperColor : Color, paperInfo : PaperInfo):
	var paperInstance : Paper = paperRef.instantiate()

	if paperInfo.info.size() > 1:
		pass #TODO: Packet Visual

	paperInstance._setup_paper(paperInfo)
	
	paperInstance.self_modulate = paperColor
	paperInstance.playmat = self
	
	paperHolder.add_child(paperInstance)
