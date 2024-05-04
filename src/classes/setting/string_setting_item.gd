class_name StringSettingItem extends SettingItem


@export var default_value: String = ""


func _create_control() -> Control:
	var new_control = LineEdit.new()
	
	if value:
		new_control.text = value
	
	new_control.text_changed.connect(func(new_text: String): value = new_text)
	
	if not setting_changed.is_connected(_on_setting_changed):
		setting_changed.connect(_on_setting_changed)
	
	return new_control


func _get_default_value() -> String:
	return default_value


func _on_setting_changed(new_value: String) -> void:
	if not new_value == control.text:
		control.text = new_value
