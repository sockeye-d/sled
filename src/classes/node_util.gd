@tool
class_name NodeUtil extends Object


static func free_children(node: Node, include_internal: bool = false) -> void:
	if not node:
		return
	
	for child in node.get_children(include_internal):
		child.queue_free()


static func foreach_child(node: Node, fn: Callable, include_internal := false) -> void:
	for child in node.get_children(include_internal):
		fn.call(child)
		NodeUtil.foreach_child(child, fn, include_internal)
