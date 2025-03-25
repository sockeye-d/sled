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
		ADD_ADD,
		SUB_SUB,
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

		BITWISE_NOT,
		BITWISE_NOT_ASSIGN,
		NOT,
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
	}
	var exp: Expr
	var op: Op
	func _init(_exp: Expr, _op: Op) -> void:
		exp = _exp
		op = _op
			
	func _to_string() -> String:
		return "(%s UNARY_%s)" % [exp.to_string(), Op.find_key(op)]


class Document:
	pass

class Function:
	var return_type: String
	var parameters: Array[VariableDeclaration]

class Assignment:
	var variable: VariableDeclaration

class VariableDeclaration:
	var type: String
	var name: String


#static func parse(string: String) -> Document:
	#return null
