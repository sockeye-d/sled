@tool
class_name ThemeImporter extends Object


static func import_theme(
		code_edit: CodeEdit,
		path: String,
		types: PackedStringArray,
		keywords: PackedStringArray,
		comment_regions: PackedStringArray,
		string_regions: PackedStringArray,
		) -> void:

	var file = FileAccess.open(path, FileAccess.READ).get_as_text(true)
	var theme: TextEditorTheme = TextEditorTheme.new()
	var highlighter = CodeHighlighter.new()

	var theme_dict: Dictionary = {}
	var theme_overrides: Dictionary = {}
	for line in file.split("\n", false).slice(1):
		var key_value: PackedStringArray = line.replace(" ", "") .split("=")
		if not key_value.size() == 2:
			continue
		var value = Color(key_value[1].trim_prefix('"').trim_suffix('"'))
		theme_dict[key_value[0]] = value
		if highlighter.get(key_value[0]) == null:
			theme_overrides[key_value[0]] = value
		else:
			highlighter.set(key_value[0], value)

	for key in theme_overrides:
		code_edit.add_theme_color_override(key, theme_overrides[key])

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
	code_edit.syntax_highlighter = highlighter
