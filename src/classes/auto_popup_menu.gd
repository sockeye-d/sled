class_name AutoPopupMenu extends PopupMenu


func _init() -> void:
	child_entered_tree.connect(
			func(node: Node):
				if node is PopupMenu:
					for item in item_count:
						if get_item_text(item) == node.name:
							remove_item(item)
					add_submenu_node_item(node.name, node)
					)
