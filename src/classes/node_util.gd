@tool
class_name NodeUtil extends Object


static func free_children(node: Node, include_internal: bool = false) -> void:
	if not node:
		return
	
	for child in node.get_children(include_internal):
		child.queue_free()
