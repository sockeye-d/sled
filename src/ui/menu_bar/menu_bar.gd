extends AutoMenuBar


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
		"File/Open recent":
			if index > FileManager.last_opened_paths.size() - 1:
				FileManager.clear_recent()
			else:
				FileManager.change_path(FileManager.last_opened_paths[index])
		"View":
			if index in [0, 1]:
				menu.set_item_checked(index, not menu.is_item_checked(index))
				if not (menu.is_item_checked(0) or menu.is_item_checked(0)):
					menu.set_item_checked(1 - index, not menu.is_item_checked(index))
					EditorManager.change_editor_visibility(1 - index, not menu.is_item_checked(index))
				EditorManager.change_editor_visibility(index, menu.is_item_checked(index))
