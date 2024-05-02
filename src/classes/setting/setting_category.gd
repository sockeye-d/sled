class_name SettingCategory extends Resource


@export var name: String
@export var settings: Array[SettingItem]


func _init(_name: String = "", _settings: Array[SettingItem] = []) -> void:
	name = _name
	settings = _settings
