class_name BrowserTree extends Tree


signal file_opened(path: String)


enum Buttons {
	ADD_FILE,
	ADD_FOLDER,
	RENAME_FILE,
	RENAME_FOLDER,
	DELETE_FILE,
	DELETE_FOLDER,
}


var last_path: String
# Maps between TreeItems and paths
var paths: TwoWayDictionary = TwoWayDictionary.new()
var folded_paths: Dictionary


func _init() -> void:
	hide_root = true
	var scroll_bar: HScrollBar
	for child in get_children(true):
		if child is HScrollBar:
			scroll_bar = child
			break
	scroll_bar.visibility_changed.connect((func(node): node.hide()).bind(scroll_bar))


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("refresh"):
		repopulate_tree()


func populate_tree(path: String, parent: TreeItem = create_item(), first: bool = true) -> TreeItem:
	if first:
		paths.clear()
		last_path = path
	path = path.replace("\\", "/").trim_suffix("/")
	var item = _create_folder_item(path, parent)

	for dir in DirAccess.get_directories_at(path):
		populate_tree(path.path_join(dir), item, false)
	for file in DirAccess.get_files_at(path):
		_create_file_item(path.path_join(file), item)
	return item


func repopulate_tree() -> void:
	if last_path:
		get_root().free()
		populate_tree(last_path)
		for path in folded_paths:
			var item: TreeItem = paths.get_key(path)
			item.collapsed = true
		deselect_all()


func _create_file_item(path: String, parent: TreeItem) -> TreeItem:
	var file_item = create_item(parent)
	file_item.add_button(0, Icons.rename, Buttons.RENAME_FILE)
	file_item.add_button(0, Icons.delete, Buttons.DELETE_FILE)
	file_item.set_text(0, path.get_file())
	paths.add(file_item, path)

	return file_item


func _create_folder_item(path: String, parent: TreeItem) -> TreeItem:
	var item = create_item(parent)
	item.set_text(0, path.substr(path.rfind("/") + 1))
	item.add_button(0, Icons.add_file, Buttons.ADD_FILE)
	item.add_button(0, Icons.add_folder, Buttons.ADD_FOLDER)
	item.add_button(0, Icons.rename, Buttons.RENAME_FOLDER)
	item.add_button(0, Icons.delete, Buttons.DELETE_FOLDER)
	item.set_selectable(0, false)
	paths.add(item, path)

	return item


func _on_empty_clicked(position: Vector2, mouse_button_index: int) -> void:
	deselect_all()


func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	match id:
		Buttons.ADD_FILE:
			_add_file(item)
		Buttons.ADD_FOLDER:
			_add_folder(item)
		Buttons.RENAME_FILE:
			_rename_item(item, "Rename file")
		Buttons.RENAME_FOLDER:
			_rename_item(item, "Rename folder")
		Buttons.DELETE_FILE:
			item.get_parent().remove_child(item)
			OS.move_to_trash(paths.get_value(item))
		Buttons.DELETE_FOLDER:
			item.get_parent().remove_child(item)
			OS.move_to_trash(paths.get_value(item))


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
		var path: String = paths.get_value(item)
		var new_path: String = path.get_base_dir().path_join(new_name)
		DirAccess.rename_absolute(path, new_path)
		paths.add(item, path.get_base_dir().path_join(new_name))
	dialog.queue_free()


func _add_file(item: TreeItem) -> void:
	var base_path: String = paths.get_value(item)

	var dialog = LineEditDialog.new()
	dialog.title = "Add file"
	add_child(dialog)
	dialog.text = ""
	dialog.placeholder_text = "File name..."
	dialog.disallowed_chars = r':/\?*"|%<>'
	dialog.popup_centered()

	var filename: String = await dialog.finished
	if filename:
		var path = base_path.path_join(filename)
		FileAccess.open(path, FileAccess.WRITE)
		repopulate_tree.call_deferred()
	dialog.queue_free()


func _add_folder(item: TreeItem) -> void:
	var base_path: String = paths.get_value(item)

	var dialog = LineEditDialog.new()
	dialog.title = "Add folder"
	add_child(dialog)
	dialog.text = ""
	dialog.placeholder_text = "Folder name..."
	dialog.disallowed_chars = r':/\?*"|%<>'
	dialog.popup_centered()

	var filename: String = await dialog.finished
	if filename:
		var path = base_path.path_join(filename)
		DirAccess.make_dir_absolute(path)
		repopulate_tree.call_deferred()

	dialog.queue_free()


func _on_item_collapsed(item: TreeItem) -> void:
	if item.collapsed:
		folded_paths[paths.get_value(item)] = null
	else:
		folded_paths.erase(paths.get_value(item))


func _on_item_activated() -> void:
	file_opened.emit(paths.get_value(get_selected()))


func _on_item_selected() -> void:
	file_opened.emit(paths.get_value(get_selected()))
