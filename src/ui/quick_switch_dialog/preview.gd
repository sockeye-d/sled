extends CodeEdit


func _ready() -> void:
	EditorThemeManager.theme_changed.connect(load_theme)
	load_theme("")


func load_theme(file: String) -> void:
	ThemeImporter.import_theme(file if file else ThemeImporter.last_imported_theme, self, GLSLLanguage.base_types, GLSLLanguage.keywords, GLSLLanguage.comment_regions, GLSLLanguage.string_regions)
	if not syntax_highlighter.has_color_region("#"):
		syntax_highlighter.add_color_region("#", "", get_theme_color("background_color").lightened(0.5))
