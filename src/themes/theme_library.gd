@tool
class_name ThemeLibrary extends Resource


@export_dir var theme_path: String:
	set(value):
		themes = { }
		for path in DirAccess.get_files_at(value):
			themes[path.get_basename().replace("-", " ").to_lower()] = FileAccess.open(ProjectSettings.globalize_path(value.path_join(path)), FileAccess.READ).get_as_text(true)
		themes = themes
		theme_path = value
	get:
		return theme_path
@export_multiline var themes: Dictionary
