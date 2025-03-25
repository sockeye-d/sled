extends Node


@export_multiline var test_string: String


const CELL = "[cell padding=1,0,1,0 border=#AAAAAA12]"


func _ready() -> void:
	var parse_tree := GLSLLanguage.parse(test_string)
	print(test_string, " -> ", parse_tree)
