extends Node


signal process_frame


func _ready() -> void:
	get_tree().process_frame.connect(process_frame.emit)
