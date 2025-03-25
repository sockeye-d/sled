expression	-> selection
assignment	-> right "=" expression
selection omitted for now
logical_or	-> logical_xor ( ( "||" ) logical_xor )*
logical_xor	-> logical_and ( ( "||" ) logical_and )*
logical_and	-> bitwise_or ( ( "&&" ) bitwise_or )*
bitwise_or 	-> bitwise_xor ( ( "|" ) bitwise_xor )*
bitwise_xor -> bitwise_and ( ( "^" ) bitwise_and )*
bitwise_and -> equality ( ( "&" ) equality )*
equality	-> comparison ( ( "!=" | "==" ) comparison )*
comparison	-> bitshift ( ( ">" | ">=" | "<" | "<=" ) bitshift )*
bitshift	-> term ( ( ">>" | "<<" ) term )*
term		-> factor ( ( "-" | "+" ) factor )*
factor		-> left_unary ( ( "/" | "*" | "%" ) left_unary )*
left_unary	-> ( "!" | "-" | "++" | "--" ) left_unary | right_unary
right_unary	-> primary ( "++" | "--" )
primary		-> NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")"
