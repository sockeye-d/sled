extends Node


func _ready() -> void:
	get_tree().node_added.connect(
			(func(node: Node):
				if (
					node is Label
					and node.get_parent() is PopupPanel
					and node.get_parent().theme_type_variation == "TooltipPanel"
					):
					var p: PopupPanel = node.get_parent()
					var new_label := RichTextLabel.new()
					new_label.bbcode_enabled = true
					
					var text = StringUtil.word_wrap(node.text.replace("\n", "\n\n"), 80)

					new_label.text = text
					new_label.scroll_active = false
					new_label.fit_content = true
					new_label.autowrap_mode = TextServer.AUTOWRAP_OFF
					new_label.visible_ratio = 1.0
					new_label.modulate.a = 0.0
					
					new_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
					
					
					p.add_child(new_label)
					# Hide instead of freeing to avoid artifacts
					node.hide()
					new_label.update_minimum_size()
					
					await RenderingServer.frame_post_draw
					
					p.max_size.x = new_label.get_minimum_size().x + 16
					
					# Fanciness
					new_label.visible_ratio = 0.0
					new_label.modulate.a = 1.0
					var t = new_label.create_tween()
					t.tween_property(new_label, "visible_ratio", 1.0, 0.0025 * text.length())
					
					).call_deferred
					)
