extends PopupMenu


func _ready() -> void:
	set_item_accelerator(0, KEY_MASK_ALT | KEY_LEFT)
	set_item_accelerator(1, KEY_MASK_ALT | KEY_RIGHT)
	
	EditorManager.opened_side_by_side.connect(func():
			set_item_disabled(0, false)
			set_item_disabled(1, false)
			
			set_item_checked(0, true)
			set_item_checked(1, true)
			)
	
	EditorManager.opened_single.connect(func():
			set_item_disabled(0, true)
			set_item_disabled(1, true)
			)
