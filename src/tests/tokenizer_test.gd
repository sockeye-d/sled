extends Node


@export_multiline var test_string: String


const CELL = "[cell padding=1,0,1,0 border=#AAAAAA11]"


func _ready() -> void:
	var tks := GLSLLanguage.Tokenizer.new(test_string).tokenize()
	print_rich("[table={3}]" + CELL + "Type[/cell]" + CELL + "Content[/cell]" + CELL + "Character index[/cell]"+"\n".join(tks.map(func(e: GLSLLanguage.Tokenizer.Token) -> String:
		return (CELL + "%s[/cell]" + CELL + "%s[/cell]" + CELL + "%s[/cell]") % [GLSLLanguage.Tokenizer.Token.Type.find_key(e.type), "'" + bbc_escape(e.content.c_escape()) + "'", e.source_index]
	)) + "[/table]")


func bbc_escape(t: String) -> String:
	return t.replace("[", "🥔👈").replace("]", "👉🥔").replace("🥔👈", "[lb]").replace("👉🥔", "[rb]")
