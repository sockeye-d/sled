extends AutoMenuBar


func _item_pressed(menu_name: String, index: int) -> void:
	match menu_name:
		"Edit":
			match index:
				0:
					Settings.show_settings_window()
