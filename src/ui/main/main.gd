class_name Main extends Control


@onready var nothing_to_show_label: Label = %NothingToShowLabel
@onready var main_container: SplitContainer = %MainContainer
@onready var browser: BrowserTree = %Browser
@onready var editors: RelativeSplitContainer = %Editors
@onready var left_editor: Editor = %LeftEditor
@onready var right_editor: Editor = %RightEditor
@onready var image_viewer: ImageViewer = %ImageViewer
@onready var search_panel: SearchPanel = %SearchPanel
@onready var menu_bar: MainMenuBar = %MenuBar


var sbs_open: bool = false


func _ready() -> void:
	editors.hide()
	FileManager.changed_paths.connect(
		func():
			editors.hide()
			nothing_to_show_label.hide()
			main_container.show()
	)
	
	FileManager.loaded_recent_paths.connect(
		func(found_any: bool):
			nothing_to_show_label.visible = not found_any
			main_container.visible = found_any
	)
	
	FileManager.file_open_requested.connect(open_file)
	
	if EditorManager:
		EditorManager.editor_visible_change_requested.connect(
			func(index: int, new_visible: bool):
				match index:
					0:
						left_editor.visible = new_visible
					1:
						right_editor.visible = new_visible
		)
		
		EditorManager.browser_visible_change_requested.connect(
			func(new_visible: bool):
				browser.visible = new_visible
		)
		
		EditorManager.search_visible_change_requested.connect(
			func(new_visible: bool):
				#if not editors.visible:
					#editors.show()
				search_panel.visible = new_visible
		)
		
		EditorManager.open_file_requested.connect(open_file)
		
		EditorManager.simple_search_requested.connect(func(folder_path: String, query: String, file_filter: String, casen: bool, recurse: bool): editors.show())
		EditorManager.regex_search_requested.connect(func(folder_path: String, query: RegEx, file_filter: String, casen: bool, recurse: bool): editors.show())


func open_file(path: String, selection_start: int = -1, selection_end: int = -1) -> void:
	var ext: String = path.get_extension().to_lower()
	if Settings.sbs_enabled:
		for pair in Settings.sbs_opening_file_exts.split(","):
			var pair_arr: PackedStringArray = pair.split(":", false, 2)
			var match_0 := pair_arr[0].to_lower() == ext
			var match_1 := pair_arr[-1].to_lower() == ext
			if match_0 or match_1:
				image_viewer.hide()
				var path_no_ext := path.get_basename()
				var file_0 := "%s.%s" % [path_no_ext, pair_arr[0]]
				var file_1 := "%s.%s" % [path_no_ext, pair_arr[-1]]
				if match_0:
					left_editor.load_file(file_0, selection_start, selection_end)
				else:
					left_editor.load_file(file_0)
				if match_1:
					right_editor.load_file(file_1, selection_start, selection_end)
				else:
					right_editor.load_file(file_1)
				menu_bar.editor_0_can_open = true
				menu_bar.editor_1_can_open = true
				left_editor.show()
				right_editor.show()
				sbs_open = true
				EditorManager.opened_side_by_side.emit()
				return
	
	if ext in Settings.image_file_types.split(",") and ext in ImageViewer.ALLOWED_FILES:
		var err := image_viewer.load_image(path)
		NotificationManager.notify_if_err(err, "Opened %s" % path.get_file(), "Failed to open %s with error %s" % [path.get_file(), "%s"], true)
		if not err:
			left_editor.unload_file()
			right_editor.unload_file()
			menu_bar.editor_0_can_open = false
			menu_bar.editor_1_can_open = false
			sbs_open = false
			image_viewer.show()
		return
	
	if ext in Settings.text_file_types or ext.length() == 0:
		right_editor.unload_file()
		image_viewer.hide()
		left_editor.load_file(path, selection_start, selection_end)
		left_editor.show()
		menu_bar.editor_0_can_open = true
		menu_bar.editor_1_can_open = false
		right_editor.hide()
		sbs_open = false
		EditorManager.opened_single.emit()
