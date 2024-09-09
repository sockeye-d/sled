class_name BrowserTree extends Tree


signal file_opened(path: String)


enum BtnType {
	ADD_FILE,
	ADD_FOLDER,
	RENAME_FILE,
	RENAME_FOLDER,
	DELETE_FILE,
	DELETE_FOLDER,
	SHOW_IN_FILE_MANAGER,
	REFRESH,
	FOLDER_FIND,
	COPY_PATH,
}


const TOOLTIPS := {
	BtnType.ADD_FILE: "Add a new file to this folder",
	BtnType.ADD_FOLDER: "Add a new sub-folder to this folder",
	BtnType.RENAME_FILE: "Rename this file",
	BtnType.RENAME_FOLDER: "Rename this folder",
	BtnType.DELETE_FILE: "Delete this file",
	BtnType.DELETE_FOLDER: "Delete this folder",
	BtnType.SHOW_IN_FILE_MANAGER: "Show in file manager",
	BtnType.REFRESH: "Refresh the view (can also press [code]Ctrl+R[/code]",
	BtnType.FOLDER_FIND: "Find within the text files of this folder",
	BtnType.COPY_PATH: "Copy the path to the clipboard. Hold control to copy the relative path, or shift to copy the filename",
}


var icons := {
	BtnType.ADD_FILE: Icons.create("add_file"),
	BtnType.ADD_FOLDER: Icons.create("add_folder"),
	BtnType.RENAME_FILE: Icons.create("rename"),
	BtnType.RENAME_FOLDER: Icons.create("rename"),
	BtnType.DELETE_FILE: Icons.create("delete"),
	BtnType.DELETE_FOLDER: Icons.create("delete"),
	BtnType.SHOW_IN_FILE_MANAGER: Icons.create("open_dir"),
	BtnType.REFRESH: Icons.create("refresh"),
	BtnType.FOLDER_FIND: Icons.create("folder_find"),
	BtnType.COPY_PATH: Icons.create("copy_path"),
}


@onready var add_file_dialog: AddFileDialog = %AddFileDialog
@onready var add_folder_dialog: AddFolderDialog = %AddFolderDialog
@onready var find_dialog: FindDialog = %FindDialog


var last_path: String
# TwoWayDictionary[TreeItem, String]
var paths: TwoWayDictionary = TwoWayDictionary.new()
var unfolded_paths: Dictionary
var new_file_folder_path: String


func _init() -> void:
	hide_root = true
	var scroll_bar: HScrollBar
	for child in get_children(true):
		if child is HScrollBar:
			scroll_bar = child
			break
	scroll_bar.visibility_changed.connect((func(node): node.hide()).bind(scroll_bar))


func _ready() -> void:
	FileManager.changed_paths.connect(
			func():
				last_path = FileManager.current_path
				repopulate_tree()
	)


func _get_drag_data(at_position: Vector2) -> Variant:
	if get_selected() == null:
		return
	var items := _get_selected_items()
	# the root folder is not actually the root item
	# and i'm too scared to change it 😬
	if get_root().get_child(0) in items:
		return null
	var item_paths: PackedStringArray
	for item in items:
		item_paths.append(paths.get_value(item))
	
	var data := DragData.new(item_paths, items)
	
	#if data.begins_with(FileManager.absolute_base_path) and Settings.browser_drag_drop_mode == 2:
		#data = data.trim_prefix(FileManager.absolute_base_path)
		#data = '#include "%s"' % data
	#elif data.begins_with(FileManager.current_path):
		#data = data.trim_prefix(FileManager.current_path)
	#else:
		#return
	
	var preview: Label = Label.new()
	for path in data.absolute_paths:
		preview.text += FileManager.get_short_path(path) + "\n"
	
	set_drag_preview(preview)
	
	return data


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var item := get_item_at_position(at_position)
	if not item:
		return false
	drop_mode_flags = DROP_MODE_INBETWEEN
	if _is_item_folder(get_item_at_position(at_position)):
		drop_mode_flags |= DROP_MODE_ON_ITEM
	else:
		for drop_item in (data as DragData).items:
			if drop_item.get_parent() == item.get_parent():
				drop_mode_flags = DROP_MODE_DISABLED
				return false
	return true


func _drop_data(at_position: Vector2, u_data: Variant) -> void:
	if u_data is BrowserTree.DragData:
		var data := u_data as BrowserTree.DragData
		var base_path: String
		var base_item: TreeItem
		if get_drop_section_at_position(at_position) == 0:
			base_item = get_item_at_position(at_position)
		else:
			base_item = get_item_at_position(at_position).get_parent()
		assert(is_instance_valid(base_item))
		base_path = paths.get_value(base_item)
		for i in data.absolute_paths.size():
			var path = data.absolute_paths[i]
			var new_path := base_path.path_join(path.get_file())
			DirAccess.rename_absolute(path, new_path)
		repopulate_tree()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"refresh", false):
		repopulate_tree()
	if event.is_action_pressed(&"find", false):
		var selected := get_selected()
		if selected:
			if selected.disable_folding:
				_on_button_clicked(selected.get_parent(), 0, BtnType.FOLDER_FIND, 0)
			else:
				_on_button_clicked(selected, 0, BtnType.FOLDER_FIND, 0)
		else:
			_on_button_clicked(null, 0, BtnType.FOLDER_FIND, 0)


func populate_tree(path: String, parent: TreeItem = null, first: bool = true) -> TreeItem:
	if first:
		paths.clear()
		last_path = path
		clear()
		parent = create_item()
		parent.disable_folding = true
	var item := _create_folder_item(path, parent)
	if first:
		item.add_button(0, Icons.create("refresh"), BtnType.REFRESH)
	
	var da := DirAccess.open(path)
	da.include_hidden = Settings.show_hidden_files
	
	for dir in da.get_directories():
		populate_tree(path.path_join(dir), item, false)
	
	for file in da.get_files():
		_create_file_item(path.path_join(file), item)
	
	get_root().get_child(0).set_deferred("collapsed", false)
	
	return item


func repopulate_tree() -> void:
	if last_path:
		var scroll = get_scroll()
		
		if get_root():
			get_root().free()
		populate_tree(last_path)
		# the engine is kind of inconsistent about how setting which things
		# will emit what signals so I have to block signals otherwise the
		# items will emit their collapsed signals
		set_block_signals(true)
		set_all_collapsed(true)
		set_block_signals(false)
		for path in unfolded_paths:
			if not paths.has_key(path):
				unfolded_paths.erase(path)
				continue
			var item: TreeItem = paths.get_key(path)
			if item and not item.disable_folding:
				item.collapsed = false
		deselect_all()


func set_all_collapsed(state: bool, root := get_root()) -> void:
	if not root.disable_folding:
		root.collapsed = state
	for child in root.get_children():
		set_all_collapsed(state, child)


func _create_file_item(path: String, parent: TreeItem) -> TreeItem:
	var item := _create_item(
		parent,
		FileManager.get_icon(path.get_extension().to_lower()),
		FileAccess.get_hidden_attribute(path),
	)
	
	item.set_text(0, path.get_file())
	item.set_tooltip_text(0, FileManager.get_short_path(path))
	
	_add_btn(item, BtnType.SHOW_IN_FILE_MANAGER)
	_add_btn(item, BtnType.COPY_PATH)
	_add_btn(item, BtnType.RENAME_FILE)
	_add_btn(item, BtnType.DELETE_FILE)
	
	item.disable_folding = true
	
	paths.add(item, path)
	
	return item


func _create_folder_item(path: String, parent: TreeItem) -> TreeItem:
	var item :=_create_item(
		parent,
		null,
		FileAccess.get_hidden_attribute(path),
	)
	
	item.set_text(0, path.get_file())
	item.set_tooltip_text(0, FileManager.get_short_path(path))
	
	_add_btn(item, BtnType.ADD_FILE)
	_add_btn(item, BtnType.ADD_FOLDER)
	_add_btn(item, BtnType.FOLDER_FIND)
	_add_btn(item, BtnType.SHOW_IN_FILE_MANAGER)
	_add_btn(item, BtnType.COPY_PATH)
	_add_btn(item, BtnType.RENAME_FOLDER)
	_add_btn(item, BtnType.DELETE_FOLDER)
	
	paths.add(item, path)
	
	return item


func _add_btn(item: TreeItem, type: BtnType) -> void:
	item.add_button(0, icons[type], type, false, TOOLTIPS[type])


func _create_item(parent: TreeItem, icon: Texture2D, is_hidden: bool) -> TreeItem:
	var item := create_item(parent)
	item.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	item.set_icon(0, icon)
	return item


func _on_empty_clicked(_position: Vector2, _mouse_button_index: int) -> void:
	deselect_all()


func _on_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	match id:
		BtnType.ADD_FILE:
			_add_file(item)
		BtnType.ADD_FOLDER:
			_add_folder(item)
		BtnType.RENAME_FILE:
			_rename_item(item, "Rename file")
		BtnType.RENAME_FOLDER:
			_rename_item(item, "Rename folder")
		BtnType.DELETE_FILE:
			_delete_item(item)
		BtnType.DELETE_FOLDER:
			_delete_item(item)
		BtnType.SHOW_IN_FILE_MANAGER:
			OS.shell_show_in_file_manager(ProjectSettings.globalize_path(paths.get_value(item)))
		BtnType.REFRESH:
			repopulate_tree()
		BtnType.FOLDER_FIND:
			if item:
				find_dialog.open(paths.get_value(item))
			else:
				find_dialog.open()
		BtnType.COPY_PATH:
			if Input.is_key_pressed(KEY_CTRL):
				DisplayServer.clipboard_set(FileManager.get_short_path(paths.get_value(item)))
			elif Input.is_key_pressed(KEY_SHIFT):
				DisplayServer.clipboard_set(paths.get_value(item).get_file())
			else:
				DisplayServer.clipboard_set(paths.get_value(item))


func _delete_item(item: TreeItem) -> void:
	var cd := ConfirmationDialog.new()
	cd.dialog_text = "Delete '%s'?" % item.get_text(0)
	cd.ok_button_text = "Delete"
	cd.title = "Confirm deletion"
	add_child(cd)
	cd.popup_centered()
	cd.confirmed.connect(
			func():
				EditorManager.file_free_requested.emit(paths.get_value(item))
				var err: Error = OS.move_to_trash(paths.get_value(item))
				NotificationManager.notify_if_err(
					err,
					"Deleted '%s'" % paths.get_value(item).get_file(),
					"Failed to delete '%s'" % paths.get_value(item).get_file()
				)
				if not err:
					item.get_parent().remove_child(item)
				)
	cd.visibility_changed.connect(func(): if not cd.visible: cd.queue_free())


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
		NotificationManager.notify_if_err(err, "'%s' renamed to '%s' successfully" % [path.get_file(), new_name], "'%s' failed to be renamed to '%s'" % [path.get_file(), new_name])
	dialog.queue_free()


func _add_file(item: TreeItem) -> void:
	new_file_folder_path = paths.get_value(item)
	add_file_dialog.reset_and_show()


func _add_folder(item: TreeItem) -> void:
	new_file_folder_path = paths.get_value(item)
	add_folder_dialog.reset_and_show()


func _on_add_file_dialog_confirmed_data(filename: String, create_matching_file: bool, add_include_guard: bool, include_guard_override: String) -> void:
	if not filename:
		return
	_add_file_from_path(filename, add_include_guard)
	if create_matching_file:
		var sbs_ext := FileManager.file_is_sbs(filename)
		if sbs_ext:
			_add_file_from_path(
				StringUtil.replace_extension(filename, sbs_ext),
				add_include_guard,
			)
	repopulate_tree.call_deferred()


func _add_file_from_path(filename: String, add_include_guard: bool) -> void:
	var path := new_file_folder_path.path_join(filename)	
	var string: String = ""
	if add_include_guard:
		var format := {
			"filename": filename.get_file().get_basename(),
			"filename_upper": filename.get_file().get_basename().to_pascal_case().to_upper(),
			"extension": filename.get_extension().to_lower(),
			"extension_upper": filename.get_extension().to_pascal_case().to_upper(),
		}
		var guard_str: String = Settings.include_guard_string.format(format)
		string = "#ifndef {0}\n#define {0}\n\n#endif".format([guard_str])
	var handle := FileAccess.open(path, FileAccess.WRITE)
	handle.store_string(string)


func _on_add_folder_dialog_confirmed_data(filename: String) -> void:
	if not filename:
		return
	var path := new_file_folder_path.path_join(filename)
	var err := DirAccess.make_dir_absolute(path)
	NotificationManager.notify_if_err(err, "Created '%s'" % path, "Failed to create '%s'" % path)
	repopulate_tree()


func _on_item_collapsed(item: TreeItem) -> void:
	if item.collapsed:
		unfolded_paths.erase(paths.get_value(item))
	else:
		unfolded_paths[paths.get_value(item)] = null


func _on_item_activated() -> void:
	if get_selected():
		if not get_selected().disable_folding:
			get_selected().collapsed = not get_selected().collapsed
		elif paths.has_value(get_selected()):
			file_opened.emit(paths.get_value(get_selected()))


func _get_selected_items() -> Array[TreeItem]:
	var arr: Array[TreeItem] = []
	var item := get_selected()
	arr.append(item)
	while true:
		item = get_next_selected(item)
		if item == null:
			break
		arr.append(item)
	return arr


func _is_item_folder(item: TreeItem) -> bool:
	return not item.disable_folding


class DragData:
	var absolute_paths: PackedStringArray
	var items: Array[TreeItem]
	
	
	func _init(_absolute_paths: PackedStringArray, _items: Array[TreeItem]) -> void:
		absolute_paths = _absolute_paths
		items = _items
