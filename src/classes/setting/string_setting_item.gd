class_name StringSettingItem extends SettingItem


@export var default_value: String = ""


func _create_control() -> Control:
	var new_control = LineEdit.new()
	
	if value:
		new_control.text = value
	
	new_control.text_changed.connect(func(new_text: String): value = new_text)
	
	self.setting_changed.connect(func(new_value): new_control.text = new_value)
	
	return new_control


func _get_default_value() -> String:
	return default_value
