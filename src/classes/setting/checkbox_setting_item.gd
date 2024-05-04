class_name CheckboxSettingItem extends SettingItem


@export var default_value: bool = false
@export var text_on: String = "On"
@export var text_off: String = "Off"


func _create_control() -> Control:
	var new_control = CheckBox.new()
	
	if value:
		new_control.button_pressed = value
	
	new_control.alignment = HORIZONTAL_ALIGNMENT_LEFT
	new_control.text = text_on if new_control.button_pressed else text_off
	
	new_control.toggled.connect(
		func(toggled_on: bool):
			value = toggled_on
			control.text = text_on if control.button_pressed else text_off
			)
	
	self.setting_changed.connect(func(new_value): control.set_pressed_no_signal(new_value))
	
	return new_control


func _get_default_value() -> bool:
	return default_value
