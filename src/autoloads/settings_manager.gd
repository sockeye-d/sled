extends Node


const SETTINGS_PATH: String = "user://settings.sledsettings"


@onready var settings_window: SettingsWindow = preload("res://src/ui/settings_window/settings_window.tscn").instantiate()
var settings_items: Dictionary:
	get:
		if settings_window:
			return settings_window.settings_items
		return { }


func _ready() -> void:
	settings_window.hide()
	get_tree().root.add_child.call_deferred(settings_window)
	
	await settings_window.ready
	EditorThemeManager.change_theme(EditorThemeManager.THEMES.themes[settings_items.theme.get_text()])
	EditorThemeManager.set_font(settings_items.font.get_text())


func show_settings_window():
	settings_window.show()


func _get(property: StringName) -> Variant:
	if property in settings_items:
		return settings_items[property].value
	
	return get(property)
