grammar Refactoring;

dataSequence
	:	Dollar LCurly accessor ((Dot|Colon) accessor)* RCurly
	;

dataCommand
	:	accessor ((Dot accessor)* Colon accessor)+
	;

params	:	'(' 	
			(('...' name=ID)
			|param (Comma param)*)
			
		RParen
	;
	
param	:	(type=ID)? name=ID ('='spaceArg)?
	;

typeCast:	LParen RParen
	;
	
id	:	ID|dataSequence
	;
	
indexer
	:	LSquare commaArg (Comma commaArg)* RSquare
	;

commaArg:	
	(
			(STRING (Comma|RSquare))=>STRING 
		|	(INT (Comma|RSquare))=>INT 
		|	(FLOAT (Comma|RSquare))=>FLOAT
		|	(dataSequence (Comma|RSquare))=>dataSequence
		|	commaSquareUnquotedString
	)
	;


spaceArg
	:	
	(
			(STRING)=>STRING 
		|	(INT)=>INT 
		|	(FLOAT)=>FLOAT
		|	(dataSequence)=>dataSequence
		|	~(NewLine)
	)
	;
work	:  spaceArg*
	;
accessor:	id* indexer* typeCast*;

commaSquareUnquotedString
	:(options {greedy=false;}: ~(Comma|RSquare|NewLine))*
	;
EqualTo	:	'=='
	;

NotEqualTo
	:	'!='
	;

GreaterThan
	:	'>'
	;

LessThan
	:	'<'
	;

LessThanEqual
	:	'<='
	;

GreaterThanEqual
	:	'>='
	;
	
Negate	:	'!';

Dollar	:	'$';

LCurly	:	'{';

RCurly	:	'}';

LParen	:	'('
	;

RParen	:	')'
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
NewLine	:	(/*{$channel=HIDDEN;}*/'\r'? '\n')
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


ID	:	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
	;

INT	:	'0'..'9'+
	;

FLOAT
    	:	('0'..'9')+ '.' ('0'..'9')* EXPONENT?
	|	'.' ('0'..'9')+ EXPONENT?
	|	('0'..'9')+ EXPONENT
	;

COMMENT	:	'/*' ( options {greedy=false;} : . )* '*/' {$channel=HIDDEN;} ;

WS	:	(' '|'\t')+{$channel=HIDDEN;}
	;

STRING	:	'"' ( ESC_SEQ | ~('\\'|'"') )* '"' ;

Other	:	//.(~(' '|'\t'|'\r'|'\n'))+
		.
	;

fragment
EXPONENT:	('e'|'E') ('+'|'-')? ('0'..'9')+ ;

fragment
HEX_DIGIT
	:	('0'..'9'|'a'..'f'|'A'..'F') ;

fragment
ESC_SEQ	:	'\\' ('b'|'$'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
	|	UNICODE_ESC
	|	OCTAL_ESC
	;

fragment
OCTAL_ESC
	:	'\\' ('0'..'3') ('0'..'7') ('0'..'7')
	|	'\\' ('0'..'7') ('0'..'7')
	|	'\\' ('0'..'7')
	;

fragment
UNICODE_ESC
	:	'\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
	;