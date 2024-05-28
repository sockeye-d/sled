extends SettingInitScript


func on_init(item: SettingItem) -> void:
	item.options.clear()
	item.options.append("Custom")
	for t in EditorThemeManager.THEMES.themes:
		item.options.append(t)
	
	item.select_text(EditorThemeManager.DEFAULT_THEME)
	item.default_value = item.value
	
	item.setting_changed.connect.call_deferred(
			func(new_value):
				var new_theme: String = item.options[new_value]
				if new_theme == "Custom":
					await SceneTreeUtil.process_frame
					EditorThemeManager.change_theme_from_path.call_deferred(Settings.custom_theme_path)
					return
				if new_theme:
					EditorThemeManager.change_theme(new_theme)
				)
