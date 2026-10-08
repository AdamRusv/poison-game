extends ClickDrag

class_name Paper

@export_category("References")
@export var paperTitleLabel : RichTextLabel
@export var paperInfoLabel : RichTextLabel
@export_group("Packet")
@export var packetParent : Control
@export var packetBehindPaperParent : Control
@export var pageFlipButton : Button
@export var pageFlipTexture : TextureRect

var playmat : PlaymatManager = null

var paperInfo : PaperInfo = null
var isPacket : bool = false

var paperPadding : float = 40

var paperIsMoving : bool = false

func _ready() -> void:
	super._ready()
	_animate_into_frame()

func _set_connections():
	super._set_connections()
	pageFlipButton.mouse_entered.connect(_on_pageflip_enter)
	pageFlipButton.mouse_exited.connect(_on_pageflip_exit)
	pageFlipButton.pressed.connect(_on_pageflip_clicked)

func _process(delta: float) -> void:
	super._process(delta)
	_clamp_paper()

func _on_down():
	if paperIsMoving == true:
		return
	super._on_down()
	playmat.paperHolder.move_child(self, playmat.paperHolder.get_children().size() - 1)
	_squish_paper()

func _on_up():
	if paperIsMoving == true:
		return
	super._on_up()
	_reset_paper()

#-------------------
func _clamp_paper():
	if paperIsMoving == true:
		return
	var playmatRect : Rect2 = playmat.get_rect()
	var paperRect : Rect2 = parentNode.get_rect()
	
	parentNode.position.x = clamp(parentNode.position.x, 0 - paperPadding, playmatRect.size.x - paperRect.size.x + paperPadding)
	parentNode.position.y = clamp(parentNode.position.y, 0 - paperPadding, playmatRect.size.y - paperRect.size.y + paperPadding)

func _setup_paper(newPaperInfo : PaperInfo):
	paperInfo = newPaperInfo
	
	pageFlipTexture.texture = pageFlipTexture.texture.duplicate(true)
	
	paperTitleLabel.text = paperInfo.title
	if newPaperInfo is EncounterInfo:
		var newEncounterInfo : EncounterInfo = newPaperInfo
		paperInfoLabel.text = newEncounterInfo.characterName + paperInfo.info[0]
	else:
		paperInfoLabel.text = paperInfo.info[0]
	
	packetParent.visible = false
	packetBehindPaperParent.visible = false
	
	if paperInfo.info.size() > 1:
		_setup_packet()

func _setup_packet():
	isPacket = true
	
	packetParent.visible = true
	packetBehindPaperParent.visible = true

#- - -
func _reset_paper() -> Tween:
	var newTween : Tween = TweenManager._scale_tween(parentNode, Vector2(1, 1), 0.1)
	return newTween

func _squish_paper() -> Tween:
	var newTween : Tween = TweenManager._scale_tween(parentNode, Vector2(0.98, 0.98), 0.1)
	return newTween

func _expand_paper() -> Tween:
	var newTween : Tween = TweenManager._scale_tween(parentNode, Vector2(1.02, 1.02), 0.1)
	return newTween

#--------------------PACKET--------------------
var currentPage : int = 0

const NEUTRAL_CORNER : Rect2 = Rect2(0, 0, 20, 20)
const HOVERED_CORNER : Rect2 = Rect2(20, 0, 20, 20)

func _on_pageflip_enter():
	_set_pageflip_texture_to(HOVERED_CORNER)

func _on_pageflip_exit():
	_set_pageflip_texture_to(NEUTRAL_CORNER)

func _on_pageflip_clicked():
	if currentPage < paperInfo.info.size() - 1:
		currentPage += 1
	elif currentPage >= paperInfo.info.size() -1:
		currentPage = 0
	
	await _squish_paper().finished
	_reset_paper()

	paperInfoLabel.text = paperInfo.info[currentPage] #NOTE: does not work with EncounterInfo

#-
func _set_pageflip_texture_to(newRect : Rect2):
	var atlasTexture : AtlasTexture = pageFlipTexture.texture
	atlasTexture.region = newRect

#----------------
var startPos : Vector2 = Vector2(520, 640)
func _animate_into_frame():
	paperIsMoving = true
	parentNode.position = startPos
	
	await get_tree().create_timer(randf_range(0, 1)).timeout
	
	var endPos : Vector2 = playmat._get_random_paper_spawn_location()
	var moveSpeed : float = randi_range(650, 700)
	var duration : float = endPos.distance_to(startPos) / moveSpeed
	
	var newTween : Tween = create_tween()
	newTween.tween_property(parentNode, "position", endPos, duration)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await newTween.finished
	paperIsMoving = false
