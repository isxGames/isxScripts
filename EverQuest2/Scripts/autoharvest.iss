function init()
{
	declare triggerCheckTimer int script 5
		
	
	;SCANS CHAT FOR THESE KEYWORDS AND THEN CALLS THE PRECEDING FUNCTION 	
	AddTrigger Mining "@*@You mined@*@"
	AddTrigger Mining "@*@You mine@*@"
	AddTrigger Mining "@*@You fail to mine@*@"
	AddTrigger Mining "@*@You failed to mine@*@"
	AddTrigger Trapping "@*@You acquire@*@"
	AddTrigger Trapping "@*@You failed to trap@*@"
	AddTrigger Gathering "@*@You gather@*@"
	AddTrigger Gathering "@*@You failed to gather@*@"
	AddTrigger Gathering "@*@You fail to gather@*@"
	AddTrigger Foresting "@*@You forest@*@"
	AddTrigger Foresting "@*@You fail to forest@*@"
	AddTrigger Foresting "@*@You failed to forest@*@"	
	AddTrigger Fishing "@*@You fish@*@"
	AddTrigger Fishing "@*@You fail to fish@*@"
	AddTrigger Fishing "@*@You failed to fish@*@"
	AddTrigger Fishing "@*@You catch@*@"
	AddTrigger Fishing "@*@You fail to catch@*@"
	AddTrigger Fishing "@*@You failed to catch@*@"

}


function main()
{
   ;THIS IS MAIN FUNCTION WHERE WE ARE ACTUALLY SCANNING
   call init
   do
      {
	call Check_Triggers
      }
   ;THIS MAKES THE FUNCTION LOOP ENDLESSLY
   while 0 < 1
}


;THE INDIVIDUAL FUNCTIONS FOR EACH NODE TYPE
function Mining(string Line)
{
	;IF TARGET IS A RESOURCE AND I AM ALSO NOT IN COMBAT, DO THIS ABILITY ON MY TARGET
	if ${Target.Type.Equal[resource]} && !${Me.InCombat}
	{
		EQ2Execute /useability Mining
	}
}

function Trapping(string Line)
{
	if ${Target.Type.Equal[resource]} && !${Me.InCombat}
	{
		EQ2Execute /useability Trapping		
	}
}

function Gathering(string Line)
{
	if ${Target.Type.Equal[resource]} && !${Me.InCombat}
	{
		EQ2Execute /useability Gathering		
	}
}

function Foresting(string Line)
{
	if ${Target.Type.Equal[resource]} && !${Me.InCombat}
	{
		EQ2Execute /useability Foresting		
	}
}

function Fishing(string Line)
{
	if ${Target.Type.Equal[resource]} && !${Me.InCombat}
	{
		EQ2Execute /useability Fishing		
	}
}




;THIS FUNCTION IS COMPLETELY LIFTED FROM THE DRUID PORT BOT SCRIPT BY SYLIAC
function Check_Triggers() 
{
   If ${Math.Calc[${Time.Timestamp}-${triggerTime.Timestamp}]}>=${triggerCheckTimer}
   {

	if ${QueuedCommands} 
	{

		do 
		{
			ExecuteQueued 
		}
		while ${QueuedCommands}
	}

	triggerTime:Set[${Time.Timestamp}]
   }
}
