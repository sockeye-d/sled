@tool
class_name FileLineEdit extends HBoxContainer


signal is_valid_path_changed
signal button_pressed
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
@export var placeholder_text: String:
	get:
		return placeholder_text
	set(value):
		placeholder_text = value
		line_edit.placeholder_text = value
@export var button_icon: Texture2D = Icons.open_dir:
	get:
		return button_icon
	set(value):
		button_icon = value
		button.icon = value
@export var mode: FileDialog.FileMode = FileDialog.FILE_MODE_OPEN_DIR:
	get:
		return mode
	set(value):
		mode = value
		file_dialog.file_mode = value
@export var access: FileDialog.Access = FileDialog.ACCESS_FILESYSTEM:
	get:
		return access
	set(value):
		access = value
		file_dialog.access = value
@export var use_native: bool = true:
	get:
		return use_native
	set(value):
		use_native = value
		file_dialog.use_native_dialog = value
@export var file_filters: PackedStringArray:
	get:
		return file_filters
	set(value):
		file_filters = value
		file_dialog.filters = value
@export var validate_path: bool = true
@export var base_path: String = ""
#endregion


func _init() -> void:
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_edit.text_changed.connect(_on_line_edit_text_changed)
	line_edit.text_submitted.connect(_on_line_edit_text_submitted)
	add_child(line_edit)
	add_child(button)
	
	file_dialog.file_selected.connect(_on_file_selected)
	file_dialog.files_selected.connect(_on_files_selected)
	file_dialog.dir_selected.connect(_on_dir_selected)
	
	add_child(file_dialog)
	button.pressed.connect(_show)


func _ready() -> void:
	file_dialog.use_native_dialog = use_native
	file_dialog.file_mode = mode
	file_dialog.access = access


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_THEME_CHANGED:
			_invalid_panel_cache = get_theme_stylebox(&"invalid", &"FileLineEdit")


func _show() -> void:
	file_dialog.use_native_dialog = use_native
	file_dialog.current_path = base_path.path_join(text)
	file_dialog.show()


func _on_line_edit_text_changed(new_text: String) -> void:
	if mode == FileDialog.FILE_MODE_OPEN_FILE or mode == FileDialog.FILE_MODE_OPEN_FILES or mode == FileDialog.FILE_MODE_SAVE_FILE:
		_set_invalid(not FileAccess.file_exists(base_path.path_join(new_text)))
	else:
		_set_invalid(not DirAccess.dir_exists_absolute(base_path.path_join(new_text)))


func _on_line_edit_text_submitted(new_text: String) -> void:
	var is_valid: bool = true
	if validate_path:
		if mode == FileDialog.FILE_MODE_OPEN_FILE or mode == FileDialog.FILE_MODE_OPEN_FILES or mode == FileDialog.FILE_MODE_SAVE_FILE:
			is_valid = FileAccess.file_exists(base_path.path_join(new_text))
		else:
			is_valid =  DirAccess.dir_exists_absolute(base_path.path_join(new_text))
	if is_valid:
		path_submitted.emit(base_path.path_join(new_text))


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
	if invalid and _invalid_panel_cache != null:
		line_edit.add_theme_stylebox_override(&"normal", _invalid_panel_cache)
	else:
		line_edit.remove_theme_stylebox_override(&"normal")
