class_name CodeEditor extends CodeEdit


signal save_requested()

@onready var editor: Editor = $".."

func _gui_input(event: InputEvent) -> void:
	if not editable:
		return
	if event is InputEventKey:
		if event.is_action_pressed("move_lines_down", true, false):
			move_lines_down()
		if event.is_action_pressed("move_lines_up", true, false):
			move_lines_up()
		if event.is_action_pressed("duplicate_lines", true, false):
			duplicate_lines()
		if event.is_action_pressed("delete_lines", true, false):
			delete_lines()
		if event.is_action_pressed("save", true, false):
			save_requested.emit()


func _make_custom_tooltip(for_text: String) -> Object:
	var container: PanelContainer = PanelContainer.new()
	container.add_theme_stylebox_override(&"panel", StyleBoxUtil.new_flat(Color.TRANSPARENT, [0], [0, 5, 0, 5]))
	var label: RichTextLabel = RichTextLabel.new()
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.fit_content = true
	label.bbcode_enabled = true
	label.text = "[code]" + for_text + "[/code]"
	container.add_child(label)
	return container


func _get_tooltip(at_position: Vector2) -> String:
	var line_column: Vector2i = get_line_column_at_pos(at_position, false)
	if line_column == Vector2i(-1, -1):
		return ""
	var index: int = StringUtil.get_index(text, line_column.y, line_column.x)
	return editor.file_contents.get_tooltip(text, index)


func move_lines_down():
	var lines: PackedStringArray = text.split("\n")
	var carets := get_carets(func(a: Vector2i, b: Vector2i): return a.y < b.y)
	if carets[-1].y == lines.size() - 1:
		return
	
	for caret_i in carets.size():
		swap_lines(carets[caret_i].y, carets[caret_i].y + 1)


func move_lines_up():
	var lines: PackedStringArray = text.split("\n")
	var carets = get_carets(func(a: Vector2i, b: Vector2i): return a.y < b.y)
	if carets[0].y == 0:
		return
	
	for caret_i in carets.size():
		swap_lines(carets[caret_i].y, carets[caret_i].y - 1)


func delete_lines():
	var lines: PackedStringArray = text.split("\n")
	var carets = get_carets(func(a: Vector2i, b: Vector2i): return a.y > b.y)
	if carets[0].y == 0:
		return
	
	for caret_i in carets.size():
		lines.remove_at(carets[caret_i].y)
		carets[caret_i].y -= 1
	
	text = "\n".join(lines)
	
	for caret in carets:
		add_caret(caret.y, caret.x)
	remove_caret(0)


func get_carets(sort_func: Callable = Callable()) -> Array[Vector2i]:
	var arr: Array[Vector2i] = []
	for i in get_caret_count():
		arr.append(Vector2i(get_caret_column(i), get_caret_line(i)))
	
	if not sort_func.is_null():
		arr.sort_custom(sort_func)
	
	return arr
