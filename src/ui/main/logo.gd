extends RichTextLabel


func _ready() -> void:
	mouse_entered.connect(
		func():
			(create_tween().tween_property(self, "modulate:a", 0.75, 0.5)
			.set_trans(Tween.TRANS_EXPO)
			.set_ease(Tween.EASE_OUT))
	)
	
	mouse_exited.connect(
		func():
			(create_tween().tween_property(self, "modulate:a", 0.25, 0.5)
			.set_trans(Tween.TRANS_EXPO)
			.set_ease(Tween.EASE_OUT))
	)
