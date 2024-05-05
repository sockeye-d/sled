extends RichTextLabel


func _ready() -> void:
	mouse_entered.connect(
		func():
			create_tween().tween_property(self, "modulate:a", 0.75, 0.5) \
			.set_trans(Tween.TRANS_EXPO) \
			.set_ease(Tween.EASE_OUT) \
			)
	
	mouse_exited.connect(
		func():
			create_tween().tween_property(self, "modulate:a", 0.25, 0.5) \
			.set_trans(Tween.TRANS_EXPO) \
			.set_ease(Tween.EASE_OUT) \
			)
	gui_input.connect(
		func(input: InputEvent):
			if input is InputEventMouseButton:
				if input.button_mask & MOUSE_BUTTON_MASK_LEFT:
					OS.shell_open("https://github.com/sockeye-d/sled")
					)
