class_name Util


func def(value, default_value):
	if value:
		return value
	return default_value


static func get_caret_index(code_edit: CodeEdit, caret_index: int = 0) -> int:
	return StringUtil.get_index(code_edit.text, code_edit.get_caret_line(caret_index), code_edit.get_caret_column(caret_index))
