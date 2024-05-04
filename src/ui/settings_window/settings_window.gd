@tool
class_name SettingsWindow extends Window


signal population_complete()
signal setting_changed(identifier: StringName, new_value)


@onready var category_container: VBoxContainer = %CategoryContainer
@onready var setting_option_container: VBoxContainer = %SettingOptionContainer


@export var repopulate_settings: bool = false:
	set(value):
		if value:
			populate_setting_categories()
		repopulate_settings = value
	get:
		return repopulate_settings
@export var setting_categories: Array[SettingCategory]
var settings: Dictionary
var settings_items: Dictionary


func _ready() -> void:
	populate_setting_categories()
	close_requested.connect(func(): hide())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		hide()


func populate_setting_categories() -> void:
	NodeUtil.free_children(category_container)
	settings.clear()
	
	for setting_category in setting_categories:
		add_setting_category(setting_category)
		
		for setting in setting_category.settings:
			settings[setting.identifier] = setting.value if setting.value else setting._get_default_value()
			setting.setting_changed.connect(
					func(new_value):
						settings[setting.identifier] = new_value
						setting_changed.emit(setting.identifier, new_value)
						)
			settings_items[setting.identifier] = setting
	
	add_custom_settings()
	
	population_complete.emit()

func add_custom_settings():
	var themes := EditorThemeManager.THEMES
	settings_items.theme.options.append("Custom")
	for t in themes.themes:
		settings_items.theme.options.append(t)
	settings_items.theme.setting_changed.connect.call_deferred(
			func(new_value):
				var new_theme: String = settings_items.theme.options[new_value]
				if new_theme == "Custom":
					await RenderingServer.frame_post_draw
					EditorThemeManager.change_theme_from_path.call_deferred(settings.custom_theme_path)
					return
				if new_theme:
					EditorThemeManager.change_theme(new_theme)
				)
	settings_items.theme.select_text(EditorThemeManager.DEFAULT_THEME)
	settings_items.theme.default_value = settings_items.theme.value
	
	settings_items.font.options.append("Monospace")
	var fonts = OS.get_system_fonts()
	var cascadia_code_index = -1
	for font_index in fonts.size():
		if fonts[font_index].to_lower() == "cascadia code":
			cascadia_code_index = font_index
		settings_items.font.options.append(fonts[font_index])
	
	settings_items.font.default_value = cascadia_code_index + 1
	
	settings_items.font.setting_changed.connect(
			func(new_value: int):
				EditorThemeManager.set_font(settings_items.font.options[new_value], settings.ligatures)
				)
	
	settings_items.ligatures.setting_changed.connect(
			func(_new_value: String):
				EditorThemeManager.set_font(settings_items.font.get_text(), settings.ligatures)
				)
	settings_items.gui_scale.setting_changed.connect(
			func(new_value: float):
				EditorThemeManager.theme.default_font_size = 16 * new_value as int
				EditorThemeManager.theme.default_base_scale = new_value
				)
	
	settings_items.font.select_text((theme.get_font(&"font", &"CodeEdit") as SystemFont).get_font_name())

func populate_settings(category: SettingCategory) -> void:
	NodeUtil.free_children(setting_option_container)
	
	for setting in category.settings:
		setting.create_control()
		setting.control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var button = HighlightButton.new()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text = setting.name
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.tooltip_text = setting.tooltip
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		
		var reset_button = HighlightButton.new()
		reset_button.icon = Icons.reset_value
		reset_button.tooltip_text = "Reset to default"
		reset_button.visible = not setting.value == setting._get_default_value()
		reset_button.pressed.connect(func(): setting.value = setting._get_default_value())
		
		var container = HBoxContainer.new()
		container.add_child(button)
		container.add_child(reset_button)
		container.add_child(setting.control)
		setting.setting_changed.connect(
			func(new_value):
				if reset_button:
					reset_button.visible = not new_value == setting._get_default_value()
				)
		
		if setting is DividerSettingItem:
			button.add_theme_font_override(&"font", Fonts.main_font_bold)
		
		setting_option_container.add_child(container)


func add_setting_category(category: SettingCategory) -> void:
	var button = HighlightButton.new()
	
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.text = category.name
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	
	category_container.add_child(button)
	
	button.pressed.connect(populate_settings.bind(category))


func load_settings(new_settings: Dictionary) -> void:
	for s in settings:
		if s in settings_items and s in new_settings:
			settings_items[s].value = new_settings[s]
