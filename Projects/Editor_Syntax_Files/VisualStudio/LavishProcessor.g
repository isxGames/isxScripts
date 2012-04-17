tree grammar LavishProcessor;
options {
	tokenVocab=LavishScript;
	ASTLabelType=CommonTree;
}
script	:	scriptStructure+
	;
scriptStructure
	:	variableDeclare
	|	function
	|	atom
	|	objectDef
	|	preProcessor
	;
objectDef
	:	^(ObjectDef ^(ID (function|atom|objectMethod|objectMember|variableDeclare)*) (^(Inherits ID))?)
	;
variableDeclare
	:	^(Variable Scope? ID indexer? ^(ID(^(Assign lineArg*))?))
	;
function:	^(Function ID ^(Returns ID?) ^(Params params?) codeBlock)
	;
atom	:	^(Atom ID ^(Returns ID?) ^(Params params?) codeBlock)
	;
objectMember
	:	^(Member ID ^(Returns ID?) ^(Params params?) codeBlock)
	;
objectMethod
	:	^(Atom ID ^(Returns ID?) ^(Params params?) codeBlock)
	;
params	:	^(Param ^(Type Elipse) ID)
	|	param*
	;
param	:	^(Param ^(Type ID?) ^(ID (^(Assign value*))?))
	;
value	:	ID|dataSequence|string|INT|FLOAT|(~(WS|NewLine))
	;
dataSequence
	:	^(Dollar accessor member?)
	;
accessor:	id (indexer|typeCast)*
	;
id	:	^(ID id?)
	|	dataSequence id?
	;
typeCast:	^(LParen id)
	;
member	:	^(Dot accessor member?)
	|	^(Colon accessor member?)
	;
string	:	^(STRING (dataSequence|quoteString)*)
	;
quoteString
	:	~(Quote)
	;
math	:	^(Bor math math)
	|	^(Xor math math)
	|	^(Band math math)
	|	^(LeftShift math math)
	|	^(RightShift math math)
	|	^(Plus math math)
	|	^(Minus math math)
	|	^(Mult math math)
	|	^(Div math math)
	|	^(Modu math math)
	|	^(Bnegate math math)
	|	INT
	|	FLOAT
	|	dataSequence
	;
commaVals
	:	commaArg+
	;

commaArg:	ID
	|	dataSequence
	|	string
	|	INT
	|	FLOAT
	|	^(MATH math)
	|	~(Comma|RSquare)
	;
command	:	^(DataCommand dataCommand)
	|	^(COMMAND ID commandArg*)
	|	^(COMMAND dataSequence commandArg*)
	;

dataCommand
	:	accessor member
	;
commandArg
	:	ID
	|	dataSequence
	|	string
	|	INT
	|	FLOAT
	|	^(MATH math)
	|	~(NewLine|Semi)
	;
indexer	:	^(LSquare (^(IndexerValue commaArg+))? (^(IndexerValue commaVals))*)
	;
lineArg	:	ID
	|	dataSequence
	|	string
	|	INT
	|	FLOAT
	|	^(MATH math)
	|	~NewLine
	;
codeBlock
	:	^(CodeBlock expression+)
	;
expression
	:	(command|declareVariable|preProcessor|variableDeclare|forStatement
				|doStatement|whileStatement|ifStatement|switchStatement|codeBlock)?
	;
declareVariable
	:	^(DeclareVariable Scope?  ^(ID indexer? ^(ID  (^(Assign lineArg*))?)))
	;
preProcessor
	:	include|define|macro|preIf|ifDef|ifNDef|echo|error|unmac
	;
include	:	
	;
define	:	^(Define ID (ID|INT|string|FLOAT|dataSequence|dataCommand|condition)+)
	;
condition
	:	^(Negate condition) orCondition? andCondition?
	|	^(CONDITION conditionValue orCondition? andCondition?)
	|	^(CONDITION ^(Comparer conditionValue conditionValue) orCondition? andCondition?)
	|	^(CONDITION orCondition? andCondition?)
	;
conditionValue
	:	^(Negate ID)
	|	^(Negate dataSequence)
	|	^(Negate string)
	|	^(Negate INT)
	|	^(Negate FLOAT)
	|	^(Negate ^(MATH math))
	|	^(Negate conditionString)
	|	ID
	|	dataSequence
	|	string
	|	INT
	|	FLOAT
	|	^(MATH math)
	|	conditionString
	;
conditionString
	:	~(Comparer|LParen|RParen|NewLine)
	;
orCondition
	:	^(Or condition)
	;
andCondition
	:	^(And condition)
	;
macro	:	^(Macro ID ^(Params params*) expression*)
	;
preIf	:	^(PreIf condition expression* preElseIf* preElse?)
	;
preElseIf
	:	^(PreElse condition expression*)
	;
preElse	:	^(PreElse expression*)
	;
ifDef	:	^(IfDef ID preElse?)
	;
ifNDef	:	^(IfNDef ID preElse?)
	;
echo	:	^(Echo lineArg*)
	;
error	:	^(Error lineArg*)
	;
unmac	:	^(Unmac ID)
	;
forStatement
	:	^(For command condition command)
	|	^(For COMMAND condition command)
	|	^(For command CONDITION command)
	;
doStatement
	:	^(Do expression condition)
	;
whileStatement
	:	^(While condition expression)
	;
ifStatement
	:	^(If condition expression (^(ElseIf condition expression))* (^(Else expression))?)
	;
switchStatement
	:	^(Switch ^(Param lineArg+) switchCase* defaultCase?)
	;
switchCase
	:	^(Case ^(Param lineArg+) expression*)
	|	^(VariableCase dataSequence expression*)
	;
defaultCase
	:	^(Default expression*)
	;