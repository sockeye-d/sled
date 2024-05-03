class_name File extends Object


const NULL = ""


static func save_variant(path: String, variant) -> Error:
	var fa := FileAccess.open(path, FileAccess.WRITE_READ)
	fa.store_var(variant)
	fa.close()
	return fa.get_error()


static func load_variant(path: String, default) -> Variant:
	var fa := FileAccess.open(path, FileAccess.READ)
	
	if fa == null:
		return default
	
	return fa.get_var()
