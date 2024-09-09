@tool
class_name NotificationLabel extends Label


const NOTIFICATION_LABEL_MATERIAL = preload("res://src/shaders/notification_label_material.tres")


@export var fade_in_time: float = 1.0
@export var hold_time: float = 1.5
@export var fade_out_time: float = 1.0


var tween: Tween


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	#material = NOTIFICATION_LABEL_MATERIAL
	if not Engine.is_editor_hint():
		mouse_entered.connect(func():
			tween.stop()
			tween = create_tween()
			(
				tween.tween_property(self, ^"modulate:a", 1.0, fade_in_time)
				.set_trans(Tween.TRANS_EXPO)
				.set_ease(Tween.EASE_OUT)
			)
		)
		mouse_exited.connect(func():
			tween.stop()
			tween = create_tween()
			tween.tween_property(self, ^"modulate:a", 0.0, fade_out_time)
			tween.tween_callback(queue_free)
		)
		tween = create_tween()
		modulate.a = 0.0
		(
			tween.tween_property(self, ^"modulate:a", 1.0, fade_in_time)
			.set_trans(Tween.TRANS_EXPO)
			.set_ease(Tween.EASE_OUT)
		)
		tween.tween_interval(hold_time)
		tween.tween_property(self, ^"modulate:a", 0.0, fade_out_time)
		tween.tween_callback(queue_free)
