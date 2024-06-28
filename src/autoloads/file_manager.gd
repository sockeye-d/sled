extends Node


const LAST_OPENED_PATHS_PATH: String = "user://last_opened.sled"
const MAX_RECENT_ITEMS: int = 8


signal changed_paths()
signal paths_changed()
signal loaded_recent_paths(found_any: bool)
signal file_open_requested(path: String)


var last_opened_paths: PackedStringArray = []
var current_path: String = ""
var absolute_base_path: String = ""


func _ready() -> void:
	last_opened_paths = File.load_variant(LAST_OPENED_PATHS_PATH, [])
	
	await get_tree().process_frame
	await get_tree().process_frame
	if last_opened_paths:
		loaded_recent_paths.emit(true)
		change_path(last_opened_paths[0])
	else:
		loaded_recent_paths.emit(false)


func get_short_path(absolute_path: String) -> String:
	return absolute_path.trim_prefix(current_path).trim_prefix("/")


func request_open_file(path: String):
	file_open_requested.emit(path)


func open_quick_switch():
	var qs: QuickSwitchDialog = preload("res://src/ui/quick_switch_dialog/quick_switch_dialog.tscn").instantiate()
	qs.path = current_path
	qs.base_path = current_path
	add_child(qs)
	qs.popup_centered()
	var path = await qs.file_selected
	if path:
		request_open_file(current_path.path_join(path))


func change_path(new_path: String) -> void:
	new_path = new_path.replace("\\", "/")
	current_path = new_path
	
	var index = last_opened_paths.find(new_path)
	if index > -1:
		last_opened_paths.remove_at(index)
	last_opened_paths.insert(0, current_path)
	if last_opened_paths.size() > MAX_RECENT_ITEMS:
		last_opened_paths.resize(MAX_RECENT_ITEMS)
	paths_changed.emit()
	
	File.save_variant(LAST_OPENED_PATHS_PATH, last_opened_paths)
	absolute_base_path = get_base_path(new_path)
	changed_paths.emit()


func change_path_browse() -> void:
	var fd := FileDialog.new()
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.use_native_dialog = true
	fd.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	
	add_child(fd)
	
	fd.show.call_deferred()
	
	fd.dir_selected.connect(
			func(dir: String):
				change_path(dir)
				fd.queue_free()
				)
	fd.visibility_changed.connect(
			func():
				if fd.visible == false:
					fd.queue_free()
					)


func get_base_path(path: String, valid_names: PackedStringArray = []) -> String:
	if not valid_names:
		valid_names = Settings.base_paths.split(",", false)
	for dir in DirAccess.get_directories_at(path):
		if dir in valid_names:
			return path.path_join(dir)
		else:
			return get_base_path(path.path_join(dir), valid_names)
	return ""


func clear_recent() -> void:
	last_opened_paths = []
	paths_changed.emit()
	File.save_variant(LAST_OPENED_PATHS_PATH, last_opened_paths)

## Given a file path, returns the matching extension or an empty string if none
## exists
func file_is_sbs(file: String) -> String:
	var ext := file.get_extension().to_lower()
	for sbs_opening_ext: String in Settings.sbs_opening_file_exts.split(","):
		var split := sbs_opening_ext.split(":")
		if ext == split[0]:
			return split[-1]
		elif ext == split[-1]:
			return split[0]
	return ""


func get_icon(extension: String) -> Texture2D:
	if not Settings.use_unique_file_icons:
		return Icons.create("file")
	if extension in Settings.get_arr(&"image_file_types"):
		return Icons.create("file_image")
	if extension in Settings.get_arr(&"include_file_types"):
		return Icons.create("file_include")
	if extension in Settings.get_arr(&"fsh_file_types"):
		return Icons.create("file_shader_fsh")
	if extension in Settings.get_arr(&"vsh_file_types"):
		return Icons.create("file_shader_vsh")
	if extension in Settings.get_arr(&"csh_file_types"):
		return Icons.create("file_shader_csh")
	if extension in Settings.get_arr(&"gsh_file_types"):
		return Icons.create("file_shader_gsh")
	if extension in Settings.get_arr(&"md_file_types"):
		return Icons.create("file_md")
	if extension in Settings.get_arr(&"txt_file_types"):
		return Icons.create("file_txt")
	if extension in Settings.get_arr(&"properties_file_types"):
		return Icons.create("file_properties")
	if extension in Settings.get_arr(&"json_file_types"):
		return Icons.create("file_json")
	if extension in Settings.get_arr(&"bin_file_types"):
		return Icons.create("file_binary")
	return Icons.create("file")
