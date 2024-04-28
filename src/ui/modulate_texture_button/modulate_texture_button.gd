@tool
class_name ModulateTextureButton extends TextureButton


@export var texture: Texture2D:
	set(value):
		texture_normal = value
		texture = value
	get:
		return texture


func _init() -> void:
	modulate.a = 0.5
	mouse_entered.connect(func(): modulate.a += 0.2)
	mouse_exited.connect(func(): modulate.a -= 0.2)
	button_down.connect(func(): modulate.a += 0.3)
	button_up.connect(func(): modulate.a -= 0.3)
