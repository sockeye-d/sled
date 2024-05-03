extends PopupMenu


func _ready() -> void:
	FileManager.paths_changed.connect(func(): _refresh_recently_opened())
	_refresh_recently_opened()


func _refresh_recently_opened():
	clear()
	for dir in FileManager.last_opened_paths:
		add_item(dir)
	add_item("Clear recent")
