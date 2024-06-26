@tool
class_name SliderSettingItem extends SettingItem


@export var default_value: float = 1.0
@export var min_value: float = 0.0
@export var max_value: float = 1.0
@export var step: float = 1.0
@export var allow_greater: bool = false
@export var allow_lesser: bool = false


func _create_control() -> Control:
	var new_control := SliderCombo.new()
	new_control.min_value = min_value
	new_control.max_value = max_value
	new_control.step = step
	new_control.allow_lesser = allow_lesser
	new_control.allow_greater = allow_greater
	new_control._on_changed()
	
	if value:
		new_control.slider_value = value as float
	else:
		new_control.slider_value = _get_default_value()
	
	new_control.changed_ended.connect(func(): value = control.slider_value)
	self.setting_changed.connect(func(new_value): control.set_value_no_signal_(new_value))
	
	return new_control


func _get_default_value():
	return default_value
