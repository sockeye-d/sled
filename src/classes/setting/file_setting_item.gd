@tool
class_name FileSettingItem extends StringSettingItem


@export var filters: PackedStringArray


func _create_control() -> Control:
	var fle := FileLineEdit.new()
	
	if value:
		fle.text = value
	
	fle.mode = FileDialog.FILE_MODE_OPEN_FILE
	fle.validate_path = false
	fle.file_filters = filters
	fle.path_changed.connect(func(new_text: String): value = new_text)
	
	return fle


func _get_default_value():
	return ""
