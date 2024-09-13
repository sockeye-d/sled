class_name SettingCategoryContainer extends Resource


@export var setting_categories: Array[SettingCategory]


func _to_string() -> String:
	return "\n".join(setting_categories)
