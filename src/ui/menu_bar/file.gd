extends AutoPopupMenu


func _ready() -> void:
	set_item_accelerator(0, KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_S)
	set_item_accelerator(1, KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_O)
	set_item_accelerator(2, KEY_MASK_CTRL | KEY_K)
