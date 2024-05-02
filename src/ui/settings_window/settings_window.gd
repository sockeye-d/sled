@tool
class_name SettingsWindow extends Window


signal population_complete()


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


func _process(delta: float) -> void:
	return
	if Input.is_action_just_pressed("save"):
		save()


func populate_setting_categories() -> void:
	NodeUtil.free_children(category_container)
	settings.clear()
	
	for setting_category in setting_categories:
		add_setting_category(setting_category)
		
		for setting in setting_category.settings:
			settings[setting.identifier] = setting.value if setting.value else setting._get_default_value()
			setting.setting_changed.connect(func(new_value): settings[setting.identifier] = new_value)
			settings_items[setting.identifier] = setting
	
	add_custom_settings()
	
	population_complete.emit()

func add_custom_settings():
	var themes := EditorThemeManager.THEMES
	for t in themes.themes:
		settings_items.theme.options.append(t)
	settings_items.theme.setting_changed.connect(
			func(new_value):
				var new_theme = settings_items.theme.get_text()
				if new_theme:
					EditorThemeManager.change_theme(new_theme)
				)
	settings_items.theme.select_text(EditorThemeManager.DEFAULT_THEME)
	
	for font in OS.get_system_fonts():
		settings_items.font.options.append(font)
	
	settings_items.font.setting_changed.connect(
			func(new_value: int):
				EditorThemeManager.set_font(settings_items.font.get_text())
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
		
		var container = HBoxContainer.new()
		container.add_child(button)
		container.add_child(setting.control)
		setting_option_container.add_child(container)


func add_setting_category(category: SettingCategory) -> void:
	var button = HighlightButton.new()
	
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.text = category.name
	
	category_container.add_child(button)
	
	button.pressed.connect(populate_settings.bind(category))


func save() -> void:
	print(settings)
	
	var path = "user://settings.tres"
	#var error = ResourceSaver.save(SettingsResourceaaa.new(setting_categories), path)
	var file_handle: FileAccess = FileAccess.open(path, FileAccess.WRITE_READ)
	file_handle.store_var(settings)
	file_handle.close()
	
	await get_tree().create_timer(0.1).timeout
	
	open()


func open() -> void:
	var path = "user://settings.tres"
	var setting_dict: Dictionary = { }
	
	var file_handle: FileAccess = FileAccess.open(path, FileAccess.READ_WRITE)
	setting_dict = file_handle.get_var()
	file_handle.close()
	
	print(setting_dict)


class SettingsResourceaaa extends Resource:
	var settings: Array[SettingCategory]
	
	func _init(_settings: Array[SettingCategory] = []):
		settings = _settings
