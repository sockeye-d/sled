extends SettingInitScript


func on_init(item: SettingItem) -> void:
	item.setting_changed.connect(
			func(new_value: float):
				#EditorThemeManager.theme.default_font_size = 16 * new_value as int
				#EditorThemeManager.theme.default_base_scale = new_value
				EditorThemeManager.set_scale(new_value)
				)
