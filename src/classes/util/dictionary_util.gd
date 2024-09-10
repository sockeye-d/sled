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


static func get_dictionary_type(dictionary: Dictionary) -> String:
	if not dictionary.is_typed():
		return "Dictionary"
	var tkey = dictionary.get_typed_key_builtin()
	var tvalue = dictionary.get_typed_value_builtin()
	if tkey == TYPE_OBJECT:
		if dictionary.get_typed_key_script() and dictionary.get_typed_key_script().get_global_name():
			tkey = dictionary.get_typed_key_script().get_global_name()
		else:
			tkey = dictionary.get_typed_key_class_name()
	else:
		tkey = type_string(tkey)
	if tvalue == TYPE_OBJECT:
		if dictionary.get_typed_value_script() and dictionary.get_typed_value_script().get_global_name():
			tvalue = dictionary.get_typed_value_script().get_global_name()
		else:
			tvalue = dictionary.get_typed_value_class_name()
	else:
		tvalue = type_string(tvalue)
	return "Dictionary[%s, %s]" % [tkey, tvalue]


static func untype(typed_dictionary: Dictionary) -> Dictionary:
	var untyped_dictionary: Dictionary
	untyped_dictionary.assign(typed_dictionary)
	return untyped_dictionary
