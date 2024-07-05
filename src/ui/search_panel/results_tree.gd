class_name ResultsTree extends Tree


func _item_custom_draw(item: TreeItem, rect: Rect2) -> void:
	rect = rect.abs()
	var f := get_theme_font(&"font", &"CodeEdit")
	var f_size := get_theme_font_size(&"font_size")
	var search_result: SearchPanel.SearchResult = item.get_metadata(0)
	var text: String = search_result.relevant_line
	var ascent := f.get_ascent(f_size)
	var h_offset := f.get_string_size(
		text.substr(0, search_result.line_start_index),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		f_size
	).x
	var h_width := f.get_string_size(
		StringUtil.substr_pos(
			text,
			search_result.line_start_index,
			search_result.line_end_index
		),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		f_size
	).x
	var h_rect := Rect2(
		rect.position.x + h_offset - 2.0,
		rect.position.y + 2.0,
		h_width + 4.0,
		rect.size.y - 4.0,
	)
	draw_rect(h_rect, get_theme_color(&"font_color"), false)
	draw_string(
		f,
		Vector2(
			rect.position.x,
			rect.get_center().y + ascent / 2.0,
		),
		search_result.relevant_line,
		HORIZONTAL_ALIGNMENT_LEFT,
		maxi(rect.size.x, 1),
		f_size,
		get_theme_color(&"font_color"),
		TextServer.JUSTIFICATION_CONSTRAIN_ELLIPSIS,
	)
