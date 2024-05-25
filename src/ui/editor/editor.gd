@tool
class_name Editor extends Control


const MAIN_FONT_ITALICS = preload("res://src/assets/fonts/main_font_italics.tres")


enum ConfirmationAction {
	SAVE,
	DISCARD,
	CANCEL,
}


signal _continue(action_taken: ConfirmationAction)


@onready var panel_container: PanelContainer = %PanelContainer
@onready var save_button: Button = %SaveButton
@onready var path_button: Button = %PathButton
@onready var code_editor: CodeEditor = %CodeEditor
@onready var confirmation_dialog: ConfirmationDialog = %ConfirmationDialog
@onready var code_completion_timer: Timer = %CodeCompletionTimer


@export var editor_theme: String:
	set(value):
		editor_theme = value
		load_theme(editor_theme)
	get:
		return editor_theme


var file_handle: FileAccess
var last_saved_text: String
var file_path: String:
	get:
		if file_handle:
			return file_handle.get_path_absolute()
		return ""
var old_text: String
var base_path: String


func _ready() -> void:
	load_theme(editor_theme)
	
	confirmation_dialog.add_button("Discard", true, "discarded")
	
	if EditorThemeManager:
		EditorThemeManager.theme_changed.connect(load_theme)
	
	if EditorManager:
		EditorManager.save_requested.connect(_on_save_button_pressed)
	
	if code_editor:
		code_editor.save_requested.connect(_on_save_button_pressed)
	
	_set_all_settings()
	Settings.settings_window.setting_changed.connect(func(identifier: StringName, new_value): _set_all_settings())


func load_file(path: String) -> void:
	if file_handle and path == file_handle.get_path_absolute():
		return
	if file_handle and not code_editor.text == last_saved_text:
		confirmation_dialog.popup_centered()
		var action: ConfirmationAction = await _continue
		match action:
			ConfirmationAction.SAVE:
				save()
			ConfirmationAction.CANCEL:
				return
			# No ConfirmationAction.DISCARD block, because it will just continue down

	# Save the old one in case loading fails
	var old_file_handle = file_handle
	file_handle = FileAccess.open(path, FileAccess.READ_WRITE)

	if file_handle == null:
		NotificationManager.notify("%s failed to open" % path.get_file(), NotificationManager.TYPE_ERROR)
		file_handle = old_file_handle
		code_editor.editable = false
		return

	NotificationManager.notify("Opened %s" % file_handle.get_path_absolute().get_file(), NotificationManager.TYPE_NORMAL)
	if old_file_handle:
		old_file_handle.close()
	code_editor.editable = true
	code_editor.text = file_handle.get_as_text(true)
	last_saved_text = code_editor.text
	old_text = code_editor.text

	path_button.text = path.get_file()
	
	if Settings.syntax_highlighting_enabled:
		if path.get_extension() in Settings.syntax_highlighted_files.split(",", false):
			if code_editor.syntax_highlighter == null:
				load_theme(ThemeImporter.last_imported_theme)
		else:
			code_editor.syntax_highlighter = null
	else:
		code_editor.syntax_highlighter = null


func save(path: String = "") -> void:
	if path:
		file_handle = FileAccess.open(path, FileAccess.READ_WRITE)
	if not file_handle:
		return
	file_handle.seek(0)
	file_handle.store_string(code_editor.text)
	file_handle.flush()
	last_saved_text = code_editor.text

	NotificationManager.notify("Saved %s" % file_handle.get_path_absolute().get_file(), NotificationManager.TYPE_NORMAL)
	path_button.remove_theme_font_override(&"font")
	path_button.text = file_handle.get_path_absolute().get_file()


func load_theme(file: String) -> void:
	if file and code_editor:
		ThemeImporter.import_theme(file, code_editor, GLSLLanguage.base_types, GLSLLanguage.keywords, GLSLLanguage.comment_regions, GLSLLanguage.string_regions)
		if not code_editor.syntax_highlighter.has_color_region("#"):
			code_editor.syntax_highlighter.add_color_region("#", "", get_theme_color("background_color").lightened(0.5))


func _set_all_settings() -> void:
	code_editor.gutters_draw_line_numbers = Settings.show_line_numbers
	code_editor.gutters_zero_pad_line_numbers = Settings.zero_pad_line_numbers
	code_editor.caret_type = Settings.caret_style
	code_editor.scroll_past_end_of_file = Settings.scroll_past_eof
	var mode = Settings.text_wrapping_mode
	if mode == 0:
		code_editor.wrap_mode = TextEdit.LINE_WRAPPING_NONE
	else:
		code_editor.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
		code_editor.autowrap_mode = mode as TextServer.AutowrapMode
	code_editor.indent_wrapped_lines = Settings.indent_wrapped_lines


func _on_confirmation_dialog_canceled() -> void:
	_continue.emit(ConfirmationAction.CANCEL)


func _on_confirmation_dialog_confirmed() -> void:
	_continue.emit(ConfirmationAction.SAVE)


func _on_confirmation_dialog_custom_action(action: StringName) -> void:
	match action:
		"discarded":
			_continue.emit(ConfirmationAction.DISCARD)
			confirmation_dialog.hide()


func _on_code_editor_text_changed() -> void:
	if Settings.auto_code_completion:
		if old_text.length() < code_editor.text.length():
			if Settings.code_completion_delay < 0.0001:
				_on_code_editor_code_completion_requested()
			else:
				code_completion_timer.start(Settings.code_completion_delay)
		else:
			if not code_completion_timer.is_stopped():
				code_completion_timer.stop()
	
	if code_editor.text == last_saved_text:
		path_button.remove_theme_font_override(&"font")
		path_button.text = file_handle.get_path_absolute().get_file()
	else:
		path_button.add_theme_font_override(&"font", MAIN_FONT_ITALICS)
		path_button.text = file_handle.get_path_absolute().get_file() + "*"

	old_text = code_editor.text


func _on_code_editor_code_completion_requested() -> void:
	_get_completion_suggestions()
	code_editor.update_code_completion_options(true)


func _get_completion_suggestions() -> void:
	CodeCompletionSuggestion.add_arr_to(GLSLLanguage.get_code_completion_suggestions(
			file_handle.get_path_absolute(),
			code_editor.text,
			code_editor.get_caret_line(code_editor.get_caret_count() - 1),
			code_editor.get_caret_column(code_editor.get_caret_count() - 1),
			FileManager.absolute_base_path if Settings.inc_absolute_paths else "",
			), code_editor)
	for keyword in GLSLLanguage.base_types:
		code_editor.add_code_completion_option(CodeEdit.KIND_CLASS, keyword, keyword, Color.WHITE, null, null, 1)
	for keyword in GLSLLanguage.keywords:
		code_editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, keyword, keyword, Color.WHITE, null, null, 2)


func _on_save_button_pressed() -> void:
	save()
