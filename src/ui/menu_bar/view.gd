class_name ViewPopupMenu extends PopupMenu


func _ready() -> void:
	set_item_accelerator(0, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_LEFT)
	set_item_accelerator(1, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_RIGHT)
	set_item_accelerator(2, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_UP)
	set_item_accelerator(3, KEY_MASK_CTRL | KEY_MASK_ALT | KEY_DOWN)
	
	EditorManager.opened_side_by_side.connect(func():
			set_item_disabled(0, false)
			set_item_checked(0, true)
			set_item_disabled(1, false)
			set_item_checked(1, true)
			refresh_disabled()
	)
	#
	EditorManager.opened_single.connect(func():
			set_item_disabled(1, true)
			set_item_checked(1, false)
			set_item_disabled(0, false)
			set_item_checked(0, true)
			refresh_disabled()
	)
	
	EditorManager.search_visible_change_requested.connect(func(panel_visible: bool):
			set_item_checked(3, panel_visible)
			refresh_disabled()
	)
	
	EditorManager.view_menu_state_change_requested.connect(func(index: int, state: bool):
			set_item_checked(index, state)
			refresh_disabled()
	)


func get_sum(predicate := self.is_item_checked) -> int:
	return range(item_count).reduce(func(accum: int, current: int) -> int: return accum + int(predicate.call(current)), 0)


func refresh_disabled() -> void:
	var checked_sum := get_sum()
	if checked_sum == 0 or (checked_sum == 1 and is_item_checked(2)):
		EditorManager.change_browser_visibility(true)
		set_item_checked(2, true)
		set_item_disabled(2, true)
	else:
		set_item_disabled(2, false)
