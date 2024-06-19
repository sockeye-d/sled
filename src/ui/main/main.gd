class_name Main extends Control


@onready var nothing_to_show_label: Label = %NothingToShowLabel
@onready var main_container: SplitContainer = %MainContainer
@onready var browser: Browser = %Browser
@onready var editors: RelativeSplitContainer = %Editors
@onready var left_editor: Editor = %LeftEditor
@onready var right_editor: Editor = %RightEditor
@onready var image_viewer: ImageViewer = %ImageViewer


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


func open_file(path: String) -> void:
	var ext: String = path.get_extension().to_lower()
	if Settings.sbs_enabled:
		for pair in Settings.sbs_opening_file_exts.split(","):
			var pair_arr: PackedStringArray = pair.split(":", false, 2)
			
			if pair_arr[0].to_lower() == ext or pair_arr[-1].to_lower() == ext:
				editors.show()
				image_viewer.hide()
				var path_no_ext = path.get_basename()
				left_editor.load_file("%s.%s" % [path_no_ext, pair_arr[0]])
				right_editor.load_file("%s.%s" % [path_no_ext, pair_arr[-1]])
				right_editor.show()
				sbs_open = true
				EditorManager.opened_side_by_side.emit()
				return
	
	if ext in Settings.image_file_types.split(",") and ext in ImageViewer.ALLOWED_FILES:
		var err := image_viewer.load_image(path)
		NotificationManager.notify_if_err(err, "Opened %s" % path.get_file(), "Failed to open %s with error %s" % [path.get_file(), "%s"], true)
		if not err:
			editors.hide()
			sbs_open = false
			image_viewer.show()
		return
	
	if ext in Settings.text_file_types:
		editors.show()
		image_viewer.hide()
		left_editor.load_file(path)
		right_editor.hide()
		sbs_open = false
		EditorManager.opened_single.emit()
