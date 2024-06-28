extends PopupMenu


func _ready() -> void:
	set_item_accelerator(0, InputUtil.MASK_CMD_OR_CTRL | KEY_P)
