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


func _get_tooltip(at_position: Vector2) -> String:
	return ""
	var pos := get_line_column_at_pos(at_position, false)
	print(pos)


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
