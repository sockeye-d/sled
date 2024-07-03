class_name ViewPopupMenu extends PopupMenu


func _ready() -> void:
	set_item_accelerator(0, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_LEFT)
	set_item_accelerator(1, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_RIGHT)
	set_item_accelerator(2, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_UP)
	set_item_accelerator(3, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_DOWN)
	
	EditorManager.opened_side_by_side.connect(func():
			set_item_disabled(1, false)
	)
	#
	EditorManager.opened_single.connect(func():
			set_item_disabled(1, true)
			set_item_checked(1, false)
	)
	#
	#EditorManager.opened_search_panel.connect(func():
			#set_item_disabled(3, false)
	#)
	
	EditorManager.view_menu_state_change_requested.connect(func(index: int, state: bool):
			set_item_checked(index, false)
	)


func get_sum(predicate := self.is_item_checked) -> int:
	return range(item_count).reduce(func(accum: int, current: int) -> int: return accum + int(predicate.call(current)), 0)
