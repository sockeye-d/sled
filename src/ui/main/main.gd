class_name Main extends Control


@onready var browser: Browser = %Browser
@onready var left_editor: Editor = %LeftEditor
@onready var right_editor: Editor = %RightEditor


func _on_browser_file_opened(path: String) -> void:
	if path.get_extension() == "":
		return
	if path.get_extension() in "fshvsh":
		var path_no_ext = path.get_basename()
		left_editor.load_file(path_no_ext + ".fsh")
		right_editor.load_file(path_no_ext + ".vsh")
		right_editor.show()
	else:
		left_editor.load_file(path)
		right_editor.hide()
