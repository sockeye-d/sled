extends Node

static var theme: Theme = load(ProjectSettings.get_setting("gui/theme/custom"))

signal theme_changed(new_theme: String)


const DEFAULT_THEME: String = "vs code dark"
const THEMES: ThemeLibrary = preload("res://src/themes/themes.tres")
const LIGATURE_SHORTHANDS: Dictionary = {
	"ss": "stylistic_set_",
	"dlig": "discretionary_ligatures",
	"calt": "contextual_alternates",
}


func change_theme(theme_name: String):
	if theme_name in THEMES.themes:
		var colors = ThemeImporter.import_theme(THEMES.themes[theme_name], null, GLSLLanguage.base_types, GLSLLanguage.keywords, GLSLLanguage.comment_regions, GLSLLanguage.string_regions)
		
		theme.set_stylebox(&"normal", &"CodeEdit",
				StyleBoxUtil.new_flat(colors.background_color, [0, 0, 8, 8], [4]))
				
		theme.set_color(&"font_color", &"CodeEdit", colors.text_color)
		
		theme.set_stylebox(&"panel", &"PanelContainer",
				StyleBoxUtil.new_flat(colors.background_color, [8, 8, 0, 0], [4]))
		
		theme.set_stylebox(&"panel", &"Tree",
				StyleBoxUtil.new_flat(colors.background_color, [8], [4]))
		
		theme.set_color(&"font_color", &"Tree", colors.text_color)
		
		theme.set_color(&"font_color", &"Button", colors.text_color)
		theme.set_color(&"font_focus_color", &"Button", colors.text_color)
		theme.set_color(&"font_hover_color", &"Button", colors.text_color.darkened(0.05))
		theme.set_color(&"font_hover_pressed_color", &"Button", colors.text_color.darkened(0.15))
		theme.set_color(&"font_pressed_color", &"Button", colors.text_color.darkened(0.1))
		
		theme.set_color(&"font_color", &"OptionButton", Color(0.875, 0.875, 0.875))
		theme.set_color(&"font_focus_color", &"OptionButton", Color(0.875, 0.875, 0.875))
		theme.set_color(&"font_hover_color", &"OptionButton", Color(0.875, 0.875, 0.875).lightened(0.05))
		theme.set_color(&"font_hover_pressed_color", &"OptionButton", Color(0.875, 0.875, 0.875).lightened(0.15))
		theme.set_color(&"font_pressed_color", &"OptionButton", Color(0.875, 0.875, 0.875).lightened(0.1))
		
		theme_changed.emit(THEMES.themes[theme_name])


func set_font(font_name: String, ligatures: String = ""):
	var sys_font: SystemFont = create_system_font(font_name, "Monospace")
	var new_font: FontVariation = FontVariation.new()
	new_font.base_font = sys_font
	
	var features: Dictionary = convert_tags_to_names(new_font.get_supported_feature_list())
	new_font.opentype_features = _convert_ligatures(features, ligatures)

	# Have to load it because it's just a path
	theme.set_font(&"font", &"CodeEdit", new_font)


func create_system_font(font_name: String, fallback: String = "") -> SystemFont:
	var font: = SystemFont.new()
	
	font.font_names = [font_name, fallback] if fallback else [font_name]
	
	return font


func convert_tags_to_names(dict: Dictionary) -> Dictionary:
	var new_dict := {}
	
	for key in dict:
		new_dict[TextServerManager.get_primary_interface().tag_to_name(key)] = dict[key]
	
	return new_dict


func _convert_ligatures(features: Dictionary, ligatures: String, shorthands: Dictionary = LIGATURE_SHORTHANDS) -> Dictionary:
	var filtered: Dictionary = {}
	var replaced: String = StringUtil.replace_all(ligatures, shorthands)
	for lig in replaced.split(","):
		if lig in features:
			filtered[TextServerManager.get_primary_interface().name_to_tag(lig)] = 1
	
	return filtered
