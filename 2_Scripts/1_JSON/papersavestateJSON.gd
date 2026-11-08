extends Node

class_name PapersavestateJSON

const PAPERPOS_PATH : String = "user://papersaveposition.json"

func _save_paper_positions(paperPositions : Dictionary):
	var saveData : Dictionary = {}

	for paperRole in paperPositions:
		if !(paperRole is String) || !(paperPositions[paperRole] is Vector2):
			push_error("Invalid paper information")
			return
		
		var paperPosition : Vector2 = paperPositions[paperRole]
		saveData[paperRole] = {
			"x" : paperPosition.x,
			"y" : paperPosition.y
		}
	
	var file : FileAccess = FileAccess.open(PAPERPOS_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open paper position file")
		return
	
	file.store_string(JSON.stringify(saveData, "\t"))
	file.close()

func _load_paper_positions() -> Dictionary:
	var paperPositions : Dictionary = {}
	
	if !FileAccess.file_exists(PAPERPOS_PATH):
		return paperPositions
	
	var file : FileAccess = FileAccess.open(PAPERPOS_PATH, FileAccess.READ)
	if file == null:
		return paperPositions
	
	var jsonText : String = file.get_as_text()
	file.close()

	var saveData : Variant = JSON.parse_string(jsonText)
	if !(saveData is Dictionary):
		return paperPositions
	
	for paperRole in saveData:
		var positionData : Variant = saveData[paperRole]

		if !(positionData is Dictionary):
			continue
		
		var xValue : Variant = positionData.get("x")
		var yValue : Variant = positionData.get("y")

		if (typeof(xValue) != TYPE_INT && typeof(xValue) != TYPE_FLOAT) || (typeof(yValue) != TYPE_INT && typeof(yValue) != TYPE_FLOAT):
			continue
		
		paperPositions[paperRole] = Vector2(float(xValue), float(yValue))

	return paperPositions