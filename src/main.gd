class_name Main extends Control


@onready var browser: Browser = %Browser
@onready var editor: Editor = %Editor


func _on_browser_file_opened(path: String) -> void:
	editor.load_file(path)
