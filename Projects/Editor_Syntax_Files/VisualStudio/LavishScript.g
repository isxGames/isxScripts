grammar LavishScript;
options {
	backtrack=true;
}

script	:	NewLine* (scriptStructure NewLine*)+
	;
scriptStructure
	:	(func|variableDeclare);
func
	:	 (Function|Atom)(Colon returnType=ID)? funcName=ID params NewLine codeBlock
	;

params	:	LParen 	
			(('...' name=ID)
			|param (Comma param)*)?
			
		RParen
	;
	
param	:	(type=ID)? name=ID ('='value)?
	;
command	:	(dataCommand|(ID spaceArgs));

dataSequence
	:	Dollar LCurly accessor RCurly
	;

dataCommand
	:	accessor ((objectMember)* objectMethod)+
	;

switchStatement
	:	Switch (newLineUnquotedString) NewLine switchCodeBlock
	;

switchCodeBlock
	:	LCurly NewLine+
			((caseExpression* defaultCase?)|NewLine)
		 RCurly 
	;
	
caseExpression
	:	(switchCase|variableCase)
	;
defaultCase
	:	Default expression* NewLine
	;
switchCase
	:	Case (number|STRING| newLineUnquotedString) expression* NewLine
	;
	
newLineUnquotedString
	:	( options {greedy=false;} :~NewLine)+
	;
	
newLineSpaceUnquotedString
	:	( options {greedy=false;} : ~(NewLine|WS))+
	;
	
commaSquareUnquotedString
	:	( options {greedy=false;} : ~(Comma|RSquare|NewLine))+
	;


variableCase
	:	VariableCase dataSequence expression* NewLine
	;

objectMember
	:	Dot accessor
	;
	
objectMethod
	:	Colon accessor
	;
	
expression
	:	(NewLine|';')+ (flowControl|decl|codeBlock|command)
	;
	
whileStatement
	:	While condition expression
	;
	
doWhileStatement
	:		Do expression While condition
	;
	
forStatement
	:	(For LParen command ';' (condition ';')? command RParen) expression
	;
	
flowControl
	:	ifStatement|whileStatement|doWhileStatement|forStatement|switchStatement
	;	

ifStatement
	:	If condition expression (NewLine ifElse)* (NewLine elseStatement)?
	;
elseStatement
	:	Else expression
	;
ifElse	:	ElseIf condition expression
	;
condition
	:	Negate? ((LParen value (comparer value) RParen)|(value (comparer value))) 
		((And|Or)((LParen value (comparer value) RParen)|(value (comparer value))))*
	;

codeBlock
	:	LCurly expression* NewLine RCurly
	;

accessor:	id indexer* typeCast*;

typeCast:	LParen id RParen
	;

id	:	ID|dataSequence;

indexer	:	LSquare commaArgs RSquare
	;

comparer:	EqualTo|NotEqualTo|GreaterThan|LessThan|LessThanEqual|GreaterThanEqual;

commaArgs
	:	((value|commaSquareUnquotedString) (Comma(value|commaSquareUnquotedString))*)?
	;

spaceArgs
	:	(value|newLineSpaceUnquotedString)*
	;

number	:	INT|FLOAT
	;
	
decl	:	variableDeclare
	|	DeclareVariable name=ID indexer? type=ID (Scope spaceArgs)?
	;
	
variableDeclare
	:	Variable (LParen Scope RParen)? type=ID name=ID indexer? ('=' spaceArgs)?
	;
	
value	:	dataSequence|number|STRING
	;


EqualTo	:	'==';

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

COMMENT	:	'/*' ( options {greedy=false;} : . )* '*/' {$channel=3;} ;

WS	:	(' '|'\t')+{$channel=HIDDEN;}
	;

STRING	:	'"' ( ESC_SEQ | ~('\\'|'"') )* '"' ;

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
	
Other	:	.
	;