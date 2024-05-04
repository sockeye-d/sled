class_name SettingItem extends Resource


signal setting_changed(new_value)


@export_storage var value:
	set(v):
		value = v
		setting_changed.emit(value)
	get:
		return value
var control: Control
@export var name: String
@export var identifier: StringName
@export_multiline var tooltip: String


func _init(_name: String = "") -> void:
	name = _name
	value = _get_default_value()


func create_control() -> void:
	control = _create_control()


func _create_control() -> Control:
	return null


func _get_default_value():
	return null
