extends Control


@export_multiline var test_string: String

var root_control: ForceDirectedControl

func _ready() -> void:
	var x := GLSLLanguageParser.new()
	x.parse("hi")
	
	pass
	#var parse_tree := GLSLLanguage.parse(test_string)
	#print(test_string, " -> ", parse_tree)
	#
	#root_control = convert_node(parse_tree)
	#root_control.connect_tree()
	#add_child(root_control)
	#root_control.position = Vector2(1152, 648) * 0.5
	
	#(func():
		#var sprite_a := ForceDirectedControl.new()
		#sprite_a.size = Vector2(100, 50)
		##sprite_a.texture = load("res://src/assets/icons/icon.png")
		#sprite_a.position = size * 0.5 - Vector2(100, 0)
		#add_child(sprite_a)
		#var sprite_b := ForceDirectedControl.new()
		#sprite_b.size = Vector2(100, 50)
		##sprite_b.texture = load("res://src/assets/icons/icon.png")
		#sprite_b.position = size * 0.5 + Vector2(100, 0)
		#add_child(sprite_b)
		#sprite_a.connected_to.append(sprite_b)
		#sprite_b.connected_to.append(sprite_a)
	#).call_deferred()


func convert_node(expr: Language.Expr) -> ForceDirectedControl:
	var content: String
	if expr is Language.NumberLiteral:
		content = expr.value
	elif expr is Language.BooleanLiteral:
		content = str(expr.value)
	elif expr is Language.BinaryExpr:
		const operator_symbols: Dictionary[Language.BinaryExpr.Op, String] = {
			Language.BinaryExpr.Op.ADD: "+",
			Language.BinaryExpr.Op.MUL: "*",
			Language.BinaryExpr.Op.DIV: "/",
			Language.BinaryExpr.Op.SUB: "-",
			Language.BinaryExpr.Op.ADD_ASSIGN: "+=",
			Language.BinaryExpr.Op.MUL_ASSIGN: "*=",
			Language.BinaryExpr.Op.SUB_ASSIGN: "-=",
			Language.BinaryExpr.Op.DIV_ASSIGN: "/=",

			Language.BinaryExpr.Op.LESS_THAN: "<",
			Language.BinaryExpr.Op.GREATER_THAN: ">",
			Language.BinaryExpr.Op.LESS_THAN_EQ: "<=",
			Language.BinaryExpr.Op.GREATER_THAN_EQ: ">=",

			Language.BinaryExpr.Op.SHIFT_LEFT: "<<",
			Language.BinaryExpr.Op.SHIFT_RIGHT: ">>",
			Language.BinaryExpr.Op.SHIFT_RIGHT_ASSIGN: ">>=",
			Language.BinaryExpr.Op.SHIFT_LEFT_ASSIGN: "<<=",

			Language.BinaryExpr.Op.BITWISE_NOT_ASSIGN: "~=",
			Language.BinaryExpr.Op.NOT_EQUAL: "!=",
			Language.BinaryExpr.Op.ASSIGN: "=",
			Language.BinaryExpr.Op.EQUALS: "==",

			Language.BinaryExpr.Op.MOD: "%",
			Language.BinaryExpr.Op.MOD_ASSIGN: "%=",

			Language.BinaryExpr.Op.AND: "&&",
			Language.BinaryExpr.Op.BITWISE_AND: "&",
			Language.BinaryExpr.Op.BITWISE_AND_ASSIGN: "&=",

			Language.BinaryExpr.Op.XOR: "^^",
			Language.BinaryExpr.Op.BITWISE_XOR: "^",
			Language.BinaryExpr.Op.BITWISE_XOR_ASSIGN: "^=",

			Language.BinaryExpr.Op.OR: "||",
			Language.BinaryExpr.Op.BITWISE_OR: "|",
			Language.BinaryExpr.Op.BITWISE_OR_ASSIGN: "|=",
		}
		content = operator_symbols[expr.op]
	elif expr is Language.LeftUnaryExpr:
		const operator_symbols: Dictionary[Language.LeftUnaryExpr.Op, String] = {
			Language.LeftUnaryExpr.Op.NOT: "!",
			Language.LeftUnaryExpr.Op.SUB: "-",
			Language.LeftUnaryExpr.Op.SUB_SUB: "--",
			Language.LeftUnaryExpr.Op.ADD_ADD: "++",
		}
		content = operator_symbols[expr.op]
	elif expr is Language.SubscriptExpr:
		content = "[]"
	elif expr is Language.FieldAccessExpr:
		content = "."
	elif expr is Language.FunctionCallExpr:
		content = "%s()" % expr.identifier.to_string()
	elif expr is Language.RightUnaryExpr:
		const operator_symbols: Dictionary[Language.RightUnaryExpr.Op, String] = {
			Language.RightUnaryExpr.Op.SUB_SUB: "--",
			Language.RightUnaryExpr.Op.ADD_ADD: "++",
		}
		content = operator_symbols[expr.op]
	elif expr is Language.TernaryExpr:
		content = "?:"
	elif expr is Language.Identifier:
		content = expr.content
	
	var node := make_node(content)
	var children := get_expr_node_children(expr)
	for child_label in children:
		var child := convert_node(children[child_label])
		node.labels[child] = child_label
		node.add_child(child)
	return node


func make_node(content: String) -> ForceDirectedControl:
	var label := Label.new()
	label.text = content
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var outer := ForceDirectedControl.new()
	outer.add_child(label)
	outer.size = Vector2(100, 50)
	return outer


func get_expr_node_children(expr: Language.Expr) -> Dictionary[String, Language.Expr]:
	if expr is Language.NumberLiteral:
		return {}
	elif expr is Language.BooleanLiteral:
		return {}
	elif expr is Language.BinaryExpr:
		return {"left": expr.left, "right": expr.right}
	elif expr is Language.LeftUnaryExpr:
		return {"exp": expr.exp}
	elif expr is Language.SubscriptExpr:
		return {"[]": expr.subscript_exp}
	elif expr is Language.FieldAccessExpr:
		return {".": expr.right}
	elif expr is Language.FunctionCallExpr:
		var d: Dictionary[String, Language.Expr] = {"fn": expr.identifier}
		var i := 0
		for arg in expr.arguments:
			d["arg%s" % i] = arg
			i += 1
		return d
	elif expr is Language.RightUnaryExpr:
		return {"exp": expr.exp}
	elif expr is Language.TernaryExpr:
		return {"left": expr.left, "middle": expr.middle, "right": expr.right}
	else:
		return {}


func _on_line_edit_text_submitted(new_text: String) -> void:
	var parse_tree := GLSLLanguage.parse(new_text)
	print(new_text, " -> ", parse_tree)
	find_children("", "ForceDirectedControl", true, false).map(func(e: Node): e.queue_free())
	root_control = convert_node(parse_tree)
	root_control.connect_tree()
	root_control.flatten_hierarchy(self)
	for child in get_children():
		if child is not ForceDirectedControl:
			continue
		child.position = get_rect().get_center()
	root_control.connect_parents()
	add_child(root_control)
