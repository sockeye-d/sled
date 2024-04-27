@tool
class_name TextEditorTheme extends Resource


@export var comment_color: Color = Color.BLACK
@export var function_color: Color = Color.BLACK
@export var keyword_color: Color = Color.BLACK
@export var member_variable_color: Color = Color.BLACK
@export var number_color: Color = Color.BLACK
@export var symbol_color: Color = Color.BLACK
@export var background_color: Color = Color.BLACK
@export var string_color: Color = Color.BLACK
@export var completion_background_color: Color = Color.BLACK
@export var completion_selected_color: Color = Color.BLACK
@export var completion_existing_color: Color = Color.BLACK
@export var completion_scroll_color: Color = Color.BLACK
@export var completion_font_color: Color = Color.BLACK


func as_code_highlighter(comment_regions: PackedStringArray = [], string_regions: PackedStringArray = [], keywords: PackedStringArray = []) -> CodeHighlighter:
	var ch = CodeHighlighter.new()

	ch.number_color = number_color
	ch.symbol_color = symbol_color
	ch.function_color = function_color
	ch.member_variable_color = member_variable_color

	for keyword in keywords:
		ch.add_keyword_color(keyword, keyword_color)
		ch.add_member_keyword_color(keyword, keyword_color)
	for region in comment_regions:
		ch.add_color_region(
				region.get_slice(" ", 0),
				region.get_slice(" ", 1),
				keyword_color,
				not region.contains(" "),
				)

	return ch


static func import_text_editor_theme(path: String, default_color: Color = Color.BLACK) -> TextEditorTheme:
	var file = FileAccess.open(path, FileAccess.READ).get_as_text(true)
	var theme: TextEditorTheme = TextEditorTheme.new()

	var theme_dict: Dictionary = {}
	for line in file.split("\n", false).slice(1):
		var key_value: PackedStringArray = line.replace(" ", "") .split("=")
		if not key_value.size() == 2:
			continue
		theme_dict[key_value[0]] = key_value[1].trim_prefix('"').trim_suffix('"')

	theme.comment_color = Color(theme_dict.get("comment_color", default_color))
	theme.number_color = Color(theme_dict.get("number_color", default_color))
	theme.symbol_color = Color(theme_dict.get("symbol_color", default_color))
	theme.function_color = Color(theme_dict.get("function_color", default_color))
	theme.keyword_color = Color(theme_dict.get("keyword_color", default_color))

	return theme
