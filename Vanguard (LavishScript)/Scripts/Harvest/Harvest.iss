;-------------------------------------------------------
; Harvest Assist Bot, Updated: 2011/10/17
;-------------------------------------------------------
;
; *Written by Iremearde
;
; *Modified by
;	Zandros & mmoAddict
;
; *Special thanks to:  
;	Lax for Innerspace
;	Amadeus for ISXVG
;	Eris for assistance with original code
;	Don'tdoit for FaceSlow routines
;
; *Description:
;	This is the awesome script originally written by Iremearde that assists with harvesting.
;	- Option to:
;		Loot - simple loot that will loot everything
;		Follow - this will follow anyone as long as they are within 50 meters of you
;		Assist - will assist the player in harvesting
;		Auto Close Harvesting Window
;
; *Special Features:
;	Consoldites Resources
;	Turns slowly instead of snapping to the direction
;	Stops harvesting when the assisted player stops harvesting
;
; *Issues:
;	Auto Close Harvesting Window works but there is a glitch in Innerspace in which
;	when the program moves the mouse to the close button it does not register in VG
;	the new location despite how it appears on the screen.  The temporary solution
;	is to move the mouse to the harvesting close button and leave it there so that
;	it will -click- at that location.;	
;
; *Requirements:
;	None
;
;
;===================================================
;===              DEFINES                       ====
;===================================================
#define ALARM "./Harvest/Sounds/Ping.wav"
;
;===================================================
;===              INCLUDES                      ====
;===================================================
#include ./Harvest/Includes/FaceSlow.iss
#include ./Harvest/Includes/ConsolidateResources.iss
;
;===================================================
;===             VARIABLES                      ====
;===================================================
;
;; General variables
variable bool isRunning = TRUE
variable bool isMoving = FALSE
variable bool GIVEUP = FALSE
variable bool doEcho=TRUE
variable string Harvester
variable int64 HarvesterID
variable int FollowDist = 4
variable int i
;
;; UI Variables
variable bool autoHarvest = FALSE
variable bool autoFollow = FALSE
variable bool autoAssist = FALSE
variable bool autoLoot = FALSE
variable bool autoDrag = FALSE
variable bool autoCloseWindow = FALSE
variable int HarvX = 975
variable int HarvY = 825
variable settingsetref setSettings

variable int StopHarvestTimer = ${Script.RunningTime}

;
;===================================================
;===            MAIN SCRIPT                     ====
;===================================================
;
function main()
{
	;-------------------------------------------
	; Load ISXVG or exit script
	;-------------------------------------------
	ext -require isxvg
	wait 100 ${ISXVG.IsReady}
	if !${ISXVG.IsReady}
	{
		cho "Unable to load ISXVG, exiting script"
		endscript Harvest
	}
	wait 30 ${Me.Chunk(exists)}


	EchoIt "Started Harvest Assist Bot"
	call LoadSettings
	
	if !${Me.DTarget.ID(exists)}
	{
		Pawn[me]:Target
		wait 5
	}
	Harvester:Set[${Me.DTarget.Name}]
	HarvesterID:Set[${Me.DTarget.ID}]
	
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	ui -reload "${Script.CurrentDirectory}/Harvest.xml"
	
	while ${isRunning}
	{
		call Dist_Check
		call Harvest
		call Assist
		call Loot
		call corpse_drag
		call Close_HarvestingWindow
	}
}

function Dist_Check()
{
	if ${autoFollow}
	{
		;; Return if Harvester is missing
		if !${Pawn[name,${Harvester}](exists)}
		{
			if ${isMoving}
			{
				VG:ExecBinding[moveforward,release]
				isMoving:Set[FALSE]
			}
			return
		}
		
		;; Convert Distance and setting minimum no less than 3 meters
		variable int Distance
		Distance:Set[${Math.Calc[${FollowDist}*100].Int}]
		if ${Distance}<300
		Distance:Set[300]

		if ${Math.Distance[${Me.X},${Me.Y},${Pawn[name,${Harvester}].X},${Pawn[name,${Harvester}].Y}]} > 5500
		{
			if ${isMoving}
			{
				VG:ExecBinding[moveforward,release]
				isMoving:Set[FALSE]
			}
			return
		}
		
		;; Chase the target
		while ${Math.Distance[${Me.X},${Me.Y},${Pawn[name,${Harvester}].X},${Pawn[name,${Harvester}].Y}]} > ${Distance} && ${isRunning} && ${autoFollow}
		{
			call faceloc ${Pawn[name,${Harvester}].X} ${Pawn[name,${Harvester}].Y} 5
			if ${Math.Distance[${Me.X},${Me.Y},${Pawn[name,${Harvester}].X},${Pawn[name,${Harvester}].Y}]} < 1000
			{
				face ${Pawn[name,${Harvester}].X} ${Pawn[name,${Harvester}].Y}
			}
				
			;face ${Pawn[name,${Harvester}].X} ${Pawn[name,${Harvester}].Y}
			isMoving:Set[TRUE]
			;waitframe
			VG:ExecBinding[moveforward]
			if ${Math.Distance[${Me.X},${Me.Y},${Pawn[name,${Harvester}].X},${Pawn[name,${Harvester}].Y}]} > 5500
			{
				if ${isMoving}
				{
					VG:ExecBinding[moveforward,release]
					isMoving:Set[FALSE]
				}
				return
			}
		}

		;; Stop moving
		if ${Math.Distance[${Me.X},${Me.Y},${Pawn[name,${Harvester}].X},${Pawn[name,${Harvester}].Y}]} <= ${Distance}
		{
			if ${isMoving}
			{
				VG:ExecBinding[moveforward,release]
				isMoving:Set[FALSE]
			}
		}
	}
	else
	{
		if ${isMoving}
		{
			VG:ExecBinding[moveforward,release]
			isMoving:Set[FALSE]
		}
	}
}

function Assist()
{
	if ${autoAssist} && ${Pawn[${Harvester}].Name(exists)} && ${Pawn[${Harvester}].Distance}<=40 && ${Pawn[id,${HarvesterID}].CombatState}>0
	{
		;; Always set our target to Harvester's target
		VGExecute /assist ${Harvester}
		waitframe
	}
}

function Harvest()
{
	;; Return if we don't have a target
	if !${Me.Target(exists)}
	{
		return
	}
	
	;; Routine to initiate harvesting if Harvester began harvesting
	if ${Pawn[id,${HarvesterID}].CombatState}>0 && ${Me.ToPawn.CombatState}==0 && ${Me.Target.IsHarvestable}
	{
		;; Convert Distance and setting minimum no less than 3 meters
		variable int Distance
		Distance:Set[${Math.Calc[${FollowDist}*100].Int}]
		if ${Distance}<300
		Distance:Set[300]
		
		;; Begin moving to the target
		while ${Math.Distance[${Me.X},${Me.Y},${Me.Target.X},${Me.Target.Y}]} > ${Distance}
		{
			;; Turn slowly toward the target
			call faceloc ${Me.Target.X} ${Me.Target.Y} 20
			face ${Me.Target.X} ${Me.Target.Y}
			isMoving:Set[TRUE]
			VG:ExecBinding[moveforward]
			if !${Me.Target(exists)}
				break
		}

		;; Stop moving
		if ${isMoving}
		{
			VG:ExecBinding[moveforward,release]
			isMoving:Set[FALSE]
		}

		;; Harvest target if in range
		if ${Me.Target.Distance} <= ${FollowDist}
		{
			VGExecute /autoattack
			wait 50 ${GV[bool,bHarvesting]}
		}
	}
	
	;; Let's wait here while we are harvesting
	if ${GV[bool,bHarvesting]}
	{
		;; Turn slowly toward the target
		call faceloc ${Me.Target.X} ${Me.Target.Y} 20
	
		StopHarvestTimer:Set[${Script.RunningTime}]

		;EchoIt "Harvesting: ${Me.Target.Name} - ${Me.Target.ID}"
		;while ${GV[bool,bHarvesting]} && !${Me.Target.ContainsLoot} && ${Math.Calc[${Math.Calc[${Script.RunningTime}-${StopHarvestTimer}]}/1000]}<20
		while ${GV[bool,bHarvesting]} && ${Math.Calc[${Math.Calc[${Script.RunningTime}-${StopHarvestTimer}]}/1000]}<20
		{
			waitframe
			if !${isRunning}
			{
				return
			}
			if ${Pawn[id,${HarvesterID}].CombatState}==0 || ${Me.Target.Name.Find[remains of]} || !${Me.Target(exists)} || ${Pawn[id,${HarvesterID}].Distance}>7
			{
				break
				VGExecute /endharvesting
				waitframe
				return
			}
		}
		
		VGExecute /endharvesting
		waitframe
		
		if ${autoLoot}
		{
			Me.Target:LootAll
		}

		wait 5
	}
}

function Loot()
{
	;; Return if we don't have a target or we do not want to loot
	if !${Me.Target(exists)}
	{
		return
	}
	
	;; No looting then clear target if already harvested
	if !${autoLoot} && ${Me.Target.Name.Find[remains of]}
	{
		;; Stop attacking if you are still attacking
		if ${GV[bool,bIsAutoAttacking]}
		{
			Me.Ability[Auto Attack]:Use
			wait 5
		}

		;; Clear Target
		VGExecute "/cleartargets"
		waitframe
		return
	}

	;if ${autoLoot} && ${Me.Target.Type.Equal[Corpse]} && !${Me.Target.IsHarvestable} && ${Me.Target.ContainsLoot}
	if ${autoLoot} && ${Me.Target.ContainsLoot}
	{
		;; Start Loot Window
		Me.Target:LootAll
		waitframe
		
		;; Stop attacking if you are still attacking
		if ${GV[bool,bIsAutoAttacking]}
		{
			Me.Ability[Auto Attack]:Use
			wait 5
		}

		;; Clear Target
		VGExecute "/cleartargets"
		waitframe
	}
	
	call ConsolidateResources
}

function corpse_drag()
{
	if ${autoDrag}
	{
		VGExecute "/corpsedrag"
	}
}

function Close_HarvestingWindow()
{
	;; Harvesting variables never lie -- yeah right!
	if ${autoCloseWindow} && ${GV[bool,bHarvesting]}
	{
		waitframe
		;; End harvesting and show Harvesting window
		VGExecute /endharvesting
		VGExecute /showwindow Harvesting

		Mouse:LeftClick
		Mouse:LeftClick
		return

		;; Is Harvesting Window still open?
		if ${GV[bool,bHarvesting]} && ${GV[bool,IsHarvestingDone]}
		{
			;; Sound the ALARM so we know we need user intervention
			PlaySound ALARM
			EchoIt "WARNING:  Please close the Harvesting Window"
			vgecho "Please close the Harvesting Window"

			;; Set our GIVEUP timer to 30 seconds
			GIVEUP:Set[FALSE]
			TimedCommand 300 Script[Harvest].Variable[GIVEUP]:Set[TRUE]
			
			;; We gonna wait until window closes or timer ran out
			while ${GV[bool,bHarvesting]} && ${GV[bool,IsHarvestingDone]} && !${GIVEUP}
			{
				HarvX:Set[${Mouse.X}]
				HarvY:Set[${Mouse.Y}]
			}
			
			;; Timer ran out so let's try again
			if ${GIVEUP}
			{
				return
			}

			;; Announce our success!
			EchoIt "New Mouse Coordinates to close Harvesting Window are X:${HarvX}, Y:${HarvY}"
			vgecho "Successfully learnt closing Harvesting Window"
		}

		;; Notify that we closed the pesky Harvesting Window
		EchoIt "Closed that pesky Harvesting window at X:${HarvX} Y:${HarvY}"
	}

	;; Hide the Harvesting Window
	if ${GV[bool,IsHarvestingDone]}
	{
		VGExecute /hidewindow Harvesting
	}

}

function LoadSettings()
{
	;; Create the Save directory incase it doesn't exist
	variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/Harvest/Save"
	mkdir "${savePath}"

	LavishSettings:AddSet[Harvest]
	LavishSettings[Harvest]:AddSet[Settings]
	LavishSettings[Harvest]:Import[${LavishScript.CurrentDirectory}/scripts/Harvest/Save/Settings.xml]
	setSettings:Set[${LavishSettings[Harvest].FindSet[Settings].GUID}]
	
	autoLoot:Set[${setSettings.FindSetting[autoLoot,FALSE]}]
	autoAssist:Set[${setSettings.FindSetting[autoAssist,FALSE]}]
	autoFollow:Set[${setSettings.FindSetting[autoFollow,FALSE]}]
	autoDrag:Set[${setSettings.FindSetting[autoDrag,FALSE]}]
	autoCloseWindow:Set[${setSettings.FindSetting[autoCloseWindow,FALSE]}]
	HarvX:Set[${setSettings.FindSetting[HarvX,975]}]
	HarvY:Set[${setSettings.FindSetting[HarvY,825]}]
}

function SaveSettings()
{
	;; Create the Save directory incase it doesn't exist
	variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/Harvest/Save"
	mkdir "${savePath}"

	setSettings:Clear
	setSettings:AddSetting[autoLoot,${autoLoot}]
	setSettings:AddSetting[autoAssist,${autoAssist}]
	setSettings:AddSetting[autoFollow,${autoFollow}]
	setSettings:AddSetting[autoDrag,${autoDrag}]
	setSettings:AddSetting[autoCloseWindow,${autoCloseWindow}]
	setSettings:AddSetting[HarvX,${HarvX}]
	setSettings:AddSetting[HarvY,${HarvY}]
	LavishSettings[Harvest]:Export[${LavishScript.CurrentDirectory}/scripts/Harvest/Save/Settings.xml]
}

function atexit()
{
	EchoIt "Ended Harvest Assist Bot"
	
	;; Save our settings
	call SaveSettings

	;; Stop moving and turning
	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[turnleft,release]
	VG:ExecBinding[turnright,release]
	
	;; Unload our UI
	ui -unload "${Script.CurrentDirectory}/Harvest.xml"
}


atom(script) PlaySound(string Filename)
{	
	System:APICall[${System.GetProcAddress[WinMM.dll,PlaySound].Hex},Filename.String,0,"Math.Dec[22001]"]
}

atom(script) EchoIt(string Text)
{
	if ${doEcho}
	{
		echo [${Time}][Harvest]: ${Text}
		vgecho ${Text}
	}
}