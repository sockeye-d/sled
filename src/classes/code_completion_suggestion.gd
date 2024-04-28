class_name CodeCompletionSuggestion extends RefCounted


@export var type: CodeEdit.CodeCompletionKind
@export var text: String
@export var location: CodeEdit.CodeCompletionLocation


func _init(_type: CodeEdit.CodeCompletionKind, _text: String, _location: CodeEdit.CodeCompletionLocation) -> void:
	type = _type
	text = _text
	location = _location


func add_to(editor: CodeEdit) -> void:
	editor.add_code_completion_option(type, text, text, Color.WHITE, null, null, location)


static func add_arr_to(suggestions: Array[CodeCompletionSuggestion], editor: CodeEdit) -> void:
	for suggestion in suggestions:
		suggestion.add_to(editor)
