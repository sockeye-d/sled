@tool
class_name ThemeImporter extends Object


static var last_imported_theme: String = ""
static var last_imported_theme_dict: Dictionary = { }
static var last_imported_theme_overrides: Dictionary = { }
static var last_imported_code_highlighter: CodeHighlighter = null


static func import_theme(
		file: String,
		code_edit: CodeEdit = null,
		types: PackedStringArray = [],
		keywords: PackedStringArray = [],
		comment_regions: PackedStringArray = [],
		string_regions: PackedStringArray = [],
		) -> Dictionary:
	

	var highlighter = CodeHighlighter.new()
	var theme_dict: Dictionary = { }
	var theme_overrides: Dictionary = { }
	if last_imported_theme == file:
		highlighter = last_imported_code_highlighter.duplicate(true)
		theme_dict = last_imported_theme_dict
		theme_overrides = last_imported_theme_overrides
	else:
		for line in file.split("\n", false).slice(1):
			var key_value: PackedStringArray = line.replace(" ", "") .split("=")
			if not key_value.size() == 2:
				continue
			var value = Color(key_value[1].strip_edges().trim_prefix('"').trim_suffix('"'))
			theme_dict[key_value[0]] = value
			if highlighter.get(key_value[0]) == null:
				theme_overrides[key_value[0]] = value
			else:
				highlighter.set(key_value[0], value)
		
		for key in theme_overrides:
			_add_color(key, &"CodeEdit", theme_overrides[key])
	
		for type in types:
			highlighter.add_member_keyword_color(type, theme_dict.base_type_color)
		
		for keyword in keywords:
			highlighter.add_member_keyword_color(keyword, theme_dict.keyword_color)
		
		for region in comment_regions:
			var region_split = region.split(" ")
			var single_line = not " " in region
			highlighter.add_color_region(region_split[0], "" if single_line else region_split[-1], theme_dict.comment_color, single_line)
		for region in string_regions:
			highlighter.add_color_region(region.get_slice(" ", 0), region.get_slice(" ", 1), theme_dict.string_color)
	
	if code_edit:
		code_edit.syntax_highlighter = highlighter
	
	last_imported_theme = file
	last_imported_code_highlighter = highlighter
	last_imported_theme_dict = theme_dict
	last_imported_theme_overrides = theme_overrides
	
	return theme_dict


static func _add_color(name: StringName, type: StringName, color: Color) -> void:
	if not "/" in name:
		EditorThemeManager.theme.set_color(name, type, color)
