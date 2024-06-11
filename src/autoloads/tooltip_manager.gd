extends Node


func _ready() -> void:
	#get_tree().node_added.connect(
			#func(node: Node):
				#if node is Control:
					#node.tooltip_text = StringUtil.word_wrap(node.tooltip_text, 10).strip_edges()
				#)
	get_tree().node_added.connect(
			func(node: Node):
				if (
					node is Label
					and node.get_parent() is PopupPanel
					and node.get_parent().theme_type_variation == "TooltipPanel"
					):
					var p: PopupPanel = node.get_parent()
					var new_label := RichTextLabel.new()
					new_label.add_theme_color_override(&"default_color", EditorThemeManager.theme.get_color(&"font_color", &"TooltipLabel"))
					
					new_label.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
					new_label.append_text(node.text)
					new_label.scroll_active = false
					new_label.fit_content = true
					new_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
					#new_label.size.x = 100
					#new_label.size.y = 200
					new_label.finished.connect(func():
						print(new_label.get_content_width(), ", ", new_label.get_content_height())
						new_label.custom_minimum_size.x = new_label.get_content_width()
						new_label.custom_minimum_size.y = new_label.get_content_height()
					)
					
					new_label.visible_ratio = 1.0
					new_label.modulate.a = 1.0
					
					new_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
					await p.ready
					# Hide instead of freeing to avoid artifacts
					#node.hide()
					node.queue_free()
					p.add_child(new_label)
					new_label.update_minimum_size()
					
					await RenderingServer.frame_pre_draw
					#
					if not p:
						return
					p.max_size.x = new_label.get_combined_minimum_size().x + 10.0
				)
