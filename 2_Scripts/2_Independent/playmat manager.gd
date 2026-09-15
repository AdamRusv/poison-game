extends Control

class_name PlaymatManager

@export_category("References")
@export var paperHolder : Control

var testPaperRef : PackedScene = load("res://1_Scenes/1_Objects/paper.tscn") #TODO: Make actual papers, replace variable

var papers : Array[Paper]

func _ready() -> void:
	await get_tree().process_frame
	_create_paper(testPaperRef, Color.DARK_CYAN)
	_create_paper(testPaperRef, Color.WHITE)
	_create_paper(testPaperRef, Color.YELLOW_GREEN)
	_create_paper(testPaperRef, Color.DARK_GOLDENROD)


#-----------------------

func _create_paper(paperRef : PackedScene, paperColor : Color):
	var paperInstance : Paper = paperRef.instantiate()
	
	paperInstance.self_modulate = paperColor
	paperInstance.playmat = self
	
	paperHolder.add_child(paperInstance)
