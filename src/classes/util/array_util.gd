class_name ArrayUtil extends Object


static func swap(array: Array, a: int, b: int) -> Array:
	if a == b:
		push_error("Indices cannot be equal")
		return array
	var temp = array[a]
	array[a] = array[b]
	array[b] = temp
	return array


static func index_wrap(array: Array, index: int) -> Variant:
	return array[posmod(index, array.size())]


static func to_string_array(array: Array) -> PackedStringArray:
	return PackedStringArray(array.map(func(elem): return str(elem)))


static func join_line(array: PackedStringArray) -> String:
	return "\n".join(array)


static func foreach(array: Array, fn: Callable) -> void:
	for e in array:
		fn.call(e)

## Like [member foreach] but [param fn] takes two parameters: the current
## element, and the index
static func foreach_i(array: Array, fn: Callable) -> void:
	var i := 0
	for e in array:
		fn.call(e, i)
		i += 1


static func map_in_place_s(array: PackedStringArray, fn: Callable) -> void:
	for i in array.size():
		array[i] = fn.call(array[i])

## TODO: incomplete method??
#static func remove_s(array: PackedStringArray, fn: Callable) -> void:
	#var new_array: PackedStringArray = []
	#new_array.resize(array.size())
	#var used_elements: int = 0
	#for i in array.size():
		#if fn.call(array[i]):
			#new_array

## If the selector returns a single value, the key will be the result of the
## function call and the key will be the element
## [br]
## If it returns an array, the key will be the first element and the value will
## be the second
static func create_dictionary(array: Array, selector: Callable) -> Dictionary:
	var d: Dictionary = { }
	for element in array:
		d[selector.call(element)] = element
	return d

## Creates a set out of an array so that contains checks are faster
static func create_set(array: Array) -> Dictionary:
	var d := { }
	for e in array:
		d[e] = null
	return d
