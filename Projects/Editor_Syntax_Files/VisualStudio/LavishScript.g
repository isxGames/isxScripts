grammar LavishScript;
options{
	output=AST;
}

script	:	(scriptStructure)*
	;

dataSequence
	:	Dollar LCurly accessor ((Dot|Colon) accessor)* RCurly
	;
scriptStructure
	:	 ((newLine ';')=>lineComment)* newLine*(func|variableDeclare);
command	:	((dataCommand)=>dataCommand|(ID ws spaceArgs)) 
	;
	
func
	:	 (Function|Atom)(Colon returnType=ID)? ws funcName=ID params newLine codeBlock
	;

dataCommand
	:	accessor ((Dot accessor)* Colon accessor)+
	;
decl	:	variableDeclare
	|	DeclareVariable ws name=ID ws indexer? ws type=ID (ws Scope ws spaceArgs)?
	;
	
variableDeclare
	:	Variable (LParen Scope RParen)? ws type=ID ws name=ID ws indexer? ws('='ws spaceArgs)?
	;
params	:	LParen 	ws
			(	'...'ws name=ID
			|	((type=ID ws name=ID)|name=ID)(ws Assign commaParenArg)?
				 (Comma ((type=ID ws name=ID)|name=ID)(ws Assign commaParenArg)?)*
			)? 
			ws
		RParen
	;
whileStatement
	:	While ws condition  expression
	;
doWhileStatement
	:		Do  expression newLine While ws condition
	;
	
ifStatement
	:	If condition  expression ((newLine ElseIf)=>newLine ElseIf condition expression)* ((newLine Else)=>newLine Else expression)?
	;

condition 
	:	comparison ((And|Or)comparison)*
	;
comparison
	:	Negate?
		 ((ws compareValue ws(comparer ws compareValue)?)
	|	(ws LParen ws condition? ws RParen))
	;
comparisonString
	:	~(EqualTo|';'|Or|And|NotEqualTo|GreaterThan|LessThan|LessThanEqual|GreaterThanEqual
		|Negate|LParen|RParen|WS|NewLine)+
	;
compareValue
	:	
	(
			(STRING (comparer|And|Or|RParen|WS|NewLine))=>STRING
		|	(INT (comparer|And|Or|RParen|WS|NewLine))=>INT
		|	(FLOAT (comparer|And|Or|RParen|WS|NewLine))=>FLOAT
		|	(dataSequence (comparer|And|Or|RParen|WS|NewLine))=>dataSequence
		|	comparisonString
	)
	;

comparer:	EqualTo|NotEqualTo|GreaterThan|LessThan|LessThanEqual|GreaterThanEqual;
switchStatement
	:	Switch ws(newLineArg)newLine LCurly
		newLine*
		(newLine switchCase)*
		(newLine defaultCase)?
		newLine
		RCurly 
	;
newLine	:	ws NewLine ws
	;
lineComment
	:	newLine ';' ~NewLine*;
switchCase
	:	(Case ws(newLineArg)|VariableCase ws dataSequence) expression+
		;	
defaultCase
	:	Default expression* 
	;

expression
	:	((newLine ';')=>lineComment)|((newLine (command|decl|switchStatement|ifStatement|forStatement|doWhileStatement|whileStatement|codeBlock)?)
			(';'  (command|decl|switchStatement|ifStatement|forStatement|doWhileStatement|whileStatement|codeBlock))*)

	;	
codeBlock
	:	LCurly
		
		(expression)+ 
		RCurly
	;
newLineArg
	:	
	(
			(STRING (NewLine|WS))=>STRING
		|	(INT (NewLine|WS))=>INT
		|	(FLOAT (NewLine|WS))=>FLOAT
		|	(dataSequence (NewLine|WS))=>dataSequence
		|	newLineString
	)
	;
value	:	STRING
	|	INT
	|	FLOAT
	|	dataSequence
	;
typeCast:	LParen id RParen
	;
	
id	:	ID|dataSequence
	;
spaceArgs:	(spaceArg (WS spaceArg)*)?
	;
indexer
	:	LSquare (commaRSquareArg (Comma commaRSquareArg)*)? RSquare
	;
	
commaParenArg:	
	(
			(STRING (Comma|RParen))=>STRING 
		|	(INT (Comma|RParen))=>INT 
		|	(FLOAT (Comma|RParen))=>FLOAT
		|	(dataSequence (Comma|RParen))=>dataSequence
		|	commaParenString
	)
	;
commaRSquareArg:	
	(
			(STRING (Comma|RSquare))=>STRING 
		|	(INT (Comma|RSquare))=>INT 
		|	(FLOAT (Comma|RSquare))=>FLOAT
		|	(dataSequence (Comma|RSquare))=>dataSequence
		|	commaSquareString
	)
	;
	
spaceArg
	:	
	(
			(STRING (WS|NewLine))=>STRING 
		|	(INT (WS|NewLine))=>INT FLOAT
		|	(FLOAT (WS|NewLine))=>FLOAT
		|	(dataSequence (WS|NewLine))=>dataSequence
		|	spaceString
	)
	;

//lineComment:	newLine ';' (~NewLine)* ;

accessor:	id* indexer* typeCast*;

commaSquareString
	:	(~(Comma|RSquare))+
	;
commaParenString
	:	(~(Comma|RSquare|LCurly))+
	;
spaceString
	:	(~(NewLine|RParen|';'|WS))+
	;
forStatement
	:	(For (~(NewLine|';')* ';') (~(NewLine|';')* ';'))=>
			((For ws LParen ws command ws ';' ws condition ';'ws command ws RParen)  (expression))
		|(For ws LParen ws condition ';'ws command ws RParen)  (expression)
	;
ws	:	WS?
	;
newLineString
	:	(~(NewLine))+
	;
	
Assign	:	'=';
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
NewLine	:	(/*{$channel=HIDDEN;}*/('\r\n'|'\n'))+// WS?
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

WS	:	(' '|'\t')+//{$channel=HIDDEN;}
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
	

