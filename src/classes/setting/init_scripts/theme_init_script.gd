extends SettingInitScript


func on_init(item: SettingItem) -> void:
	item.options.clear()
	item.options.append("custom")
	for t in EditorThemeManager.THEMES.themes:
		item.options.append(t)
	
	item.default_value = item.options.find(EditorThemeManager.DEFAULT_THEME)
	
