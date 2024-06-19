class_name AddFolderDialog extends ConfirmationDialog


signal confirmed_data(name: String)


@onready var file_name_line_edit: LineEdit = %FileNameLineEdit


func _ready() -> void:
	confirmed.connect(_submit)
	canceled.connect(confirmed_data.emit.bind(""))


func reset_and_show() -> void:
	file_name_line_edit.text = ""
	get_ok_button().disabled = true
	popup_centered()
	file_name_line_edit.grab_focus.call_deferred()


func _on_file_name_line_edit_text_changed(new_text: String) -> void:
	get_ok_button().disabled = false if new_text else true


func _on_file_name_line_edit_text_submitted(_new_text: String) -> void:
	_submit()


func _submit() -> void:
	confirmed_data.emit(file_name_line_edit.text)
	hide()
