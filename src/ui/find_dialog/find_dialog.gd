class_name FindDialog extends ConfirmationDialog


signal finished


@onready var file_line_edit: FileLineEdit = %FileLineEdit
@onready var regex_line_edit: RegExLineEdit = %RegExLineEdit
@onready var use_regex_check_box: CheckBox = %UseRegExCheckBox
@onready var casen_check_box: CheckBox = %CasenCheckBox
@onready var use_filter_check_box: CheckBox = %UseFilterCheckBox
@onready var recursive_check_box: CheckBox = %RecursiveCheckBox
@onready var filter_line_edit: LineEdit = %FilterLineEdit
@onready var panel_container: PanelContainer = %PanelContainer


func open(path: String) -> void:
	file_line_edit.base_path = FileManager.current_path
	file_line_edit.text = FileManager.get_short_path(path)
	file_line_edit.update_validity()
	_set_validity()
	regex_line_edit.grab_focus.call_deferred()
	popup_centered(get_child(0).get_combined_minimum_size())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action(&"escape"):
		_cancel()


func _cancel() -> void:
	finished.emit("")
	hide()


func _set_validity() -> bool:
	var is_valid: bool = true
	if not regex_line_edit.is_valid_pattern:
		is_valid = false
	if regex_line_edit.text.length() == 0:
		is_valid = false
	if not file_line_edit.is_valid_path:
		is_valid = false
	get_ok_button().disabled = not is_valid
	return is_valid


func _on_use_filter_check_box_toggled(toggled_on: bool) -> void:
	filter_line_edit.visible = toggled_on
	size.y = panel_container.get_combined_minimum_size().y
	_set_validity()


func _on_finished() -> void:
	if visible:
		hide()
	if use_regex_check_box.button_pressed:
		EditorManager.regex_search_requested.emit(
			FileManager.get_abs_path(file_line_edit.text),
			regex_line_edit.compiled_regex,
			filter_line_edit.text if use_filter_check_box.button_pressed else "",
			casen_check_box.button_pressed,
			recursive_check_box.button_pressed,
		)
	else:
		EditorManager.simple_search_requested.emit(
			FileManager.get_abs_path(file_line_edit.text),
			regex_line_edit.text,
			filter_line_edit.text if use_filter_check_box.button_pressed else "",
			casen_check_box.button_pressed,
			recursive_check_box.button_pressed,
		)


func _on_use_reg_ex_check_box_toggled(toggled_on: bool) -> void:
	regex_line_edit.pattern_type = (
		RegExLineEdit.PatternType.REGEX if toggled_on else RegExLineEdit.PatternType.SIMPLE
	)
	_set_validity()


func _on_casen_check_box_toggled(toggled_on: bool) -> void:
	regex_line_edit.case_insensitive = toggled_on
	_set_validity()


func _on_file_line_edit_is_valid_path_changed() -> void:
	_set_validity()


func _on_reg_ex_line_edit_text_changed(new_text: String) -> void:
	_set_validity()


func _on_reg_ex_line_edit_text_submitted(new_text: String) -> void:
	var is_valid := _set_validity()
	if is_valid:
		_on_finished()
