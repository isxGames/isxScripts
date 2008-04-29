;-----------------------------------------------------------------------------------------------
; EQ2NavCreator.iss Version 1  Updated: 04/28/2008
;
; Written by: Amadeus  (Based upon EQ2PatherLegacy.iss by Blazer)
;
; v1.0 - * Initial Release
;-----------------------------------------------------------------------------------------------

#include ${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/EQ2Nav_Lib.iss

#define ADDNAMEPOINT f2
#define SAVEPOINTS f3
#define QUIT f11

function main()
{
    declarevariable Mapper EQ2Mapper global
	declarevariable CurrentTask int global
    declarevariable HudX int script
    declarevariable HudY int script
    
	Script:Squelch

	; Set the default location of the HUD
	HudX:Set[230]
	HudY:Set[200]

	echo "---------------------------"
	echo "EQ2NavCreator:: Initializing."
    Mapper:Initialize
    Mapper:LoadMapper	
	echo "EQ2NavCreator:: Initialization complete."
    echo "---------------------------"

	bind addnamepoint "ADDNAMEPOINT" "CurrentTask:Set[1]"
	bind savepoints "SAVEPOINTS" "CurrentTask:Set[2]"
	bind quit "QUIT" "CurrentTask:Set[3]"

	HUD -add FunctionKey2 ${HudX},${HudY:Inc[15]} "ADDNAMEPOINT - Adds a Navigational Point with a Label you specify."
	HUD -add FunctionKey3 ${HudX},${HudY:Inc[15]} "SAVEPOINTS - Saves ALL Navigational Points."
	HUD -add FunctionKey11 ${HudX},${HudY:Inc[15]} "QUIT - Exit EQ2NavCreator (and save all navigation points)"
	
	HUD -add NavPointStatus ${HudX},${HudY:Inc[30]} "Last Nav Point Added: \${Mapper.LastRegionAdded_Name} [\${Mapper.LastRegionAdded_X.Precision[2]}(x) \${Mapper.LastRegionAdded_Y.Precision[2]}(y) \${Mapper.LastRegionAdded_Z.Precision[2]}(z)]"
	HUD -add NavCountStatus ${HudX},${HudY:Inc[15]} "Total Number of Points Used: \${Mapper.CurrentZone.ChildCount}"
	
	HUDSet NavPointStatus -c FFFF00
	HUDSet NavCountStatus -c FFFF00	
	
	
	if ${Mapper.CurrentZone.ChildCount}==0
	{
		CurrentTask:Set[1]
	}

	Do
	{
		switch ${CurrentTask}
		{
			case 1
				CurrentTask:Set[0]
				InputBox "What name do you want to give this NavPoint?"
				if ${UserInput.Length}
				{
					Mapper:MapLocation[${Me.X},${Me.Y},${Me.Z},${UserInput}]
					announce "\\#FF6E6ENavigational Point Added" 1 2
				}
				break
			case 2
				CurrentTask:Set[0]
				Mapper:Save
				announce "Navigational Points have been Saved" 1 3
				break
			case 3
				CurrentTask:Set[99]
				break
		}
		
		Mapper:Pulse
		waitframe
	}
	while ${CurrentTask}<4

	Script:End
}

function atexit()
{
    Mapper:Save
    
	bind -delete addnamepoint
	bind -delete savepoints
	bind -delete quit

	HUD -remove FunctionKey2
	HUD -remove FunctionKey3
	HUD -remove FunctionKey11
	HUD -remove NavPointStatus
	HUD -remove NavCountStatus
}
