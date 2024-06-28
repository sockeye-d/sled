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
	FOLDER_FIND,
}


enum Columns {
	ICON = 0,
	TEXT = 0,
	BUTTON = 0,
}

const BUTTON_TOOLTIPS := {
	Buttons.ADD_FILE: "Add a new file to this folder",
	Buttons.ADD_FOLDER: "Add a new sub-folder to this folder",
	Buttons.RENAME_FILE: "Rename this file",
	Buttons.RENAME_FOLDER: "Rename this folder",
	Buttons.DELETE_FILE: "Delete this file",
	Buttons.DELETE_FOLDER: "Delete this folder",
	Buttons.SHOW_IN_FILE_MANAGER: "Show in file manager",
	Buttons.REFRESH: "Refresh the view (can also press [code]Ctrl+R[/code]",
	Buttons.FOLDER_FIND: "Find within the text files of this folder",
}


@onready var add_file_dialog: AddFileDialog = %AddFileDialog
@onready var add_folder_dialog: AddFolderDialog = %AddFolderDialog
@onready var find_dialog: ConfirmationDialog = %FindDialog


var last_path: String
# Maps between TreeItems and paths
var paths: TwoWayDictionary = TwoWayDictionary.new()
var folded_paths: Dictionary
var new_file_folder_path: String


func _init() -> void:
	#set_column_expand(Columns.ICON, false)
	#set_column_custom_minimum_width(Columns.ICON, 21)
	#set_column_expand(Columns.TEXT, true)
	#set_column_expand(Columns.BUTTON, false)
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
		item.add_button(Columns.BUTTON, Icons.create("refresh"), Buttons.REFRESH)
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
	var item := _create_item(parent, FileManager.get_icon(path.get_extension()))
	
	item.set_metadata(Columns.TEXT, path.get_file())
	item.set_tooltip_text(Columns.TEXT, FileManager.get_short_path(path))
		
	item.add_button(
		Columns.BUTTON,
		Icons.create("open_dir"),
		Buttons.SHOW_IN_FILE_MANAGER,
		false,
		BUTTON_TOOLTIPS[Buttons.SHOW_IN_FILE_MANAGER]
	)
	item.add_button(
		Columns.BUTTON,
		Icons.create("rename"),
		Buttons.RENAME_FILE,
		false,
		BUTTON_TOOLTIPS[Buttons.RENAME_FILE]
	)
	item.add_button(
		Columns.BUTTON,
		Icons.create("delete"),
		Buttons.DELETE_FILE,
		false,
		BUTTON_TOOLTIPS[Buttons.DELETE_FILE]
	)
	
	paths.add(item, path)

	return item


func _create_folder_item(path: String, parent: TreeItem) -> TreeItem:
	var item := _create_item(parent, Icons.create("folder"))
	
	item.set_metadata(Columns.TEXT, path.substr(path.rfind("/") + 1))
	item.set_tooltip_text(Columns.TEXT, path)
	item.set_tooltip_text(Columns.TEXT, FileManager.get_short_path(path))
		
	item.add_button(
		Columns.BUTTON,
		Icons.create("open_dir"),
		Buttons.SHOW_IN_FILE_MANAGER,
		false,
		BUTTON_TOOLTIPS[Buttons.SHOW_IN_FILE_MANAGER]
	)	
	item.add_button(
		Columns.BUTTON,
		Icons.create("add_file"),
		Buttons.ADD_FILE,
		false,
		BUTTON_TOOLTIPS[Buttons.ADD_FILE]
	)
	item.add_button(
		Columns.BUTTON,
		Icons.create("add_folder"),
		Buttons.ADD_FOLDER,
		false,
		BUTTON_TOOLTIPS[Buttons.ADD_FOLDER]
	)
	item.add_button(
		Columns.BUTTON,
		Icons.create("rename"),
		Buttons.RENAME_FOLDER,
		false,
		BUTTON_TOOLTIPS[Buttons.RENAME_FOLDER]
	)
	item.add_button(
		Columns.BUTTON,
		Icons.create("delete"),
		Buttons.DELETE_FOLDER,
		false,
		BUTTON_TOOLTIPS[Buttons.DELETE_FOLDER]
	)
	item.add_button(
		Columns.BUTTON,
		Icons.create("folder_find"),
		Buttons.FOLDER_FIND,
		false,
		BUTTON_TOOLTIPS[Buttons.FOLDER_FIND]
	)
	
	item.set_selectable(Columns.TEXT, false)
	
	paths.add(item, path)
	
	return item


func _create_item(parent: TreeItem, icon: Texture2D) -> TreeItem:
	var item := create_item(parent)
	item.set_cell_mode(Columns.TEXT, TreeItem.CELL_MODE_CUSTOM)
	item.set_custom_draw_callback(Columns.TEXT, func(item: TreeItem, rect: Rect2) -> void: _item_custom_draw(item, rect, icon))
	return item


func _item_custom_draw(item: TreeItem, rect: Rect2, icon: Texture2D) -> void:
	var f := get_theme_font(&"font")
	var f_size := get_theme_font_size(&"font_size") if has_theme_font_size(&"font_size") else get_theme_default_font_size()
	var text: String = item.get_metadata(Columns.TEXT)
	var ascent := f.get_ascent(f_size)
	var string_size := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, f_size)
	var icon_width: int = icon.get_width() * EditorThemeManager.get_scale()
	if get_theme_constant(&"icon_max_width") != 0:
		icon_width = mini(icon_width, get_theme_constant(&"icon_max_width"))
	var icon_offset := (rect.size.y - icon_width) / 2.0
	var icon_rect := Rect2(round(rect.position + Vector2.ONE * icon_offset), Vector2(icon_width, icon_width))
	if icon_rect.size.x + 2.0 * icon_offset > rect.size.x:
		return
	draw_texture_rect(icon,	icon_rect, false)
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
		get_theme_color(&"font_color"),
		TextServer.JUSTIFICATION_CONSTRAIN_ELLIPSIS,
	)


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
			cd.dialog_text = "Delete %s?" % item.get_metadata(Columns.TEXT)
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
		Buttons.FOLDER_FIND:
			find_dialog.show()


func _rename_item(item: TreeItem, title: String) -> void:
	var dialog = LineEditDialog.new()
	dialog.title = title
	add_child(dialog)
	dialog.text = item.get_metadata(Columns.TEXT)
	dialog.disallowed_chars = r':/\?*"|%<>'
	dialog.popup_centered()
	var new_name = await dialog.finished
	if new_name:
		var path: String = paths.get_value(item)
		var new_path: String = path.get_base_dir().path_join(new_name)
		var err: Error = DirAccess.rename_absolute(path, new_path)
		if not err:
			item.set_metadata(Columns.TEXT, new_name)
			paths.add(item, path.get_base_dir().path_join(new_name))
		NotificationManager.notify_if_err(err, "%s renamed to %s successfully" % [path.get_file(), new_name], "%s failed to be renamed to %s" % [path.get_file(), new_name])
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
			"extension": filename.get_extension(),
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
	NotificationManager.notify_if_err(err, "Created directory at %s" % path, "Failed to create directory at %s" % path)


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
