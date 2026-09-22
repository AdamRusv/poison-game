extends ClickDrag

class_name Paper #TODO: SET Z INDEX TO 0

@export_category("References")
@export var paperTitleLabel : RichTextLabel
@export var paperInfoLabel : RichTextLabel
@export_group("Packet")
@export var packetParent : Control
@export var pageFlipButton : Button
@export var pageFlipTexture : TextureRect

var playmat : PlaymatManager = null

var paperInfo : PaperInfo = null
var isPacket : bool = false

var paperPadding : float = 40

func _set_connections():
	super._set_connections()
	pageFlipButton.mouse_entered.connect(_on_pageflip_enter)
	pageFlipButton.mouse_exited.connect(_on_pageflip_exit)
	pageFlipButton.pressed.connect(_on_pageflip_clicked)

func _process(delta: float) -> void:
	super._process(delta)
	_clamp_paper()

func _on_down():
	super._on_down()
	playmat.paperHolder.move_child(self, playmat.paperHolder.get_children().size() - 1)
	_squish_paper()

func _on_up():
	super._on_up()
	_reset_paper()

#-------------------
func _clamp_paper():
	var playmatRect : Rect2 = playmat.get_rect()
	var paperRect : Rect2 = parentNode.get_rect()
	
	parentNode.position.x = clamp(parentNode.position.x, 0 - paperPadding, playmatRect.size.x - paperRect.size.x + paperPadding)
	parentNode.position.y = clamp(parentNode.position.y, 0 - paperPadding, playmatRect.size.y - paperRect.size.y + paperPadding)

func _setup_paper(newPaperInfo : PaperInfo):
	paperInfo = newPaperInfo
	
	paperTitleLabel.text = paperInfo.title
	paperInfoLabel.text = paperInfo.info[0]
	
	packetParent.visible = false
	
	if paperInfo.info.size() > 1:
		_setup_packet()

func _setup_packet():
	isPacket = true
	
	
	
	packetParent.visible = true

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

#--------------------
var currentPage : int = 0

func _on_pageflip_enter():
	pass

func _on_pageflip_exit():
	pass

func _on_pageflip_clicked():
	if currentPage < paperInfo.info.size() - 1:
		currentPage += 1
	elif currentPage >= paperInfo.info.size() -1:
		currentPage = 0
	
	paperInfoLabel.text = paperInfo.info[currentPage]
