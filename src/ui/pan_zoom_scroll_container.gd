@tool
class_name PanZoomScrollContainer extends ScrollContainer


enum ZoomMode {
	LINEAR,
	EXPONENTIAL,
}


signal zoomed(new_zoom: float)


const DRAG_NONE = Vector2(-1, -1)


@export var zoom: float = 1.0:
	get:
		return zoom
	set(value):
		zoom = value
		if target:
			target.custom_minimum_size = get_rect().size * zoom
@export var zoom_mode: ZoomMode
@export var zoom_step: float = 0.0
@export var zoom_min: float
@export var zoom_max: float
@export var target: Control:
	get:
		return target
	set(value):
		target = value
		if target:
			target.custom_minimum_size = get_rect().size * zoom


func _ready() -> void:
	resized.connect(func(): target.custom_minimum_size = get_rect().size * zoom)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			scroll_horizontal -= event.relative.x
			scroll_vertical -= event.relative.y
			get_tree().root.set_input_as_handled()
	if event is InputEventMouseButton:
		if event.is_command_or_control_pressed():
			match event.button_index:
				MOUSE_BUTTON_WHEEL_DOWN:
					change_zoom(-event.factor)
					get_tree().root.set_input_as_handled()
				MOUSE_BUTTON_WHEEL_UP:
					change_zoom(event.factor)
					get_tree().root.set_input_as_handled()


func change_zoom(fac: float, toward_mouse: bool = true) -> void:
	var new_zoom: float = zoom
	match zoom_mode:
		ZoomMode.LINEAR:
			new_zoom += fac * zoom_step
		ZoomMode.EXPONENTIAL:
			new_zoom *= exp(fac * zoom_step)
	zoom = clampf(new_zoom, zoom_min, zoom_max)
