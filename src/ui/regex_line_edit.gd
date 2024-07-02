@tool
class_name RegExLineEdit extends LineEdit


enum PatternType {
	## There can be no invalid strings
	SIMPLE,
	## RegEx patterns [i]do[/i] have invalid strings
	REGEX,
	## Glob patterns have no invalid strings I think
	GLOB,
}


signal valid_changed(regex: RegEx)
signal valid_submitted(regex: RegEx)

## If true the resulting [class RegEx] will only match lowercase characters,
## and so lowercase text can be compared with it
@export var case_insensitive: bool = false
## This [b]only[/b] applies to visuals, not to the signals emmitted.
@export var validate_pattern: bool = true
@export var pattern_type: PatternType = PatternType.REGEX:
	get:
		return pattern_type
	set(value):
		pattern_type = value
		_changed(text)
## Only valid if the [param pattern_type] is set to [constant PatternType.REGEX]
var compiled_regex: RegEx
var is_valid_pattern: bool

var invalid_panel_cache: StyleBox


func _init() -> void:
	text_changed.connect(_changed)
	text_submitted.connect(_submitted)


func _set(property: StringName, value: Variant) -> bool:
	if property == &"text" and value is String:
		_changed(value)
	return false


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_THEME_CHANGED:
			invalid_panel_cache = get_theme_stylebox(&"invalid", &"RegExLineEdit")


func _changed(pattern: String) -> void:
	match pattern_type:
		PatternType.REGEX:
			if case_insensitive:
				pattern = RegExUtil.as_lowercase(pattern)
			var new_regex := RegExUtil.create(pattern)
			_set_sb(new_regex != null)
			is_valid_pattern = new_regex != null
			if new_regex:
				compiled_regex = new_regex
				valid_changed.emit(compiled_regex)
		_:
			_set_sb(true)
			is_valid_pattern = true


func _set_sb(is_valid: bool) -> void:
	if is_valid or not validate_pattern:
		remove_theme_stylebox_override(&"normal")
	else:
		add_theme_stylebox_override(&"normal", invalid_panel_cache)


func _submitted(pattern: String) -> void:
	if case_insensitive:
		pattern = RegExUtil.as_lowercase(pattern)
	var new_regex := RegExUtil.create(pattern)
	if new_regex:
		compiled_regex = new_regex
		valid_submitted.emit(compiled_regex)
