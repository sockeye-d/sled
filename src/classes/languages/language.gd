class_name Language extends Object


static var base_types: PackedStringArray
## [code]Dictionary[String, Texture2D][/code]
static var keywords: Dictionary
static var comment_regions: PackedStringArray
static var string_regions: PackedStringArray


static func get_code_completion_suggestions(path: String, file: String, line: int = -1, col: int = -1, base_path: String = path) -> Array[CodeCompletionSuggestion]:
	return []
