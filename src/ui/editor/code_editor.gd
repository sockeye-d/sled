class_name CodeEditor extends CodeEdit


signal save_requested()
signal find_requested()


@onready var editor: Editor = $".."

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
