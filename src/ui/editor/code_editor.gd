class_name CodeEditor extends CodeEdit


signal save_requested()
signal find_requested()


@onready var editor: Editor = $".."
@onready var zoom_label: Label = %ZoomLabel
var zoom: float = 1.0


var highlight_ranges: Array[Vector2i]:
	get:
		return highlight_ranges
	set(value):
		highlight_ranges = value
		_generate_highlight_cache()
var _old_ranges_hash: int
var _highlight_cache: Dictionary[Vector2i, Vector2i]


func _ready() -> void:
	_set_zoom()
	EditorThemeManager.scale_changed.connect(func(_new_scale: float) -> void: _set_zoom())
	EditorThemeManager.code_font_size_changed.connect(func() -> void: _set_zoom())


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is BrowserTree.DragData and Settings.browser_drag_drop_mode != 0:
		var lc := get_line_column_at_pos(at_position, false)
		if Util.is_none(lc):
			return false
		return true
	return false


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is BrowserTree.DragData and Settings.browser_drag_drop_mode != 0:
		remove_secondary_carets()
		var lc := get_line_column_at_pos(at_position, false)
		if Util.is_none(lc):
			return
		
		var insertions: PackedStringArray = []
		for path: String in data.absolute_paths:
			var final_path: String
			match Settings.browser_drag_drop_mode:
				1:
					insertions.append(FileManager.get_short_path(path))
				2:
					insertions.append('#include "%s"' % ("/" + FileManager.get_include_path(path)))
		
		insert_text("\n".join(insertions), lc[1], lc[0])
		set_caret_column(lc[0])
		set_caret_line(lc[1])
		
		grab_focus()


func _draw() -> void:
	var highlight := get_theme_color(&"word_highlighted_color")
	for r in highlight_ranges:
		var col_line: Vector2i = _highlight_cache[r]
		var test_pos := get_pos_at_line_column(col_line.y, col_line.x)
		if test_pos.x < 0 or test_pos.y < 0:
			continue
		var rects: Array[Rect2] = []
		for i in range(r[0] + 1, r[1] + 1):
			var create_new_rect: bool = false
			col_line.x += 1
			if text[i - 1] == "\n":
				col_line.x = 0
				col_line.y += 1
				create_new_rect = true
			var rect := Rect2(get_rect_at_line_column(col_line.y, col_line.x))
			if rect.position.x < 0 or rect.position.y < 0:
				continue
			rect = Rect2(rect.position, rect.size)
			if not rects or create_new_rect:
				rects.append(rect)
				continue
			rects[-1] = rects[-1].merge(rect)
		for rect in rects:
			draw_rect(rect, highlight)


func _generate_highlight_cache() -> void:
	var new_hash := hash(highlight_ranges)
	if _old_ranges_hash == new_hash:
		return
	for r in highlight_ranges:
		_highlight_cache[r] = StringUtil.get_line_col(text, r[0])
	_old_ranges_hash = new_hash


func _gui_input(event: InputEvent) -> void:
	if not editable:
		return
	if event is InputEventKey:
		if event.is_action_pressed("find", false, true):
			find_requested.emit()
		if event.is_action_pressed("move_lines_down", true, true):
			move_lines_down()
		if event.is_action_pressed("move_lines_up", true, true):
			move_lines_up()
		if event.is_action_pressed("duplicate_lines", true, true):
			duplicate_lines()
		if event.is_action_pressed("delete_lines", true, true):
			delete_lines()
			for caret_index in get_caret_count():
				set_caret_line(get_caret_line(caret_index))
		if event.is_action_pressed("save", true, true):
			save_requested.emit()
		if event.is_action_pressed(&"reset_zoom", false, true):
			zoom = 1.0
			_set_zoom()
	if event.is_action_pressed(&"zoom_in", true, true):
		zoom += 0.2
		zoom = clampf(zoom, 0.2, 3.0)
		_set_zoom()
	if event.is_action_pressed(&"zoom_out", true, true):
		zoom -= 0.2
		zoom = clampf(zoom, 0.2, 3.0)
		_set_zoom()


func _set_zoom() -> void:
	add_theme_font_size_override(&"font_size", EditorThemeManager.theme.get_font_size(&"font_size", &"CodeEdit") * zoom * EditorThemeManager.get_scale() as int)
	zoom_label.text = "%.f" % (zoom * 100.0) + "%"


func _make_custom_tooltip(for_text: String) -> Object:
	var container: PanelContainer = PanelContainer.new()
	container.add_theme_stylebox_override(&"panel", StyleBoxUtil.new_flat(Color.TRANSPARENT, [0], [0, 5, 0, 5]))
	var label: RichTextLabel = RichTextLabel.new()
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.fit_content = true
	label.bbcode_enabled = true
	label.text = "[code]" + for_text + "[/code]"
	label.add_theme_color_override(&"default_color", EditorThemeManager.theme.get_color(&"font_color", &"TooltipLabel"))
	container.add_child(label)
	return container


func _get_tooltip(at_position: Vector2) -> String:
	if not editor.file_contents:
		return ""
	var line_column: Vector2i = get_line_column_at_pos(at_position, false)
	if line_column == Vector2i(-1, -1):
		return ""
	var index: int = StringUtil.get_index(text, line_column.y, line_column.x)
	return editor.file_contents.get_tooltip(text, index)


func get_carets(sort_func: Callable = Callable()) -> Array[Vector2i]:
	var arr: Array[Vector2i] = []
	for i in get_caret_count():
		arr.append(Vector2i(get_caret_column(i), get_caret_line(i)))
	
	if not sort_func.is_null():
		arr.sort_custom(sort_func)
	
	return arr
