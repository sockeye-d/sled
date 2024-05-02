@tool
class_name RelativeSplitContainer extends SplitContainer


@export_range(0.0, 1.0, 0.001) var relative_split_offset: float:
	set(value):
		relative_split_offset = value
		split_offset = relative_split_offset * (size.y if vertical else size.x)
	get:
		return relative_split_offset


func _init() -> void:
	dragged.connect(
			func(offset: int):
				relative_split_offset = offset / (size.y if vertical else size.x)
				)
	resized.connect(
			func():
				split_offset = relative_split_offset * (size.y if vertical else size.x)
				)
