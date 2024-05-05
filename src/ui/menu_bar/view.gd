extends PopupMenu


func _ready() -> void:
	set_item_accelerator(0, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_LEFT)
	set_item_accelerator(1, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_RIGHT)
	set_item_accelerator(2, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_DOWN)
	
	EditorManager.opened_side_by_side.connect(func():
			set_item_disabled(0, false)
			set_item_disabled(1, false)
			
			set_item_checked(0, true)
			set_item_checked(1, true)
			
			set_item_disabled(2, false)
			)
	
	EditorManager.opened_single.connect(func():
			set_item_disabled(0, true)
			set_item_disabled(1, true)
			set_item_disabled(2, false)
			)
