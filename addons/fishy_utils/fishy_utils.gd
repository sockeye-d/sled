@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_tool_menu_item("Copy scene unique nodes",
			func():
				DisplayServer.clipboard_set(_get_var(EditorInterface.get_edited_scene_root()))
				)


func _exit_tree() -> void:
	remove_tool_menu_item("Copy scene unique nodes")


func _get_var(node: Node) -> String:
	var str: String = ""
	for child in node.get_children():
		if child.unique_name_in_owner:
			var type: String = ""
			if child.get_script() and child.get_script().get_global_name():
				type = child.get_script().get_global_name()
			else:
				type = child.get_class()
			str += "@onready var %s: %s = %%%s\n" % [child.name.to_snake_case(), type, child.name]
		
		str += _get_var(child)
	
	return str
