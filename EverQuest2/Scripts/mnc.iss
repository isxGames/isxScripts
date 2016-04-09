

function main()
{       
        call Initialize

	do
	{
		call Check_Triggers
	
	}
	while 1 		
}

; ================================================================
; ===   Initializing Script!				       ===
; ================================================================
function Initialize()
{
  EQ2Echo Initializing MyNameChecker!

  call Clear_Triggers

  AddTrigger FullRecieved "@*@YourName@*@"
  AddTrigger ShortRecieved "@*@YourNickName@*@"
  AddTrigger TellRecieved "\\aPC @*@ @*@:@sender@\\/a tells you@*@@*@"
  AddTrigger SayRecieved "\\aPC @*@ @*@:@sender@\\/a says,@*@@*@"

}


; ===   Resets the triggers so we dont get spammed with tells  ===
; ===   This should be run BEFORE adding any triggers!         ===
; ================================================================
function Clear_Triggers()
{
	do 
	{
		ExecuteQueued 
	}
	while ${QueuedCommands}
}



; ================================================================
; ===   This function will check any queued events. This can   ===
; ===   can maximum be activated so often as the given var in  ===
; ===   Initialize()                                           ===
; ================================================================
function Check_Triggers() 
{
   If ${Math.Calc[${Time.Timestamp}-${triggerTime.Timestamp}]}>=${triggerCheckTimer}
   {

	if ${QueuedCommands} 
	{

		EQ2Echo Your name is noticed!

		do 
		{
			ExecuteQueued 
		}
		while ${QueuedCommands}
	}

	triggerTime:Set[${Time.Timestamp}]
   }
}

; ================================================================
; ===   Tells the bot master if our bot recieves a tell        ===
; ================================================================
function TellRecieved(string Line, string sender)
{
   EQ2Echo Someone is talking to you!

   call PlaySound "Scripts/Sounds/IncommingChat.wav"

}


; ================================================================
; ===   Tells the bot master if our bot recieves a tell        ===
; ================================================================
function SayRecieved(string Line, string sender)
{
   EQ2Echo Someone is talking to you!

   call PlaySound "Scripts/Sounds/IncommingChat.wav"

}


; ================================================================
; ===   Tells the bot master if our bot recieves a tell        ===
; ================================================================
function FullRecieved(string Line, string sender)
{
   EQ2Echo Someone is talking to you!

   call PlaySound "Scripts/Sounds/IncommingChat.wav"

}

; ================================================================
; ===   Tells the bot master if our bot notice a say near him  ===
; ================================================================
function ShortRecieved(string Line, string sender)
{
   EQ2Echo Someone is talking to you!

   call PlaySound "Scripts/Sounds/IncommingChat.wav"

}


; ================================================================
; ===   Playing the given sound!			       ===
; ================================================================
function PlaySound(string Filename) 
{ 
System:APICall[${System.GetProcAddress[WinMM.dll,PlaySound].Hex},Filename.String,0,"Math.Dec[22001]"] 
}
; ================================================================
; ===   Runs when script ends				       ===
; ================================================================
function atexit()
{
	
	EQ2Echo MyNameChecker is now exiting!
}

