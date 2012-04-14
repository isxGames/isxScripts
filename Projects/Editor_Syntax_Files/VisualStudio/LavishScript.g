grammar LavishScript;
options{
	output=AST;
	ASTLabelType=CommonTree;
}

script	:	scriptStructure+
	;

dataSequence
<<<<<<< .mine
	:	Dollar LCurly name=accessor (((memberType+=Colon|memberType+=Dot) member+=accessor)*) RCurly
		->^(Dollar $name ^($memberType $member)*)
		
=======
	:	Dollar^ LCurly! accessor member* RCurly!
	
>>>>>>> .r3082
	;
member	:	(Colon^|Dot^) accessor
	;
scriptStructure
<<<<<<< .mine
	:	(newLine*)! (func^|variableDeclare^|objectDef^);
	
command	:
	(
		(dataCommand)=>dataCommand->^(Command dataCommand)
	|	(ID ws spaceArgs)->^(Command ID spaceArgs?)
	) 
=======
	:	newLine (func^|variableDeclare^|objectDef^);
	
command	:
	(
		(dataCommand)=>dataCommand->^(Command dataCommand)
	|	(ID ws spaceArgs)->^(Command ID spaceArgs)
	) 
>>>>>>> .r3082
	;
	
func
<<<<<<< .mine
	:	newLine? Function(Colon returnType=ID)? ws funcName=ID params newLine codeBlock
			->^(Function $funcName ^(Returns $returnType?) ^(Params params?) codeBlock)
		
=======
	:	Function(Colon returnType=ID)? ws funcName=ID params newLine codeBlock
			->^(Function $funcName ^(Returns $returnType?) params codeBlock)
		
>>>>>>> .r3082
	;
<<<<<<< .mine
fragment
Params	:	
	;
atom	:	Atoms (Colon returnType=ID)? ws atomName=ID params newLine codeBlock
			->^(Atoms ^($atomName ^(Returns $returnType?) params?)codeBlock)
	;
=======
atom	:	Atoms (Colon returnType=ID)? ws atomName=ID params newLine codeBlock
			->^(Atoms ^($atomName ^(Returns $returnType?) params)codeBlock)
	;
>>>>>>> .r3082

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
	:	accessor ((Dot^ accessor)* Colon^ accessor)+
	;
decl	:	variableDeclare^
	|	declVar^
	;
<<<<<<< .mine
declVar	:	DeclareVariable ws name=ID ws indexer? ws type=ID (ws Scope ws spaceArgs)?
		-> ^(VarDef ^(TYPE $type) indexer? ^(SCOPE Scope?) ^($name ^(ASSIGN (spaceArgs)?)))
	;
=======
declVar	:	DeclareVariable ws name=ID ws indexer? ws type=ID (ws Scope ws spaceArgs)?
		-> ^(VarDef ^(TYPE $type) ^(INDEX indexer?) ^(SCOPE Scope?) ^($name ^(ASSIGN (spaceArgs)?)))
	;
>>>>>>> .r3082
variableDeclare
<<<<<<< .mine
	:	Variable (LParen Scope RParen)? ws type=ID ws name=ID ws indexer? ws(Assign ws spaceArgs)?
		-> ^(VarDef ^(TYPE $type?) indexer? ^(SCOPE Scope?) ^($name ^(ASSIGN (spaceArgs)?)))
=======
	:	Variable (LParen Scope RParen)? ws type=ID ws name=ID ws indexer? ws(Assign ws spaceArgs)?
		-> ^(VarDef ^(TYPE $type?) ^(INDEX indexer?) ^(SCOPE Scope?) ^($name ^(ASSIGN (spaceArgs)?)))
>>>>>>> .r3082
	;
params	:	LParen 	ws
<<<<<<< .mine
				('...'ws name=ID ->^(TYPE'...') ID
			|	commaArg (Comma commaArg)* ->commaArg*)?
=======
			(	'...'ws name=ID ->^(Param ^(TYPE'...') ID)
			|	commaArg (Comma commaArg)* ->commaArg*
			)? 
>>>>>>> .r3082
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
<<<<<<< .mine
	:	If ifCondition=condition  ifExpression=expression 
		(((newLine ElseIf)=>newLine elseIfs+=ElseIf elseIfConditions+=condition elseIfExpressions+=expression))* 
		((newLine Else)=>newLine Else elseExpression=expression)?
		->^(If $ifCondition $ifExpression ^($elseIfs $elseIfConditions $elseIfExpressions)* ^(Else $elseExpression)?)
=======
	:	If condition  expression (elseIf)* (elseStatement)?
		->^(If condition expression elseIf* elseStatement?)
>>>>>>> .r3082
	;
<<<<<<< .mine
=======
elseStatement
	:	(newLine Else)=>newLine Else expression
		->^(Else expression)
	;
elseIf	:	(newLine ElseIf)=>newLine ElseIf condition expression
		->^(ElseIf condition expression)
	;
>>>>>>> .r3082
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
		(newLine cases+=switchCase)*
		(newLine cases+=defaultCase)?
		newLine
		RCurly 
<<<<<<< .mine
		->^(Switch $cases*)newLineArg
=======
		->^(Switch switchCase* defaultCase?)newLineArg
>>>>>>> .r3082
	;
<<<<<<< .mine
	
newLine	:	NewLine! (WS?)! (((';')=>lineComment)*)!
=======
	
newLine	:	NewLine WS? ((';')=>lineComment)*
	;
lineComment
	:	(';' ~NewLine* NewLine WS?)
	;
/*
newLine	:	ws NewLine ws
>>>>>>> .r3082
	;
	
lineComment
<<<<<<< .mine
	:	(';'! newLineString! NewLine! (WS?)!)
	;

=======
	:	';' ~NewLine*;
	*/
>>>>>>> .r3082
switchCase
<<<<<<< .mine
	:	(Case^ ws!(newLineArg)|VariableCase^ ws! dataSequence) ws! expression+
	;
=======
	:	Case^ ws!(newLineArg)expression+
	|	VariableCase^ ws! dataSequence expression+
	;
>>>>>>> .r3082
defaultCase
	:	Default expression+
		->^(Default expression+)
	;

expression
<<<<<<< .mine
	:	newLine! ((command|decl|switchStatement|ifStatement|forStatement|doWhileStatement|whileStatement|codeBlock)
			(';'  (command|decl|switchStatement|ifStatement|forStatement|doWhileStatement|whileStatement))*)?
=======
	:	newLine ((command|decl|switchStatement|ifStatement|forStatement|doWhileStatement|whileStatement|codeBlock)
			(';'  (command|decl|switchStatement|ifStatement|forStatement|doWhileStatement|whileStatement|codeBlock))*)?
>>>>>>> .r3082

	;	
codeBlock
	:	LCurly
		(expression)+ 
		RCurly
		-> ^(CODEBLOCK expression+)
	;
newLineArg
	:	
	(
			(STRING (NewLine|WS))=>STRING
		|	(INT (NewLine|WS))=>INT
		|	(FLOAT (NewLine|WS))=>FLOAT
		|	(dataSequence (NewLine|WS))=>dataSequence
		|	newLineString->^(String newLineString)
	)
	;
value	:	STRING^
	|	INT^
	|	FLOAT^
	|	dataSequence^
	;
typeCast:	LParen id RParen
		->^(TYPECAST id)
	;
fragment
TYPECAST:	
	;
<<<<<<< .mine
fragment
CODEBLOCK:	
=======
spaceArgs:	(spaceArg (WS spaceArg)*->spaceArg+)?
>>>>>>> .r3082
	;
id	:	(ID|dataSequence)
	;
spaceArgs:	(spaceArg (ws spaceArg)*->spaceArg+)? ws
	;
indexer
	:	LSquare (commaRSquareArg (Comma commaRSquareArg)*)? RSquare
<<<<<<< .mine
		->^(INDEX commaRSquareArg*)
=======
		->commaRSquareArg*
>>>>>>> .r3082
	;
	
commaParenArg:	
	(
			(STRING (Comma|RParen))=>STRING
		|	(INT (Comma|RParen))=>INT
		|	(FLOAT (Comma|RParen))=>FLOAT
		|	(dataSequence (Comma|RParen))=>dataSequence
		|	commaParenString->^(String commaParenString)
	)
	;
commaRSquareArg:	
	(
			(STRING (Comma|RSquare))=>STRING->STRING
		|	(INT (Comma|RSquare))=>INT->INT
		|	(FLOAT (Comma|RSquare))=>FLOAT->FLOAT
		|	(dataSequence (Comma|RSquare))=>dataSequence->dataSequence
		|	commaSquareString->^(String commaSquareString)
	)
	;
	
spaceArg
	:	
	(
<<<<<<< .mine
			(STRING (WS|NewLine))=>STRING->STRING
		|	(INT (WS|NewLine))=>INT->INT
		|	(FLOAT (WS|NewLine))=>FLOAT->FLOAT
		|	(dataSequence (WS|NewLine))=>dataSequence->dataSequence
		|	spaceString->^(String spaceString)
=======
			(STRING (WS|NewLine))=>STRING 
		|	(INT (WS|NewLine))=>INT
		|	(FLOAT (WS|NewLine))=>FLOAT
		|	(dataSequence (WS|NewLine))=>dataSequence
		|	spaceString
>>>>>>> .r3082
	)
	;

//lineComment:	newLine ';' (~NewLine)* ;

accessor:	id (indexer|typeCast)*
		
	;
ACCESSOR	:	;
commaSquareString
	:	~(Comma|RSquare)+
	;
commaParenString
	:	(~(Comma|RSquare|NewLine|LCurly))+
	;
spaceString
	:	(~(NewLine|RParen|WS))+
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
fragment
String	:	
	;
newLineString
	:	~(NewLine)+
	;
<<<<<<< .mine
COMMENT	:	'/*' ( options {greedy=false;} : . )* '*/' {$channel=HIDDEN;} ;

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
=======
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
>>>>>>> .r3082
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
NewLine	:	(('\r\n'|'\n'))+
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

