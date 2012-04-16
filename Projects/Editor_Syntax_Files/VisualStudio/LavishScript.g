grammar LavishScript;
options{
	output=AST;
	ASTLabelType=CommonTree;
}
script	:	NewLine* scriptStructure (NewLine+ scriptStructure)* NewLine?->^(Script scriptStructure+)
	;
fragment
Script	:	
	;
scriptStructure
	:	(variableDeclare|function|atom|objectDef|preProcessor)
	;

preProcessor
	:	(include)=>include|define|macro|preIf|ifDef|ifNDef|echo|error|unmac
	;
unmac	:	'#unmac'^WS! ID
	;
define	:	'#define'^WS! ID WS! ID
	;
macro	:	'#macro'^WS! ID ws LParen ws params ws RParen WS!?
			(expression*)
		'#endmac'
	;
preIf	:	'#if'^ WS! condition WS!?
			expression*
		 preElseIf*
		 preElse?
		 endIf
		
	;
endIf	:	NewLine! '#endif'!
	;
preElse	:	NewLine! '#else'^ WS!? expression*
	;
preElseIf
	:	NewLine! '#elseif'^ WS!? condition expression*
	;
ifDef	:	'#ifdef'^ WS! ID
		preElse?
		endIf
	;
ifNDef	:	'#ifndef'^ WS! ID
		preElse?
		endIf
	;
echo	:	'#echo'^WS! lineArg*
	;
error	:	'#error'^WS! lineArg*
	;
include	:	'#include'^WS! string
	;
string	:	Quote^
			((dataSequence)=>dataSequence|~(Quote) )*
		Quote!
	;
dataSequence
	:	Dollar^ LCurly! accessor member? RCurly!
	;
id	:	(ID^|dataSequence) id?
	;
member	:	(Dot^|Colon^) accessor member?
	;

dataCommand
	:	accessor member
	;
switchStatement
	:	Switch (lineArg+) NewLine
		LCurly
		(NewLine NewLine* switchCase)*
		(NewLine NewLine* defaultCase)?
		NewLine RCurly
		->^(Switch ^(Param lineArg+) switchCase* defaultCase?)
	;
switchCase
	:	Case lineArg+ expression* ->^(Case ^(Param lineArg+) expression*)
	|	VariableCase dataSequence expression*->^(VariableCase dataSequence expression*)
	;
variableCase
	:	
	;
defaultCase
	:	Default^ expression*
	;
lineArg
	:	(ID)=>ID|(dataSequence)=>dataSequence
		|(string)=>string|(INT)=>INT|(FLOAT)=>FLOAT
		|(math)=>math->^(MATH math)
		|(~NewLine)
	;
commaArg
	:	(ID (Comma|RSquare))=>ID|(dataSequence (Comma|RSquare))=>dataSequence|(string (Comma|RSquare))=>string
		|(INT (Comma|RSquare))=>INT|(FLOAT (Comma|RSquare))=>FLOAT
		|(math Comma|RSquare)=>math->^(MATH math)
		|(~(Comma|RSquare))
		
	;
objectDef
	:	ObjectDef WS ID WS (Inherits WS ID)? NewLine
		LCurly
			(NewLine+ (members+=function|members+=atom|members+=objectMethod|members+=objectMember|members+=variableDeclare)?)+
		RCurly
			->^(ObjectDef ^(ID $members*) ^(Inherits ID)?)
	;
function:	Function(Colon returnType=ID)?WS name=ID LParen params? RParen NewLine codeBlock
			->^(Function $name ^(Returns $returnType?) ^(Params params?) codeBlock)
	;
atom	:	Atom(Colon returnType=ID)? name=ID LParen params? RParen NewLine codeBlock
			->^(Atom $name ^(Returns $returnType?) ^(Params params?) codeBlock)
	;
objectMember
	:	Member(Colon returnType=ID)? name=ID LParen params? RParen NewLine codeBlock
			->^(Member $name ^(Returns $returnType?) ^(Params params?) codeBlock)
	;
objectMethod
	:	Method(Colon returnType=ID)? name=ID LParen params? RParen NewLine codeBlock
			->^(Method $name ^(Returns $returnType?) ^(Params params?) codeBlock)
	;

command	:	(dataCommand)=>dataCommand->^(DataCommand dataCommand)|
		(ID)=>(ID WS) commandArg*->^(COMMAND ^(ID commandArg*))
	|	(dataSequence WS)=>(dataSequence) commandArg*->^(COMMAND ^(dataSequence commandArg*))
	;
fragment
DataCommand
	:	 	
	;
commandArg
	:	(ID)=>ID|(dataSequence)=>dataSequence
		|(string)=>string|(INT)=>INT|(FLOAT)=>FLOAT
		|(math)=>math->^(MATH math)
		|(~(NewLine|Semi))
	;
expression
	:	(NewLine!)(command|declareVariable|preProcessor|variableDeclare|forStatement|doStatement|whileStatement|ifStatement|switchStatement|codeBlock)?
		((Semi)=>chainExpression)?
	;
chainExpression
	:	Semi! (command|declareVariable|variableDeclare|forStatement|doStatement|whileStatement|ifStatement|switchStatement|codeBlock)
		((Semi)=>chainExpression)?
	;
params	:	
		(('...' WS ID)->^(Param ^(Type '...') ^(ID))
		|param (ws Comma ws param)*->param*
		)
		
	;
param	:	((type=ID WS name=ID)|name=ID)(ws Assign ws value*)?
			->^(Param ^(Type $type?)^($name ^(Assign value*)?))
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
ifStatement
	:	If ws ifCondition=condition WS? ifExpression=expression
		((NewLine ElseIf)=>NewLine elseIfs+=ElseIf elseifCondition+=condition elseifexpression+=expression)*
		((NewLine Else)=>NewLine Else elseexpression+=expression)?
			->^(If $ifCondition $ifExpression ^($elseIfs $elseifCondition $elseifexpression)* ^(Else $elseexpression)?)
	;	
doStatement
	:	Do^ expression NewLine! While! condition
	;
whileStatement
	:	While^ condition expression
	;
forStatement
	:	(For ws LParen ws command ws';'ws condition ws';'ws command RParen)=>(For ws LParen ws command ws';'ws condition ws';'ws command ws RParen)WS? expression
			->^(For command condition command)
	|	(For ws LParen ws condition ws ';'ws command ws RParen)=>(For ws LParen ws condition ws';'ws command ws RParen)WS?expression
			->^(For COMMAND ^(CONDITION condition) command)
	|	(For ws LParen ws command ws ';'ws command ws RParen)WS? expression
			->^(For command ^(CONDITION) command)
	;
fragment
CONDITION
	:	
	;
conditionValue
	:	(ID)=>ID
		|(dataSequence)=>dataSequence
		|(string)=>string
		|(INT)=>INT
		|(FLOAT)=>FLOAT
		|(math)=>math->^(MATH math)
		|(~(Comparer|LParen|RParen|NewLine))
	;
math	:	expr (MathSymbol^ expr)+
	;
expr	:	(value)|LParen! math RParen!
	;
fragment
MATH	:	
	;
condition
	:	Negate^? ws 
		(
			LParen! ws  condition ws RParen!
		|	conditionValue (ws Comparer^ ws conditionValue)?
		) (ws(And^|Or^)ws condition)?
	;
ws	:	NewLine!? WS!?
	;
variableDeclare
	:	Variable(LParen Scope RParen)? WS type=ID WS name=ID indexer? (ws Assign ws lineArg*)?
			-> ^(Variable Scope?  ^($type indexer? ^($name  ^(Assign lineArg*)?)))
	;
codeBlock
	:	LCurly^
		expression*
		 RCurly!
	;
declareVariable
	:	DeclareVariable name=ID indexer? type=ID (Scope (lineArg*))?
			-> ^(DeclareVariable Scope?  ^($type indexer? ^($name  ^(Assign lineArg*)?)))
	;
value	:	ID|dataSequence|string|INT|FLOAT
	;
accessor:	id^ (indexer|typeCast)*
	;
indexer	:	LSquare (commaArg+ commaVals*)? RSquare->^(LSquare ^(IndexerValue commaArg+)? ^(IndexerValue commaVals)*)
	;
commaVals
	:	Comma! commaArg+
	;
fragment
IndexerValue
	:	
	;
typeCast:	LParen^ id RParen!
	;

fragment
COMMAND	:		
	;
Comparer:	EqualTo|NotEqualTo|GreaterThan|LessThan|LessThanEqual|GreaterThanEqual;

COMMENT	:	'/*' ( options {greedy=false;} : . )* '*/' {$channel=HIDDEN;}
	|	NewLine WS? Semi ~('\r'|'\n')*{$channel=HIDDEN;}
	;
MathSymbol
	:	'+'|'/'|'%'|'^'|'~'|'*'|'<<'|'>>'|'&'|'-'
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
fragment
Returns	:	
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
WS	:	(' '|'\t')+//{$channel=HIDDEN;}
	;
FLOAT
    :   ('0'..'9')+ '.' ('0'..'9')* EXPONENT?
    |   '.' ('0'..'9')+ EXPONENT?
    |   ('0'..'9')+ EXPONENT
    ;
fragment
STRING	:	
	;
 //   ://  '"' ( ESC_SEQ | ~('\\'|'"') )* '"'
//    ;
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