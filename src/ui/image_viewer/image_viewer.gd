class_name ImageViewer extends PanelContainer


const ALLOWED_FILES: PackedStringArray = ["bmp", "dds", "ktx", "exr", "jpg", "png", "tga", "svg", "webp"]


@onready var image_display: TextureRect = %ImageDisplay
@onready var pan_zoom_scroll_container: PanZoomScrollContainer = %PanZoomScrollContainer
@onready var info_label: Label = %InfoLabel
@onready var zoom_label: Label = %ZoomLabel
@onready var filter_dropdown: OptionButton = %FilterDropdown


@onready var formats := ClassDB.class_get_enum_constants("Image", "Format")


func _ready() -> void:
	pan_zoom_scroll_container.zoomed.connect(func(new_zoom: float): zoom_label.text = str(floorf(new_zoom * 100.0)) + "%")


func load_image(path: String) -> Error:
	var img := Image.new()
	var err: Error = img.load(path)
	if not img:
		return err
	
	image_display.texture = ImageTexture.create_from_image(img)
	
	info_label.text = "%s×%s@%s" % [img.get_width(), img.get_height(), formats[img.get_format()].trim_prefix("FORMAT_").strip_edges()]
	
	return OK


func _on_filter_dropdown_item_selected(index: int) -> void:
	(image_display.material as ShaderMaterial).set_shader_parameter(&"filter", index)


func _on_channel_dropdown_item_selected(index: int) -> void:
	(image_display.material as ShaderMaterial).set_shader_parameter(&"channel", index)
