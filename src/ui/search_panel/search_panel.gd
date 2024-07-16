class_name SearchPanel extends PanelContainer


enum Task {
	FIND,
	FILTER,
	EXIT,
}


signal search_done(results: Array[SearchResult])


var current_results: SearchResults
var search_data: Dictionary


var header_items: Array[TreeItem]

@onready var mut: Mutex = Mutex.new()
@onready var search_thread: Thread = Thread.new()
@onready var sem: Semaphore = Semaphore.new()

@onready var label: Label = %Label
@onready var throbber: Throbber = %Throbber
@onready var stats_container: LowerPanelContainer = %StatsContainer
@onready var count_label: Label = %CountLabel
@onready var stats_label: Label = %StatsLabel
@onready var results_tree: ResultsTree = %ResultsTree
@onready var fold_button: Button = %FoldButton

@onready var fold_icon := Icons.create("fold_large")
@onready var unfold_icon := Icons.create("unfold_large")

@export_multiline var fold_tooltip: String = ""
@export_multiline var unfold_tooltip: String = ""

var unfolded_count: int = 0

func _ready() -> void:
	EditorManager.simple_search_requested.connect(_on_search_requested)
	EditorManager.regex_search_requested.connect(_on_search_requested)
	
	search_done.connect(display_results)


func _exit_tree() -> void:
	if search_thread.is_alive():
		mut.lock()
		search_data = {
			"task": Task.EXIT,
		}
		mut.unlock()
		sem.post()
		search_thread.wait_to_finish()


func display_results(results: SearchResults = current_results, is_new: bool = false) -> void:
	if is_new:
		current_results = results
	var items := { }
	stats_container.show()
	results_tree.clear()
	results_tree.hide_root = true
	results_tree.create_item()
	header_items.clear()
	for result in results.results:
		if not result.file_path in items:
			var header := _create_header_item(result.file_path)
			items[result.file_path] = header
			header_items.append(header)
			unfolded_count += 1
		_create_result_item(items[result.file_path], result)
	
	throbber.hide()
	if not results:
		label.text = "No results found 😭"
		label.show()
	else:
		label.hide()
	
	stats_label.text = "%s files searched in %.3fs" % [
		results.files_searched,
		results.get_elapsed_time(Stopwatch.TimeUnit.SECONDS),
	]
	
	count_label.text = "%s results" % results.results.size()
	fold_button.icon = fold_icon


func _create_header_item(file_path: String) -> TreeItem:
	var item := results_tree.create_item(results_tree.get_root())
	item.set_text(0, FileManager.get_short_path(file_path))
	item.disable_folding = false
	item.set_selectable(0, false)
	
	return item


func _create_result_item(parent: TreeItem, result: SearchResult) -> TreeItem:
	var item := results_tree.create_item(parent)
	
	item.set_metadata(0, result)
	item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
	item.set_custom_draw_callback(0, results_tree._item_custom_draw)
	item.disable_folding = false
	item.set_selectable(0, true)
	
	return item


func _on_search_requested(folder_path: String, query, file_filter: String, casen: bool, recurse: bool) -> void:
	if not search_thread.is_alive():
		search_thread.start(_search_on_thread)
	
	EditorManager.change_search_visibility(true)
	EditorManager.search_results_enabled.emit()
	
	stats_container.hide()
	results_tree.clear()
	label.text = "Searching"
	label.show()
	throbber.show()
	
	mut.lock()
	search_data = {
		"task": Task.FIND,
		"folder_path": folder_path,
		"query": query,
		"file_filter": file_filter,
		"casen": casen,
		"recurse": recurse,
	}
	mut.unlock()
	
	sem.post()


func _search_on_thread() -> void:
	while true:
		sem.wait()
		
		mut.lock()
		var data_copy := search_data.duplicate()
		mut.unlock()
		
		if data_copy.task == Task.EXIT:
			break
		
		if data_copy.task == Task.FIND:
			var search_results := _get_search_results(data_copy)
			call_deferred_thread_group(&"display_results", search_results, true)
		elif data_copy.task == Task.FILTER:
			var filtered_results: SearchResults = data_copy.old_results.copy_empty()
			# Dictionary[SearchResult, float (weight)]
			var weights: Dictionary
			var q: String = data_copy.query
			var old: SearchResults = data_copy.old_results
			ArrayUtil.foreach(old.results,
				func(result: SearchResult) -> void:
					weights[result] = StringUtil.fuzzy_dist(result.file_path, q)
			)
			
			var old_filtered: Array[SearchResult] = old.results.filter(
				func(result: SearchResult) -> bool:
					return not is_nan(weights[result])
			)
			
			old_filtered.sort_custom(
				func(a: SearchResult, b: SearchResult) -> bool:
					return weights[a] < weights[b]
			)
			
			
			filtered_results.results.assign(old_filtered)
			call_deferred_thread_group(&"display_results", filtered_results, false)


func _get_search_results(data: Dictionary) -> SearchResults:
	var folder_path: String = data.folder_path
	# either a RegEx or String
	var query: Variant = data.query
	var file_filter: String = data.file_filter
	var casen: bool = data.casen
	var recurse: bool = data.recurse
	
	var results := SearchResults.new()
	results.ticks_usec_start = Time.get_ticks_usec()
	var files := _filter_files(folder_path, file_filter, recurse)
	results.files_searched = files.size()
	for file in files:
		var file_text := File.get_text(file)
		var matches := _get_matches(file_text, query, casen)
		results.results.append_array(matches.map(func(r: Vector2i): return SearchResult.create_result(file, file_text, r)))
	results.ticks_usec_end = Time.get_ticks_usec()
	
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


func _on_item_selected() -> void:
	var selected := results_tree.get_selected()
	var search_result: SearchResult = selected.get_metadata(0)
	EditorManager.open_file_requested.emit(search_result.file_path, search_result.start_index, search_result.end_index)


func _on_search_filter_line_edit_text_changed(new_text: String) -> void:
	if new_text == "":
		display_results()
		return
	
	throbber.show()
	
	mut.lock()
	search_data = {
		"task": Task.FILTER,
		"old_results": current_results,
		"query": new_text,
	}
	mut.unlock()
	
	sem.post()


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


class SearchResults extends RefCounted:
	var results: Array[SearchResult]
	var files_searched: int
	var ticks_usec_start: int
	var ticks_usec_end: int
	
	
	func get_elapsed_time(unit: Stopwatch.TimeUnit = Stopwatch.TimeUnit.SECONDS) -> float:
		return float(ticks_usec_end - ticks_usec_start) / unit
	
	func copy_empty() -> SearchResults:
		var new := SearchResults.new()
		new.files_searched = self.files_searched
		new.ticks_usec_start = self.ticks_usec_start
		new.ticks_usec_end = self.ticks_usec_end
		return new


func _on_fold_button_pressed() -> void:
	var should_fold := unfolded_count > 0
	
	for item in header_items:
		item.collapsed = should_fold
	
	if should_fold:
		unfolded_count = 0
	else:
		unfolded_count = header_items.size()
	
	_set_fold_button_icon()


func _on_results_tree_item_collapsed(item: TreeItem) -> void:
	unfolded_count += -1 if item.collapsed else 1
	_set_fold_button_icon()


func _set_fold_button_icon() -> void:
	fold_button.icon = fold_icon if unfolded_count > 0 else unfold_icon
	fold_button.tooltip_text 
