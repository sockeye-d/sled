extends Node


const SETTINGS_PATH: String = "user://settings.sled"


var settings_window: SettingsWindow = preload("res://src/ui/settings_window/settings_window.tscn").instantiate()
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
var could_load_settings: bool = false


func _init() -> void:
	load_settings()
	settings_window.hide()


func _ready() -> void:
	get_tree().root.add_child.call_deferred(settings_window)
	settings_window.setting_changed.connect(func(_identifier: String, _new_value): save_settings())
	
	if not could_load_settings:
		await get_tree().process_frame
		await get_tree().process_frame
		settings_window.set_all_to_default()


func show_settings_window():
	settings_window.show()


func _get(property: StringName) -> Variant:
	if property in settings_window.settings:
		return settings_window.settings[property]
	
	if property in settings_window.settings_items:
		return settings_window.settings_items[property].value
	
	return null


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
		could_load_settings = true
		return OK
	else:
		could_load_settings = false
		settings_window.set_all_to_default()
		return FileAccess.get_open_error()
