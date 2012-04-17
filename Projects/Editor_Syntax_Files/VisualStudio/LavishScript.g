parser grammar LavishScript;
options{
	output=AST;
	ASTLabelType=CommonTree;
	tokenVocab=LavishTokens;
	
}
script	:	NewLine* scriptStructure (NewLine+ scriptStructure)* NewLine?->scriptStructure+
	;

scriptStructure
	:	variableDeclare|function|atom|objectDef|preProcessor
	;

preProcessor
	:	(include)=>include|define|macro|preIf|ifDef|ifNDef|echo|error|unmac
	;
unmac	:	Unmac WS ID->^(Unmac ID)
	;
define	:	Define WS ID (WS vals+=(ID|INT|string|FLOAT|(dataSequence)=>dataSequence|(command)=>command|condition))+
			->^(Define ID $vals+)
	;
macro	:	Macro WS  ID ws LParen ws params ws RParen WS?
			(expression*)
		EndMac ->^(Macro ID ^(Params params*) expression*)
	;
preIf	:	PreIf WS condition WS?
			expression*
		 preElseIf*
		 preElse?
		 endIf ->^(PreIf condition expression* preElseIf* preElse?)
		
	;
endIf	:	NewLine! EndIf!
	;
preElse	:	NewLine PreElse WS? expression* ->^(PreElse expression*)
	;
preElseIf
	:	NewLine PreElseIf WS? condition expression*->^(PreElse condition expression*)
	;
ifDef	:	IfDef WS ID
		preElse?
		endIf ->^(IfDef ID preElse?)
	;
ifNDef	:	IfNDef WS ID
		preElse?
		endIf ->^(IfNDef ID preElse?)
	;
echo	:	Echo WS lineArg*->^(Echo lineArg*)
	;
error	:	Error WS lineArg*->^(Error lineArg*)
	;
include	:	Include WS string->^(Include string)
	;
string	:	(Quote 
			val+=((dataSequence)=>dataSequence|quoteString)*
		Quote)->^(STRING $val*)
	;
quoteString
	:	~(Quote)
	;
dataSequence
	:	Dollar LCurly accessor member? RCurly ->^(Dollar accessor member?)
	;
id	:	ID id? ->^(ID id?)
	|	dataSequence id?
	;
member	:	Dot accessor member? ->^(Dot accessor member?)
	|	Colon accessor member?->^(Colon accessor member?)
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
function:	Function(Colon returnType=ID)?WS name=ID params NewLine codeBlock
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

command	:	(dataCommand)=>dataCommand (Semi command)?->^(DataCommand dataCommand)command?
	|	(ID)=>(ID WS) commandArg* (Semi command)?->^(COMMAND ID commandArg*) command?
	|	(dataSequence WS)=>(dataSequence) commandArg* (Semi command)?->^(COMMAND dataSequence commandArg*) command?
		
	;

commandArg
	:	(ID)=>ID|(dataSequence)=>dataSequence
		|(string)=>string|(INT)=>INT|(FLOAT)=>FLOAT
		|(math)=>math->^(MATH math)
		|(~(NewLine|Semi))
	;
expression
	:	(NewLine!)(command|declareVariable|preProcessor|variableDeclare|forStatement
				|doStatement|whileStatement|ifStatement|switchStatement|codeBlock)?
	;
params	:	LParen ws Elipse WS ID ws RParen->^(Params ^(Param Elipse ID))
	|	LParen ws (param (ws Comma ws param)*)? ws RParen->^(Params param*)
		
	;
param	:	((type=ID WS name=ID)|name=ID)(ws Assign ws value)?
			->^(Param ^(Type $type?)^($name ^(Assign value)?))
	;

ifStatement
	:	If ws ifCondition=condition WS? ifExpression=expression
		((NewLine ElseIf)=>NewLine elseIfs+=ElseIf elseifCondition+=condition elseifexpression+=expression)*
		((NewLine Else)=>NewLine Else elseexpression+=expression)?
			->^(If $ifCondition $ifExpression ^($elseIfs $elseifCondition $elseifexpression)* ^(Else $elseexpression)?)
	;	
doStatement
	:	Do expression NewLine While condition->^(Do expression condition)
	;
whileStatement
	:	While condition expression->^(While condition expression)
	;
forStatement
	:	(For ws LParen ws command ws Semi ws condition ws Semi ws command RParen)=>(For ws LParen ws command ws Semi ws condition ws Semi ws command ws RParen)WS? expression
			->^(For command condition command)
	|	(For ws LParen ws condition ws Semi ws command ws RParen)=>(For ws LParen ws condition ws Semi ws command ws RParen)WS?expression
			->^(For COMMAND condition command)
	|	(For ws LParen ws command ws Semi ws command ws RParen)WS? expression
			->^(For command CONDITION command)
	;

conditionValue
	:	(
			(Negate
			((ID)=>ID->^(Negate ID)
			|(dataSequence)=>dataSequence->^(Negate dataSequence)
			|(string)=>string->^(Negate string)
			|(INT)=>INT->^(Negate INT)
			|(FLOAT)=>FLOAT->^(Negate FLOAT)
			|(math)=>math->^(Negate ^(MATH math))
			| conditionString)->^(Negate conditionString))
		)
		|
		(
			(ID)=>ID->ID
			|(dataSequence)=>dataSequence->dataSequence
			|(string)=>string->string
			|(INT)=>INT->INT
			|(FLOAT)=>FLOAT->FLOAT
			|(math)=>math->^(MATH math)
			| conditionString->conditionString
		)
	;
conditionString
	:	~(Comparer|LParen|RParen|NewLine)
	;
math	:	bitXor (Bor^ bitXor)*
	;
bitXor	:	bitAnd (Xor^ bitAnd)*
	;
bitAnd	:	shift (Band^ shift)*
	;
shift	:	addSub ((LeftShift^|RightShift^) addSub)*
	;
addSub	:	multDiv ((Plus^|Minus^) multDiv)*
	;
multDiv	:	bitNegate ((Mult^|Div^|Modu^) bitNegate)*
	;
bitNegate
	:	mathVal (Bnegate^ mathVal)*
	;
mathVal	:	LParen! math RParen!
	|	(INT|FLOAT|dataSequence)
	;
ws	:	NewLine!? WS!?
	;
	
condition
	:	ws 
	(	LParen ws condition ws RParen (orCondition|andCondition)?
			->condition orCondition? andCondition?
	|	Negate ws LParen ws condition ws RParen (orCondition|andCondition)?
			->^(Negate condition) orCondition? andCondition?
	|	(conditionValue ws Comparer)=>conditionValue ws Comparer ws conditionValue (orCondition|andCondition)?
			->^(CONDITION ^(Comparer conditionValue conditionValue) orCondition? andCondition?)
	|	conditionValue (orCondition|andCondition)?->^(CONDITION conditionValue orCondition? andCondition?)
	)
	;
orCondition
	:	Or condition->^(Or condition)
		
	;
andCondition
	:	And condition->^(And condition)
	;

variableDeclare
	:	Variable(LParen Scope RParen)? WS type=ID WS name=ID indexer? (ws Assign ws lineArg (WS lineArg)*)?
			-> ^(Variable Scope?  ^($type indexer? ^($name  ^(Assign lineArg*)?)))
	;
codeBlock
	:	LCurly
		expression+
		 RCurly->^(CodeBlock expression+)
	;
declareVariable
	:	DeclareVariable WS name=ID indexer? WS type=ID WS(Scope (WS lineArg)*)?
			-> ^(DeclareVariable Scope?  ^($type indexer? ^($name  ^(Assign lineArg*)?)))
	;
value	:	ID|dataSequence|string|INT|FLOAT
	;
accessor:	id (indexer|typeCast)*
	;
indexer	:	LSquare (commaValue (Comma commaValue)*)? RSquare->^(LSquare commaValue*)
	;
commaValue
	:	commaArg+->^(IndexerValue commaArg+)
	;
typeCast:	LParen id RParen -> ^(LParen id)
	;