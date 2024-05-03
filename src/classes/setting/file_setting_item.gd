class_name FileSettingItem extends StringSettingItem


var line_edit: LineEdit
@export var filters: PackedStringArray
@export var button_text: String


func _create_control() -> Control:
	var hbox := HBoxContainer.new()
	line_edit = super()
	line_edit.caret_blink = true
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var button = Button.new()
	button.text = button_text
	
	if value:
		line_edit.text = value
	
	line_edit.text_changed.connect(func(new_text: String): value = new_text)
	button.pressed.connect(_show_file_dialog)
	hbox.add_child(line_edit)
	hbox.add_child(button)
	
	self.setting_changed.connect(func(new_value): line_edit.text = new_value)
	
	return hbox


func _show_file_dialog() -> void:
	var fd := FileDialog.new()
	fd.use_native_dialog = true
	fd.filters = filters
	fd.file_selected.connect(_on_file_accepted)
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	
	fd.show()


func _get_default_value():
	return ""
	

func _on_file_accepted(path: String) -> void:
	line_edit.text = path
