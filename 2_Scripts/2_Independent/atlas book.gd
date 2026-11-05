extends Paper

class_name AtlasBook

@export_category("References")
@export var mapAtlas : Control
@export var mainAtlas : Control
@export var mapHolder : AtlasMapManager
@export var leftDetectionZone : Button
@export var rightDetectionZone : Button
@export var dragArea : Button

@export_group("Pages")
@export var mapPageSprite : TextureRect
@export var atlasFullPageSprite : TextureRect
@export var atlasSinglePageSprite : TextureRect
@export var coverSprite : TextureRect
##SET TO 4
@export var pageTitles : Array[RichTextLabel]
##SET TO 4
@export var pageInfos : Array[RichTextLabel]
@export var titleSeparator : Control

@export var generalInfoHolder : Control
@export var flutterScene : PackedScene
@export var flutterHolder : Control
@export var flutterCount : int = 4

var flutterPool : Array[FlutterPage]

var openDragAmount : float =  0
var closedDragAmount : float = 0

var isTurning : bool = false
var currentPageIndex : int = 0
var maxPages : int = 3
var loadedBaseSpread : int = -1
var loadedFlipSpread : int = -1

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

	leftPadding += 116
	openDragAmount = dragArea.custom_minimum_size.x
	closedDragAmount = dragArea.custom_minimum_size.x / 2

	if _is_closed() == true:
		dragArea.custom_minimum_size.x = closedDragAmount
	else:
		dragArea.custom_minimum_size.x = openDragAmount
	

	pageFlipMaterial = atlasSinglePageSprite.material
	coverMaterial = coverSprite.material
	activeMaterial = coverMaterial
	coverMaterial.set_shader_parameter("progress" , 0)
	mapHolder.visible = false
	_set_bend_amount(0)
	_set_page_progress(0.0) # start book closed
	_update_page_state()

	for i in range(flutterCount):
		var sheet : FlutterPage = flutterScene.instantiate()
		flutterHolder.add_child(sheet)
		sheet.visible = false
		flutterPool.append(sheet)

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
	await _update_pages(false)
	mapHolder.visible = _is_first_page()
	await _animate_left_to_right_page_turn(0.4).finished

	if _is_closed() == true:
		dragArea.custom_minimum_size.x = closedDragAmount
	
	_finish_turn()

func _go_to_next_right_page():
	if isTurning || currentPageIndex >= maxPages:
		return

	var isOpeningCover : bool = _is_closed() # check before index changes

	isTurning = true
	currentPageIndex += 1

	GlobalReferences.cursor.imageNode.frame = 0
	_prepare_turn(isOpeningCover, -2)
	await _update_pages(true)
	await _animate_right_to_left_page_turn(0.4).finished

	if _is_first_page() == true:
		dragArea.custom_minimum_size.x = openDragAmount

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
	_recalculate_max_pages()

	loadedBaseSpread = -1
	loadedFlipSpread = -1

	_load_spread(0, false)
	_load_spread(1,true)

func _update_pages(isTurningRight : bool):
	if currentPageIndex < 2:
		return
	
	var newSpread : int = currentPageIndex - 2

	if isTurningRight:
		_load_spread(newSpread - 1, false)
		await _wait_for_viewports()
		_set_page_progress(0.0)
		_load_spread(newSpread, true)
	else:
		_load_spread(newSpread + 1, true)
		await _wait_for_viewports()
		_set_page_progress(1.0)
		_load_spread(newSpread, false)
	
	await _wait_for_viewports()

func _wait_for_viewports():
	await get_tree().process_frame
	await RenderingServer.frame_post_draw

func _set_slot(slot : int, contentIndex : int):
	var page : Dictionary = countryInfo._get_page(contentIndex)
	pageTitles[slot].text = page.title
	pageInfos[slot].text = bbcodeManager._highlight(page.info)

	if slot == 0:
		titleSeparator.visible = (contentIndex == 0)

func _load_spread(spread : int, isFlipSide : bool):
	if isFlipSide:
		if loadedFlipSpread == spread:
			return
		loadedFlipSpread = spread
	else:
		if loadedBaseSpread == spread:
			return
		loadedBaseSpread = spread

	var firstSlot : int = 2 if isFlipSide else 0
	_set_slot(firstSlot, spread * 2)
	_set_slot(firstSlot + 1, spread * 2 + 1)

func _recalculate_max_pages():
	var spreads : int = ceili(countryInfo._get_page_count() / 2.0)
	maxPages = 1 + spreads

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

#-------------------------FLUTTER-------------------------
func _flip_to_main():
	_flip_section(true)


func _flip_to_map():
	_flip_section(false)

func _flip_section(toMain : bool):
	isTurning = true
	currentPageIndex = 2 if toMain else 1
	GlobalReferences.cursor.imageNode.frame = 0
	await _play_flutter(toMain)
	_finish_turn()

func _play_flutter(toMain : bool):
	var middleIndex : int = flutterCount / 2
	var lastIndex : int = flutterCount - 1
	var mapSheetIndex : int = 0 if toMain else lastIndex
	var funSheetIndex : int = lastIndex if toMain else 0
	var funPage : Dictionary = countryInfo._get_page(0)

	for i in range(flutterCount):
		flutterHolder.move_child(flutterPool[i], flutterCount - 1 - i)

		if i == mapSheetIndex:
			flutterPool[i]._set_front_content()
		else:
			flutterPool[i]._clear_front_content()

		if i == funSheetIndex:
			flutterPool[i]._set_back_text(funPage.title, bbcodeManager._highlight(funPage.info))
		else:
			flutterPool[i]._clear_back_text()
	

	if toMain:
		mapHolder.visible = false
		generalInfoHolder.modulate.a = 0.0

	await _wait_for_viewports()

	for i in range(flutterCount):
		var sheet : FlutterPage = flutterPool[i]

		sheet.crossed.connect(flutterHolder.move_child.bind(sheet, i), CONNECT_ONE_SHOT)

		if i == middleIndex:
			sheet.crossed.connect(_swap_section.bind(toMain), CONNECT_ONE_SHOT)
		
		if i == lastIndex && !toMain:
			sheet.crossed.connect(_show_map_holder, CONNECT_ONE_SHOT)
		
		sheet._play(toMain, 0.5, 0.8)

		if i < lastIndex:
			await get_tree().create_timer(0.07).timeout
	
	await flutterPool[lastIndex].finished
	generalInfoHolder.modulate.a = 1.0

func _swap_section(toMain : bool):
	mapAtlas.visible = !toMain
	mainAtlas.visible = toMain

func _show_map_holder():
	mapHolder.visible = true
