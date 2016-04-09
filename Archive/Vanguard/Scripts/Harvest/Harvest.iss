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
variable bool BUMP = FALSE

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

	;-------------------------------------------
	; Turn on our event
	;-------------------------------------------
	Event[VG_onHitObstacle]:AttachAtom[Bump]
	
	
	while ${isRunning}
	{
		;; Set DTarget to our Master Harvester
		if !${Me.DTarget.Name.Equal[${Harvester}]} && !${Harvester.Equal[${Me}]} && ${autoFollow}
		{
			Pawn[Name,${Harvester}]:Target
			waitframe
		}
	
		;; return if Master Harvester can't be found
		if ${Me.DTarget.Name.Equal[${Harvester}]} && !${Harvester.Equal[${Me}]}
		{
			waitframe
			if !${Me.DTarget.Name.Equal[${Harvester}]} && !${Harvester.Equal[${Me}]}
			{
				vgecho Turn AutoFollow OFF if trying to change who you will be assisting
			}
			
			if ${Me.DTarget.Name.Equal[${Harvester}]} && !${Harvester.Equal[${Me}]}
			{
				call FollowHarvester
				call AssistHarvester
				call MoveCloserToResource
				call BeginHarvesting
				call Loot
				call corpse_drag
				call Close_HarvestingWindow
			}
		}
	}
}

;; ALWAYS MOVE CLOSER TO OUR HARVESTER
function FollowHarvester()
{
	if ${autoFollow}
	{
		;; did target move out of rang?
		if ${Me.DTarget.Distance}>=2
		{
			variable bool AreWeMoving = TRUE
			variable bool Strifing = FALSE
			;; start moving until target is within range
			while ${isRunning} && ${Me.DTarget(exists)} && ${Me.DTarget.Distance}>=2 && ${autoFollow}
			{
				Me.DTarget:Face
				VG:ExecBinding[moveforward]
				if ${BUMP}
				{
					call HandleBump
				}
				wait .5 !${isRunning} || !${Me.DTarget(exists)} !! ${Me.DTarget.Distance}<2 || !${autoFollow}
			}
			;; if we moved then we want to stop moving
			if ${AreWeMoving}
			{
				isMoving:Set[FALSE]
				VG:ExecBinding[moveforward,release]
			}
		}
	}
}

;; TARGET WHATEVER THE HARVESTER IS TARGETING
function AssistHarvester()
{
	;; sometime when Bonus Yield is up the bHarvesting says we are still harvesting but we are not in combat, so...
	if ${autoAssist}
	{
		if !${Me.InCombat} || !${GV[bool,bHarvesting]}
		{
			if ${Me.DTarget.Distance}<5
			{
				;; Always set our target to Harvester's target
				VGExecute /assist ${Harvester}
				waitframe
			}
		}
	}
}

;; WE GOT A TARGET SO MOVE IN CLOSER
function MoveCloserToResource()
{
	if ${Me.Target(exists)}
	{
		;; take control and move closer if within 12m of target
		if  ${Me.Target.Distance}>5 && ${Me.Target.Distance}<15 && ${Me.Target.IsHarvestable}
		{
			;; Turn slowly toward the target
			call faceloc ${Me.Target.X} ${Me.Target.Y} 20
			
			;; Start moving closer to target
			isMoving:Set[FALSE]
			while ${Me.Target.Distance}>5 && ${Me.Target(exists)}
			{
				isMoving:Set[TRUE]
				Me.Target:Face
				VG:ExecBinding[moveforward]
			}
			
			;; Stop moving
			if ${isMoving}
			{
				VG:ExecBinding[moveforward,release]
				isMoving:Set[FALSE]
			}
		}
	}
}

;; BEGIN HARVESTING
function BeginHarvesting()
{
	if ${Pawn[id,${HarvesterID}].CombatState}>0
	{
		;; Begin harvesting if we are not harvesting
		if ${Me.ToPawn.CombatState}==0 && !${Me.InCombat}
		{
			if !${Me.Target(exists)}
			{
				;; do nothing
				if !${autoAssist}
				{
					return
				}
				VGExecute /assist ${Harvester}
				wait 10 ${Me.Target(exists)}
			}
			
			;; Begin Harvesting
			if ${Me.Target.Distance}<=5
			{
				Me.Ability[Auto Attack]:Use
				wait 50 ${GV[bool,bHarvesting]} && ${Me.ToPawn.CombatState}>0
			}
		}
		
		;; Let's wait here while we are harvesting
		if ${GV[bool,bHarvesting]} && ${Me.ToPawn.CombatState}>0
		{
			StopHarvestTimer:Set[${Script.RunningTime}]

			while ${GV[bool,bHarvesting]} && ${Me.ToPawn.CombatState}>0 && ${Math.Calc[${Math.Calc[${Script.RunningTime}-${StopHarvestTimer}]}/1000]}<20
			{
				waitframe
				if !${isRunning}
				{
					return
				}

				;; this will stop the harvest
				if ${Pawn[id,${HarvesterID}].CombatState}==0 || ${Me.Target.Name.Find[remains of]} || !${Me.Target(exists)} || ${Pawn[id,${HarvesterID}].Distance}>7 || !${Me.Target.IsHarvestable}
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

			VGExecute /hidewindow bonus yield
			waitframe
			VGExecute /hidewindow depletion bonus yield 
			waitframe
		}
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
		wait 1
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

;-------------------------------------------
; This happens when we bump into an obstacle
;-------------------------------------------
atom Bump(string Name)
{
	;; Set our BUMP flag
	BUMP:Set[TRUE]
}

;-------------------------------------------
; Handle the bump - lame routine
;-------------------------------------------
function HandleBump()
{
	variable int WAIT = 7
	variable int RANDOM = ${Math.Rand[10]}
	X:Set[${Me.X}]
	Y:Set[${Me.Y}]
	Z:Set[${Me.Z}]

	;; Try moving LEFT then RIGHT
	if ${RANDOM}>5
	{
		;; Move LEFT
		VG:ExecBinding[StrafeLeft]
		wait ${WAIT}
		VG:ExecBinding[StrafeLeft,release]
		if ${ECHO}
			echo "[${Time}][VG:AutoFollow] OBSTACLE - Going LEFT (Moved: ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}].Int}/100]})"

		;; Move RIGHT if we didn't move
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<150
		{
			if ${ECHO}
				echo "[${Time}][VG:AutoFollow] OBSTACLE - Trying RIGHT (Moved: ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}].Int}/100]})"
			VG:ExecBinding[StrafeRight]
			wait ${WAIT}
			VG:ExecBinding[StrafeRight,release]
		}
	}

	;; Try moving RIGHT then LEFT
	if ${RANDOM}<6
	{
		;; Move RIGHT
		VG:ExecBinding[StrafeRight]
		wait ${WAIT}
		VG:ExecBinding[StrafeRight,release]
		if ${ECHO}
			echo "[${Time}][VG:AutoFollow] OBSTACLE - Going RIGHT (Moved: ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}].Int}/100]})"

		;; Move LEFT if we didn't move
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<150
		{
			if ${ECHO}
				echo "[${Time}][VG:AutoFollow] OBSTACLE - Trying LEFT (Moved: ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}].Int}/100]})"
			VG:ExecBinding[StrafeLeft]
			wait ${WAIT}
			VG:ExecBinding[StrafeLeft,release]
		}
	}

	;; If we didn't move then JUMP or BAIL
	if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<250
	{
		VG:ExecBinding[Jump]
		wait 2
		VG:ExecBinding[Jump,release]
		wait 1
		VG:ExecBinding[Jump]
		wait 2
		VG:ExecBinding[Jump,release]
		wait 1

		;; If we still didn't move then BAIL
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<175
		{
			if ${ECHO}
			echo "[${Time}][VG:AutoFollow] BAILED - Unable to move (Moved: ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}].Int}/100]})"
			endscript AutoFollow
		}

		;; Successful JUMP if we moved
		if ${ECHO}
			echo "[${Time}][VG:AutoFollow] OBSTACLE - Jumped worked (Moved: ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}].Int}/100]})"

	}
	;; Clear our BUMP flag and resume
	BUMP:Set[FALSE]
}