;Druid Port Bot v1.0 2.30.07
; By Syliac

function initPortBot()
{
	declare FollowMode bool script 0
	declare triggerCheckTimer int script 5
	
	
	
	call Clear_Triggers
	
	AddTrigger QueueCommonlands "\\aPC @*@ @*@:@sender@\\/a tells@*@Port to Commonlands Please!@*@"
	AddTrigger QueueAntonica "\\aPC @*@ @*@:@sender@\\/a tells@*@Port to Antonica Please!@*@"	
	AddTrigger QueueButcherBlock "\\aPC @*@ @*@:@sender@\\/a tells@*@Port to ButcherBlock Please!@*@"
	AddTrigger QueueGfay "\\aPC @*@ @*@:@sender@\\/a tells@*@Port to Gfay Please!@*@"
	AddTrigger QueueSteamfont "\\aPC @*@ @*@:@sender@\\/a tells@*@Port to Steamfont Please!@*@"
}

function main(int Follow)
{
	EQ2Echo Initializing Druid Port Bot!
	
	call initPortBot
	FollowMode:Set[${Follow}]
	
	do
	{
		call Check_Triggers
	
	}
	while 1 	
	
}

function QueueCommonlands(string Line, string sender)
{
	EQ2Echo Porting to Commonlands
	
	call CastPort Commonlands
}

function QueueAntonica(string Line, string sender)
{
	EQ2Echo Porting to Antonica
	
	call CastPort Antonica
}

function QueueButcherBlock(string Line, string sender)
{
	EQ2Echo Porting to ButcherBlock
	
	call CastPort ButcherBlock
}

function QueueGfay(string Line, string sender)
{
	EQ2Echo Porting to Gfay
	
	call CastPort Gfay
}

function QueueSteamfont(string Line, string sender)
{
	EQ2Echo Porting to Steamfont
	
	call CastPort Steamfont
}


function CastPort(string destination)
{
	switch ${destination}
	{
		case Commonlands
			Me.Ability[Circle of Commonlands]:Use
			break
		case Antonica
			Me.Ability[Circle of Antonica]:Use
			break
		case ButcherBlock
			Me.Ability[Circle of ButcherBlock]:Use
			break
		case Gfay	
			Me.Ability[Circle of Greater Faydark]:Use
			break
		case Steamfont
			Me.Ability[Circle of Steamfont]:Use
			break
		case default
			Eq2echo ERROR!
			break
	}
	
	if ${FollowMode}
	{
		call ClickZone ${destination}
	}
	
}

function ClickZone(string destination)
{
	wait 200
	switch ${destination}
	{
		case Commonlands
			Actor[portal_to_commonlands]:DoubleClick
			break
		case Antonica
			Actor[portal_to_antonica]:DoubleClick
			break
		case ButcherBlock
			Actor[portal_to_butcherblock]:DoubleClick
			break
		case Gfay	
			Actor[portal_to_greater_fay]:DoubleClick
			break
		case Steamfont
			Actor[portal_to_steamfont]:DoubleClick
			break
		case default
			Eq2echo ERROR!
			break
	}
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
; ===   Runs when script ends				       ===
; ================================================================
function atexit()
{
	
	EQ2Echo Druid Port Bot is now exiting!
}