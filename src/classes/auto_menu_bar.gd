class_name AutoMenuBar extends MenuBar


func _init() -> void:
	child_entered_tree.connect(
			func(child: Node):
				if child is PopupMenu:
					child.index_pressed.connect(func(index: int): _item_pressed(child.name, index))
					)


func _item_pressed(_menu_name: String, _index: int) -> void:
	pass
