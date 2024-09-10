class_name SettingsWindow extends Window


const SETTING_CATEGORIES = preload("res://src/ui/settings_window/setting_categories.tres")


signal population_complete()
signal setting_changed(identifier: StringName, new_value)
signal secret_signaled


@onready var category_container: VBoxContainer = %CategoryContainer
@onready var setting_option_container: VBoxContainer = %SettingOptionContainer
@onready var show_settings_file_button: Button = %ShowSettingsFileButton
@onready var export_theme_button: Button = %ExportThemeButton
@onready var right_container: PanelContainer = %RightContainer


@export var secret_code: Array[InputEvent]
@export var secret_offsets: PackedVector2Array


var setting_categories: Array[SettingCategory]
var settings: Dictionary[StringName, Variant]
var settings_items: Dictionary[StringName, SettingItem]
var current_category := ""
var current_secret_index: int
var old_window_pos: Vector2i
var window_offset: Vector2


func _init() -> void:
	close_requested.connect(func(): hide())


func _ready() -> void:
	populate_setting_categories()
	show_settings_file_button.pressed.connect(func():
		OS.shell_show_in_file_manager(
			ProjectSettings.globalize_path(Settings.SETTINGS_PATH)
		)
	)
	await SceneTreeUtil.process_frame
	await SceneTreeUtil.process_frame
	emit_changed_all()
	category_container.get_child(0).pressed.emit()


func _process(delta: float) -> void:
	if window_offset.length_squared() > 0.01 * 0.01:
		window_offset *= exp(-15.0 * delta)
		position = old_window_pos + Vector2i(window_offset)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		hide()
	if event.is_pressed():
		if event.is_match(secret_code[current_secret_index], false):
			old_window_pos = position
			window_offset += 16.0 * secret_offsets[current_secret_index]
			current_secret_index += 1
			if current_secret_index == secret_code.size():
				secret_signaled.emit()
				current_secret_index = 0
		elif event is InputEventKey:
			current_secret_index = 0


func set_all_to_default() -> void:
	if not setting_categories:
		setting_categories.assign(SETTING_CATEGORIES.setting_categories)
	settings.clear()
	for category in setting_categories:
		for setting in category.settings:
			settings[setting.identifier] = setting._get_default_value()
	for category in setting_categories:
		for setting in category.settings:
			if setting.identifier in settings_items:
				settings_items[setting.identifier].value = settings_items[setting.identifier]._get_default_value()


func populate_setting_categories() -> void:
	NodeUtil.remove_children(category_container)
	settings.clear()
	for setting_category in setting_categories:
		add_setting_category(setting_category)
		
		for setting in setting_category.settings:
			settings[setting.identifier] = setting.value if setting.value else setting._get_default_value()
			if setting.setting_changed.get_connections().size() == 0:
				setting.setting_changed.connect(
						func(new_value):
							settings[setting.identifier] = new_value
							setting_changed.emit(setting.identifier, new_value)
							)
			settings_items[setting.identifier] = setting
	
	population_complete.emit()


func add_setting_category(category: SettingCategory) -> void:
	var category_button = HighlightButton.new()
	
	category_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	category_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	category_button.text = category.name
	category_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	
	if category_container:
		category_container.add_child(category_button)
	
	category_button.pressed.connect(func():
		if category.name != current_category:
			current_category = category.name
			right_container.show()
			populate_settings(category)
	)


func populate_settings(category: SettingCategory) -> void:
	var removed_nodes := NodeUtil.remove_children(setting_option_container, true, false, func(node: Node) -> bool: return not node.has_meta(&"item_control"))
	for node in removed_nodes:
		node.queue_free()
	
	for setting in category.settings:
		setting.create_control()
		setting.run_init_script.call_deferred()
		setting.control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var label_button = HighlightButton.new()
		label_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		label_button.text = setting.name
		label_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label_button.tooltip_text = setting.tooltip
		label_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		
		var reset_button = HighlightButton.new()
		reset_button.icon = Icons.create("reset_value")
		reset_button.tooltip_text = "Reset to default"
		reset_button.visible = not setting.value == setting._get_default_value()
		reset_button.pressed.connect(func():
			setting.value = setting._get_default_value()
		)
		
		var container = HBoxContainer.new()
		container.add_child(label_button)
		container.add_child(reset_button)
		container.add_child(setting.control)
		setting.setting_changed.connect(func(new_value):
			if reset_button:
				reset_button.visible = not new_value == setting._get_default_value()
		)
		
		if setting is DividerSettingItem:
			label_button.add_theme_font_override(&"font", Fonts.main_font_bold)
		
		setting_option_container.add_child(container)


func load_settings(new_settings: Dictionary[StringName, Variant]) -> void:
	setting_categories.assign(SETTING_CATEGORIES.setting_categories)
	if not settings_items:
		populate_setting_categories()
	#settings = new_settings
	for s in settings:
		if s in settings_items and s in new_settings:
			settings_items[s].value = new_settings[s]


func emit_changed_all() -> void:
	for item_key in settings_items:
		var item: SettingItem = settings_items[item_key]
		setting_changed.emit(item.identifier, item.value)


func _on_button_2_pressed() -> void:
	var fd := FileDialog.new()
	fd.use_native_dialog = true
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	fd.file_selected.connect(_on_fd_done)
	fd.show()


func _on_fd_done(file: String) -> void:
	FileAccess.open(file, FileAccess.WRITE_READ).store_string(EditorThemeManager.get_theme_as_text())
