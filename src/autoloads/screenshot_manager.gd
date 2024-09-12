extends Node


func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"take_screenshot", true):
		screenshot_all()


func screenshot_all(node: Node = get_tree().root) -> void:
	if node is Viewport:
		screenshot(node)
	for child in node.get_children(true):
		if not child.get("visible"):
			continue
		screenshot_all(child)


func screenshot(node: Viewport) -> void:
	var path := ProjectSettings.globalize_path("user://screenshots/%s_%s.webp") % [
		node.name,
		Time.get_datetime_string_from_system().replace(":", "_"),
	]
	
	if not DirAccess.dir_exists_absolute(path.get_base_dir()):
		DirAccess.make_dir_absolute(path.get_base_dir())
	
	var err := node.get_texture().get_image().save_webp(path, true)
	if err:
		NotificationManager.notify(
			"Failed to take screenshot",
			NotificationManager.TYPE_ERROR,
		)
	else:
		NotificationManager.notify(
			"Saved screenshot to '%s'" % path,
			NotificationManager.TYPE_NORMAL,
		)
