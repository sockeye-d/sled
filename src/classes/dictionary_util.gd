class_name DictionaryUtil


static func flip(dict: Dictionary) -> Dictionary:
	var new_dict: Dictionary = { }
	for key in dict:
		new_dict[dict[key]] = key
	return new_dict


static func erase_all(dictionary: Dictionary, eraser: Dictionary) -> void:
	for key in eraser:
		dictionary.erase(key)


static func custom_merge(dictionary_a: Dictionary, dictionary_b: Dictionary, merger: Callable) -> void:
	for key in dictionary_a:
		assert(key in dictionary_b)
		dictionary_a[key] = merger.call(dictionary_a[key], dictionary_b[key], key)
