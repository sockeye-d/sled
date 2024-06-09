class_name DictionaryUtil


static func flip(dict: Dictionary) -> Dictionary:
	var new_dict: Dictionary = { }
	for key in dict:
		new_dict[dict[key]] = key
	return new_dict
