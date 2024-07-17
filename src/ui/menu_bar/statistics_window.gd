class_name StatisticsWindow extends PopupWindow


enum Task {
	WORK,
	EXIT,
}


@onready var mut: Mutex = Mutex.new()
@onready var thread: Thread = Thread.new()
@onready var sem: Semaphore = Semaphore.new()
var data: Dictionary


@onready var left: VBoxContainer = %Left
@onready var right: VBoxContainer = %Right
@onready var loading_panel: Panel = %LoadingPanel
@onready var container: Control = %Container


func _exit_tree() -> void:
	if thread.is_alive():
		mut.lock()
		data = {
			"task": Task.EXIT,
		}
		mut.unlock()
		sem.post()
		thread.wait_to_finish()


func _thread_task() -> void:
	while true:
		sem.wait()
		
		mut.lock()
		var data_copy := data.duplicate()
		mut.unlock()
		
		if data_copy.task == Task.EXIT:
			break
		
		if data_copy.task == Task.WORK:
			var stats := _get_folder_stats(data_copy.text_files)
			call_deferred_thread_group(&"_add_stats", stats)


func _on_visibility_changed() -> void:
	if visible:
		generate_list()


func generate_list() -> void:
	if not thread.is_alive():
		thread.start(_thread_task)
	loading_panel.show()
	container.hide()
	
	mut.lock()
	data = {
		"task": Task.WORK,
		"text_files": Settings.get_arr("text_file_types"),
	}
	mut.unlock()
	sem.post()


func _add_stats(stats: Dictionary) -> void:
	_clear()
	_add_item("File count", stats.count)
	_add_item("Total file size", "%2.f MiB" % (stats.size / 1024 ** 2))
	_add_item("Total lines of code", stats.lines)
	
	container.show()
	loading_panel.hide()
	
	await SceneTreeUtil.process_frame
	
	size = container.get_combined_minimum_size()


func _clear() -> void:
	NodeUtil.free_children(left)
	NodeUtil.free_children(right)


func _add_item(key: String, value) -> void:
	left.add_child(_create_label(str(key) + ":", HORIZONTAL_ALIGNMENT_RIGHT))
	right.add_child(_create_label(str(value), HORIZONTAL_ALIGNMENT_LEFT))


func _create_label(text: String, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.horizontal_alignment = alignment
	#l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	l.text = text
	return l


func _get_folder_stats(text_files: PackedStringArray, path: String = FileManager.current_path) -> Dictionary:
	var s := {
		"count": 0,
		"size": 0.0,
		"lines": 0,
	}
	for file_name in DirAccess.get_files_at(path):
		DictionaryUtil.custom_merge(
			s,
			_get_file_stats(path.path_join(file_name), file_name.get_extension() in text_files),
			_sum
		)
	for folder_name in DirAccess.get_directories_at(path):
		DictionaryUtil.custom_merge(
			s,
			_get_folder_stats(text_files, path.path_join(folder_name)),
			_sum
		)
	return s


func _get_file_stats(path: String, count_lines: bool) -> Dictionary:
	var file_bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	var lines := 0
	if count_lines:
		var file_string := file_bytes.get_string_from_utf8()
		var i := 0
		while i < file_string.length() and i != -1:
			var new_i := file_string.find("\n", i + 1)
			if StringUtil.substr_pos(file_string, i, new_i).strip_edges() != "":
				lines += 1
			i = new_i
	
	return {
		"count": 1,
		"size": file_bytes.size(),
		"lines": lines,
	}


func _sum(value_a, value_b, _key):
	return value_a + value_b
