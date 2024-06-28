class_name DictionaryUtil


static func flip(dict: Dictionary) -> Dictionary:
	var new_dict: Dictionary = { }
	for key in dict:
		new_dict[dict[key]] = key
	return new_dict


static func erase_all(dictionary: Dictionary, eraser: Dictionary) -> void:
	for key in eraser:
		dictionary.erase(key)
