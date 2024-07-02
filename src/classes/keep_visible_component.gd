@tool
class_name KeepVisibleComponent extends Node


func _ready() -> void:
	get_parent().child_entered_tree.connect(func(child: Node) -> void:
		if child is CanvasItem:
			if not child.visibility_changed.is_connected(_update_visibility):
				child.visibility_changed.connect(_update_visibility)
	)
	for child_ut in get_parent().get_children():
		if child_ut is CanvasItem:
			var child := child_ut as CanvasItem
			if not child.visibility_changed.is_connected(_update_visibility):
				child.visibility_changed.connect(_update_visibility)


func _update_visibility() -> void:
	var new_visible := false
	for child in get_parent().get_children():
		if not child is CanvasItem:
			continue
		new_visible = new_visible or child.visible
	get_parent().visible = new_visible
