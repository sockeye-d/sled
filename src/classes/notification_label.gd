class_name NotificationLabel extends Label


const NOTIFICATION_LABEL_MATERIAL = preload("res://src/shaders/notification_label_material.tres")


@export var fade_in_time: float = 0.0
@export var hold_time: float = 1.5
@export var fade_out_time: float = 1.0


func _ready() -> void:
	material = NOTIFICATION_LABEL_MATERIAL
	var tween = create_tween()
	modulate.a = 0.0
	tween.tween_property(self, ^"modulate:a", 1.0, fade_in_time)
	tween.tween_interval(hold_time)
	tween.tween_property(self, ^"modulate:a", 0.0, fade_out_time)
	tween.tween_callback(queue_free)
