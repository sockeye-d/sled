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
