class_name Editor extends Control


const MAIN_FONT_ITALICS = preload("res://src/assets/fonts/main_font_italics.tres")


enum ConfirmationAction {
	SAVE,
	DISCARD,
	CANCEL,
}


signal _continue(action_taken: ConfirmationAction)


@onready var panel_container: PanelContainer = %UpperPanelContainer
@onready var save_button: Button = %SaveButton
@onready var path_button: Button = %PathButton
@onready var code_editor: CodeEditor = %CodeEditor
@onready var confirmation_dialog: ConfirmationDialog = %ConfirmationDialog
@onready var code_completion_timer: Timer = %CodeCompletionTimer
@onready var find_box: FindBox = %FindBox
@onready var caret_pos_label: Label = %CaretPosLabel


@export var editor_theme: String:
	set(value):
		editor_theme = value
		load_theme(editor_theme)
	get:
		return editor_theme


var file_handle: FileAccess
var last_saved_text: String
var file_path: String:
	get:
		if file_handle:
			return file_handle.get_path_absolute()
		return ""
var old_text: String
var base_path: String
var file_contents: GLSLLanguage.FileContents:
	set(value):
		file_contents = value
	get:
		if not file_contents:
			refresh_file_contents()
		return file_contents
var found_ranges: Array[Vector2i]
var current_range_index: int


var analysis_thread: Thread = Thread.new()
var analyzer_invalidate_sem: Semaphore = Semaphore.new()
## [code]{ file_path: String, text: String, base_path: String, exit_loop: bool }[/code]
var analysis_data: Dictionary
var analyzer_mut: Mutex = Mutex.new()


func _ready() -> void:
	load_theme(editor_theme)
	
	confirmation_dialog.add_button("Discard", true, "discarded")
	
	if EditorThemeManager:
		EditorThemeManager.theme_changed.connect(load_theme)
	
	if EditorManager:
		EditorManager.save_requested.connect(_on_save_button_pressed)
	
	if code_editor:
		code_editor.save_requested.connect(_on_save_button_pressed)
	
	analysis_thread.start(analyze_file_on_thread)
	
	Settings.settings_window.setting_changed.connect(func(_identifier: StringName, _new_value): _set_all_settings())
	await get_tree().process_frame
	await get_tree().process_frame
	_set_all_settings()


func _exit_tree() -> void:
	analyzer_mut.lock()
	analysis_data = { "file_path": "", "text": "", "base_path": "", "exit_loop": true }
	analyzer_mut.unlock()
	analyzer_invalidate_sem.post()
	analysis_thread.wait_to_finish()


func load_file(path: String) -> void:
	if file_handle and path == file_handle.get_path_absolute():
		return
	if file_handle and not code_editor.text == last_saved_text:
		confirmation_dialog.popup_centered()
		var action: ConfirmationAction = await _continue
		match action:
			ConfirmationAction.SAVE:
				save()
			ConfirmationAction.CANCEL:
				return
			# No ConfirmationAction.DISCARD block, because it will just continue down

	# Save the old one in case loading fails
	var old_file_handle = file_handle
	file_handle = FileAccess.open(path, FileAccess.READ)

	if file_handle == null:
		NotificationManager.notify("%s failed to open" % path.get_file(), NotificationManager.TYPE_ERROR)
		file_handle = old_file_handle
		code_editor.editable = false
		return

	NotificationManager.notify("Opened %s" % file_handle.get_path_absolute().get_file(), NotificationManager.TYPE_NORMAL)
	if old_file_handle:
		old_file_handle.close()
	code_editor.editable = true
	code_editor.text = file_handle.get_as_text(true)
	last_saved_text = code_editor.text
	old_text = code_editor.text

	path_button.text = path.get_file()
	
	if Settings.syntax_highlighting_enabled:
		if path.get_extension() in Settings.syntax_highlighted_files.split(",", false):
			if code_editor.syntax_highlighter == null:
				load_theme(ThemeImporter.last_imported_theme)
		else:
			code_editor.syntax_highlighter = null
	else:
		code_editor.syntax_highlighter = null
	
	refresh_file_contents()


func save(path: String = file_path) -> void:
	file_handle = FileAccess.open(path, FileAccess.WRITE)
	if not file_handle:
		NotificationManager.notify("Failed to save at path %s" % file_handle.get_path_absolute().get_file(), NotificationManager.TYPE_ERROR)
		return
	file_handle.seek(0)
	file_handle.store_string(code_editor.text)
	file_handle.flush()
	last_saved_text = code_editor.text

	NotificationManager.notify("Saved %s" % file_handle.get_path_absolute().get_file(), NotificationManager.TYPE_NORMAL)
	path_button.remove_theme_font_override(&"font")
	path_button.text = file_handle.get_path_absolute().get_file()
	
	code_editor.tag_saved_version()


func load_theme(file: String) -> void:
	if file and code_editor:
		ThemeImporter.import_theme(file, code_editor, GLSLLanguage.base_types, GLSLLanguage.keywords.keys(), GLSLLanguage.comment_regions, GLSLLanguage.string_regions)
		if not code_editor.syntax_highlighter.has_color_region("#"):
			code_editor.syntax_highlighter.add_color_region("#", "", get_theme_color("background_color").lightened(0.5))


func analyze_file_on_thread() -> void:
	while true:
		analyzer_invalidate_sem.wait()
		
		analyzer_mut.lock()
		var data_copy = analysis_data.duplicate()
		analyzer_mut.unlock()

		if data_copy.exit_loop:
			break

		var start_time := Time.get_ticks_msec()
		var parse_results := GLSLLanguage.get_file_contents(data_copy.file_path, data_copy.text, 0, data_copy.base_path, true)
		print(Time.get_ticks_msec() - start_time, "milliseconds")
		
		analyzer_mut.lock()
		file_contents = parse_results
		analyzer_mut.unlock()


func _set_all_settings() -> void:
	code_editor.gutters_draw_line_numbers = Settings.show_line_numbers
	code_editor.gutters_zero_pad_line_numbers = Settings.zero_pad_line_numbers
	code_editor.caret_type = Settings.caret_style
	code_editor.scroll_past_end_of_file = Settings.scroll_past_eof
	var mode = Settings.text_wrapping_mode
	if mode == 0:
		code_editor.wrap_mode = TextEdit.LINE_WRAPPING_NONE
	else:
		code_editor.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
		code_editor.autowrap_mode = mode as TextServer.AutowrapMode
	code_editor.indent_wrapped_lines = Settings.indent_wrapped_lines


func _on_confirmation_dialog_canceled() -> void:
	_continue.emit(ConfirmationAction.CANCEL)


func _on_confirmation_dialog_confirmed() -> void:
	_continue.emit(ConfirmationAction.SAVE)


func _on_confirmation_dialog_custom_action(action: StringName) -> void:
	match action:
		"discarded":
			_continue.emit(ConfirmationAction.DISCARD)
			confirmation_dialog.hide()


func _on_code_editor_text_changed() -> void:
	refresh_file_contents()
	
	if Settings.auto_code_completion:
		if old_text.length() < code_editor.text.length():
			if Settings.code_completion_delay < 0.0001:
				_on_code_editor_code_completion_requested()
			else:
				code_completion_timer.start(Settings.code_completion_delay)
		else:
			if not code_completion_timer.is_stopped():
				code_completion_timer.stop()
	
	if code_editor.text == last_saved_text:
		path_button.remove_theme_font_override(&"font")
		path_button.text = file_handle.get_path_absolute().get_file()
	else:
		path_button.add_theme_font_override(&"font", MAIN_FONT_ITALICS)
		path_button.text = file_handle.get_path_absolute().get_file() + " (unsaved)"
	
	old_text = code_editor.text
	
	if find_box.visible:
		_on_find_box_pattern_changed(find_box.pattern, find_box.use_regex, find_box.case_insensitive, false)


func _on_code_editor_code_completion_requested() -> void:
	_get_completion_suggestions()
	code_editor.update_code_completion_options(true)


func _get_completion_suggestions() -> void:
	var is_exclusive: Array
	analyzer_mut.lock()
	if not file_contents:
		analyzer_mut.unlock()
		return
	CodeCompletionSuggestion.add_arr_to(
			file_contents.as_suggestions(
				StringUtil.get_index(
					code_editor.text,
					code_editor.get_caret_line(code_editor.get_caret_count() - 1),
					code_editor.get_caret_column(code_editor.get_caret_count() - 1),
				),
				code_editor.text,
				Settings.exclusive_suggestions,
				is_exclusive,
			),
			code_editor,
		)
	print(file_contents)
	analyzer_mut.unlock()
	if not is_exclusive[0]:
		CodeCompletionSuggestion.add_arr_to(GLSLLanguage.FileContents.built_in_contents.as_suggestions(0), code_editor)
		for keyword in GLSLLanguage.keywords:
			code_editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, keyword, keyword.lstrip("#"), Color.WHITE, GLSLLanguage.keywords[keyword])


func refresh_file_contents():
	analyzer_mut.lock()
	analysis_data = {
		"file_path": file_path,
		"text": code_editor.text,
		"base_path": FileManager.absolute_base_path if Settings.inc_absolute_paths else "",
		"exit_loop": false,
	}
	analyzer_mut.unlock()

	analyzer_invalidate_sem.post()


func _on_save_button_pressed() -> void:
	save()


func _on_code_editor_symbol_validate(symbol: String) -> void:
	# TODO: implement go to def?
	return
	print(symbol)
	code_editor.set_symbol_lookup_word_as_valid(true)


func _on_code_editor_symbol_lookup(symbol: String, line: int, column: int) -> void:
	return
	print(symbol)


func _on_find_box_pattern_changed(pattern: String, use_regex: bool, case_insensitive: bool, select_occurence: bool = true) -> void:
	if use_regex:
		var regex: RegEx
		var text: String
		if case_insensitive:
			pattern = RegExUtil.as_lowercase(pattern)
			text = code_editor.text.to_lower()
		else:
			text = code_editor.text
		regex = RegExUtil.create(pattern)
		if not regex:
			find_box.set_invalid_pattern(true)
			NotificationManager.notify("Pattern '%s' failed to compile" % pattern, NotificationManager.TYPE_ERROR)
			found_ranges = []
		else:
			find_box.set_invalid_pattern(false)
			# have to use assign because it treats Array and Array[Vector2i] as
			# separate types :(
			found_ranges.assign(regex.search_all(text).map(_match_to_range))
	else:
		find_box.set_invalid_pattern(false)
		if case_insensitive:
			found_ranges = StringUtil.findn_all_occurrences(code_editor.text, pattern)
		else:
			found_ranges = StringUtil.find_all_occurrences(code_editor.text, pattern)
	find_box.set_match_count(found_ranges.size())
	if found_ranges:
		current_range_index = _find_closest_range(Util.get_caret_index(code_editor), found_ranges)
		if select_occurence:
			_select_range(found_ranges[current_range_index])


func _match_to_range(m: RegExMatch) -> Vector2i:
	return Vector2i(m.get_start(), m.get_end())


func _on_find_box_go_to_next_requested() -> void:
	if not found_ranges:
		return
	current_range_index += 1
	if current_range_index > found_ranges.size() - 1:
		current_range_index = 0
	_select_range()


func _on_find_box_go_to_previous_requested() -> void:
	if not found_ranges:
		return
	current_range_index -= 1
	if current_range_index < 0:
		current_range_index = found_ranges.size() - 1
	_select_range()


func _select_range(range: Vector2i = found_ranges[current_range_index] if current_range_index < found_ranges.size() else Vector2i(-1, -1), add_new_caret: bool = false) -> void:
	if range == Vector2i(-1, -1):
		return
	var col_line_0: Vector2i = StringUtil.get_line_col(code_editor.text, range[0])
	var col_line_1: Vector2i = StringUtil.get_line_col(code_editor.text, range[1])
	if add_new_caret:
		var caret_i: int = code_editor.add_caret(col_line_0.y, col_line_0.x)
		code_editor.select(col_line_0.y, col_line_0.x, col_line_1.y, col_line_1.x, caret_i)
	else:
		code_editor.select(col_line_0.y, col_line_0.x, col_line_1.y, col_line_1.x, 0)
	code_editor.center_viewport_to_caret(code_editor.get_caret_count() - 1)


func _on_code_editor_caret_changed() -> void:
	caret_pos_label.text = "%s, %s" % [code_editor.get_caret_line(), code_editor.get_caret_column()]


func _convert_range(range: Vector2i) -> Array[Vector2i]:
	return [StringUtil.get_line_col(code_editor.text, range[0]), StringUtil.get_line_col(code_editor.text, range[1])]


func _on_find_box_select_all_occurrences_requested() -> void:
	if found_ranges:
		var range_0 := _convert_range(found_ranges[0])
		code_editor.select(range_0[0].y, range_0[0].x, range_0[1].y, range_0[1].x)
		for range in found_ranges.slice(1):
			var range_1 := _convert_range(range)
			var caret := code_editor.add_caret(0, 0)
			code_editor.select(range_1[0].y, range_1[0].x, range_1[1].y, range_1[1].x, caret)
		##if found_ranges.size() > 1:
			##code_editor.remove_caret(0)
		code_editor.grab_focus()


func _on_code_editor_find_requested() -> void:
	find_box.show_with_focus()
	


func _on_find_box_replace_requested(with_what: String) -> void:
	if current_range_index > found_ranges.size() - 1:
		return
	var r := found_ranges[current_range_index]
	var range_offset: int = with_what.length() - r.y + r.x
	_select_range(r)
	code_editor.insert_text_at_caret(with_what, 0)
	found_ranges.remove_at(current_range_index)
	if found_ranges:
		for i in range(current_range_index, found_ranges.size()):
			found_ranges[i] += Vector2i.ONE * range_offset
		_select_range()


func _find_closest_range(to_what: int, ranges: Array[Vector2i]) -> int:
	var closest_range: Vector2i = Vector2i.ZERO
	var closest_range_index: int = -1
	for range_i in ranges.size():
		var x_diff := absi(to_what - ranges[range_i].x) - absi(to_what - closest_range.x)
		if x_diff == 0:
			var y_diff := absi(to_what - ranges[range_i].y) - absi(to_what - closest_range.y)
			if y_diff >= 0:
				continue
		elif x_diff > 0:
			continue
		closest_range_index = range_i
		closest_range = ranges[range_i]
	return closest_range_index


func _on_find_box_replace_all_occurrences_requested(with_what: String) -> void:
	_on_find_box_select_all_occurrences_requested()
	code_editor.insert_text_at_caret(with_what)


func _on_find_box_hidden() -> void:
	code_editor.grab_focus()
