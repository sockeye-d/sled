class_name ViewPopupMenu extends PopupMenu


func _ready() -> void:
	set_item_accelerator(0, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_LEFT)
	set_item_accelerator(1, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_RIGHT)
	set_item_accelerator(2, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_UP)
	set_item_accelerator(3, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_DOWN)
	
	#EditorManager.opened_side_by_side.connect(func():
			#set_item_disabled(0, false)
			#set_item_disabled(1, false)
			#
			#set_item_checked(0, true)
			#set_item_checked(1, true)
			#
			#set_item_disabled(2, false)
	#)
	#
	#EditorManager.opened_single.connect(func():
			#set_item_disabled(0, true)
			#set_item_disabled(1, true)
			#set_item_disabled(2, false)
	#)
	#
	#EditorManager.opened_search_panel.connect(func():
			#set_item_disabled(3, false)
	#)
	
	#EditorManager.view_menu_state_change_requested.connect(func(index: int, state: bool):
			#if is_item_checked(index) and not state:
				#set_item_checked(index, false)
			#if not state:
				#set_item_disabled(1 - index, true)
			#set_item_disabled(index, not state)
	#)


func get_sum(predicate := self.is_item_checked) -> int:
	return range(item_count).reduce(func(accum: int, current: int) -> int: return accum + int(predicate.call(current)), 0)
