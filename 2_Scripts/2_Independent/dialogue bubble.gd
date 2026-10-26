extends Control

class_name DialogueBubble

@export_category("References")
@export var visualHolder : Control
@export var texture : NinePatchRect
@export var dialogueLabel : RichTextLabel

var speaker : Dialogue.Speaker = Dialogue.Speaker.opponent

var dialogueSize : Vector2 = Vector2.ZERO

const MAX_BUBBLE_SIZE : float = 120.0
var singleLineSize : float = 0

var finishedTween : bool = false

func _set_length_size():
	dialogueSize = visualHolder.size
	
	singleLineSize = dialogueSize.x
	if singleLineSize > MAX_BUBBLE_SIZE:
		_custom_autowrap()

func _hide_label():
	dialogueLabel.visible_characters = 2
	dialogueLabel.visible = false

func _show_label():
	dialogueLabel.visible = true

#----------------------------------------
func _custom_autowrap():
	dialogueLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	var dialogueFont : Font = dialogueLabel.theme.default_font
	var newParagraph : TextParagraph = TextParagraph.new()
	newParagraph.add_string(dialogueLabel.text, dialogueFont, 9)
	newParagraph.width = MAX_BUBBLE_SIZE
	
	var longestLine : float = 0
	for i in newParagraph.get_line_count():
		longestLine = maxf(longestLine, newParagraph.get_line_width(i))
	dialogueSize.x = longestLine
	visualHolder.custom_minimum_size.y = 12 + newParagraph.get_line_count() * 8

func _add_cutoff(): #NOTE: sometimes causes a jump in bubble size if "-" is larger than character being deleted (LOL)
	var newestVisibleCharacterPos : int = dialogueLabel.visible_characters
	
	dialogueLabel.text = dialogueLabel.text.erase(newestVisibleCharacterPos)
	dialogueLabel.text = dialogueLabel.text.insert(newestVisibleCharacterPos, "-")
	dialogueLabel.visible_characters += 1
