class_name StyleBoxUtil extends Object


static func new_flat(bg_color: Color, radii: PackedInt32Array = [0], margins: PackedInt32Array = [0], border_width: PackedInt32Array = [0], border_color := Color.TRANSPARENT) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	# Uses indices relative to the end so that a single-item array will result
	# in all the radii being the same
	sb.corner_radius_top_left = radii[-4 % radii.size()]
	sb.corner_radius_top_right = radii[-3 % radii.size()]
	sb.corner_radius_bottom_left = radii[-2 % radii.size()]
	sb.corner_radius_bottom_right = radii[-1 % radii.size()]
	
	sb.content_margin_left = margins[-4 % margins.size()]
	sb.content_margin_top = margins[-3 % margins.size()]
	sb.content_margin_right = margins[-2 % margins.size()]
	sb.content_margin_bottom = margins[-1 % margins.size()]
	
	sb.border_width_left = border_width[-4 % border_width.size()]
	sb.border_width_top = border_width[-3 % border_width.size()]
	sb.border_width_right = border_width[-2 % border_width.size()]
	sb.border_width_bottom = border_width[-1 % border_width.size()]
	
	sb.border_color = border_color
	
	sb.bg_color = bg_color
	
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


static func change_content_margins(sb: StyleBoxFlat, margins: PackedInt32Array = [0]) -> StyleBoxFlat:
	sb.content_margin_left = margins[0]
	sb.content_margin_top = margins[-3]
	sb.content_margin_right = margins[-2]
	sb.content_margin_bottom = margins[-1]
	return sb
