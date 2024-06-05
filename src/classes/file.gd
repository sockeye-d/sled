class_name File extends Object


const NULL = ""


static func save_variant(path: String, variant) -> Error:
	var fa := FileAccess.open(path, FileAccess.WRITE_READ)
	fa.store_var(variant)
	fa.close()
	return fa.get_error()


static func load_variant(path: String, default = null) -> Variant:
	var fa := FileAccess.open(path, FileAccess.READ)
	
	if fa == null:
		return default
	
	return fa.get_var()


static func get_text(path: String, skip_cr: bool = true) -> String:
	var handle = FileAccess.open(path, FileAccess.READ)
	return handle.get_as_text(skip_cr) if handle else ""
