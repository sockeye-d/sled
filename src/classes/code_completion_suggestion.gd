class_name CodeCompletionSuggestion extends RefCounted


var type: CodeEdit.CodeCompletionKind
var text: String
var insert_text: String
var location: CodeEdit.CodeCompletionLocation
var icon: Texture2D


func _init(_type: CodeEdit.CodeCompletionKind, _text: String, _location: CodeEdit.CodeCompletionLocation, _icon: Texture2D = null, _insert_text := _text) -> void:
	type = _type
	text = _text
	location = _location
	icon = _icon
	insert_text = _insert_text


func add_to(editor: CodeEdit) -> void:
	var l := location
	if l < CodeEdit.LOCATION_PARENT_MASK:
		l = CodeEdit.LOCATION_PARENT_MASK - l - 1
	editor.add_code_completion_option(type, text, insert_text, Color.WHITE, icon, null, l)


static func add_arr_to(suggestions: Array[CodeCompletionSuggestion], editor: CodeEdit) -> void:
	for suggestion in suggestions:
		if suggestion:
			suggestion.add_to(editor)
