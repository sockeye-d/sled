extends Node


func _ready() -> void:
	get_tree().node_added.connect(
			func(node: Node):
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
					
					# Hide instead of freeing to avoid artifacts
					node.hide()
					p.add_child.call_deferred(new_label)
					new_label.update_minimum_size.call_deferred()
					
					await get_tree().process_frame
					
					if not p:
						return
					
					p.max_size.x = new_label.get_minimum_size().x + 16
					
					# Fanciness
					new_label.visible_ratio = 0.0
					new_label.modulate.a = 1.0
					new_label.create_tween().tween_property(new_label, "visible_ratio", 1.0, 0.0025 * text.length())
					)
