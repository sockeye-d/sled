class_name SettingItem extends Resource


signal setting_changed(new_value)


@export_storage var value:
	set(v):
		value = v
		setting_changed.emit(v)
	get:
		return value
var control: Control
var on_create_control_callback: Callable
@export var name: String
@export var identifier: StringName
@export_multiline var tooltip: String


func _init(_name: String = "", _on_create_control_callback: Callable = Callable()) -> void:
	name = _name
	on_create_control_callback = _on_create_control_callback
	value = _get_default_value()
	#setting_changed.connect(func(new_value): value = new_value)


func create_control() -> void:
	control = _create_control()
	#if on_create_control_callback:
		#on_create_control_callback.call(self)


func _create_control() -> Control:
	return null


func _get_default_value():
	return -1000
