extends Control

class_name AtlasMapManager

@export_category("References")
##SHOULD BE ORDERED SAME AS ATLASHOLDER
@export var countryButtons : Array[TextureButton]
@export var atlas : AtlasBook

func _ready() -> void:
	_set_connections()
func _set_connections():
	for i in range(0, countryButtons.size()):
		countryButtons[i].pressed.connect(_turn_to_country.bind(i))

#- - -
func _turn_to_country(i : int):
	if atlas._has_moved() == true:
		return
	
	if atlas.atlasHolder.countryInfos[i] != null:
		atlas.countryInfo = atlas.atlasHolder.countryInfos[i]
	
	atlas._initialize_pages()

	atlas._flip_to_main()
