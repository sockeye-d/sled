class_name CodeCompletionSuggestion extends RefCounted


var type: CodeEdit.CodeCompletionKind
var text: String
var location: CodeEdit.CodeCompletionLocation
var icon: Texture2D


func _init(_type: CodeEdit.CodeCompletionKind, _text: String, _location: CodeEdit.CodeCompletionLocation, _icon: Texture2D = null) -> void:
	type = _type
	text = _text
	location = _location
	icon = _icon


func add_to(editor: CodeEdit) -> void:
	editor.add_code_completion_option(type, text, text, Color.WHITE, null, null, location)


static func add_arr_to(suggestions: Array[CodeCompletionSuggestion], editor: CodeEdit) -> void:
	for suggestion in suggestions:
		suggestion.add_to(editor)
