tree grammar LavishProcessor;
options {
	tokenVocab=LavishScript;
	ASTLabelType=CommonTree;
	language=CSharp3;
}
public script
	:	scriptStructure+
	;
public scriptStructure
	:	variableDeclare 
	|	function 
	|	atom 
	|	objectDef
	|	preProcessor
	;
public objectDef
	:	^(ObjectDef ^(ID (function|atom|objectMember|variableDeclare|objectMethod)*) (^(Inherits ID))?)
	;
public variableDeclare
	:	^(Variable Scope? ID indexer? ^(ID(^(Assign lineArg*))?))
	;
public function
	:	^(Function ID ^(Returns ID?) params codeBlock)
	;
public atom
	:	^(Atom ID ^(Returns ID?) params codeBlock)
	;
public objectMember
	:	^(Member ID ^(Returns ID?) params codeBlock)
	;
public objectMethod
	:	^(Method ID ^(Returns ID?) params codeBlock)
	;
public params
	:	^(Params ^(Param Elipse ID))
	|	^(Params (^(Param ^(Type ID?)) ^(ID ^(Assign value)))*)
	;
public value
	:	ID|dataSequence|string|INT|FLOAT|(~(WS|NewLine))
	;
public dataSequence
	:	^(Dollar accessor member?)
	;
public accessor
	:	id (indexer|typeCast)*
	;
public id
	:	^(ID id?)
	|	dataSequence id?
	;
public typeCast
	:	^(LParen id)
	;
public member
	:	^(Dot accessor member?)
	|	^(Colon accessor member?)
	;
public string
	:	^(STRING (dataSequence|quoteString)*)
	;
public quoteString
	:	~(Quote)
	;
public math
	:	^(Bor math math)
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
public commaVals
	:	commaArg+
	;

public commaArg
	:	ID
	|	string
	|	math
	|	~(Comma|RSquare)
	;
public command
	:	^(DataCommand dataCommand)
	|	^(COMMAND ID commandArg*)
	|	^(COMMAND dataSequence commandArg*)
	;

public dataCommand
	:	accessor member
	;
public commandArg
	:	ID
	|	string
	|	math
	|	~(NewLine|Semi)
	;
public indexer
	:	^(LSquare commaValue*)
	;
public commaValue
	:	^(ARG commaArg+)
	;
public lineArg
	:	ID
	|	string
	|	math
	|	~NewLine
	;
public codeBlock
	:	^(CodeBlock expression*)
	;
public expression
	:	command|declareVariable|preProcessor
			|variableDeclare|forStatement
				|doStatement|whileStatement|ifStatement|switchStatement|codeBlock
	;
public declareVariable
	:	^(DeclareVariable Scope?  ^(ID indexer? ^(ID  (^(Assign lineArg*))?)))
	;
public preProcessor
	:	include
	|	define
	|	macro
	|	preIf
	|	ifDef
	|	ifNDef
	|	echo
	|	error
	|	unmac
	;
public include
	:	^(Include string)
	;
public define
	:	^(
		Define 
			(ID
			|INT
			|string
			|FLOAT
			|dataSequence
			|command
			|condition
			)+
		)
	;
public condition
	:	^(Negate condition) orCondition? andCondition?
	|	^(CONDITION conditionValue orCondition? andCondition?)
	|	^(CONDITION ^(Comparer conditionValue conditionValue) orCondition? andCondition?)
	|	^(CONDITION orCondition? andCondition?)
	;
public conditionValue
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
public conditionString
	:	~(Comparer|LParen|RParen|NewLine)
	;
public orCondition
	:	^(Or condition)
	;
public andCondition
	:	^(And condition)
	;
public macro
	:	^(Macro ID ^(Params params) expression*)
	;
public preIf
	:	^(PreIf condition expression* preElseIf* preElse?)
	;
public preElseIf
	:	^(PreElse condition expression*)
	;
public preElse
	:	^(PreElse expression*)
	;
public ifDef
	:	^(IfDef ID preElse?)
	;
public ifNDef
	:	^(IfNDef ID preElse?)
	;
public echo
	:	^(Echo lineArg*)
	;
public error
	:	^(Error lineArg*)
	;
public unmac
	:	^(Unmac ID)
	;
public forStatement
	:	^(For command condition command)
	;
public doStatement
	:	^(Do expression condition)
	;
public whileStatement
	:	^(While condition expression)
	;
public ifStatement
	:	^(If condition expression (^(ElseIf condition expression))* (^(Else expression))?)
	;
public switchStatement
	:	^(Switch ^(Param lineArg+) switchCase* defaultCase?)
	;
public switchCase
	:	^(Case ^(Param lineArg+) expression)
	|	^(VariableCase dataSequence expression)
	;
public defaultCase
	:	^(Default expression)
	;