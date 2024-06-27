@tool
extends Node


signal process_frame
var root: Window


func _ready() -> void:
	get_tree().process_frame.connect(process_frame.emit)
	root = get_tree().root
