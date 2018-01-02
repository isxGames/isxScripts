parser grammar LavishScript;
options{
	output=AST;
	tokenVocab=LavishTokens;
	ASTLabelType=CommonTree;
	language=CSharp3;
}
public script	:	NewLine* scriptStructure (NewLine+ scriptStructure)* NewLine?->scriptStructure+
	;

public scriptStructure
	:	variableDeclare|function|atom|objectDef|preProcessor
	;

public preProcessor
	:	(include)=>include|define|macro|preIf|ifDef|ifNDef|echo|error|unmac
	;
public unmac
	:	Unmac WS ID->^(Unmac ID)
	;
public define
	:	Define WS ID (
			WS vals+=
			(
				ID
			|	INT
			|	string
			|	FLOAT
			|	(dataSequence)=>dataSequence
			|	(command)=>command
			|	condition
			)
			)+
			->^(Define ID $vals+)
	;
public macro
	:	Macro WS  ID ws LParen ws params ws RParen WS?
			(expression*)
		EndMac ->^(Macro ID ^(Params params*) expression*)
	;
public preIf
	:	PreIf WS condition WS?
			expression*
		 preElseIf*
		 preElse?
		 endIf ->^(PreIf condition expression* preElseIf* preElse?)
		
	;
public endIf
	:	NewLine! EndIf!
	;
public preElse
	:	NewLine PreElse WS? expression* ->^(PreElse expression*)
	;
public preElseIf
	:	NewLine PreElseIf WS? condition expression*->^(PreElse condition expression*)
	;
public ifDef
	:	IfDef WS ID
		preElse?
		endIf ->^(IfDef ID preElse?)
	;
public ifNDef
	:	IfNDef WS ID
		preElse?
		endIf ->^(IfNDef ID preElse?)
	;
public echo
	:	Echo WS lineArg*->^(Echo lineArg*)
	;
public error
	:	Error WS lineArg*->^(Error lineArg*)
	;
public include
	:	Include WS string->^(Include string)
	;
public string
	:	(Quote 
			val+=((dataSequence)=>dataSequence|quoteString)*
		Quote)->^(STRING $val*)
	;
public quoteString
	:	~(Quote)
	;
public dataSequence
	:	Dollar LCurly accessor member? RCurly ->^(Dollar accessor member?)
	;
public id
	:	ID id? ->^(ID id?)
	|	dataSequence id?
	;
public member
	:	Dot accessor member? ->^(Dot accessor member?)
	|	Colon accessor member?->^(Colon accessor member?)
	;

public dataCommand
	:	accessor member
	;
public switchStatement
	:	Switch (lineArg+) NewLine
		LCurly
		(NewLine NewLine* switchCase)*
		(NewLine NewLine* defaultCase)?
		NewLine RCurly
		->^(Switch ^(Param lineArg+) switchCase* defaultCase?)
	;
public switchCase
	:	Case lineArg+ expression* ->^(Case ^(Param lineArg+) expression*)
	|	VariableCase dataSequence expression*->^(VariableCase dataSequence expression*)
	;
public defaultCase
	:	Default^ expression*
	;

public objectDef
	:	ObjectDef WS ID WS (Inherits WS ID)? NewLine
		LCurly
			(NewLine+ (members+=function|members+=atom|members+=objectMethod|members+=objectMember|members+=variableDeclare)?)+
		RCurly
			->^(ObjectDef ^(ID $members*) ^(Inherits ID)?)
	;
public function
	:	Function(Colon returnType=ID)?WS name=ID params NewLine codeBlock
			->^(Function $name ^(Returns $returnType?)  params? codeBlock)
	;
public atom
	:	Atom(Colon returnType=ID)? name=ID LParen params? RParen NewLine codeBlock
			->^(Atom $name ^(Returns $returnType?) params? codeBlock)
	;
public objectMember
	:	Member(Colon returnType=ID)? name=ID LParen params? RParen NewLine codeBlock
			->^(Member $name ^(Returns $returnType?) params? codeBlock)
	;
public objectMethod
	:	Method(Colon returnType=ID)? name=ID LParen params? RParen NewLine codeBlock
			->^(Method $name ^(Returns $returnType?) params? codeBlock)
	;

public command
	:	(dataCommand)=>dataCommand (Semi command)?->^(DataCommand dataCommand)command?
	|	(ID)=>(ID WS) commandArg* (Semi command)?->^(COMMAND ID ^(ARG commandArg*)) command?
	|	(dataSequence WS)=>(dataSequence) commandArg* (Semi command)?->^(COMMAND dataSequence ^(ARG commandArg*)) command?
		
	;

public expression
	:	NewLine! WS!? 
		(
		command
	|	declareVariable
	|	preProcessor
	|	variableDeclare
	|	forStatement
	|	doStatement
	|	whileStatement
	|	ifStatement
	|	switchStatement
	|	codeBlock
		)?
		WS!?
	;
public params
	:	LParen ws Elipse WS ID ws RParen->^(Params ^(Param Elipse ID))
	|	LParen ws (param (ws Comma ws param)*)? ws RParen->^(Params param*)
		
	;
public param
	:	((type=ID WS name=ID)|name=ID)(ws Assign ws value)?
			->^(Param ^(Type $type?)^($name ^(Assign value)?))
	;

public ifStatement
	:	If ws ifCondition=condition WS? ifExpression=expression
		((NewLine ElseIf)=>NewLine elseIfs+=ElseIf elseifCondition+=condition elseifexpression+=expression)*
		((NewLine Else)=>NewLine Else elseexpression+=expression)?
			->^(If $ifCondition $ifExpression ^($elseIfs $elseifCondition $elseifexpression)* ^(Else $elseexpression)?)
	;	
public doStatement
	:	Do expression NewLine While condition->^(Do expression condition)
	;
public whileStatement
	:	While condition expression->^(While condition expression)
	;
public forStatement
	:	(For ws LParen ws command ws Semi ws condition ws Semi ws command RParen)=>(For ws LParen ws command ws Semi ws condition ws Semi ws command ws RParen)WS? expression
			->^(For command condition command)
	|	(For ws LParen ws condition ws Semi ws command ws RParen)=>(For ws LParen ws condition ws Semi ws command ws RParen)WS?expression
			->^(For COMMAND condition command)
	|	(For ws LParen ws command ws Semi ws command ws RParen)WS? expression
			->^(For command CONDITION command)
	;

public conditionValue
	:	(
			(Negate
			(ID->^(Negate ID)
			|string->^(Negate string)
			|(math)=>math->^(Negate math)
			|conditionString)->^(Negate conditionString))
		)
		|
		(
			(ID
			|string
			|(math)=>math
			|conditionString)
		)
	;
public conditionString
	:	~(Comparer|LParen|RParen|NewLine)
	;
public math
	:	bitXor (Bor^ bitXor)*
	;
public bitXor
	:	bitAnd (Xor^ bitAnd)*
	;
public bitAnd
	:	shift (Band^ shift)*
	;
public shift
	:	addSub ((LeftShift^|RightShift^) addSub)*
	;
public addSub
	:	multDiv ((Plus^|Minus^) multDiv)*
	;
public multDiv
	:	bitNegate ((Mult^|Div^|Modu^) bitNegate)*
	;
public bitNegate
	:	mathVal (Bnegate^ mathVal)*
	;
public mathVal
	:	LParen! math RParen!
	|	(INT|FLOAT|dataSequence)
	;
public ws
	:	NewLine!? WS!?
	;
public lineArg
	:	ID
	|	string
	|	(math)=>math
	|	(~NewLine)
	;
public commaArg
	:	ID
	|	string
	|	(math)=>math
	|	(~(Comma|RSquare))
	;
public commandArg
	:	ID
	|	string
	|	(math)=>math
	|	~(NewLine|Semi)
	;
public condition
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
public orCondition
	:	Or condition->^(Or condition)
		
	;
public andCondition
	:	And condition->^(And condition)
	;

public variableDeclare
	:	Variable(LParen Scope RParen)? WS type=ID WS name=ID indexer? (ws Assign ws lineArg (WS lineArg)*)?
			-> ^(Variable Scope?  ^($type indexer? ^($name  ^(Assign lineArg*)?)))
	;
public codeBlock
	:	LCurly
		expression+
		 RCurly->^(CodeBlock expression+)
	;
public declareVariable
	:	DeclareVariable WS name=ID indexer? WS type=ID WS(Scope (WS lineArg)*)?
			-> ^(DeclareVariable Scope?  ^($type indexer? ^($name  ^(Assign lineArg*)?)))
	;
public value	:	ID|dataSequence|string|INT|FLOAT
	;
public accessor:	id (indexer|typeCast)*
	;
public indexer	:	LSquare (commaValue (Comma commaValue)*)? RSquare->^(LSquare commaValue*)
	;
public commaValue
	:	commaArg+->^(ARG commaArg+)
	;
public typeCast:	LParen id RParen -> ^(LParen id)
	;