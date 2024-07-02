class_name MainMenuBar extends AutoMenuBar


var editor_0_can_open: bool:
	get:
		return editor_0_can_open
	set(value):
		editor_0_can_open = value
		view.set_item_disabled(1, editor_0_can_open)
var editor_1_can_open: bool:
	get:
		return editor_1_can_open
	set(value):
		editor_1_can_open = value
		view.set_item_disabled(2, editor_1_can_open)
var search_can_open: bool:
	get:
		return search_can_open
	set(value):
		search_can_open = value
		view.set_item_disabled(3, search_can_open)


@onready var view: PopupMenu = %View


func _item_pressed(menu_name: String, index: int, menu: PopupMenu) -> void:
	match menu_name:
		"Edit":
			match index:
				0:
					Settings.show_settings_window()
		"File":
			match index:
				0:
					EditorManager.save_all_editors()
				1:
					FileManager.change_path_browse()
				2:
					FileManager.open_quick_switch()
		"File/Open recent":
			if index >= FileManager.last_opened_paths.size():
				FileManager.clear_recent()
			else:
				FileManager.change_path(FileManager.last_opened_paths[index])
		"View":
			menu.set_item_checked(index, not menu.is_item_checked(index))
			var checked_sum := view.get_sum
			match index:
				0, 1:
					if not (menu.is_item_checked(0) or menu.is_item_checked(0)):
						menu.set_item_checked(1 - index, not menu.is_item_checked(index))
						EditorManager.change_editor_visibility(1 - index, not menu.is_item_checked(index))
					EditorManager.change_editor_visibility(index, menu.is_item_checked(index))
				2:
					EditorManager.change_browser_visibility(menu.is_item_checked(index))
				3:
					EditorManager.change_search_visibility(menu.is_item_checked(index))
