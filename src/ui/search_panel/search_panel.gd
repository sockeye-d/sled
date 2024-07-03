class_name SearchPanel extends Tree


signal search_done(results: Array[SearchResult])


var items: Dictionary
var mut: Mutex = Mutex.new()
var search_thread: Thread = Thread.new()
var search_data: Dictionary
var sem: Semaphore = Semaphore.new()

@onready var label: Label = %Label
@onready var throbber: ColorRect = %Throbber

func _ready() -> void:
	EditorManager.simple_search_requested.connect(_on_search_requested)
	EditorManager.regex_search_requested.connect(_on_search_requested)
	
	search_done.connect(display_results)


func display_results(results: Array[SearchResult]) -> void:
	items.clear()
	clear()
	hide_root = true
	create_item()
	for result in results:
		if not result.file_path in items:
			items[result.file_path] = _create_header_item(result.file_path)
		_create_result_item(items[result.file_path], result)
	
	throbber.hide()
	if not results:
		label.text = "No results found 😭"
		label.show()
	else:
		label.hide()


func _create_header_item(file_path: String) -> TreeItem:
	var item := create_item(get_root())
	item.set_text(0, FileManager.get_short_path(file_path))
	item.disable_folding = false
	item.set_selectable(0, false)
	
	return item


func _create_result_item(parent: TreeItem, result: SearchResult) -> TreeItem:
	var item := create_item(parent)
	
	item.set_metadata(0, result)
	item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
	item.set_custom_draw_callback(0, _item_custom_draw)
	item.disable_folding = false
	item.set_selectable(0, true)
	
	return item


func _item_custom_draw(item: TreeItem, rect: Rect2) -> void:
	rect = rect.abs()
	var f := get_theme_font(&"font", &"CodeEdit")
	var f_size := get_theme_font_size(&"font_size")
	var search_result: SearchResult = item.get_metadata(0)
	var text: String = search_result.relevant_line
	var ascent := f.get_ascent(f_size)
	var h_offset := f.get_string_size(
		text.substr(0, search_result.line_start_index),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		f_size
	).x
	var h_width := f.get_string_size(
		StringUtil.substr_pos(
			text,
			search_result.line_start_index,
			search_result.line_end_index
		),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		f_size
	).x
	var h_rect := Rect2(
		rect.position.x + h_offset - 2.0,
		rect.position.y + 2.0,
		h_width + 4.0,
		rect.size.y - 4.0,
	)
	draw_rect(h_rect, get_theme_color(&"font_color"), false)
	draw_string(
		f,
		Vector2(
			rect.position.x,
			rect.get_center().y + ascent / 2.0,
		),
		search_result.relevant_line,
		HORIZONTAL_ALIGNMENT_LEFT,
		maxi(rect.size.x, 1),
		f_size,
		get_theme_color(&"font_color"),
		TextServer.JUSTIFICATION_CONSTRAIN_ELLIPSIS,
	)


func _on_search_requested(folder_path: String, query, file_filter: String, casen: bool, recurse: bool) -> void:
	#var files := _filter_files(folder_path, file_filter, recurse)
	#var results: Array[SearchResult] = []
	#for file in files:
		#var file_text := File.get_text(file)
		#var matches := _get_matches(file_text, query, casen)
		#results.append_array(matches.map(func(r: Vector2i): return SearchResult.create_result(file, file_text, r)))
	#search_done.emit(results)
	if not search_thread.is_alive():
		search_thread.start(_search_on_thread)
	
	EditorManager.change_search_visibility(true)
	EditorManager.search_results_enabled.emit()
	
	clear()
	label.text = "Searching"
	label.show()
	throbber.show()
	(throbber.material as ShaderMaterial).set_shader_parameter(&"color", get_theme_color(&"loader_color", &"SearchPanel"))
	
	mut.lock()
	search_data = {
		"folder_path": folder_path,
		"query": query,
		"file_filter": file_filter,
		"casen": casen,
		"recurse": recurse,
		"exit_loop": false,
	}
	mut.unlock()
	
	sem.post()


func _search_on_thread() -> void:
	while true:
		sem.wait()
		
		mut.lock()
		var data_copy := search_data.duplicate()
		mut.unlock()
		
		if data_copy.exit_loop:
			break
		
		var search_results := _get_search_results(data_copy)
		
		call_deferred_thread_group(&"display_results", search_results)


func _get_search_results(data: Dictionary) -> Array[SearchResult]:
	var folder_path: String = data.folder_path
	# either a RegEx or String
	var query: Variant = data.query
	var file_filter: String = data.file_filter
	var casen: bool = data.casen
	var recurse: bool = data.recurse
	
	var files := _filter_files(folder_path, file_filter, recurse)
	var results: Array[SearchResult] = []
	for file in files:
		var file_text := File.get_text(file)
		var matches := _get_matches(file_text, query, casen)
		results.append_array(matches.map(func(r: Vector2i): return SearchResult.create_result(file, file_text, r)))
	
	return results


func _get_matches(text: String, query, casen: bool) -> Array[Vector2i]:
	if query is String:
		if casen:
			return StringUtil.findn_all_occurrences(text, query)
		else:
			return StringUtil.find_all_occurrences(text, query)
	elif query is RegEx:
		if casen:
			text = text.to_lower()
		var arr: Array[Vector2i]
		arr.assign(query.search_all(text).map(
			func(m: RegExMatch) -> Vector2i:
				return Vector2i(m.get_start(), m.get_end())
		))
		return arr
	return []


func _filter_files(folder: String, filter: String, recursive: bool, allowed_extensions := Settings.get_arr(&"text_file_types")) -> PackedStringArray:
	var arr := PackedStringArray()
	for filename in DirAccess.get_files_at(folder):
		var file = folder.path_join(filename)
		if not file.get_extension() in allowed_extensions:
			continue
		if filter == "" or FileManager.get_short_path(file).match(filter):
			arr.append(file)
	if recursive:
		for dirname in DirAccess.get_directories_at(folder):
			var dir = folder.path_join(dirname)
			arr.append_array(_filter_files(dir, filter, recursive, allowed_extensions))
	return arr


class SearchResult extends RefCounted:
	var file_path: String
	var start_index: int
	var end_index: int
	var line_start_index: int
	var line_end_index: int
	var relevant_line: String
	
	
	func _init(_file_path: String, _start_index: int, _end_index: int, _relevant_line: String, _line_start_index: int, _line_end_index: int) -> void:
		file_path = _file_path
		start_index = _start_index
		end_index = _end_index
		relevant_line = _relevant_line
		line_start_index = _line_start_index
		line_end_index = _line_end_index
	
	
	static func create_result(file_path: String, text: String, index_range: Vector2i) -> SearchResult:
		var line_begin := text.rfind("\n", index_range[0]) + 1
		var line_end := text.find("\n", index_range[1])
		if line_end == -1:
			line_end = text.length()
		return SearchResult.new(
			file_path,
			index_range[0],
			index_range[1],
			StringUtil.substr_pos(text, line_begin, line_end),
			index_range[0] - line_begin,
			index_range[1] - line_begin,
		)


func _on_item_selected() -> void:
	var selected := get_selected()
	var search_result: SearchResult = selected.get_metadata(0)
	EditorManager.open_file_requested.emit(search_result.file_path, search_result.start_index, search_result.end_index)
