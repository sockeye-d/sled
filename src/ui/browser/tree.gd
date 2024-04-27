class_name BrowserTree extends Tree


enum Buttons {
	ADD_FILE,
	ADD_FOLDER,
	RENAME_FILE,
	RENAME_FOLDER,
}


var paths: Dictionary


func _init() -> void:
	hide_root = true


func populate_tree(path: String, parent: TreeItem = create_item()) -> TreeItem:
	path = path.replace("\\", "/").trim_suffix("/")
	var item = create_item(parent)
	item.set_text(0, path.substr(path.rfind("/") + 1))
	item.set_editable(0, true)
	item.add_button(0, Icons.add_file_icon, Buttons.ADD_FILE)
	item.add_button(0, Icons.add_folder_icon, Buttons.ADD_FOLDER)
	item.add_button(0, Icons.rename_icon, Buttons.RENAME_FOLDER)
	paths[item] = path

	for dir in DirAccess.get_directories_at(path):
		populate_tree(path.path_join(dir), item)
	for file in DirAccess.get_files_at(path):
		var file_item = create_item(item)
		file_item.add_button(0, Icons.rename_icon, Buttons.RENAME_FILE)
		file_item.set_editable(0, false)
		file_item.set_text(0, file)
		paths[file_item] = path.path_join(file)
	return item


func _on_empty_clicked(position: Vector2, mouse_button_index: int) -> void:
	deselect_all()


func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	match id:
		Buttons.ADD_FILE:
			print("Add file pressed")
		Buttons.ADD_FOLDER:
			print("Add folder pressed")
		Buttons.RENAME_FILE:
			_rename_item(item, "Rename file")
		Buttons.RENAME_FOLDER:
			_rename_item(item, "Rename folder")


func _rename_item(item: TreeItem, title: String) -> void:
	var dialog = LineEditDialog.new()
	dialog.title = title
	add_child(dialog)
	dialog.text = item.get_text(0)
	dialog.disallowed_chars = r':/\?*"|%<>'
	dialog.popup_centered()
	var new_name = await dialog.finished
	if new_name:
		item.set_text(0, new_name)
		var path: String = paths[item]
		var new_path: String = path.get_base_dir().path_join(new_name)
		DirAccess.rename_absolute(path, new_path)
		paths[item] = path.get_base_dir().path_join(new_name)
	dialog.queue_free()
