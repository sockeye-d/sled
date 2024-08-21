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


#var file_handle: FileAccess
var last_saved_text: String
var file_path: String
var file_gets_completion: bool
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


var highlighter: CodeHighlighter = CodeHighlighter.new()


var analysis_thread: Thread = Thread.new()
var analyzer_invalidate_sem: Semaphore = Semaphore.new()
## [code]{ file_path: String, text: String, base_path: String, exit_loop: bool }[/code]
var analysis_data: Dictionary
var analyzer_mut: Mutex = Mutex.new()


func _ready() -> void:
	confirmation_dialog.add_button("Discard", true, "discarded")
	
	if EditorThemeManager:
		EditorThemeManager.theme_changed.connect(load_theme)
	
	if EditorManager:
		EditorManager.save_requested.connect(_on_save_button_pressed)
		EditorManager.file_free_requested.connect(func(path: String):
			if path == file_path:
				unload_file()
		)
	
	if code_editor:
		code_editor.save_requested.connect(_on_save_button_pressed)
	
	analysis_thread.start(analyze_file_on_thread)
	
	Settings.settings_window.setting_changed.connect(func(_identifier: StringName, _new_value): _set_all_settings())
	_set_all_settings()
	
	load_theme()


func _exit_tree() -> void:
	if analysis_thread.is_alive():
		analyzer_mut.lock()
		analysis_data = {
			"exit_loop": true,
		}
		analyzer_mut.unlock()
		analyzer_invalidate_sem.post()
		
		analysis_thread.wait_to_finish()


func load_file(path: String, selection_from: int = -1, selection_to: int = -1) -> void:
	if path == file_path:
		if selection_from > 0:
			var a := StringUtil.get_line_col(code_editor.text, selection_from)
			var b := StringUtil.get_line_col(code_editor.text, selection_to)
			code_editor.select(a.y, a.x, b.y, b.x)
			code_editor.center_viewport_to_caret.call_deferred()
		return
	if not code_editor.text == last_saved_text:
		confirmation_dialog.popup_centered()
		var action: ConfirmationAction = await _continue
		match action:
			ConfirmationAction.SAVE:
				save()
			ConfirmationAction.CANCEL:
				return
			# No ConfirmationAction.DISCARD block, because it will just continue down

	var file_handle = FileAccess.open(path, FileAccess.READ)

	if file_handle == null:
		NotificationManager.notify("'%s' failed to open" % path.get_file(), NotificationManager.TYPE_ERROR)
		#file_handle = old_file_handle
		file_path = ""
		unload_file.call_deferred()
		return
	
	NotificationManager.notify("Opened '%s'" % file_handle.get_path_absolute().get_file(), NotificationManager.TYPE_NORMAL)
	code_editor.editable = true
	code_editor.text = file_handle.get_as_text(true)
	code_editor.clear_undo_history()
	last_saved_text = code_editor.text
	old_text = code_editor.text
	found_ranges = []
	find_box.hide()
	
	_set_unsaved(false)
	
	file_path = path
	
	file_gets_completion = path.get_extension().to_lower() in Settings.get_arr(&"completing_file_types")
	
	if selection_from > 0:
		var a := StringUtil.get_line_col(code_editor.text, selection_from)
		var b := StringUtil.get_line_col(code_editor.text, selection_to)
		code_editor.select(a.y, a.x, b.y, b.x)
		code_editor.center_viewport_to_caret.call_deferred()
	
	path_button.text = path.get_file()
	
	if (
		Settings.syntax_highlighting_enabled
		and path.get_extension().to_lower() in Settings.get_arr(&"syntax_highlighted_files")
		):
		code_editor.syntax_highlighter = highlighter
	else:
		code_editor.syntax_highlighter = null
	
	refresh_file_contents()


func unload_file() -> void:
	code_editor.text = ""
	code_editor.editable = false
	hide()
	EditorManager.view_menu_state_change_requested.emit(get_index(), false)
	NotificationManager.notify("Closed '%s'" % file_path.get_file(), NotificationManager.TYPE_NORMAL)


func save(path: String = file_path) -> void:
	var file_handle = FileAccess.open(path, FileAccess.WRITE)
	if not file_handle:
		NotificationManager.notify_err(FileAccess.get_open_error(), "Failed to save '%s' (reason: %s)" % [path.get_file(), "%s"], true)
		return
	file_handle.store_string(code_editor.text)
	file_handle.close()
	last_saved_text = code_editor.text

	NotificationManager.notify("Saved '%s'" % file_path.get_file(), NotificationManager.TYPE_NORMAL)
	path_button.remove_theme_font_override(&"font")
	path_button.text = file_handle.get_path_absolute().get_file()
	
	code_editor.tag_saved_version()
	
	file_path = path


func load_theme(file: String = "") -> void:
	if code_editor:
		ThemeImporter.mut_highlighter(EditorThemeManager.last_imported_theme, highlighter, GLSLLanguage.base_types, GLSLLanguage.keywords.keys(), GLSLLanguage.comment_regions, GLSLLanguage.string_regions)
		if not highlighter.has_color_region("#"):
			highlighter.add_color_region("#", "", Color(code_editor.get_theme_color(&"font_color"), 0.7))


func analyze_file_on_thread() -> void:
	while true:
		analyzer_invalidate_sem.wait()
		
		analyzer_mut.lock()
		var data_copy = analysis_data.duplicate()
		analyzer_mut.unlock()

		if data_copy.exit_loop:
			break
		
		var parse_results := GLSLLanguage.get_file_contents(data_copy.file_path, data_copy.text, 0, data_copy.base_path, true)
		
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
	code_editor.scroll_smooth = Settings.use_smooth_scrolling
	code_editor.scroll_v_scroll_speed = Settings.scroll_speed
	code_editor.minimap_draw = Settings.show_minimap
	code_editor.minimap_width = Settings.minimap_width


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
	if file_gets_completion:
		refresh_file_contents()
	
	if Settings.auto_code_completion and file_gets_completion:
		if old_text.length() <= code_editor.text.length():
			if Settings.code_completion_delay < 0.0001:
				_on_code_editor_code_completion_requested()
			else:
				code_completion_timer.stop()
				code_completion_timer.start(Settings.code_completion_delay)
		else:
			if not code_completion_timer.is_stopped():
				code_completion_timer.stop()
	
	_set_unsaved(code_editor.text == last_saved_text)
	
	old_text = code_editor.text
	
	if find_box.visible:
		_on_find_box_pattern_changed(find_box.pattern, find_box.use_regex, find_box.case_insensitive, false)


func _set_unsaved(is_unsaved: bool) -> void:
	if is_unsaved:
		path_button.remove_theme_font_override(&"font")
		path_button.text = file_path.get_file()
	else:
		path_button.add_theme_font_override(&"font", MAIN_FONT_ITALICS)
		path_button.text = file_path.get_file() + " (unsaved)"


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
	analyzer_mut.unlock()
	if not is_exclusive[0]:
		CodeCompletionSuggestion.add_arr_to(GLSLLanguage.FileContents.built_in_contents.as_suggestions(0), code_editor)
		for keyword in GLSLLanguage.keywords:
			code_editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, keyword, keyword, EditorThemeManager.completion_color, GLSLLanguage.keywords[keyword])


func refresh_file_contents():
	if not analysis_thread.is_alive():
		analysis_thread.start(analyze_file_on_thread)
	
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


func _on_find_box_pattern_changed(pattern: String, use_regex: bool, case_insensitive: bool, select_occurence: bool = true) -> void:
	if use_regex:
		if pattern:
			var regex: RegEx
			var text: String
			if case_insensitive:
				pattern = RegExUtil.as_lowercase(pattern)
				text = code_editor.text.to_lower()
			else:
				text = code_editor.text
			regex = RegExUtil.create(pattern)
			if not regex:
				found_ranges = []
			else:
				# have to use assign because it treats Array and Array[Vector2i] as
				# separate types :(
				found_ranges.assign(regex.search_all(text).map(_match_to_range))
		else:
			found_ranges = []
	else:
		if case_insensitive:
			found_ranges = StringUtil.findn_all_occurrences(code_editor.text, pattern)
		else:
			found_ranges = StringUtil.find_all_occurrences(code_editor.text, pattern)
	find_box.set_match_count(found_ranges.size())
	if found_ranges:
		current_range_index = _find_closest_range(Util.get_caret_index(code_editor), found_ranges)
		if select_occurence:
			_select_range(found_ranges[current_range_index])
	code_editor.highlight_ranges = found_ranges


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


func _select_range(selection_range: Vector2i = found_ranges[current_range_index] if current_range_index < found_ranges.size() else Vector2i(-1, -1), add_new_caret: bool = false) -> void:
	if selection_range == Vector2i(-1, -1):
		return
	var col_offset := 0

	if selection_range[1] < code_editor.text.length() and code_editor.text[selection_range[1]] == "\n":
		selection_range[1] -= 1
		col_offset = 1
	var col_line_0: Vector2i = StringUtil.get_line_col(code_editor.text, selection_range[0])
	var col_line_1: Vector2i = StringUtil.get_line_col(code_editor.text, selection_range[1])
	if add_new_caret:
		var caret_i: int = code_editor.add_caret(col_line_0.y, col_line_0.x)
		code_editor.select(col_line_0.y, col_line_0.x, col_line_1.y, col_line_1.x + col_offset, caret_i)
	else:
		code_editor.select(col_line_0.y, col_line_0.x, col_line_1.y, col_line_1.x + col_offset, 0)
	code_editor.center_viewport_to_caret(code_editor.get_caret_count() - 1)


func _on_code_editor_caret_changed() -> void:
	if code_editor.get_caret_count() == 1:
		caret_pos_label.text = "%s, %s" % [code_editor.get_caret_line(), code_editor.get_caret_column()]
	else:
		caret_pos_label.text = ", ".join(
			Array(code_editor.get_sorted_carets()).map(func(caret: int) -> String:
				return "(%s, %s)" % [
					code_editor.get_caret_line(caret),
					code_editor.get_caret_column(caret),
				],
			),
		)


func _convert_range(selection_range: Vector2i) -> Array[Vector2i]:
	return [
		StringUtil.get_line_col(code_editor.text, selection_range[0]),
		StringUtil.get_line_col(code_editor.text, selection_range[1]),
	]


func _on_find_box_select_all_occurrences_requested() -> void:
	if found_ranges:
		var range_0 := _convert_range(found_ranges[0])
		code_editor.select(range_0[0].y, range_0[0].x, range_0[1].y, range_0[1].x)
		for found_range in found_ranges.slice(1):
			var range_1 := _convert_range(found_range)
			var caret := code_editor.add_caret(0, 0)
			code_editor.select(range_1[0].y, range_1[0].x, range_1[1].y, range_1[1].x, caret)
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
	code_editor.highlight_ranges = []
	code_editor.grab_focus()
