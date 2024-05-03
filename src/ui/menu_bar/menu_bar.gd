extends AutoMenuBar


func _item_pressed(menu_name: String, index: int) -> void:
	match menu_name:
		"Edit":
			match index:
				0:
					Settings.show_settings_window()
		"File":
			match index:
				0:
					print("save")
				1:
					FileManager.change_path_browse()
		"File/Open recent":
			if index > FileManager.last_opened_paths.size() - 1:
				FileManager.clear_recent()
			else:
				FileManager.change_path(FileManager.last_opened_paths[index])
