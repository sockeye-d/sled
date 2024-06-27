@tool
class_name SettingItem extends Resource


signal setting_changed(new_value)


@export_storage var value:
	set(v):
		value = v
		print("emitted1")
		setting_changed.emit(v)
	get:
		return value
var control: Control
@export var name: String
@export var identifier: StringName:
	get:
		return identifier
	set(value):
		identifier = value
		resource_name = "%s (%s)" % [identifier, get_script().get_global_name()]
@export_multiline var tooltip: String
@export var init_script: Script


var init_script_ran: bool = false


func _init(_name: String = "") -> void:
	name = _name
	value = _get_default_value()
	(func():
		if init_script:
			ScriptUtils.run(init_script, SettingInitScript.METHOD, [self])
		).call_deferred()


func _property_can_revert(property: StringName) -> bool:
	match property:
		&"identifier":
			return true
	return false


func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"identifier":
			if name:
				return name.to_snake_case()
			else:
				return null
	return null


func run_init_script() -> void:
	if not init_script_ran and init_script:
		ScriptUtils.run(init_script, SettingInitScript.METHOD, [self])
		init_script_ran = true

## Returns whether a control was created or not
func create_control() -> bool:
	if not is_instance_valid(control):
		control = _create_control()
		control.set_meta(&"item_control", true)
		return true
	return false


func _create_control() -> Control:
	return null


func _get_default_value():
	return null
