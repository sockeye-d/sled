@tool
extends Node


const MAIN_FONT = preload("res://src/assets/fonts/Red_Hat_Text/RedHatText-VariableFont_wght.ttf")
var main_font: FontVariation = preload("res://src/assets/fonts/main_font.tres")


var theme: Theme:
	get:
		return ThemeDB.get_project_theme()
var last_imported_theme: Dictionary
var completion_color: Color
var current_code_font: Font


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
	Settings.connect_setting(&"ligatures", func(_new_value: String): set_ligatures())
	
	Settings.connect_setting(&"font", func(_new_value: int) -> void:
		if _new_value == 0:
			set_font_from_path(Settings.custom_font_path, Settings.ligatures)
		else:
			var f = Settings.get_item(&"font").get_text()
			EditorThemeManager.set_font(f, Settings.ligatures)
	)
	
	Settings.connect_setting(&"ui_font", func(new_value: int) -> void:
		var font: String = Settings.get_item(&"ui_font").get_text()
		if new_value == 0:
			main_font.base_font = MAIN_FONT
		else:
			var sys_font := SystemFont.new()
			sys_font.font_names = [font]
			main_font.base_font = sys_font
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
	
	Settings.connect_setting(&"theme_contrast", func(_new_value) -> void:
		var new_theme: String = Settings.get_item(&"theme").get_text()
		if new_theme.to_lower() == "custom":
			await SceneTreeUtil.process_frame
			EditorThemeManager.change_theme_from_path.call_deferred(Settings.custom_theme_path)
			return
		if new_theme:
			EditorThemeManager.change_theme(new_theme)
	)
	
	Settings.connect_setting(&"custom_theme_path", func(path: String) -> void:
		var current_theme: String = Settings.get_item(&"theme").get_text()
		if current_theme.to_lower() == "custom" and FileAccess.file_exists(path):
			EditorThemeManager.change_theme_from_path(Settings.custom_theme_path)
	)
	
	Settings.connect_setting(&"code_font_size", func(new_value: float) -> void:
		theme.set_font_size(&"font_size", &"CodeEdit", new_value as int)
		code_font_size_changed.emit()
	)
	
	Settings.connect_setting(&"main_font_size", func(new_value: float) -> void:
		theme.default_font_size = int(new_value)
		main_font_size_changed.emit()
	)
	
	Settings.connect_setting(&"icon_theme", func(_new_value: int) -> void:
		set_icon_mode()
	)
	
	Settings.connect_setting(&"gui_scale", func(new_value: float):
		EditorThemeManager.set_scale.call_deferred(new_value)
	)
	
	Settings.settings_window.secret_signaled.connect(func(): EditorThemeManager.change_theme("vs code dark", true))
	
	#icons_changed.connect(Icons.singleton.icons_changed.emit)


func get_scale() -> float:
	if theme.has_default_base_scale():
		return theme.default_base_scale
	else:
		return 1.0


func set_scale(scale: float) -> void:
	theme.default_font_size = 16 * scale as int
	theme.default_base_scale = scale
	change_theme_from_text()
	scale_changed.emit(scale)


func change_theme(theme_name: String, random := false):
	if theme_name in THEMES.themes:
		var t = THEMES.themes[theme_name]
		change_theme_from_text(false, t.text, random)


func change_theme_from_path(theme_path: String):
	var file: String = FileAccess.get_file_as_string(theme_path)
	
	if file == "":
		return
	
	change_theme_from_text(false, file)


func change_theme_from_text(use_cache: bool = true, theme_text: String = "", random: bool = false) -> void:
	var root := get_tree().root
	var main_scene := get_node_or_null(^"/root/Main")
	if main_scene:
		root.remove_child(main_scene)
	
	await get_tree().process_frame
	var colors: Dictionary
	if use_cache:
		colors = last_imported_theme
	else:
		colors = ThemeImporter.get_theme_dict(theme_text, random)
		last_imported_theme = colors
	ThemeImporter.add_code_edit_themes(EditorThemeManager.theme, colors)
	var t: Theme = theme
	StyleBoxUtil.scale = get_scale()
	var contrast: float = Settings.theme_contrast * 5.0
	
	var focus_sb := StyleBoxUtil.new_flat(Color.TRANSPARENT, [4], [4], [2], colors.text_color, [2])
	
	t.clear_color(&"background_color", &"CodeEdit")
	
	t.set_stylebox(&"normal", &"CodeEdit", StyleBoxUtil.new_flat(colors.background_color, [0, 0, 0, 0], [4]))
	t.set_stylebox(&"read_only", &"CodeEdit", StyleBoxUtil.new_flat(colors.background_color, [0, 0, 0, 0], [4]))
	t.set_color(&"font_color", &"CodeEdit", colors.text_color)
	t.set_color(&"word_highlighted_color", &"CodeEdit", Color(colors.word_highlighted_color, colors.word_highlighted_color.a * 0.5))
	completion_color = colors.completion_font_color
	
	t.set_stylebox(&"panel", &"PanelContainer",	StyleBoxUtil.new_flat(colors.background_color, [8], [4]))
	t.set_stylebox(&"panel", &"UpperPanelContainer", StyleBoxUtil.new_flat(colors.background_color, [8, 8, 0, 0], [4]))
	t.set_stylebox(&"panel", &"LowerPanelContainer", StyleBoxUtil.new_flat(colors.background_color, [0, 0, 8, 8], [4]))
	
	t.set_color(&"color", &"Throbber", Color(colors.selection_color, 1.0))
	t.set_constant(&"thickness", &"Throbber", int(get_scale() * 15.0))
	
	t.set_stylebox(&"panel", &"Tree", StyleBoxUtil.new_flat(colors.background_color, [8], [4]))
	#t.set_stylebox(&"focus", &"Tree", focus_sb)
	t.set_stylebox(&"cursor", &"Tree",
		StyleBoxUtil.new_flat(
			Color(colors.text_color, 0.2), [4], [0], [2], colors.text_color, [2]
		)
	)
	t.set_stylebox(&"cursor_unfocused", &"Tree",
		StyleBoxUtil.new_flat(
			Color(colors.text_color, 0.2), [4], [0]
		)
	)
	var guide_color := Color(colors.text_color, 0.5)
	
	t.set_color(&"font_color", &"Tree", colors.text_color)
	t.set_color(&"children_hl_line_color", &"Tree", guide_color)
	t.set_color(&"parent_hl_line_color", &"Tree", guide_color)
	t.set_color(&"relationship_line_color", &"Tree", guide_color)
	t.set_color(&"drop_position_color", &"Tree", guide_color)
	t.set_color(&"guide_color", &"Tree", guide_color)
	
	t.set_constant(&"item_margin", &"Tree", int(16 * get_scale()))
	t.set_constant(&"h_separation", &"Tree", int(4 * get_scale()))
	t.set_constant(&"v_separation", &"Tree", int(4 * get_scale()))
	t.set_constant(&"button_margin", &"Tree", int(4 * get_scale()))
	
	t.set_color(&"font_color", &"Button", colors.text_color)
	t.set_color(&"font_focus_color", &"Button", colors.text_color)
	t.set_color(&"font_hover_color", &"Button", colors.text_color)
	t.set_color(&"font_hover_pressed_color", &"Button", colors.text_color)
	t.set_color(&"font_pressed_color", &"Button", colors.text_color)
	t.set_stylebox(&"disabled", &"Button", StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.25), [4], [4]))
	t.set_stylebox(&"normal", &"Button", StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.2), [4], [4]))
	t.set_stylebox(&"hover", &"Button", StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.15), [4], [4]))
	t.set_stylebox(&"pressed", &"Button", StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.1), [4], [4]))
	
	t.set_color(&"font_color", &"MenuBar", colors.text_color)
	t.set_color(&"font_focus_color", &"MenuBar", colors.text_color)
	t.set_color(&"font_hover_color", &"MenuBar", _color_adjust(colors.text_color, contrast * 0.05))
	t.set_color(&"font_hover_pressed_color", &"MenuBar", _color_adjust(colors.text_color, contrast * 0.15))
	t.set_color(&"font_pressed_color", &"MenuBar", _color_adjust(colors.text_color, contrast * 0.1))
	t.set_stylebox(&"disabled", &"MenuBar", StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.25), [4], [4]))
	t.set_stylebox(&"normal", &"MenuBar", StyleBoxUtil.new_flat(colors.background_color, [4], [4]))
	t.set_stylebox(&"hover", &"MenuBar", StyleBoxUtil.new_flat(_color_adjust(colors.background_color, -contrast * 0.05), [4], [4]))
	t.set_stylebox(&"pressed", &"MenuBar", StyleBoxUtil.new_flat(_color_adjust(colors.background_color, -contrast * 0.075), [4], [4]))
	t.set_constant(&"h_separation", &"MenuBar", int(4 * get_scale()))
	
	t.set_color(&"font_color", &"CheckBox", colors.text_color)
	t.set_color(&"font_focus_color", &"CheckBox", colors.text_color)
	t.set_color(&"font_hover_color", &"CheckBox", _color_adjust(colors.text_color, contrast * 0.05))
	t.set_color(&"font_hover_pressed_color", &"CheckBox", _color_adjust(colors.text_color, contrast * 0.15))
	t.set_color(&"font_pressed_color", &"CheckBox", _color_adjust(colors.text_color, contrast * 0.1))
	t.set_stylebox(&"disabled", &"CheckBox", StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.25), [4], [4]))
	t.set_stylebox(&"normal", &"CheckBox", StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.2), [4], [4]))
	t.set_stylebox(&"hover", &"CheckBox", StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.15), [4], [4]))
	t.set_stylebox(&"hover_pressed", &"CheckBox", StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.15), [4], [4]))
	t.set_stylebox(&"pressed", &"CheckBox", StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.2), [4], [4]))
	t.set_icon(&"checked", &"CheckBox", Icons.create("checkbox_checked"))
	t.set_icon(&"checked_disabled", &"CheckBox", Icons.create("checkbox_checked_disabled"))
	t.set_icon(&"unchecked", &"CheckBox", Icons.create("checkbox_unchecked"))
	t.set_icon(&"unchecked_disabled", &"CheckBox", Icons.create("checkbox_unchecked_disabled"))
	
	t.set_color(&"font_color", &"Label", colors.text_color)
	
	t.set_color(&"font_color", &"LineEdit", colors.text_color)
	t.set_color(&"font_selected_color", &"LineEdit", colors.text_color)
	t.set_color(&"font_uneditable_color", &"LineEdit", Color(colors.text_color, 0.5))
	t.set_color(&"caret_color", &"LineEdit", colors.caret_color)
	t.set_color(&"selection_color", &"LineEdit", colors.selection_color)
	t.set_color(&"placeholder_color", &"LineEdit", _color_adjust(colors.background_color, contrast * 0.25))
	t.set_stylebox(&"normal", &"LineEdit",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.2), [4], [4]))
	t.set_stylebox(&"read_only", &"LineEdit",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.25), [4], [4]))
	
	t.set_stylebox(&"invalid", &"RegExLineEdit",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.2).lerp(Color(0.8, 0.3, 0.2), 0.2), [4], [4], [2], Color(0.8, 0.3, 0.2)))
	
	t.set_stylebox(&"panel", &"SliderCombo",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.2), [4], [4]))
	
	t.set_stylebox(&"grabber_area", &"HSlider",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, -contrast * 0.4), [16]))
	t.set_stylebox(&"grabber_area_highlight", &"HSlider",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, -contrast * 0.6), [16]))
	t.set_stylebox(&"slider", &"HSlider",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, -contrast * 0.2), [16], [0, 2]))
	
	t.set_stylebox(&"grabber_area", &"VSlider",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, -contrast * 0.4), [16]))
	t.set_stylebox(&"grabber_area_highlight", &"VSlider",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, -contrast * 0.6), [16]))
	t.set_stylebox(&"slider", &"VSlider",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, -contrast * 0.2), [16], [2, 0]))
	
	t.set_stylebox(&"grabber", &"HScrollBar",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, -contrast * 0.3), [16], [2, 0]))
	t.set_stylebox(&"grabber_highlight", &"HScrollBar",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, -contrast * 0.4), [16]))
	t.set_stylebox(&"grabber_pressed", &"HScrollBar",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, -contrast * 0.5), [16]))
	t.set_stylebox(&"scroll", &"HScrollBar",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.2), [16], [0, 2]))
	t.set_stylebox(&"scroll_focus", &"HScrollBar",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.15), [16], [0, 2]))
	t.set_stylebox(&"grabber", &"VScrollBar",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, -contrast * 0.3), [16], [2, 0]))
	t.set_stylebox(&"grabber_highlight", &"VScrollBar",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, -contrast * 0.4), [16]))
	t.set_stylebox(&"grabber_pressed", &"VScrollBar",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, -contrast * 0.5), [16]))
	t.set_stylebox(&"scroll", &"VScrollBar",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.2), [16], [2, 0]))
	t.set_stylebox(&"scroll_focus", &"VScrollBar",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.15), [16], [2, 0]))
	
	t.set_stylebox(&"invalid", &"FileLineEdit",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.1), [4], [4], [2], Color(0.8, 0.3, 0.2)))
	
	t.set_color(&"font_focus_color", &"OptionButton", colors.text_color)
	t.set_color(&"font_color", &"OptionButton", colors.text_color)
	t.set_color(&"font_hover_color", &"OptionButton", _color_adjust(colors.text_color, -contrast * 0.05))
	t.set_color(&"font_hover_pressed_color", &"OptionButton", _color_adjust(colors.text_color, -contrast * 0.15))
	t.set_color(&"font_pressed_color", &"OptionButton", _color_adjust(colors.text_color, -contrast * 0.1))
	t.set_stylebox(&"normal", &"OptionButton",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.2), [4], [4]))
	t.set_stylebox(&"hover", &"OptionButton",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.15), [4], [4]))
	t.set_stylebox(&"pressed", &"OptionButton",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.1), [4], [4]))
	
	t.set_stylebox(&"panel", &"AcceptDialog",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.0), [0], [4]))
	
	t.set_color(&"font_color", &"PopupMenu", colors.text_color)
	t.set_color(&"font_disabled_color", &"PopupMenu", _color_adjust(colors.text_color, contrast * 0.2))
	t.set_color(&"font_hover_color", &"PopupMenu", _color_adjust(colors.text_color, -contrast * 0.05))
	t.set_color(&"font_accelerator_color", &"PopupMenu", Color(colors.text_color, 0.5))
	t.set_stylebox(&"panel", &"PopupMenu",
		StyleBoxUtil.new_flat(colors.background_color, [4], [4], [2], _color_adjust(colors.background_color, contrast * 0.2)))
	t.set_stylebox(&"hover", &"PopupMenu",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.1), [4], [4]))
	t.set_color(&"font_color", &"PopupMenu", colors.text_color)
	t.set_color(&"font_hover_color", &"PopupMenu", colors.text_color)
	
	t.set_stylebox(&"panel", &"TooltipPanel",
		StyleBoxUtil.new_flat(colors.background_color, [4], [8, 4], [2],
		_color_adjust(colors.background_color, -contrast * 0.2)))
	
	t.set_color(&"font_color", &"TooltipLabel", colors.text_color)
	RenderingServer.set_default_clear_color(_color_adjust(colors.background_color, contrast * 0.2))
	
	t.set_constant(&"separation", &"HBoxContainer", int(4 * get_scale()))
	t.set_constant(&"separation", &"VBoxContainer", int(4 * get_scale()))
	
	t.set_constant(&"separation", &"SplitContainer", int(4 * get_scale()))
	t.set_constant(&"minimum_grab_thickness", &"SplitContainer", int(8 * get_scale()))
	
	t.set_color(&"font_color", &"ProgressBar", colors.text_color)
	t.set_stylebox(&"background", &"ProgressBar",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.05), [4], [4])
	)
	t.set_stylebox(&"fill", &"ProgressBar",
		StyleBoxUtil.new_flat(_color_adjust(colors.background_color, contrast * 0.2), [4], [8])
	)
	
	_set_focus_sb(t, focus_sb)
	
	set_icon_mode()
	
	await get_tree().process_frame
	
	if main_scene:
		root.add_child(main_scene)
	theme_changed.emit(theme_text)


func _color_adjust(color: Color, amount: float) -> Color:
	if amount < 0:
		# it is negated here because amount would be negative
		# but I want the absolute value
		#
		# so don't remove the - here please
		return color.lightened(-amount)
	else:
		return color.darkened(amount)


func _set_focus_sb(on_theme: Theme, sb: StyleBox, theme_type := &"Control") -> void:
	for child_type in ClassDB.get_inheriters_from_class(theme_type):
		on_theme.set_stylebox(&"focus", theme_type, sb)


func set_icon_mode() -> void:
	var icon_color_override: int = Settings.icon_theme
	if icon_color_override == 0:
		if not last_imported_theme:
			await theme_changed
		Icons.is_light_mode = (last_imported_theme.background_color as Color).srgb_to_linear().get_luminance() > 0.5
		Icons.singleton.icons_changed.emit()
	elif icon_color_override == 1:
		Icons.is_light_mode = true
		Icons.singleton.icons_changed.emit()
	elif icon_color_override == 2:
		Icons.is_light_mode = false
		Icons.singleton.icons_changed.emit()


func get_theme_as_text() -> String:
	var sb := StringBuilder.new("[color_theme]\n\n")
	for key: String in last_imported_theme:
		sb.append_line("%s=\"%s\"" % [key, (last_imported_theme[key] as Color).to_html()])
	return str(sb)


func update_font() -> void:
	if Settings.font == 0:
		set_font_from_path(Settings.custom_font_path, Settings.ligatures)
	else:
		var f = Settings.get_item(&"font").get_text()
		EditorThemeManager.set_font(f, Settings.ligatures)


func set_font(font_name: String, ligatures: String = ""):
	var new_font: FontVariation = FontVariation.new()
	new_font.base_font = create_system_font(font_name, "Monospace")
	
	var features: Dictionary = convert_tags_to_names(new_font.get_supported_feature_list())
	new_font.opentype_features = _convert_ligatures(features, ligatures)
	
	current_code_font = new_font
	set_ligatures()
	
	theme.set_font(&"font", &"CodeEdit", new_font)
	theme.set_font(&"mono_font", &"RichTextLabel", new_font)


func set_ligatures(font = current_code_font, ligatures: String = Settings.ligatures) -> void:
	var features := convert_tags_to_names(font.get_supported_feature_list())
	features = _convert_ligatures(features, ligatures)
	
	if font is FontFile:
		font.opentype_feature_overrides = features
	elif font is FontVariation:
		font.opentype_features = features


func set_font_from_path(font_path: String, ligatures: String = "") -> void:
	if not FileAccess.file_exists(font_path):
		NotificationManager.notify("Failed to find font " + font_path.get_file(), NotificationManager.TYPE_ERROR)
		set_font("Monospace")
		return
	var new_font := FontFile.new()
	var err: Error
	if font_path.get_extension().to_lower() in ["fnt", "font"]:
		err = new_font.load_bitmap_font(font_path)
	else:
		err = new_font.load_dynamic_font(font_path)
	
	NotificationManager.notify_if_err(
		err,
		"Loaded " + font_path.get_file(),
		"Failed to load %s (%s)" % [font_path.get_file(), "%s"],
		true
	)
	
	if err:
		set_font("Monospace")
		return
	
	current_code_font = new_font
	set_ligatures()
	
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
