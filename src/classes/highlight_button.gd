@tool
class_name HighlightButton extends Button


static var empty_stylebox: StyleBoxEmpty = null
static var focused_stylebox: StyleBoxFlat = null


static func _static_init() -> void:
	empty_stylebox = StyleBoxEmpty.new()
	empty_stylebox.content_margin_left = 4
	empty_stylebox.content_margin_top = 4
	empty_stylebox.content_margin_right = 4
	empty_stylebox.content_margin_bottom = 4
	
	focused_stylebox = StyleBoxFlat.new()
	focused_stylebox.corner_radius_bottom_left = 4
	focused_stylebox.corner_radius_bottom_right = 4
	focused_stylebox.corner_radius_top_left = 4
	focused_stylebox.corner_radius_top_right = 4
	
	focused_stylebox.content_margin_left = 4
	focused_stylebox.content_margin_top = 4
	focused_stylebox.content_margin_right = 4
	focused_stylebox.content_margin_bottom = 4


func _init() -> void:
	if get_parent() is Control:
		get_parent().theme_changed.connect(_update_styles.call_deferred)
	_update_styles()
	
	add_theme_stylebox_override("disabled", empty_stylebox)
	add_theme_stylebox_override("hover_pressed", empty_stylebox)
	add_theme_stylebox_override("hover", empty_stylebox)
	add_theme_stylebox_override("pressed", empty_stylebox)
	add_theme_stylebox_override("normal", empty_stylebox)
	
	add_theme_stylebox_override("focus", focused_stylebox)


func _update_styles() -> void:
	empty_stylebox = StyleBoxEmpty.new()
	focused_stylebox = StyleBoxUtil.new_flat(Color(1.0, 1.0, 1.0, 0.1), [4], [2])
	
	empty_stylebox.content_margin_left = get_theme_stylebox("normal", "Button").content_margin_left
	empty_stylebox.content_margin_top = get_theme_stylebox("normal", "Button").content_margin_top
	empty_stylebox.content_margin_right = get_theme_stylebox("normal", "Button").content_margin_right
	empty_stylebox.content_margin_bottom = get_theme_stylebox("normal", "Button").content_margin_bottom
