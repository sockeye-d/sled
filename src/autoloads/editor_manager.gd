extends Node


signal editor_visible_change_requested(index: int, visible: bool)
signal browser_visible_change_requested(visible: bool)
signal opened_side_by_side()
signal opened_single()
signal save_requested()
signal file_free_requested(path: String)


func change_editor_visibility(index: int, visible: bool) -> void:
	editor_visible_change_requested.emit(index, visible)


func change_browser_visibility(visible: bool) -> void:
	browser_visible_change_requested.emit(visible)


func save_all_editors():
	save_requested.emit()
