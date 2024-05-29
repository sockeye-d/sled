extends CodeEdit


var old_text := ""


func _ready() -> void:
	EditorThemeManager.theme_changed.connect(load_theme)
	load_theme("")
	text_set.connect(_on_text_set)
	text_changed.connect(_on_text_changed)


func load_theme(file: String) -> void:
	ThemeImporter.import_theme(file if file else ThemeImporter.last_imported_theme, self, GLSLLanguage.base_types, GLSLLanguage.keywords, GLSLLanguage.comment_regions, GLSLLanguage.string_regions)
	if not syntax_highlighter.has_color_region("#"):
		syntax_highlighter.add_color_region("#", "", get_theme_color("background_color").lightened(0.5))


func _on_text_set():
	old_text = text


func _on_text_changed():
	text = old_text
