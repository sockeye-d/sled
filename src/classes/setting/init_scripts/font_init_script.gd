extends SettingInitScript


func on_init(item: SettingItem) -> void:
	item.options.append("Monospace")
	var fonts := OS.get_system_fonts()
	var cascadia_code_index = -1
	for font_index in fonts.size():
		if fonts[font_index].to_lower() == "cascadia code":
			cascadia_code_index = font_index
		item.options.append(fonts[font_index])
	
	if not cascadia_code_index == -1:
		item.default_value = cascadia_code_index + 1
		#item.value = item.default_value
