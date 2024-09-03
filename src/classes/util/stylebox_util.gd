class_name StyleBoxUtil extends Object


static var scale: float = 1.0


static func new_flat(bg_color: Color, radii: PackedInt32Array = [0], margins: PackedInt32Array = [-1, -1, -1, -1], border_width: PackedInt32Array = [0], border_color := Color.TRANSPARENT, expand_margins: PackedInt32Array = [0]) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	# Uses indices relative to the end so that a single-item array will result
	# in all the radii being the same
	sb.corner_radius_top_left = maxi(0, int(radii[-4 % radii.size()] * scale))
	sb.corner_radius_top_right = maxi(0, int(radii[-3 % radii.size()] * scale))
	sb.corner_radius_bottom_left = maxi(0, int(radii[-2 % radii.size()] * scale))
	sb.corner_radius_bottom_right = maxi(0, int(radii[-1 % radii.size()] * scale))
	
	sb.content_margin_left = maxi(-1, int(margins[-4 % margins.size()] * scale))
	sb.content_margin_top = maxi(-1, int(margins[-3 % margins.size()] * scale))
	sb.content_margin_right = maxi(-1, int(margins[-2 % margins.size()] * scale))
	sb.content_margin_bottom = maxi(-1, int(margins[-1 % margins.size()] * scale))
	
	sb.border_width_left = int(border_width[-4 % border_width.size()] * scale)
	sb.border_width_top = int(border_width[-3 % border_width.size()] * scale)
	sb.border_width_right = int(border_width[-2 % border_width.size()] * scale)
	sb.border_width_bottom = int(border_width[-1 % border_width.size()] * scale)
	
	sb.expand_margin_left = maxi(-1, int(expand_margins[-4 % expand_margins.size()] * scale))
	sb.expand_margin_top = maxi(-1, int(expand_margins[-3 % expand_margins.size()] * scale))
	sb.expand_margin_right = maxi(-1, int(expand_margins[-2 % expand_margins.size()] * scale))
	sb.expand_margin_bottom = maxi(-1, int(expand_margins[-1 % expand_margins.size()] * scale))
	
	sb.border_color = border_color
	
	sb.bg_color = bg_color
	
	sb.draw_center = true
	
	return sb


static func change_bg_color(sb: StyleBoxFlat, bg_color: Color) -> StyleBoxFlat:
	sb.bg_color = bg_color
	return sb


static func change_corner_rad(sb: StyleBoxFlat, radii: PackedInt32Array = [0]) -> StyleBoxFlat:
	sb.corner_radius_top_left = radii[0]
	sb.corner_radius_top_right = radii[-3]
	sb.corner_radius_bottom_left = radii[-2]
	sb.corner_radius_bottom_right = radii[-1]
	return sb


static func change_content_margins(sb: StyleBox, margins: PackedInt32Array = [0]) -> StyleBox:
	sb.content_margin_left = int(margins[-4 % margins.size()] * scale)
	sb.content_margin_top = int(margins[-3 % margins.size()] * scale)
	sb.content_margin_right = int(margins[-2 % margins.size()] * scale)
	sb.content_margin_bottom = int(margins[-1 % margins.size()] * scale)
	return sb
