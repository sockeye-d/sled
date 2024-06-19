class_name FilteredLineEdit extends LineEdit

## :/\?*"|%<> for filenames
@export var disallowed_chars: String = ""


var previous_text: String


func _init() -> void:
	text_changed.connect(
		func(new_text: String):
			if disallowed_chars:
				var pos = _check_text(new_text, disallowed_chars)
				if not pos == -1:
					text = previous_text
					caret_column = pos
			previous_text = text
			)


## r':/\?*"|%<>' for filenames
func _check_text(bad_text: String, pattern: String) -> int:
	for pattern_char in pattern:
		var pos = bad_text.find(pattern_char)
		if not pos == -1:
			return pos
	return -1
