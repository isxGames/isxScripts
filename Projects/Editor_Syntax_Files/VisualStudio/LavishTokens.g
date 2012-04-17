lexer grammar LavishTokens;

fragment
STRING	:	
	;
fragment
CodeBlock:	
	;
fragment
MATH	:	
	;
fragment
Script	:	
	;
fragment
DataCommand
	:	 	
	;
fragment
CONDITION
	:	
	;
fragment
Param	:	
	;
fragment
Params	:	
	;
fragment
Type	:	
	;
fragment
IndexerValue
	:	
	;
fragment
Returns	:	
	;
fragment
COMMAND	:		
	;

Elipse
	:	'...'
	;
Comparer:	EqualTo|NotEqualTo|GreaterThan|LessThan|LessThanEqual|GreaterThanEqual;

COMMENT	:	'/*' ( options {greedy=false;} : . )* '*/' {$channel=HIDDEN;}
	|	NewLine WS? Semi ~('\r'|'\n')*{$channel=HIDDEN;}
	;

Mult	:	'*'
	;

Div	:	'/'
	;

Plus	:	'+'
	;

Minus	:	'-'
	;

Modu	:	'%'
	;

Xor	:	'^'
	;

Band	:	'&'
	;

Bor	:	'|'
	;

LeftShift
	:	'<<'
	;

RightShift
	:	'>>'
	;

Bnegate	:	'~'
	;

Assign	:	'=';
fragment
EqualTo	:	'=='
	;
fragment
NotEqualTo
	:	'!='
	;
fragment
GreaterThan
	:	'>'
	;
fragment
LessThan
	:	'<'
	;
fragment
LessThanEqual
	:	'<='
	;
fragment
GreaterThanEqual
	:	'>='
	;

Unmac
	:	'#unmac'
	;

Define
	:	'#define'
	;

Macro
	:	'#macro'
	;

EndMac
	:	'#endmac'
	;

PreIf
	:	'#if'
	;

EndIf
	:	'#endif'
	;

PreElse
	:	'#else'
	;

PreElseIf
	:	'#elseif'
	;

IfDef
	:	'#ifdef'
	;

IfNDef
	:	'#ifndef'
	;

Echo
	:	'#echo'
	;

Error
	:	'#error'
	;

Include
	:	'#include'
	;
Negate	:	'!';

Dollar	:	'$';

LCurly	:	'{';

RCurly	:	'}';

LParen	:	'('
	;
Quote	:	'"'
	;
RParen	:	')'
	;
ObjectDef
	:	'objectdef'
	;
Dot	:	'.'
	;

Colon	:	':'
	;

Comma	:	','
	;

RSquare	:	']'
	;

LSquare	:	'['
	;	
Default
	:	'default'
	;

Case
	:	'case'
	;

VariableCase
	:	'variablecase'
	;

While
	:	'while'
	;

Do
	:	'do'
	;

For
	:	'for'
	;

If
	:	'if'
	;

ElseIf
	:	'elseif'
	;

Else
	:	'else'
	;

And
	:	'&&'
	;

Or
	:	'||'
	;

Variable
	:	'variable'
	;

DeclareVariable
	:	'declarevariable'
	;
	
Switch
	:	'switch'
	;
Function
	:	'function'
	;
	
Atom	:	'atom'
	;
	
Method	:	'method'
	;
	
Member	:	'member'
	;

Scope	:	'local'|'object'|'script'|'global'|'globalkeep';

Inherits
	:	'inherits'
	;
ID  :	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
    ;

INT :	'0'..'9'+
    ;
    
NewLine	:	('\\'?'\r'? '\n' WS?)+
	;
Semi	:	';'
	;
WS	:	(' '|'\t')+
	;
FLOAT
    :   ('0'..'9')+ '.' ('0'..'9')* EXPONENT?
    |   '.' ('0'..'9')+ EXPONENT?
    |   ('0'..'9')+ EXPONENT
    ;
    

fragment
EXPONENT : ('e'|'E') ('+'|'-')? ('0'..'9')+ ;

fragment
HEX_DIGIT : ('0'..'9'|'a'..'f'|'A'..'F') ;

fragment
ESC_SEQ
    :   '\\' ('b'|'t'|'n'|'$'|'f'|'r'|'\"'|'\''|'\\')
    |   UNICODE_ESC
    |   OCTAL_ESC
    ;

fragment
OCTAL_ESC
    :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7')
    ;

fragment
UNICODE_ESC
    :   '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
	;
Other	:	.
	;