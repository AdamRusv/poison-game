extends Paper

class_name AtlasBook

@export_category("References")
@export var mapAtlas : Control
@export var mainAtlas : Control
@export var mapHolder : AtlasMapManager
@export var leftDetectionZone : Button
@export var rightDetectionZone : Button

@export_group("Pages")
@export var mapPageSprite : TextureRect
@export var atlasFullPageSprite : TextureRect
@export var atlasSinglePageSprite : TextureRect
@export var coverSprite : TextureRect
##SET TO 4
@export var pageTitles : Array[RichTextLabel]
##SET TO 4
@export var pageInfos : Array[RichTextLabel]

var isTurning : bool = false
var currentPageIndex : int = 0
var maxPages : int = 3

var atlasHolder : AtlasHolder = null
var countryInfo : CountryInfo = null
var maxCountries : int = 0

var pageFlipMaterial : ShaderMaterial = null
var coverMaterial : ShaderMaterial = null
var activeMaterial : ShaderMaterial = null

func _init() -> void:
	canBePacket = false

func _ready() -> void:
	super._ready()
	pageFlipMaterial = atlasSinglePageSprite.material
	coverMaterial = coverSprite.material
	activeMaterial = coverMaterial
	coverMaterial.set_shader_parameter("progress" , 0)
	mapHolder.visible = false
	_set_bend_amount(0)
	_set_page_progress(0.0) # start book closed
	_update_page_state()

func _set_connections():
	super._set_connections()
	leftDetectionZone.mouse_entered.connect(_on_enter_next_page.bind(true))
	leftDetectionZone.mouse_exited.connect(_on_exit_next_page)
	leftDetectionZone.button_down.connect(_on_page_down)
	leftDetectionZone.pressed.connect(_go_to_next_left_page)

	rightDetectionZone.mouse_entered.connect(_on_enter_next_page.bind(false))
	rightDetectionZone.mouse_exited.connect(_on_exit_next_page)
	rightDetectionZone.button_down.connect(_on_page_down)
	rightDetectionZone.pressed.connect(_go_to_next_right_page)

#- - -
func _on_enter_next_page(isLeftPage : bool):
	GlobalReferences.cursor._swap_cursor_to(GlobalReferences.cursor.atlasPageTurnCursor)
	
	if isLeftPage == true:
		GlobalReferences.cursor.imageNode.flip_h = true

func _on_exit_next_page():
	GlobalReferences.cursor.imageNode.flip_h = false
	GlobalReferences.cursor._swap_cursor_to(GlobalReferences.cursor.defaultCursor)

func _on_page_down():
	GlobalReferences.cursor.imageNode.frame = 1

func _go_to_next_left_page():
	if isTurning || currentPageIndex <= 0:
		return
	
	var isClosingCover : bool = _is_first_page() # check before index changes
	var isTurningToMap : bool = _is_on_main()

	if(isTurningToMap):
		_flip_to_map()
		return
	
	isTurning = true
	currentPageIndex -= 1

	GlobalReferences.cursor.imageNode.frame = 0
	_prepare_turn(isClosingCover, 2)
	mapHolder.visible = _is_first_page()
	await _animate_left_to_right_page_turn(0.4).finished
	_finish_turn()

func _go_to_next_right_page():
	if isTurning || currentPageIndex >= maxPages:
		return

	var isOpeningCover : bool = _is_closed() # check before index changes

	isTurning = true
	currentPageIndex += 1

	GlobalReferences.cursor.imageNode.frame = 0
	_prepare_turn(isOpeningCover, -2)
	await _animate_right_to_left_page_turn(0.4).finished

	_finish_turn()

func _prepare_turn(isCoverTurn : bool, pageBend : float):
	if isCoverTurn:
		activeMaterial = coverMaterial
		_set_bend_amount(0)
	else:
		activeMaterial = pageFlipMaterial
		_set_bend_amount(pageBend)

func _finish_turn():
	isTurning = false
	_update_page_state()

#- - - 

func _setup_atlas(newAtlasHolder : AtlasHolder, regionInfo : RegionInfo):
	atlasHolder = newAtlasHolder
	maxCountries = regionInfo.maxCountryCount

	mapAtlas.visible = true
	mainAtlas.visible = false
	
	for i in range(0, mapHolder.countryButtons.size()):
		mapHolder.countryButtons[i].visible = false

	for i in range(0, mapHolder.countryButtons.size()):
		print(maxCountries)
		if i < maxCountries:
			print("wqefqfqwf")
			mapHolder.countryButtons[i].visible = true

#- - -
func _is_closed() -> bool:
	return currentPageIndex == 0

func _is_first_page() -> bool:
	return currentPageIndex == 1

func _is_on_main() -> bool:
	return currentPageIndex == 2

func _is_last_page() -> bool:
	return currentPageIndex == maxPages

func _update_page_state():
	var leftWasHovered : bool = leftDetectionZone.is_hovered()
	var rightWasHovered : bool = rightDetectionZone.is_hovered()
	
	leftDetectionZone.visible = !_is_closed()
	rightDetectionZone.visible = !_is_last_page() && !_is_first_page()

	mapHolder.visible = _is_first_page()
	
	# Hidden buttons don't fire mouse_exited, so reset the cursor manually
	if (leftWasHovered && !leftDetectionZone.visible) || (rightWasHovered && !rightDetectionZone.visible):
		_on_exit_next_page()

func _initialize_pages():
	pageTitles[0].text = countryInfo.countryTitle
	pageInfos[0].text = bbcodeManager._highlight(countryInfo.funInfo)

	pageTitles[1].text = countryInfo.pages[0].title
	pageInfos[1].text = bbcodeManager._highlight(countryInfo.pages[0].info)

	pageTitles[2].text = countryInfo.pages[1].title
	pageInfos[2].text = bbcodeManager._highlight(countryInfo.pages[1].info)

	pageTitles[3].text = countryInfo.pages[2].title
	pageInfos[3].text = bbcodeManager._highlight(countryInfo.pages[2].info)

func _update_pages():
	pass

#- - -
func _animate_right_to_left_page_turn(turnSpeed : float) -> Tween:
	var newTween : Tween = create_tween()

	newTween.tween_method(_set_page_progress, 0.0, 1.0, turnSpeed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	return newTween

func _animate_left_to_right_page_turn(turnSpeed : float) -> Tween:
	var newTween: Tween = create_tween()

	newTween.tween_method(_set_page_progress, 1.0, 0.0, turnSpeed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	return newTween

#--------------
func _set_page_progress(value : float):
	activeMaterial.set_shader_parameter("progress", value)

func _set_bend_amount(value : float):
	activeMaterial.set_shader_parameter("bend", value)


#-------------------------ATLAS SECTIONS-------------------------
func _flip_to_main():
	mapHolder.visible = false
	mapAtlas.visible = false
	mainAtlas.visible = true
	currentPageIndex = 2
	_update_page_state()


func _flip_to_map():
	mapHolder.visible = true
	mapAtlas.visible = true
	mainAtlas.visible = false
	currentPageIndex = 1
	_update_page_state()
