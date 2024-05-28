@tool
class_name SettingsWindow extends Window


const SETTING_CATEGORIES = preload("res://src/ui/settings_window/setting_categories.tres")


signal population_complete()
signal setting_changed(identifier: StringName, new_value)


@onready var category_container: VBoxContainer = %CategoryContainer
@onready var setting_option_container: VBoxContainer = %SettingOptionContainer
@onready var button: Button = %Button


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


func _init() -> void:
	close_requested.connect(func(): hide())


func _ready() -> void:
	populate_setting_categories()
	button.pressed.connect(func(): OS.shell_show_in_file_manager(ProjectSettings.globalize_path(Settings.SETTINGS_PATH)))
	await SceneTreeUtil.process_frame
	emit_changed_all()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		hide()


func set_all_to_default() -> void:
	if not setting_categories:
		setting_categories = SETTING_CATEGORIES.setting_categories
	settings.clear()
	for category in setting_categories:
		for setting in category.settings:
			settings[setting.identifier] = setting._get_default_value()
	for category in setting_categories:
		for setting in category.settings:
			if setting.identifier in settings_items:
				settings_items[setting.identifier].value = settings_items[setting.identifier]._get_default_value()


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
	
	population_complete.emit()

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
		reset_button.pressed.connect(func():
			setting.value = setting._get_default_value()
		)
		
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
	
	if category_container:
		category_container.add_child(button)
	
	button.pressed.connect(populate_settings.bind(category))


func load_settings(new_settings: Dictionary) -> void:
	setting_categories = SETTING_CATEGORIES.setting_categories
	if not settings_items:
		populate_setting_categories()
	for s in settings:
		if s in settings_items and s in new_settings:
			settings_items[s].value = new_settings[s]


func emit_changed_all() -> void:
	for item_key in settings_items:
		var item: SettingItem = settings_items[item_key]
		setting_changed.emit(item.identifier, item.value)
