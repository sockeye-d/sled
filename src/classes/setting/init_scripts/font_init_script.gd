extends SettingInitScript


func on_init(item: SettingItem) -> void:
	item.options.clear()
	item.options.append("Custom")
	item.options.append("Monospace")
	var fonts: Array[String]
	fonts.assign(OS.get_system_fonts())
	fonts.sort_custom(func(a: String, b: String): return a.to_lower() < b.to_lower())
	var cascadia_code_index = -1
	for font_index in fonts.size():
		if fonts[font_index].to_lower() == "cascadia code":
			cascadia_code_index = font_index
		item.options.append(fonts[font_index])
	
	if not cascadia_code_index == -1:
		item.default_value = cascadia_code_index + 2
		#item.value = item.default_value
