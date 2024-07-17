class_name PopupWindow extends Window


@export var hide_on_lost_focus: bool = true
@export var hide_on_close_requested: bool = true


func _init() -> void:
	close_requested.connect(_on_close_requested)
	focus_exited.connect(_on_lost_focus)


func _on_close_requested() -> void:
	if hide_on_close_requested:
		hide()


func _on_lost_focus() -> void:
	if hide_on_lost_focus:
		hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel", false, true):
		hide()
