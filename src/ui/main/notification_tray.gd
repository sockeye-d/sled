@tool
class_name NotificationTray extends Container


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_sort()
	if what == NOTIFICATION_THEME_CHANGED:
		queue_sort()


func _sort() -> void:
	var right_pos := size.x
	for child_control: Control in get_children().filter(
		func(child): return child is Control
	):
		var child_min_size := child_control.get_combined_minimum_size()
		var child_rect := Rect2(Vector2(right_pos - child_min_size.x, position.y), child_min_size)
		fit_child_in_rect(child_control, child_rect)
		right_pos -= child_min_size.x + get_theme_constant(&"separation", &"NotificationTray")


func _get_minimum_size() -> Vector2:
	return Vector2.ZERO
