extends Resource

class_name BBCodePaperManager

const LIE_COLOR : String = "#b65c5f"
const FOOL_COLOR : String = "#66845f"
const SAGE_COLOR : String = "#6c67eb"

const KEYWORD_COLORS : Dictionary = {
	"lie": LIE_COLOR,
	"liar": LIE_COLOR,
	"lying": LIE_COLOR,
	"fool": FOOL_COLOR,
	"fools": FOOL_COLOR,
	"sage": SAGE_COLOR,
	"sages": SAGE_COLOR,
}

var _regex : RegEx

func _init() -> void:
	var keys : Array = KEYWORD_COLORS.keys()
	keys.sort_custom(func(a,b): return a.length() > b.length())
	_regex = RegEx.new()
	_regex.compile("(?i)\\b(" + "|".join(keys) + ")\\b")
	
func _highlight(text : String) -> String:
	var result : String = ""
	var last_end : int = 0
	for m in _regex.search_all(text):
		var word : String = m.get_string()
		var color : String = KEYWORD_COLORS[word.to_lower()]
		result += text.substr(last_end, m.get_start() - last_end)
		result += "[color=%s]%s[/color]" % [color, word]
		last_end = m.get_end()
	return result + text.substr(last_end)
