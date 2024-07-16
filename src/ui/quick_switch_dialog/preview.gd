class_name PreviewCodeEdit extends CodeEdit


var old_text := ""
@onready var highlighter: CodeHighlighter = CodeHighlighter.new()


var all_carets: Array[Vector2i]
var old_h_scroll: float
var old_v_scroll: float


func _ready() -> void:
	EditorThemeManager.theme_changed.connect(load_theme)
	text_set.connect(_on_text_set)
	text_changed.connect(_on_text_changed)
	get_h_scroll_bar().value_changed.connect(_on_scrolled)
	get_v_scroll_bar().value_changed.connect(_on_scrolled)
	load_theme()


func load_theme(file: String = "") -> void:
	ThemeImporter.mut_highlighter(EditorThemeManager.last_imported_theme, highlighter, GLSLLanguage.base_types, GLSLLanguage.keywords.keys(), GLSLLanguage.comment_regions, GLSLLanguage.string_regions)
	if not highlighter.has_color_region("#"):
		highlighter.add_color_region("#", "", Color(get_theme_color(&"font_color"), 0.7))


func load_file(path: String) -> void:
	text = FileAccess.get_file_as_string(path)
	
	if (
		Settings.syntax_highlighting_enabled
		and path.get_extension().to_lower() in Settings.get_arr(&"syntax_highlighted_files")
		):
		syntax_highlighter = highlighter
	else:
		syntax_highlighter = null


func _on_text_set():
	old_text = text


func _on_text_changed():
	text = old_text
	remove_secondary_carets()
	set_caret_line(all_carets[0].y, false)
	set_caret_column(all_carets[0].x, false)
	for caret_pos: Vector2i in all_carets.slice(1):
		add_caret(caret_pos.y, caret_pos.x)
	scroll_horizontal = old_h_scroll
	scroll_horizontal = old_v_scroll


func _on_caret_changed() -> void:
	all_carets.resize(get_caret_count())
	for caret_i in get_caret_count():
		all_carets[caret_i] = Vector2i(get_caret_column(caret_i), get_caret_line(caret_i))


func _on_scrolled(_new_value: float) -> void:
	old_h_scroll = scroll_horizontal
	old_v_scroll = scroll_vertical
