grammar test;
options{
	output=AST;
	ASTLabelType=CommonTree;
}
script	:	NewLine* scriptStructure (NewLine+ scriptStructure)* ->^(Script scriptStructure+)
	;
fragment
Script	:	
	;
scriptStructure
	:	(variableDeclare|function|atom|objectDef|preProcessor)
	;

preProcessor
	:	include|'#' ~NewLine*
	;
include	:	'#'^ 'include' STRING
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
	:	Case lineArg+ expression+ ->^(Case ^(Param lineArg+) expression+)
	|	VariableCase dataSequence expression+->^(VariableCase dataSequence expression+)
	;
variableCase
	:	
	;
defaultCase
	:	Default^ expression+
	;
lineArg
	:	(ID)=>ID|(dataSequence)=>dataSequence
		|(STRING)=>STRING|(INT)=>INT|(FLOAT)=>FLOAT
		|(math)=>math->^(MATH math)
		|(~NewLine)
	;
commaArg
	:	(ID (Comma|RSquare))=>ID|(dataSequence (Comma|RSquare))=>dataSequence|(STRING (Comma|RSquare))=>STRING
		|(INT (Comma|RSquare))=>INT|(FLOAT (Comma|RSquare))=>FLOAT
		|(math Comma|RSquare)=>math->^(MATH math)
		|(~(Comma|RSquare))
		
	;
objectDef
	:	ObjectDef^ ID (Inherits ID)? NewLine!
		LCurly!
			(NewLine! (atom|objectMethod|objectMember|variableDeclare)?)+
		RCurly!
	;
function:	Function(Colon returnType=ID)? name=ID LParen params? RParen NewLine codeBlock
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

command	:	(dataCommand)=>dataCommand->^(DataCommand dataCommand)
	|	(ID)=>(ID) commandArg*->^(COMMAND ^(ID commandArg*))
	|	(dataSequence)=>(dataSequence) commandArg*->^(COMMAND ^(dataSequence commandArg*))
	;
fragment
DataCommand
	:	 	
	;
commandArg
	:	(ID)=>ID|(dataSequence)=>dataSequence
		|(STRING)=>STRING|(INT)=>INT|(FLOAT)=>FLOAT
		|(math)=>math->^(MATH math)
		|(~(NewLine|Semi))
	;
expression
	:	(NewLine!)(command|declareVariable|variableDeclare|forStatement|doStatement|whileStatement|ifStatement|switchStatement|codeBlock)?
		((Semi)=>chainExpression)?
	;
chainExpression
	:	Semi! (command|declareVariable|variableDeclare|forStatement|doStatement|whileStatement|ifStatement|switchStatement|codeBlock)
		((Semi)=>chainExpression)?
	;
params	:	
		(('...' ID)->^(Param ^(Type '...') ^(ID))
		|param (Comma param)*->param*
		)
		
	;
param	:	((type=ID name=ID)|name=ID)(Assign value*)?
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
	:	If ifCondition=condition ifExpression=expression
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
	:	(For LParen command ';' condition ';' command RParen)=>(For LParen command ';' condition ';' command RParen) expression
			->^(For command condition command)
	|	(For LParen condition ';' command RParen)=>(For LParen condition ';' command RParen)expression
			->^(For COMMAND ^(CONDITION condition) command)
	|	(For LParen command';' command RParen)expression
			->^(For command ^(CONDITION) command)
	;
fragment
CONDITION
	:	
	;
conditionValue
	:	(ID (Comparer|LParen|RParen|NewLine))=>ID
		|(dataSequence (Comparer|LParen|RParen|NewLine))=>dataSequence
		|(STRING (Comparer|LParen|RParen|NewLine))=>STRING
		|(INT (Comparer|LParen|RParen|NewLine))=>INT
		|(FLOAT (Comparer|LParen|RParen|NewLine))=>FLOAT
		|(math (Comparer|LParen|RParen|NewLine))=>math->^(MATH math)
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
	:	(Negate?)^ (LParen! condition RParen!|conditionValue (Comparer^ conditionValue)?) ((And^|Or^) condition)?
	;
variableDeclare
	:	Variable(LParen Scope RParen)? type=ID name=ID indexer? (Assign lineArg*)?
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
value	:	ID|dataSequence|STRING|INT|FLOAT
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
    
NewLine	:	('\r'? '\n' WS?)+
	;
Semi	:	';'
	;
WS	:	(' '|'\t')+{$channel=HIDDEN;}
	;
FLOAT
    :   ('0'..'9')+ '.' ('0'..'9')* EXPONENT?
    |   '.' ('0'..'9')+ EXPONENT?
    |   ('0'..'9')+ EXPONENT
    ;

STRING
    :  '"' ( ESC_SEQ | ~('\\'|'"') )* '"'
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