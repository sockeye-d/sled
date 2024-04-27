@tool
extends CodeEdit


@export_file var editor_theme: String:
	set(value):
		editor_theme = value
		ThemeImporter.import_theme(self, value)
		(syntax_highlighter as CodeHighlighter).add_color_region("#", "", get_theme_color("background_color").lightened(0.5))
	get:
		return editor_theme

