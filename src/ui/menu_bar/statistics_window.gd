class_name StatisticsWindow extends Window


@onready var item_list: ItemList = %ItemList


func _on_about_to_popup() -> void:
	generate_list()


func generate_list() -> void:
	item_list.clear()
	var s := _get_folder_stats()
	_add_item("File count", s.count)
	_add_item("Total file size", str(s.size / 1024 ** 2) + " MiB")
	_add_item("Total lines of code", s.lines)


func _add_item(key: String, value: String) -> void:
	item_list.add_item(key)
	item_list.add_item(value)


func _get_folder_stats(path: String = FileManager.current_path) -> Dictionary:
	var s := {
		"count": 0,
		"size": 0.0,
		"lines": 0,
	}
	for file_name in DirAccess.get_files_at(path):
		DictionaryUtil.custom_merge(
			s,
			_get_file_stats(path.path_join(file_name)),
			_sum
		)
	for folder_name in DirAccess.get_directories_at(path):
		DictionaryUtil.custom_merge(
			s,
			_get_folder_stats(path.path_join(folder_name)),
			_sum
		)
	return s


func _get_file_stats(path: String) -> Dictionary:
	var file_bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	var file_string := file_bytes.get_string_from_utf8()
	var lines := 0
	var i := 0
	while i < file_string.length() and i != -1:
		var new_i = file_string.find("\n", i)
		if StringUtil.substr_pos(file_string, i, new_i).strip_edges() == "":
			i = new_i
			continue
		lines += 1
	
	return {
		"count": 1,
		"size": file_bytes.size(),
		"lines": lines,
	}


func _sum(value_a, value_b, _key):
	return value_a + value_b
