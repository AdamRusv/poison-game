extends ClickDrag

class_name Paper #TODO: SET Z INDEX TO 0

var playmat : PlaymatManager = null

var paperPadding : float = 40

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
