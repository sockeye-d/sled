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
var folded_paths: Dictionary
var new_file_folder_path: String


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
	if Settings.browser_drag_drop_mode == 0 or not get_selected():
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
		item.add_button(0, Icons.create("refresh"), BtnType.REFRESH)
		item.disable_folding = true
	
	var da := DirAccess.open(path)
	da.include_hidden = Settings.show_hidden_files
	
	for dir in da.get_directories():
		populate_tree(path.path_join(dir), item, false)
	
	for file in da.get_files():
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
				if not paths.has_key(path):
					continue
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
	var item := _create_item(
		parent,
		FileManager.get_icon(path.get_extension().to_lower()),
		FileAccess.get_hidden_attribute(path),
	)
	
	item.set_metadata(0, path.get_file())
	item.set_tooltip_text(0, FileManager.get_short_path(path))
	
	_add_btn(item, BtnType.SHOW_IN_FILE_MANAGER)
	_add_btn(item, BtnType.COPY_PATH)
	_add_btn(item, BtnType.RENAME_FILE)
	_add_btn(item, BtnType.DELETE_FILE)
	
	paths.add(item, path)
	
	return item


func _create_folder_item(path: String, parent: TreeItem) -> TreeItem:
	var item :=_create_item(
		parent,
		Icons.create("folder"),
		FileAccess.get_hidden_attribute(path),
	)
	
	item.set_metadata(0, path.substr(path.rfind("/") + 1))
	item.set_tooltip_text(0, path)
	item.set_tooltip_text(0, FileManager.get_short_path(path))
		
	_add_btn(item, BtnType.ADD_FILE)
	_add_btn(item, BtnType.ADD_FOLDER)
	_add_btn(item, BtnType.FOLDER_FIND)
	_add_btn(item, BtnType.SHOW_IN_FILE_MANAGER)
	_add_btn(item, BtnType.COPY_PATH)
	_add_btn(item, BtnType.RENAME_FOLDER)
	_add_btn(item, BtnType.DELETE_FOLDER)
	
	item.set_selectable(0, false)
	
	paths.add(item, path)
	
	return item


func _add_btn(item: TreeItem, type: BtnType) -> void:
	item.add_button(0, icons[type], type, false, TOOLTIPS[type])


func _create_item(parent: TreeItem, icon: Texture2D, is_hidden: bool) -> TreeItem:
	var item := create_item(parent)
	item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
	item.set_custom_draw_callback(0, func(item: TreeItem, rect: Rect2) -> void: _item_custom_draw(item, rect, icon, is_hidden))
	return item


func _item_custom_draw(item: TreeItem, rect: Rect2, icon: Texture2D, is_hidden: bool) -> void:
	if rect.size.x < 0.0:
		return
	var f := get_theme_font(&"font")
	var f_size := get_theme_font_size(&"font_size") if has_theme_font_size(&"font_size") else get_theme_default_font_size()
	var text: String = item.get_metadata(0)
	var ascent := f.get_ascent(f_size)
	var string_size := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, f_size)
	var icon_width: int = icon.get_width() * EditorThemeManager.get_scale()
	if get_theme_constant(&"icon_max_width") != 0:
		icon_width = mini(icon_width, get_theme_constant(&"icon_max_width"))
	var icon_offset := (rect.size.y - icon_width) / 2.0
	var icon_rect := Rect2(round(rect.position + Vector2.ONE * icon_offset), Vector2(icon_width, icon_width))
	#if icon_rect.size.x + 2.0 * icon_offset > rect.size.x:
		#return
	var icon_mod: float = Settings.hidden_file_icon_brightness if is_hidden else 1.0
	var text_mod: float = Settings.hidden_file_text_brightness if is_hidden else 1.0
	var icon_rect_isect := icon_rect.intersection(rect)
	var width_mod := Vector2(icon_rect_isect.size.x / icon_rect.size.x, 1)
	draw_texture_rect_region(icon, icon_rect.intersection(rect), Rect2(Vector2.ZERO, icon.get_size() * width_mod), Color(Color.WHITE, icon_mod))
	draw_string(
		f,
		Vector2(
			rect.position.x + icon_width + icon_offset * 2.0,
			rect.get_center().y + ascent / 2.0
		),
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		maxi(rect.size.x - icon_width - icon_offset * 2.0, 1),
		f_size,
		get_theme_color(&"font_color") * Color(Color.WHITE, text_mod),
		TextServer.JUSTIFICATION_CONSTRAIN_ELLIPSIS,
	)


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
			find_dialog.open(paths.get_value(item))
		BtnType.COPY_PATH:
			if Input.is_key_pressed(KEY_CTRL):
				DisplayServer.clipboard_set(FileManager.get_short_path(paths.get_value(item)))
			elif Input.is_key_pressed(KEY_SHIFT):
				DisplayServer.clipboard_set(paths.get_value(item).get_file())
			else:
				DisplayServer.clipboard_set(paths.get_value(item))


func _delete_item(item: TreeItem) -> void:
	var cd := ConfirmationDialog.new()
	cd.dialog_text = "Delete '%s'?" % item.get_metadata(0)
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
	dialog.text = item.get_metadata(0)
	dialog.disallowed_chars = r':/\?*"|%<>'
	dialog.popup_centered()
	var new_name = await dialog.finished
	if new_name:
		var path: String = paths.get_value(item)
		var new_path: String = path.get_base_dir().path_join(new_name)
		var err: Error = DirAccess.rename_absolute(path, new_path)
		if not err:
			item.set_metadata(0, new_name)
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
