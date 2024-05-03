extends Node


const SETTINGS_PATH: String = "user://settings.sled"


@onready var settings_window: SettingsWindow = preload("res://src/ui/settings_window/settings_window.tscn").instantiate()
var settings: Dictionary:
	get:
		if settings_window:
			return settings_window.settings
		return { }
var settings_items: Dictionary:
	get:
		if settings_window:
			return settings_window.settings_items
		return { }


func _ready() -> void:
	settings_window.hide()
	get_tree().root.add_child.call_deferred(settings_window)
	
	await RenderingServer.frame_pre_draw
	load_settings()
	
	settings_window.setting_changed.connect(func(_identifier: String, _new_value): save_settings())


func show_settings_window():
	settings_window.show()


func _get(property: StringName) -> Variant:
	if property in settings:
		return settings_items[property].value
	
	return get(property)


func save_settings(path: String = SETTINGS_PATH) -> Error:
	var file_handle := FileAccess.open(path, FileAccess.WRITE_READ)
	
	file_handle.store_var(settings)
	var err: Error = file_handle.get_error()
	file_handle.close()
	
	return err


func load_settings(path: String = SETTINGS_PATH) -> Error:
	var file_handle := FileAccess.open(path, FileAccess.READ)
	
	if file_handle:
		var new_settings = file_handle.get_var()
		settings_window.load_settings(new_settings)
		return OK
	else:
		return FileAccess.get_open_error()
