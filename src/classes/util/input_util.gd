class_name InputUtil extends Object


static var MASK_CMD_OR_CTRL: int


static func _static_init() -> void:
	if OS.get_name() == "macOS":
		MASK_CMD_OR_CTRL = KEY_MASK_META
	else:
		MASK_CMD_OR_CTRL = KEY_MASK_CTRL
