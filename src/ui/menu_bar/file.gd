extends AutoPopupMenu


func _ready() -> void:
	set_item_accelerator(0, KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S)
