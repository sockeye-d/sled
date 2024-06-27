@tool
class_name NodeUtil extends Object


const _CALLABLE_EMPTY := Callable()


static func free_children(node: Node, include_internal: bool = false) -> void:
	if not node:
		return
	
	for child in node.get_children(include_internal):
		child.queue_free()

## Returns a list of all the removed nodes
## [param predicate] should return true if the node is to be removed, false if not
static func remove_children(node: Node, deep: bool = false, include_internal: bool = false, predicate: Callable = _CALLABLE_EMPTY) -> Array[Node]:
	var arr: Array[Node] = []
	if not node:
		return []
	
	for child in node.get_children(include_internal):
		if predicate != _CALLABLE_EMPTY:
			if not predicate.call(child):
				continue
		node.remove_child(child)
		arr.append(child)
		if deep:
			arr.append_array(NodeUtil.remove_children(child, deep, include_internal))
	return arr


static func foreach_child(node: Node, fn: Callable, include_internal := false) -> void:
	for child in node.get_children(include_internal):
		fn.call(child)
		NodeUtil.foreach_child(child, fn, include_internal)
