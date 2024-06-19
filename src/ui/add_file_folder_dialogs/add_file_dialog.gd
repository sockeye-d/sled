class_name AddFileDialog extends ConfirmationDialog


signal confirmed_data(name: String, create_matching_file: bool, add_include_guard: bool, include_guard_override: String)


@onready var file_name_line_edit: LineEdit = %FileNameLineEdit
@onready var h_separator: HSeparator = %HSeparator
@onready var create_matching_file_check_box: CheckBox = %CreateMatchingFileCheckBox
@onready var add_include_guard_check_box: CheckBox = %AddIncludeGuardCheckBox
@onready var include_guard_override_line_edit: LineEdit = %IncludeGuardOverrideLineEdit


func _ready() -> void:
	confirmed.connect(_submit)
	canceled.connect(confirmed_data.emit.bind("", false, false, ""))


func reset_and_show() -> void:
	file_name_line_edit.text = ""
	add_include_guard_check_box.button_pressed = false
	create_matching_file_check_box.button_pressed = false
	create_matching_file_check_box.disabled = true
	get_ok_button().disabled = true
	popup_centered()
	file_name_line_edit.grab_focus.call_deferred()


func _on_file_name_line_edit_text_changed(new_text: String) -> void:
	var is_inc: bool = new_text.get_extension() in Settings.include_file_types.split(",")
	var is_sbs: bool = true if FileManager.file_is_sbs(new_text) else false
	add_include_guard_check_box.button_pressed = is_inc
	create_matching_file_check_box.disabled = not is_sbs
	create_matching_file_check_box.button_pressed = is_sbs
	get_ok_button().disabled = false if new_text else true


func _on_file_name_line_edit_text_submitted(new_text: String) -> void:
	_submit()


func _submit() -> void:
	confirmed_data.emit(
		file_name_line_edit.text,
		create_matching_file_check_box.button_pressed,
		add_include_guard_check_box.button_pressed,
		include_guard_override_line_edit.text,
	)
	hide()


func _on_add_include_guard_check_box_toggled(toggled_on: bool) -> void:
	include_guard_override_line_edit.visible = toggled_on
