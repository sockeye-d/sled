class_name AddFolderDialog extends ConfirmationDialog


signal confirmed_data(name: String)


@onready var folder_name_line_edit: LineEdit = %FolderNameLineEdit


func _ready() -> void:
	confirmed.connect(_submit)
	canceled.connect(confirmed_data.emit.bind(""))


func reset_and_show() -> void:
	folder_name_line_edit.text = ""
	get_ok_button().disabled = true
	popup_centered()
	folder_name_line_edit.grab_focus.call_deferred()


func _on_folder_name_line_edit_text_changed(new_text: String) -> void:
	get_ok_button().disabled = false if new_text else true


func _on_folder_name_line_edit_text_submitted(_new_text: String) -> void:
	_submit()


func _submit() -> void:
	confirmed_data.emit(folder_name_line_edit.text)
	hide()
