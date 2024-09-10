@tool
class_name ThemeLibrary extends Resource


@export_dir var theme_path: String:
	set(value):
		if not Engine.is_editor_hint():
			return
		themes = { }
		for path in DirAccess.get_files_at(value):
			var t := EdTheme.new()
			t.text = FileAccess.open(ProjectSettings.globalize_path(value.path_join(path)), FileAccess.READ).get_as_text(true)
			themes[path.get_basename().replace("-", " ").to_lower()] = t
		themes = themes
		theme_path = value
	get:
		return theme_path
@export_multiline var themes: Dictionary[String, EdTheme]
