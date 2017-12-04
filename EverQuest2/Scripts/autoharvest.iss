function init()
{
	declare triggerCheckTimer int script 5
		
	
	;SCANS CHAT FOR THESE KEYWORDS AND THEN CALLS THE PRECEDING FUNCTION 	
	AddTrigger Harvest "@*@You mined@*@"
	AddTrigger Harvest "@*@You mine@*@"
	AddTrigger Harvest "@*@You fail to mine@*@"
	AddTrigger Harvest "@*@You failed to mine@*@"
	AddTrigger Harvest "@*@You acquire@*@"
	AddTrigger Harvest "@*@You failed to trap@*@"
	AddTrigger Harvest "@*@You gather@*@"
	AddTrigger Harvest "@*@You failed to gather@*@"
	AddTrigger Harvest "@*@You fail to gather@*@"
	AddTrigger Harvest "@*@You forest@*@"
	AddTrigger Harvest "@*@You fail to forest@*@"
	AddTrigger Harvest "@*@You failed to forest@*@"	
	AddTrigger Harvest "@*@You fish@*@"
	AddTrigger Harvest "@*@You fail to fish@*@"
	AddTrigger Harvest "@*@You failed to fish@*@"
	AddTrigger Harvest "@*@You catch@*@"
	AddTrigger Harvest "@*@You fail to catch@*@"
	AddTrigger Harvest "@*@You failed to catch@*@"
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


;THE Harvest FUNCTION FOR ALL NODE TYPES
;Daybreak changed it so all nodes in PoP trigger "acquire"
;so I updated the script to one function for all nodes
function Harvest(string Line)
{
	;IF TARGET IS A RESOURCE AND I AM ALSO NOT IN COMBAT, DO THIS ABILITY ON MY TARGET
	if ${Target.Type.Equal[resource]} && !${Me.InCombat}
	{
		Actor[${Me.Target}]:DoubleClick
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
