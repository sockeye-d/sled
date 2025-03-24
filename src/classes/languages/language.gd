class_name Language


static var base_types: PackedStringArray
static var keywords: Dictionary[String, IconTexture2D]
static var comment_regions: PackedStringArray
static var string_regions: PackedStringArray


class ASTNode:
	var parent: ASTNode
	var children: Array[ASTNode]

class Document extends ASTNode:
	pass

class Function extends ASTNode:
	var return_type: String
	var parameters: Array[VariableDeclaration]

class Assignment extends ASTNode:
	var variable: VariableDeclaration

class VariableDeclaration extends ASTNode:
	var type: String
	var name: String


static func parse(string: String) -> Document:
	return null
