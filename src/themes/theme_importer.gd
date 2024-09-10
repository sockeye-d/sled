@tool
class_name ThemeImporter extends Object


static var last_imported_theme: String = ""
static var last_imported_theme_dict: Dictionary[String, Color] = { }
static var last_imported_theme_overrides: Dictionary[String, Color] = { }
static var last_imported_code_highlighter: CodeHighlighter = null

## Mutates a CodeHighlighter
static func mut_highlighter(
	theme: Dictionary[String, Color],
	highlighter: CodeHighlighter,
	types: PackedStringArray = [],
	keywords: PackedStringArray = [],
	comment_regions: PackedStringArray = [],
	string_regions: PackedStringArray = []) -> SyntaxHighlighter:
	
	for key in theme:
		if highlighter.get(key) != null:
			highlighter.set(key, theme[key])
	
	highlighter.clear_member_keyword_colors()
	if "base_type_color" in theme:
		for type in types:
			highlighter.add_member_keyword_color(type, theme.base_type_color)
	
	if "keyword_color" in theme:
		for keyword in keywords:
			highlighter.add_member_keyword_color(keyword, theme.keyword_color)
	
	highlighter.clear_color_regions()
	if "comment_color" in theme:
		for region in comment_regions:
			var region_split := region.split(" ")
			var single_line: bool = not " " in region
			highlighter.add_color_region(region_split[0], "" if single_line else region_split[-1], theme.comment_color, single_line)
	if "string_color" in theme:
		for region in string_regions:
			highlighter.add_color_region(region.get_slice(" ", 0), region.get_slice(" ", 1), theme.string_color)
	
	return highlighter


static func get_theme_dict(file: String, random: bool = false) -> Dictionary[String, Color]:
	var theme_dict: Dictionary[String, Color] = { }
	if last_imported_theme == file:
		theme_dict = last_imported_theme_dict
	else:
		for line in file.split("\n", false).slice(1):
			var key_value: PackedStringArray = line.replace(" ", "") .split("=")
			if not key_value.size() == 2:
				continue
			# no secrets here :)
			var value := Color.from_ok_hsl(randf(), randf(), randf()) if random else Color(key_value[1].strip_edges().trim_prefix('"').trim_suffix('"'))
			theme_dict[key_value[0]] = value
	
	last_imported_theme_dict = theme_dict
	return theme_dict


static func add_code_edit_themes(theme: Theme, colors: Dictionary[String, Color]) -> void:
	for key in colors:
		if String(key).is_valid_identifier():
			theme.set_color(key, &"CodeEdit", colors[key])


static func _add_color(name: StringName, type: StringName, color: Color) -> void:
	if not "/" in name:
		EditorThemeManager.theme.set_color(name, type, color)
