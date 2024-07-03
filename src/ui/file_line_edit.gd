@tool
class_name FileLineEdit extends HBoxContainer


signal is_valid_path_changed
signal button_pressed
signal text_changed(new_text: String)
signal text_submitted(new_text: String)
signal path_changed(new_path: String)
signal path_submitted(new_path: String)


var button: Button = Button.new()
var line_edit: LineEdit = LineEdit.new()
var file_dialog: FileDialog = FileDialog.new()
var is_valid_path: bool


@onready var _invalid_panel_cache: StyleBox = get_theme_stylebox(&"invalid", &"FileLineEdit")


#region exported vars
@export var text: String:
	get:
		return text
	set(value):
		text = value
		line_edit.text = value
		_set_invalid(_is_path_invalid(base_path.path_join(text)))
@export var placeholder_text: String:
	get:
		return placeholder_text
	set(value):
		placeholder_text = value
		line_edit.placeholder_text = value
@export var button_icon: Texture2D = null:
	get:
		return button_icon
	set(value):
		button_icon = value
		button.icon = value
@export var mode: FileDialog.FileMode = FileDialog.FILE_MODE_OPEN_DIR
@export var access: FileDialog.Access = FileDialog.ACCESS_FILESYSTEM
@export var use_native: bool = true
@export var file_filters: PackedStringArray
@export var validate_path: bool = true
@export var base_path: String = ""
#endregion


func _init() -> void:
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_edit.text_changed.connect(_on_line_edit_text_changed)
	line_edit.text_submitted.connect(_on_line_edit_text_submitted)
	line_edit.text_changed.connect(text_changed.emit)
	line_edit.text_submitted.connect(text_submitted.emit)
	add_child(line_edit)
	add_child(button)
	
	file_dialog.file_selected.connect(_on_file_selected)
	file_dialog.files_selected.connect(_on_files_selected)
	file_dialog.dir_selected.connect(_on_dir_selected)
	
	add_child(file_dialog)
	button.pressed.connect(_show)


func _ready() -> void:
	if button_icon == null:
		button_icon = Icons.create("open_dir_large")


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_THEME_CHANGED:
			_invalid_panel_cache = get_theme_stylebox(&"invalid", &"FileLineEdit")


func update_validity() -> void:
	_set_invalid(_is_path_invalid(base_path.path_join(text)))


func _show() -> void:
	file_dialog.use_native_dialog = use_native
	file_dialog.current_path = base_path.path_join(text)
	file_dialog.access = access
	file_dialog.filters = file_filters
	file_dialog.file_mode = mode
	file_dialog.show()


func _on_line_edit_text_changed(new_text: String) -> void:
	var current_path = base_path.path_join(new_text)
	var is_valid: bool = _is_path_invalid(current_path)
	_set_invalid(is_valid)
	if is_valid or not validate_path:
		path_changed.emit(current_path)


func _on_line_edit_text_submitted(new_text: String) -> void:
	var current_path = base_path.path_join(new_text)
	var is_valid: bool = _is_path_invalid(current_path)
	_set_invalid(is_valid)
	if is_valid or not validate_path:
		path_submitted.emit(current_path)


func _is_path_invalid(path: String) -> bool:
	if mode == FileDialog.FILE_MODE_OPEN_FILE or mode == FileDialog.FILE_MODE_OPEN_FILES or mode == FileDialog.FILE_MODE_SAVE_FILE:
		return not FileAccess.file_exists(path)
	else:
		return not DirAccess.dir_exists_absolute(path)


func _on_file_selected(file: String) -> void:
	file = _transform_path(file)
	path_changed.emit(file)
	path_submitted.emit(file)
	line_edit.text = file


func _on_files_selected(files: PackedStringArray) -> void:
	var file := files[0]
	file = _transform_path(file)
	path_changed.emit(file)
	path_submitted.emit(file)
	line_edit.text = file


func _on_dir_selected(folder: String) -> void:
	folder = _transform_path(folder)
	path_changed.emit(folder)
	path_submitted.emit(folder)
	line_edit.text = folder


func _transform_path(path: String) -> String:
	return path.replace("\\", "/").trim_prefix(base_path)


func _set_invalid(invalid: bool) -> void:
	var old_is_valid_path := is_valid_path
	is_valid_path = not invalid
	if old_is_valid_path != not invalid:
		is_valid_path_changed.emit()
	if invalid and _invalid_panel_cache != null:
		line_edit.add_theme_stylebox_override(&"normal", _invalid_panel_cache)
	else:
		line_edit.remove_theme_stylebox_override(&"normal")
