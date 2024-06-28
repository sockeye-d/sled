@tool
class_name FileSettingItem extends StringSettingItem


var line_edit: LineEdit
@export var filters: PackedStringArray
@export var button_text: String
@export var button_icon: Texture2D


func _create_control() -> Control:
	var hbox := HBoxContainer.new()
	line_edit = super()
	line_edit.caret_blink = true
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var button = Button.new()
	button.text = button_text
	button.icon = Util.default(button_icon, Icons.create("open_dir"))
	
	if value:
		line_edit.text = value
	
	line_edit.text_changed.connect(func(new_text: String): value = new_text)
	button.pressed.connect(_show_file_dialog)
	hbox.add_child(line_edit, false, Node.INTERNAL_MODE_BACK)
	hbox.add_child(button, false, Node.INTERNAL_MODE_BACK)
	
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
	value = path


func _on_setting_changed(new_value: String) -> void:
	if not new_value == line_edit.text:
		line_edit.text = new_value
