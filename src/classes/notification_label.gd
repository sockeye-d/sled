class_name NotificationLabel extends Label


const NOTIFICATION_LABEL_MATERIAL = preload("res://src/shaders/notification_label_material.tres")


@export var fade_in_time: float = 0.0
@export var hold_time: float = 1.5
@export var fade_out_time: float = 1.0


@onready var tween: Tween = create_tween()


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	material = NOTIFICATION_LABEL_MATERIAL
	mouse_entered.connect(func():
		tween.stop()
		modulate.a = 1.0
		)
	mouse_exited.connect(func():
		tween.play()
		tween.tween_property(self, ^"modulate:a", 0.0, fade_out_time)
		tween.tween_callback(queue_free)
		)
	modulate.a = 0.0
	tween.tween_property(self, ^"modulate:a", 1.0, fade_in_time)
	tween.tween_interval(hold_time)
	tween.tween_property(self, ^"modulate:a", 0.0, fade_out_time)
	tween.tween_callback(queue_free)
