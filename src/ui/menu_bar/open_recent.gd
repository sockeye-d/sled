extends PopupMenu


func _ready() -> void:
	FileManager.changed_paths.connect(func(): _refresh_recently_opened())


func _refresh_recently_opened():
	clear()
	for dir in FileManager.last_opened_paths:
		add_item(dir)
	add_item("Clear recent")
