@tool
class_name DividerSettingItem extends SettingItem


func _create_control() -> Control:
	var new_control = Panel.new()
	
	new_control.add_theme_stylebox_override(&"panel", StyleBoxUtil.new_flat(Color(1.0, 1.0, 1.0, 0.1), [32], [0, 1, 0, 1]))

	new_control.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	new_control.custom_minimum_size.y = 3
	
	return new_control
