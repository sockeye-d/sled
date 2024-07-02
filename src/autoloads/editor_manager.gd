extends Node


signal editor_visible_change_requested(index: int, visible: bool)
signal browser_visible_change_requested(visible: bool)
signal search_visible_change_requested(visible: bool)
signal opened_side_by_side()
signal opened_single()
signal opened_search_panel()
signal view_menu_state_change_requested(index: int, new_state: bool)
signal save_requested()
signal open_file_requested(path: String, selection_start: int, selection_end: int)
signal file_free_requested(path: String)
signal search_results_enabled()
signal simple_search_requested(folder_path: String, query: String, file_filter: String, casen: bool, recurse: bool)
signal regex_search_requested(folder_path: String, query: RegEx, file_filter: String, casen: bool, recurse: bool)


func change_editor_visibility(index: int, visible: bool) -> void:
	editor_visible_change_requested.emit(index, visible)


func change_browser_visibility(visible: bool) -> void:
	browser_visible_change_requested.emit(visible)


func change_search_visibility(visible: bool) -> void:
	search_visible_change_requested.emit(visible)


func save_all_editors():
	save_requested.emit()
