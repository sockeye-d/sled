class_name Language


static var base_types: PackedStringArray
static var keywords: Dictionary[String, IconTexture2D]
static var comment_regions: PackedStringArray
static var string_regions: PackedStringArray


class Expr:
	func _to_string() -> String:
		return ""


class NumberLiteral extends Expr:
	## yes, numbers are stored as strings
	var value: String
	
	func _init(_value: String) -> void:
		value = _value
	
	func _to_string() -> String:
		return value


class BooleanLiteral extends Expr:
	var value: bool
	
	func _init(_value: bool) -> void:
		value = _value
	
	func _to_string() -> String:
		return "true" if value else "false"


class BinaryExpr extends Expr:
	enum Op {
		ADD,
		MUL,
		DIV,
		SUB,
		ADD_ASSIGN,
		MUL_ASSIGN,
		SUB_ASSIGN,
		DIV_ASSIGN,

		LESS_THAN,
		GREATER_THAN,
		LESS_THAN_EQ,
		GREATER_THAN_EQ,

		SHIFT_LEFT,
		SHIFT_RIGHT,
		SHIFT_RIGHT_ASSIGN,
		SHIFT_LEFT_ASSIGN,

		BITWISE_NOT_ASSIGN,
		NOT_EQUAL,
		ASSIGN,
		EQUALS,

		MOD,
		MOD_ASSIGN,

		AND,
		BITWISE_AND,
		BITWISE_AND_ASSIGN,

		XOR,
		BITWISE_XOR,
		BITWISE_XOR_ASSIGN,

		OR,
		BITWISE_OR,
		BITWISE_OR_ASSIGN,
	}
	var left: Expr
	var right: Expr
	var op: Op
	func _init(_left: Expr, _op: Op, _right: Expr) -> void:
		left = _left
		right = _right
		op = _op
	
	func _to_string() -> String:
		return "(%s %s %s)" % [left.to_string(), Op.find_key(op), right.to_string()]

class TernaryExpr extends Expr:
	var left: Expr
	var middle: Expr
	var right: Expr
	
	func _init(_left: Expr, _middle: Expr, _right: Expr) -> void:
		left = _left
		middle = _middle
		right = _right
	
	func _to_string() -> String:
		return "(%s ? %s : %s)" % [left.to_string(), middle.to_string(), right.to_string()]

class LeftUnaryExpr extends Expr:
	enum Op {
		NOT,
		SUB,
		ADD_ADD,
		SUB_SUB,
	}
	var exp: Expr
	var op: Op
	func _init(_exp: Expr, _op: Op) -> void:
		exp = _exp
		op = _op
		
	func _to_string() -> String:
		return "(UNARY_%s %s)" % [Op.find_key(op), exp.to_string()]

class RightUnaryExpr extends Expr:
	enum Op {
		ADD_ADD,
		SUB_SUB,
		
		SUBSCRIPT,
		FIELD_ACCESS,
	}
	var exp: Expr
	var op: Op
	func _init(_exp: Expr, _op: Op) -> void:
		exp = _exp
		op = _op
			
	func _to_string() -> String:
		return "(%s UNARY_%s)" % [exp.to_string(), Op.find_key(op)]

class SubscriptExpr extends RightUnaryExpr:
	var subscript_exp: Expr
	
	func _init(_exp: Expr, _subscript_exp: Expr) -> void:
		op = Op.SUBSCRIPT
		exp = _exp
		subscript_exp = _subscript_exp
	
	func _to_string() -> String:
		return "(%s[%s])" % [exp.to_string(), subscript_exp.to_string()]

class FieldAccessExpr extends RightUnaryExpr:
	var right: RightUnaryExpr
	
	func _init(_exp: Expr, _right: RightUnaryExpr) -> void:
		op = Op.FIELD_ACCESS
		exp = _exp
		right = _right
	
	func _to_string() -> String:
		return "(%s.%s)" % [exp.to_string(), right.to_string()]

class FunctionCallExpr extends Expr:
	var identifier: Identifier
	var arguments: Array[Expr]
	
	func _init(_identifier: Identifier, _arguments: Array[Expr]) -> void:
		identifier = _identifier
		arguments = _arguments

class Identifier extends Expr:
	var content: String
	
	func _init(_content: String) -> void:
		content = _content
	
	func _to_string() -> String:
		return content

class Document:
	pass


#static func parse(string: String) -> Document:
	#return null
