class_name Main extends Control


@onready var nothing_to_show_label: Label = %NothingToShowLabel
@onready var main_container: SplitContainer = %MainContainer
@onready var browser: Browser = %Browser
@onready var editors: RelativeSplitContainer = %Editors
@onready var left_editor: Editor = %LeftEditor
@onready var right_editor: Editor = %RightEditor


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


func open_file(path: String) -> void:
	if path.get_extension() == "":
		return
	editors.show()
	if path.get_extension() in "fshvsh":
		var path_no_ext = path.get_basename()
		left_editor.load_file(path_no_ext + ".fsh")
		right_editor.load_file(path_no_ext + ".vsh")
		right_editor.show()
	else:
		left_editor.load_file(path)
		right_editor.hide()
