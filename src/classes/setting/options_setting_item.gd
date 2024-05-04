class_name OptionsSettingItem extends SettingItem


@export var default_value: int = 0
@export var options: PackedStringArray


func _create_control() -> Control:
	var new_control := OptionButton.new()
	new_control.allow_reselect = true
	for option in options:
		new_control.add_item(option)
	
	if value:
		new_control.selected = value
	
	new_control.item_selected.connect(
			func(index: int):
				value = index
				)
	setting_changed.connect(
			func(new_value):
				control.select(new_value)
				)
	
	return new_control


func _get_default_value() -> int:
	return default_value


func get_text() -> String:
	if control:
		return options[control.selected]
	return options[value]


func select_text(text: String) -> bool:
	var index = options.find(text)
	if index == -1:
		return false
	value = index
	if control:
		(control as OptionButton).select(index)
	return true
