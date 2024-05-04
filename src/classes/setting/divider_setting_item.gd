class_name DividerSettingItem extends SettingItem


func _create_control() -> Control:
	var new_control = Panel.new()
	
	new_control.add_theme_stylebox_override(&"panel", StyleBoxUtil.new_flat(Color(1.0, 1.0, 1.0, 0.25), [32], [0, 1, 0, 1]))
	
	value = _get_default_value()
	
	(func():
		new_control.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		new_control.custom_minimum_size.y = 3
		).call_deferred()
	
	return new_control
