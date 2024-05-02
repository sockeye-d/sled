extends Node


signal theme_changed(new_theme: String)


const DEFAULT_THEME: String = "vs code dark"
const THEMES: ThemeLibrary = preload("res://src/themes/themes.tres")
const ID_OPEN_THEME: int = 1024


@onready var theme_menu: PopupMenu = get_tree().get_first_node_in_group(&"theme_popup_menu")
@onready var main: Control = get_node("/root/Main")


func _ready() -> void:
	pass


func change_theme(theme_name: String):
	if theme_name in THEMES.themes:
		theme_changed.emit(THEMES.themes[theme_name])


func set_font(font_name: String):
	if font_name in OS.get_system_fonts():
		var new_font := create_system_font(font_name, "Monospace")
		# Have to load it because it's just a path
		var theme = load(ProjectSettings.get_setting("gui/theme/custom"))
		theme.set_font(&"font", &"CodeEdit", new_font)


func create_system_font(font_name: String, fallback: String = "") -> SystemFont:
	var font: = SystemFont.new()
	
	font.font_names = [font_name, fallback] if fallback else [font_name]
	
	return font
