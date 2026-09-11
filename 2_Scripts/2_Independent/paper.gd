extends ClickDrag

class_name Paper

var playmat : PlaymatManager = null

var paperPadding : float = 40

func _process(delta: float) -> void:
	super._process(delta)
	_clamp_paper()

func _on_down() -> void:
	super._on_down()
	playmat.paperHolder.move_child(self, playmat.paperHolder.get_children().size() - 1)

#-------------------

func _clamp_paper():
	var playmatRect : Rect2 = playmat.get_rect()
	var paperRect : Rect2 = parentNode.get_rect()
	
	parentNode.position.x = clamp(parentNode.position.x, 0 - paperPadding, playmatRect.size.x - paperRect.size.x + paperPadding)
	parentNode.position.y = clamp(parentNode.position.y, 0 - paperPadding, playmatRect.size.y - paperRect.size.y + paperPadding)
