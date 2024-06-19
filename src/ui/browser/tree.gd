class_name BrowserTree extends Tree


signal file_opened(path: String)


enum Buttons {
	ADD_FILE,
	ADD_FOLDER,
	RENAME_FILE,
	RENAME_FOLDER,
	DELETE_FILE,
	DELETE_FOLDER,
	SHOW_IN_FILE_MANAGER,
	REFRESH,
}


var last_path: String
# Maps between TreeItems and paths
var paths: TwoWayDictionary = TwoWayDictionary.new()
var folded_paths: Dictionary


func _init() -> void:
	hide_root = true
	var scroll_bar: HScrollBar
	get_scroll()
	for child in get_children(true):
		if child is HScrollBar:
			scroll_bar = child
			break
	scroll_bar.visibility_changed.connect((func(node): node.hide()).bind(scroll_bar))


func _get_drag_data(at_position: Vector2) -> Variant:
	if Settings.browser_drag_drop_mode == 0:
		return
	var data := paths.get_value(get_selected()) as String
	
	if data.begins_with(FileManager.absolute_base_path) and Settings.browser_drag_drop_mode == 2:
		data = data.trim_prefix(FileManager.absolute_base_path)
		data = '#include "%s"' % data
	elif data.begins_with(FileManager.current_path):
		data = data.trim_prefix(FileManager.current_path)
	else:
		return
	
	var preview: Label = Label.new()
	preview.text = data
	
	set_drag_preview(preview)
	
	return data


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("refresh", false):
		repopulate_tree()


func populate_tree(path: String, parent: TreeItem = null, first: bool = true) -> TreeItem:
	if first:
		paths.clear()
		last_path = path
		clear()
		parent = create_item()
		parent.disable_folding = true
	var item := _create_folder_item(path, parent)
	if first:
		item.add_button(0, Icons.refresh, Buttons.REFRESH)
		item.disable_folding = true

	for dir in DirAccess.get_directories_at(path):
		populate_tree(path.path_join(dir), item, false)
	for file in DirAccess.get_files_at(path):
		_create_file_item(path.path_join(file), item)
	return item


func repopulate_tree() -> void:
	if last_path:
		if get_root():
			get_root().free()
		populate_tree(last_path)
		if folded_paths.size() == 0:
			set_all_collapsed(true)
		else:
			for path in folded_paths:
				var item: TreeItem = paths.get_key(path)
				if item and not item.disable_folding:
					item.collapsed = true
		deselect_all()


func set_all_collapsed(state: bool, root := get_root()) -> void:
	if not root.disable_folding:
		root.collapsed = state
	for child in root.get_children():
		set_all_collapsed(state, child)


func _create_file_item(path: String, parent: TreeItem) -> TreeItem:
	var item := create_item(parent)
	item.add_button(0, Icons.open_dir, Buttons.SHOW_IN_FILE_MANAGER)
	item.add_button(0, Icons.rename, Buttons.RENAME_FILE)
	item.add_button(0, Icons.delete, Buttons.DELETE_FILE)
	item.set_text(0, path.get_file())
	item.set_icon_max_width(0, 1e10)
	paths.add(item, path)

	return item


func _create_folder_item(path: String, parent: TreeItem) -> TreeItem:
	var item := create_item(parent)
	item.set_text(0, path.substr(path.rfind("/") + 1))
	item.add_button(0, Icons.open_dir, Buttons.SHOW_IN_FILE_MANAGER)	
	item.add_button(0, Icons.add_file, Buttons.ADD_FILE)
	item.add_button(0, Icons.add_folder, Buttons.ADD_FOLDER)
	item.add_button(0, Icons.rename, Buttons.RENAME_FOLDER)
	item.add_button(0, Icons.delete, Buttons.DELETE_FOLDER)
	item.set_icon_max_width(0, 1e10)
	item.set_selectable(0, false)
	paths.add(item, path)

	return item


func _on_empty_clicked(_position: Vector2, _mouse_button_index: int) -> void:
	deselect_all()


func _on_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
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
			var cd := ConfirmationDialog.new()
			cd.dialog_text = "Delete %s?" % item.get_text(0)
			cd.ok_button_text = "Delete"
			cd.title = "Confirm deletion"
			add_child(cd)
			cd.popup_centered()
			cd.confirmed.connect(
					func():
						var err: Error = OS.move_to_trash(paths.get_value(item))
						NotificationManager.notify_if_err(
							err,
							"Deleted %s" % paths.get_value(item).get_file(),
							"Failed to delete %s" % paths.get_value(item).get_file()
						)
						if not err:
							item.get_parent().remove_child(item)
						)
			cd.visibility_changed.connect(func(): if not cd.visible: cd.queue_free())
		Buttons.DELETE_FOLDER:
			item.get_parent().remove_child(item)
			OS.move_to_trash(paths.get_value(item))
		Buttons.SHOW_IN_FILE_MANAGER:
			OS.shell_show_in_file_manager(ProjectSettings.globalize_path(paths.get_value(item)))
		Buttons.REFRESH:
			repopulate_tree()


func _rename_item(item: TreeItem, title: String) -> void:
	var dialog = LineEditDialog.new()
	dialog.title = title
	add_child(dialog)
	dialog.text = item.get_text(0)
	dialog.disallowed_chars = r':/\?*"|%<>'
	dialog.popup_centered()
	var new_name = await dialog.finished
	if new_name:
		var path: String = paths.get_value(item)
		var new_path: String = path.get_base_dir().path_join(new_name)
		var err: Error = DirAccess.rename_absolute(path, new_path)
		if not err:
			item.set_text(0, new_name)
			paths.add(item, path.get_base_dir().path_join(new_name))
		NotificationManager.notify_if_err(err, "%s renamed to %s successfully" % [path.get_file(), new_name], "%s failed to be renamed to %s" % [path.get_file(), new_name])
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
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		while true:
			var input: InputEvent = await gui_input
			if input is InputEventMouseButton:
				if not input.pressed:
					break
		if not has_focus():
			return
	file_opened.emit(paths.get_value(get_selected()))
