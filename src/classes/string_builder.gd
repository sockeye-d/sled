class_name StringBuilder extends RefCounted
## Watered-down GDScript version of C#'s excellent StringBuilder class


var _array: PackedStringArray

var internal_length: int:
	get:
		return _array.size()
var length: int:
	get:
		return Array(_array).reduce(func(accum: int, string: String): return accum + string.length())

func _init(string := "", size: int = 0) -> void:
	if string:
		_array = [string]
	else:
		_array = []
		_array.resize(size)


func append(string: String) -> void:
	_array.append(string)


func append_line(string: String) -> void:
	_array.append(string + "\n")


func clear() -> void:
	_array.clear()


func _to_string() -> String:
	return "".join(_array)
