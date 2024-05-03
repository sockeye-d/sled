class_name AutoMenuBar extends MenuBar


func _ready() -> void:
	_connect_children()


func _connect_children(node: Node = self):
	for child in node.get_children():
		if child is PopupMenu:
			child.index_pressed.connect(func(index: int): _item_pressed(String(get_path_to(child)), index))
		_connect_children(child)


func _item_pressed(_menu_name: String, _index: int) -> void:
	pass
