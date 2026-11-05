extends Resource

class_name CountryInfo

##country info is always index 0
@export var pages : Array[SinglePage]

@export_group("First Page")
@export var countryTitle : String 
@export_multiline var funInfo : String

func _get_page_count() -> int:
	return 1 + pages.size()

func _get_page(index : int) -> Dictionary:
	if index == 0:
		return {"title": countryTitle, "info": funInfo}
	
	if index < 0 || index > pages.size():
		return {"title": "", "info": ""}
	
	var page : SinglePage = pages[index - 1]

	if page == null:
		return {"title": "", "info": ""}
	
	return {"title": page.title, "info": page.info}