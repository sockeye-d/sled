@tool
class_name ControlArrow extends Control


enum SnapMode {
	AUTOMATIC,
	MANUAL,
}


@export var start_control: Control
@export var end_control: Control
@export var arrow_size: Vector2 = Vector2(10.0, 10.0)
@export var label: String

@export var snap_mode: SnapMode:
	set(value):
		notify_property_list_changed()
		snap_mode = value

@export_range(0.0, 1.0, 0.01, "or_greater", "or_less") var start_x_snap: float
@export_range(0.0, 1.0, 0.01, "or_greater", "or_less") var start_y_snap: float
@export_range(0.0, 1.0, 0.01, "or_greater", "or_less") var end_x_snap: float
@export_range(0.0, 1.0, 0.01, "or_greater", "or_less") var end_y_snap: float


func _process(delta: float) -> void:
	queue_redraw()


func _validate_property(property: Dictionary) -> void:
	if property.name in [
			&"start_x_snap",
			&"start_y_snap",
			&"end_x_snap",
			&"end_y_snap",
		]:
			if snap_mode == SnapMode.AUTOMATIC:
				property.usage &= ~PROPERTY_USAGE_EDITOR
			else:
				property.usage |= PROPERTY_USAGE_EDITOR


func _draw() -> void:
	if start_control and end_control and start_control.is_inside_tree() and end_control.is_inside_tree():
		if snap_mode == SnapMode.AUTOMATIC:
			var d := end_control.get_global_rect().get_center() - start_control.get_global_rect().get_center()
			if absf(d.y) < absf(d.x):
				start_x_snap = signf(d.x - 0.5) * 0.5 + 0.5
				end_x_snap = 1.0 - start_x_snap
				start_y_snap = 0.5
				end_y_snap = 0.5
			else:
				start_x_snap = 0.5
				end_x_snap = 0.5
				start_y_snap = signf(d.y - 0.5) * 0.5 + 0.5
				end_y_snap = 1.0 - start_y_snap
		
		var start_pos := start_control.global_position + start_control.size * Vector2(start_x_snap, start_y_snap)
		var end_pos := end_control.global_position + end_control.size * Vector2(end_x_snap, end_y_snap)
		var start_end_vec := (end_pos - start_pos).normalized()
		
		var min_rect := Rect2(start_pos, end_pos - start_pos)
		if min_rect.size.x < 0.0 or min_rect.size.y < 0.0:
			min_rect = min_rect.abs()
		global_position = min_rect.position
		size = min_rect.size
		draw_set_transform_matrix(get_global_transform().affine_inverse())
		draw_line(start_pos, end_pos.move_toward(start_pos, arrow_size.y), Color.BLACK, 2.0, true)
		var tri_points: PackedVector2Array
		for tri_point in [
				Vector2(0, 0),
				Vector2(-0.5, -1.0),
				Vector2(+0.5, -1.0),
			]:
				var tx2d := Transform2D(start_end_vec.rotated(PI / 2) * arrow_size.x, start_end_vec * arrow_size.y, end_pos)
				tri_points.append(tx2d * tri_point)
		draw_colored_polygon(tri_points, Color.BLACK)
		draw_set_transform_matrix(Transform2D.IDENTITY)
		var font := get_theme_font("font", "Label")
		var string_size := font.get_string_size(label)
		string_size.y = -string_size.y * 0.5
		draw_string_outline(font, (start_pos - global_position) + (end_pos - start_pos) * 0.5 - string_size * 0.5, label, 0, -1, 16, 10, Color.BLACK)
		draw_string(font, (start_pos - global_position) + (end_pos - start_pos) * 0.5 - string_size * 0.5 , label)
