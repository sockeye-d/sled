extends SettingInitScript


func on_init(item: SettingItem) -> void:
	item.options.clear()
	item.options.append("Default")
	var fonts: Array[String]
	fonts.assign(OS.get_system_fonts())
	fonts.sort_custom(func(a: String, b: String): return a.to_lower() < b.to_lower())
	for font_index in fonts.size():
		item.options.append(fonts[font_index])
