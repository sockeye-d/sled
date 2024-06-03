class_name InputUtil extends Object


static func is_pressed_repeating(event: InputEventKey, action: StringName) -> bool:
	var keys := InputMap.action_get_events(action)
	return false
