extends Node

static var theme: Theme:
	get:
		return preload("res://src/main.theme")
static var last_imported_theme: Dictionary

signal theme_changed(new_theme: String)
signal scale_changed(new_scale: float)
signal code_font_size_changed()
signal main_font_size_changed()


const DEFAULT_THEME: String = "vs code dark"
const THEMES: ThemeLibrary = preload("res://src/themes/themes.tres")
const LIGATURE_SHORTHANDS: Dictionary = {
	"ss": "stylistic_set_",
	"dlig": "discretionary_ligatures",
	"calt": "contextual_alternates",
}


func _ready() -> void:
	Settings.connect_setting(&"ligatures", func(_new_value):
		var f = Settings.get_item(&"font").get_text()
		EditorThemeManager.set_font(f, Settings.ligatures)
	)
	
	Settings.connect_setting(&"font", func(_new_value) -> void:
		var f = Settings.get_item(&"font").get_text()
		EditorThemeManager.set_font(f, Settings.ligatures)
	)
	
	Settings.connect_setting(&"theme", func(_new_value) -> void:
		var new_theme: String = Settings.get_item(&"theme").get_text()
		if new_theme.to_lower() == "custom":
			await SceneTreeUtil.process_frame
			EditorThemeManager.change_theme_from_path.call_deferred(Settings.custom_theme_path)
			return
		if new_theme:
			EditorThemeManager.change_theme(new_theme)
		)
	
	Settings.connect_setting(&"code_font_size", func(new_value: float) -> void:
		theme.set_font_size(&"font_size", &"CodeEdit", new_value as int)
		code_font_size_changed.emit()
	)
	
	Settings.connect_setting(&"main_font_size", func(new_value: float) -> void:
		theme.default_font_size = new_value
		main_font_size_changed.emit()
	)


func get_scale() -> float:
	if theme.has_default_base_scale():
		return theme.default_base_scale
	else:
		return 1.0


func set_scale(scale: float) -> void:
	#theme.default_font_size = 16 * scale as int
	theme.default_base_scale = scale
	scale_changed.emit(scale)


func change_theme_custom(theme_name: String):
	if theme_name in THEMES.themes:
		change_theme_from_text(THEMES.themes[theme_name])


func change_theme(theme_name: String):
	if theme_name in THEMES.themes:
		change_theme_from_text(THEMES.themes[theme_name])


func change_theme_from_path(theme_path: String):
	var file: String = FileAccess.get_file_as_string(theme_path)
	
	if file == "":
		return
	
	change_theme_from_text(file)


func change_theme_from_text(theme_text: String) -> void:
	print("frame ", Engine.get_process_frames())
	#print_stack()
	var start_time := Time.get_ticks_usec()
	var colors := ThemeImporter.get_theme_dict(theme_text)
	last_imported_theme = colors
	ThemeImporter.add_code_edit_themes(EditorThemeManager.theme, colors)
	print(colors)
	print("time taken: ", (Time.get_ticks_usec() - start_time) / 1000000.0, " seconds")
	var t: Theme = theme
	
	t.set_stylebox(&"normal", &"CodeEdit", StyleBoxUtil.new_flat(colors.background_color, [0, 0, 8, 8], [4]))
			
	t.set_color(&"font_color", &"CodeEdit", colors.text_color)
	t.set_color(&"word_highlighted_color", &"CodeEdit", Color(colors.word_highlighted_color, colors.word_highlighted_color.a * 0.5))
	
	t.set_stylebox(&"panel", &"PanelContainer",	StyleBoxUtil.new_flat(colors.background_color, [8, 8, 8, 8], [4]))
	t.set_stylebox(&"panel", &"UpperPanelContainer",	StyleBoxUtil.new_flat(colors.background_color, [8, 8, 0, 0], [4]))
	t.set_stylebox(&"panel", &"LowerPanelContainer",	StyleBoxUtil.new_flat(colors.background_color, [0, 0, 8, 8], [4]))
	
	t.set_stylebox(&"panel", &"Tree", StyleBoxUtil.new_flat(colors.background_color, [8], [4]))
	
	t.set_color(&"font_color", &"Tree", colors.text_color)
	
	t.set_color(&"font_color", &"Button", colors.text_color)
	t.set_color(&"font_focus_color", &"Button", colors.text_color)
	t.set_color(&"font_hover_color", &"Button", colors.text_color.darkened(0.05))
	t.set_color(&"font_hover_pressed_color", &"Button", colors.text_color.darkened(0.15))
	t.set_color(&"font_pressed_color", &"Button", colors.text_color.darkened(0.1))
	t.set_stylebox(&"disabled", &"Button", StyleBoxUtil.new_flat(colors.background_color.darkened(0.25), [4], [4]))
	t.set_stylebox(&"normal", &"Button", StyleBoxUtil.new_flat(colors.background_color.darkened(0.2), [4], [4]))
	t.set_stylebox(&"hover", &"Button", StyleBoxUtil.new_flat(colors.background_color.darkened(0.15), [4], [4]))
	t.set_stylebox(&"pressed", &"Button", StyleBoxUtil.new_flat(colors.background_color.darkened(0.1), [4], [4]))
	
	t.set_color(&"font_color", &"CheckBox", colors.text_color)
	t.set_color(&"font_focus_color", &"CheckBox", colors.text_color)
	t.set_color(&"font_hover_color", &"CheckBox", colors.text_color.darkened(0.05))
	t.set_color(&"font_hover_pressed_color", &"CheckBox", colors.text_color.darkened(0.15))
	t.set_color(&"font_pressed_color", &"CheckBox", colors.text_color.darkened(0.1))
	t.set_stylebox(&"disabled", &"CheckBox", StyleBoxUtil.new_flat(colors.background_color.darkened(0.25), [4], [4]))
	t.set_stylebox(&"normal", &"CheckBox", StyleBoxUtil.new_flat(colors.background_color.darkened(0.2), [4], [4]))
	t.set_stylebox(&"hover", &"CheckBox", StyleBoxUtil.new_flat(colors.background_color.darkened(0.15), [4], [4]))
	t.set_stylebox(&"hover_pressed", &"CheckBox", StyleBoxUtil.new_flat(colors.background_color.darkened(0.15), [4], [4]))
	t.set_stylebox(&"pressed", &"CheckBox", StyleBoxUtil.new_flat(colors.background_color.darkened(0.1), [4], [4]))
	
	t.set_color(&"font_color", &"Label", colors.text_color)
	
	t.set_color(&"font_color", &"LineEdit", colors.text_color)
	
	t.set_stylebox(&"normal", &"LineEdit",
		StyleBoxUtil.new_flat(colors.background_color.darkened(0.2), [4], [4]))
	t.set_stylebox(&"read_only", &"LineEdit",
		StyleBoxUtil.new_flat(colors.background_color.darkened(0.25), [4], [4]))
	
	t.set_color(&"font_color", &"OptionButton", colors.text_color)
	t.set_color(&"font_focus_color", &"OptionButton", colors.text_color)
	t.set_color(&"font_hover_color", &"OptionButton", colors.text_color.lightened(0.05))
	t.set_color(&"font_hover_pressed_color", &"OptionButton", colors.text_color.lightened(0.15))
	t.set_color(&"font_pressed_color", &"OptionButton", colors.text_color.lightened(0.1))
	t.set_stylebox(&"normal", &"OptionButton",
		StyleBoxUtil.new_flat(colors.background_color.darkened(0.2), [4], [4]))
	t.set_stylebox(&"hover", &"OptionButton",
		StyleBoxUtil.new_flat(colors.background_color.darkened(0.15), [4], [4]))
	t.set_stylebox(&"pressed", &"OptionButton",
		StyleBoxUtil.new_flat(colors.background_color.darkened(0.1), [4], [4]))
	
	t.set_stylebox(&"panel", &"AcceptDialog",
		StyleBoxUtil.new_flat(colors.background_color.darkened(0.2), [0], [4]))
	
	t.set_stylebox(&"panel", &"PopupMenu",
		StyleBoxUtil.new_flat(colors.background_color, [4], [4], [2], colors.background_color.darkened(0.2)))
	t.set_stylebox(&"hover", &"PopupMenu",
		StyleBoxUtil.new_flat(colors.background_color.darkened(0.1), [4], [4]))
	t.set_color(&"font_color", &"PopupMenu", colors.text_color)
	t.set_color(&"font_hover_color", &"PopupMenu", colors.text_color)
	
	t.set_stylebox(&"panel", &"TooltipPanel",
		StyleBoxUtil.new_flat(colors.background_color, [4], [8, 4], [2],
		colors.background_color.lightened(0.2)))
	
	t.set_color(&"font_color", &"TooltipLabel", colors.text_color)
	RenderingServer.set_default_clear_color(colors.background_color.darkened(0.2))
	
	theme_changed.emit(theme_text)

func set_font(font_name: String, ligatures: String = ""):
	var new_font: FontVariation = FontVariation.new()
	new_font.base_font = create_system_font(font_name, "Monospace")
	
	var features: Dictionary = convert_tags_to_names(new_font.get_supported_feature_list())
	new_font.opentype_features = _convert_ligatures(features, ligatures)
	
	theme.set_font(&"font", &"CodeEdit", new_font)
	theme.set_font(&"mono_font", &"RichTextLabel", new_font)


func create_system_font(font_name: String, fallback: String = "") -> SystemFont:
	var font: = SystemFont.new()
	
	font.font_names = [font_name, fallback] if fallback else [font_name]
	
	return font


func convert_tags_to_names(dict: Dictionary) -> Dictionary:
	var new_dict := { }
	
	for key in dict:
		new_dict[TextServerManager.get_primary_interface().tag_to_name(key)] = dict[key]
	
	return new_dict


func _convert_ligatures(features: Dictionary, ligatures: String, shorthands: Dictionary = LIGATURE_SHORTHANDS) -> Dictionary:
	var filtered: Dictionary = { }
	var replaced: String = StringUtil.replace_all(ligatures, shorthands)
	for lig in replaced.split(",", false):
		if lig in features:
			filtered[TextServerManager.get_primary_interface().name_to_tag(lig)] = 1
	
	return filtered
