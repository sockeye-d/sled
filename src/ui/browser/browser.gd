class_name Browser extends Control


@export var path: String


@onready var browser_tree: BrowserTree = %BrowserTree


func _ready() -> void:
	refresh_tree()


func refresh_tree() -> void:
	browser_tree.populate_tree(path)
