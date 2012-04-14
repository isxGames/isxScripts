grammar LavishScript;
options{
	output=AST;
	ASTLabelType=CommonTree;
}

script	:	scriptStructure+
	;

dataSequence
	:	Dollar^ LCurly! accessor member* RCurly!
	
	;
member	:	(Colon^|Dot^) accessor
	;
scriptStructure
	:	newLine (func^|variableDeclare^|objectDef^);
	
command	:
	(
		(dataCommand)=>dataCommand->^(Command dataCommand)
	|	(ID ws spaceArgs)->^(Command ID spaceArgs)
	) 
	;
	
func
	:	Function(Colon returnType=ID)? ws funcName=ID params newLine codeBlock
			->^(Function $funcName ^(Returns $returnType?) params codeBlock)
		
	;
atom	:	Atoms (Colon returnType=ID)? ws atomName=ID params newLine codeBlock
			->^(Atoms ^($atomName ^(Returns $returnType?) params)codeBlock)
	;

objectDef
	:	ObjectDef^ ws! ID (ws! Inherits ws! ID)? newLine!
		LCurly! 
		(newLine! (atom|objectMethod|objectMember|variableDeclare))*
		newLine! RCurly!
		
	;
fragment
TYPE	:	
	;
objectMember
	:	Member (Colon returnType=ID)? ws funcName=ID params newLine codeBlock
		->^(Member ^($funcName ^(Returns $returnType?) params)codeBlock)
	;
	
objectMethod
	:	Method (Colon returnType=ID)? ws funcName=ID params newLine codeBlock
			->^(Method ^($funcName ^(Returns $returnType?) params)codeBlock)
	;

dataCommand
	:	accessor ((Dot accessor)* Colon accessor)+
	;
decl	:	variableDeclare^
	|	declVar^
	;
declVar	:	DeclareVariable ws name=ID ws indexer? ws type=ID (ws Scope ws spaceArgs)?
		-> ^(VarDef ^(TYPE $type) ^(INDEX indexer?) ^(SCOPE Scope?) ^($name ^(ASSIGN (spaceArgs)?)))
	;
variableDeclare
	:	Variable (LParen Scope RParen)? ws type=ID ws name=ID ws indexer? ws(Assign ws spaceArgs)?
		-> ^(VarDef ^(TYPE $type?) ^(INDEX indexer?) ^(SCOPE Scope?) ^($name ^(ASSIGN (spaceArgs)?)))
	;
params	:	LParen 	ws
			(	'...'ws name=ID ->^(Param ^(TYPE'...') ID)
			|	commaArg (Comma commaArg)* ->commaArg*
			)? 
			ws
		RParen
	;
commaArg
	:	((type=ID ws name=ID)|name=ID)(ws Assign commaParenArg)?
		->^(Param ^(TYPE $type?) ^($name ^(ASSIGN commaParenArg?)))
	;
fragment
Param	:	
	;
whileStatement
	:	While ws condition  expression
		->^(While condition expression)
	;
doWhileStatement
	:	Do  expression newLine While ws condition
		->^(Do expression)^(While condition)
	;
	
ifStatement
	:	If condition  expression (elseIf)* (elseStatement)?
		->^(If condition expression elseIf* elseStatement?)
	;
elseStatement
	:	(newLine Else)=>newLine Else expression
		->^(Else expression)
	;
elseIf	:	(newLine ElseIf)=>newLine ElseIf condition expression
		->^(ElseIf condition expression)
	;
condition 
	:	comparison^ ((And^|Or^)comparison)*
	;
	
comparison
	:	ws Negate? ws
	(	(compareValue ws comparer ws compareValue)=>(compareValue ws comparer ws compareValue)->^(comparer compareValue+)
	|	(compareValue) ->^(compareValue)
	|	(ws LParen ws condition ws RParen)->condition
	)
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
		->^(Switch switchCase* defaultCase?)newLineArg
	;
	
newLine	:	NewLine WS? ((';')=>lineComment)*
	;
lineComment
	:	(';' ~NewLine* NewLine WS?)
	;
/*
newLine	:	ws NewLine ws
	;
	
lineComment
	:	';' ~NewLine*;
	*/
switchCase
	:	Case^ ws!(newLineArg)expression+
	|	VariableCase^ ws! dataSequence expression+
	;
defaultCase
	:	Default expression+
		->^(Default expression+)
	;

expression
	:	newLine ((command|decl|switchStatement|ifStatement|forStatement|doWhileStatement|whileStatement|codeBlock)
			(';'  (command|decl|switchStatement|ifStatement|forStatement|doWhileStatement|whileStatement|codeBlock))*)?

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
spaceArgs:	(spaceArg (WS spaceArg)*->spaceArg+)?
	;
indexer
	:	LSquare (commaRSquareArg (Comma commaRSquareArg)*)? RSquare
		->commaRSquareArg*
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
		|	(INT (WS|NewLine))=>INT
		|	(FLOAT (WS|NewLine))=>FLOAT
		|	(dataSequence (WS|NewLine))=>dataSequence
		|	spaceString
	)
	;

//lineComment:	newLine ';' (~NewLine)* ;

accessor:	id* indexer* typeCast*;

commaSquareString
	:	~(Comma|RSquare)+
	;
commaParenString
	:	(~(Comma|RSquare|NewLine|LCurly))+
	;
spaceString
	:	(~(NewLine|RParen|';'|WS))+
	;
forStatement
	:	(For (~(NewLine|';')* ';') (~(NewLine|';')* ';'))=>
		((For ws LParen ws startCommand=command ws ';' ws condition ';'ws iterateCommand=command ws RParen)  (expression))
			->^(For $startCommand condition $iterateCommand expression)
	|	(For ws LParen ws condition ';'ws iterateCommand=command ws RParen)  (expression)
		->^(For ^(Command) condition $iterateCommand expression)
	;
	
ws	:	WS?
	;
newLineString
	:	(~(NewLine))+
	;
fragment
SCOPE	:	
	;
fragment
Returns	:	
	;
fragment
VarDef	:
	;
fragment
Command	:
	;
fragment
ASSIGN	:	
	;
fragment
INDEX	:	
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

fragment
COMMAND
	:	
	;
Switch
	:	'switch'
	;
Function
	:	'function'
	;
	
Atoms	:	'atom'
	;
	
Method	:	'method'
	;
	
Member	:	'member'
	;

Scope	:	'local'|'object'|'script'|'global'|'globalkeep';

Inherits
	:	'inherits'
	;

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

