class_name TwoWayDictionary extends RefCounted


var keys_dict: Dictionary
var values_dict: Dictionary


func _init(dictionary: Dictionary = { }) -> void:
	keys_dict = { }
	values_dict = { }
	if dictionary:
		for key in dictionary:
			add(key, dictionary[key])


func has_key(key: Variant) -> bool:
	return values_dict.has(key)


func has_value(value: Variant) -> bool:
	return keys_dict.has(value)


func get_value(key: Variant) -> Variant:
	return keys_dict[key]


func get_key(value: Variant) -> Variant:
	return values_dict[value]


func add(key: Variant, value: Variant) -> void:
	keys_dict[key] = value
	values_dict[value] = key


func erase_key(key: Variant) -> void:
	var value = keys_dict[key]
	keys_dict.erase(key)
	values_dict.erase(value)


func erase_value(value: Variant) -> void:
	var key = values_dict[value]
	values_dict.erase(value)
	keys_dict.erase(key)


func clear() -> void:
	keys_dict.clear()
	values_dict.clear()
