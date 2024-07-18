extends Node


const SETTINGS_PATH: String = "user://settings.sled"


var settings_window: SettingsWindow = load("res://src/ui/settings_window/settings_window.tscn").instantiate()
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
	settings_window.setting_changed.connect(func(_identifier: String, _new_value): save_settings())
	$/root/Main.add_child(settings_window)
	
	if not could_load_settings:
		await get_tree().process_frame
		await get_tree().process_frame
		settings_window.set_all_to_default()


func show_settings_window():
	settings_window.popup_centered()


func _get(property: StringName) -> Variant:
	if property in settings_window.settings:
		return settings_window.settings[property]
	
	if property in settings_window.settings_items:
		return settings_window.settings_items[property].value
	
	return null


func get_arr(item_identifier: StringName, delim := ",") -> PackedStringArray:
	return Settings.get(item_identifier).split(delim)


func get_item(item_identifier: StringName) -> SettingItem:
	return settings_window.settings_items[item_identifier]


func save_settings(path: String = SETTINGS_PATH) -> Error:
	var file_handle := FileAccess.open(path, FileAccess.WRITE_READ)
	File.save_variant(path, settings)
	var err: Error = file_handle.get_error()
	file_handle.close()
	
	return err


func load_settings(path: String = SETTINGS_PATH) -> Error:
	var new_settings = File.load_variant(path)
	if new_settings is Dictionary:
		settings_window.load_settings(new_settings)
		could_load_settings = true
		return OK
	else:
		var def_settings: Dictionary = { }
		for cat in SettingsWindow.SETTING_CATEGORIES.setting_categories:
			for setting in cat.settings:
				def_settings[setting.identifier] = setting._get_default_value()
		File.save_variant(path, def_settings)
		settings_window.load_settings(def_settings)
		return OK


## Connects a method to run when the setting specified by target_identifier is changed
func connect_setting(target_identifier: StringName, target: Callable) -> void:
	settings_window.setting_changed.connect(func(identifier, new_value): if identifier == target_identifier: target.call(new_value))
