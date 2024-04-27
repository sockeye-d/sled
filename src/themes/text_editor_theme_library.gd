@tool
class_name TextEditorThemeLibrary extends Resource

## Dictionary<String, TextEditorTheme>
@export var themes: Dictionary = {}
@export_dir var import_themes: String:
	set(value):
		themes = {}
		if not DirAccess.dir_exists_absolute(value):
			push_error("Couldn't open path at %s" % value)
		for file in DirAccess.get_files_at(value):
			var theme_name = file.get_file().get_slice(".", 0)
			var theme: TextEditorTheme = TextEditorTheme.import_text_editor_theme(value.trim_suffix("/") + "/" + file)
			
			themes[theme_name] = theme
	get:
		return ""
@export_dir var export_themes: String:
	set(value):
		if not DirAccess.dir_exists_absolute(value):
			push_error("%s isn't a valid path" % value)
		for theme in themes.keys():
			var path: String = value.trim_suffix("/") + "/%s.tres" % theme
			var error: Error = ResourceSaver.save(themes[theme], path)
			if error:
				push_error("%s failed to save at path %s with error code %s" % [theme, path, error])
	get:
		return ""
