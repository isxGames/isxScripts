;---------------------------------------------------
; VGFish.iss Version 2.1  Created: 12/18/08 by Zandros123
;
;VERSIONS:
; 2.1 -- Patched to catch movement, adjusted some timers, and get back on boat if drowning (05/11/09)
; 2.0 -- Updated to include all of Sckary and BackseatScripters ComboSets, and new facing routine (02/13/09)
; 1.9a - Small patch to to correct minor issue with saving (01/19/08)
; 1.9 -- Special requests and new movement detection routines (12/30/08)
; 1.8 -- Reorganized and cleaned up the code (12/25/08)
; 1.7 -- Implemented MMOAddicts routines and made some adjustments (12/25/08)
; 1.6 -- Updated log output (12/24/08)
; 1.5 -- Logs and About tabs added (12/24/08)
; 1.4 -- UI modified for simplicity for now (12/23/08)
; 1.3 -- UI by MMOAddict (12/21/08)
; 1.2 -- New calculations for detecting Fish direction (12/21/08)
; 1.1 -- Added some Fish Combos (12/19/08)
; 1.0 -- Initial (12/18/08)
;
;DESCRIPTION:
; Simple Fishing Assist Bot Script:  Semi-Auto
;
;CURRENT FEATURES:
; 1) Easy interface to program fish combos
; 2) Find a Fish and face it
; 3) Cast within 5m of Fish (fish do move so it can be greater)
; 4) Recast if name is Unknown or Fish, or Delay timer runs out
; 5) Troll Line working smoothly
; 6) Assist on reeling in the snagged fish
; 7) Loot the darn fish
; 8) Autoload Bait and Equip Fishing Pole
;
;FUTURE VERSIONS:
; 1) Detect teleporting, drowning, inventory full, and Combat
; 2) Self learning new combos on new fishes (Sweet, it can be done!)
; 3) Any special requests users would like to see
;
;PROBLEMS:
; 1) The code works great but sometimes I noticed
; that the direction the Fish facing is not the
; same direction the Fish is moving to.  This was
; corrected by the concept of precalculated distance.
; Its not perfect but it works most of the time.
;
; 2) If fish is too far away to loot, it sits and wait.
;
;SPECIAL THANKS:
; Kudos to MMOAddict for sharing great ideas and for
; his hard effort looking over the script and building
; an awsome UI.
;
;---------------------------------------------------
;===================================================
;===               Includes                     ====
;===================================================
;
#include "${LavishScript.CurrentDirectory}/scripts/VGFish/Includes/settings.iss"
#include "${LavishScript.CurrentDirectory}/scripts/VGFish/Includes/mainPause.iss"
#include "${LavishScript.CurrentDirectory}/scripts/VGFish/Includes/mainNoTargetExist.iss"
#include "${LavishScript.CurrentDirectory}/scripts/VGFish/Includes/mainTargetExist.iss"
#include "${LavishScript.CurrentDirectory}/scripts/VGFish/Includes/mainDrowning.iss"
#include "${LavishScript.CurrentDirectory}/scripts/VGFish/Includes/atoms.iss"
#include "${LavishScript.CurrentDirectory}/scripts/VGFish/Includes/faceslow.iss"
;
;===================================================
;===               Defines                      ====
;===================================================
;
#define ALARM "${LavishScript.CurrentDirectory}/scripts/VGFish/Sounds/ping.wav"
;
;===================================================
;===              Variables                     ====
;===================================================
;
variable string UP=w
variable string DOWN=s
variable string LEFT=a
variable string RIGHT=d
;
;variable string UP="Up"
;variable string DOWN="Down"
;variable string LEFT="Left"
;variable string RIGHT="Right"
;
variable string Command = Paused
variable bool isRunning = TRUE
variable bool Paused = TRUE
;
variable float SavX
variable float SavY
variable float LastX
variable float LastY
variable float SavZ
;variable int Angle
variable float DistFB
variable float DistLR
variable int Temp
;
variable int64 LastTargetID = 0
;
variable float DistX
variable float DistY
;
variable(script) Fishlist Fishes[50]
variable string FishName = "Squid"
variable string Combo1 = "u"
variable string Combo2 = "d"
variable string Combo3 = "l"
variable string Combo4 = "r"
variable string Combo = "xxxx"
;
objectdef Fishlist
{
	method Initialize()
	{
		Name:Set["Empty"]
		Combo1:Set["Empty"]
		Combo2:Set["Empty"]
		Combo3:Set["Empty"]
		Combo4:Set["Empty"]
	}
	method Clear()
	{
		Name:Set["Empty"]
		Combo1:Set["Empty"]
		Combo2:Set["Empty"]
		Combo3:Set["Empty"]
		Combo4:Set["Empty"]
	}
	variable string Name
	variable string Combo1
	variable string Combo2
	variable string Combo3
	variable string Combo4
}

variable bool DoLogFishMovement

;*******Add MMOaddict**********
variable bool NeedToCast = TRUE
variable bool DoFindFish
variable bool DoCastLine
variable bool DoShortenCast
variable bool DoTrollLine
variable bool DoReleaseUnknown
variable bool DoAutoBait
variable bool DoDebug
variable bool DoFishingPole
variable bool DoOverideDetectMove
variable bool DoOverideHeading

variable int MinFindFish
variable int MaxFindFish
variable int ShortenCastDelay
variable int TrollLineTimes
variable int TrollLineWaitTime
variable string Bait
variable string FishingPole

variable int ForwardMinAngle
variable int ForwardMaxAngle
variable int Forward2MinAngle
variable int Forward2MaxAngle
variable int BackwardMinAngle
variable int BackwardMaxAngle
variable int LeftMinAngle
variable int LeftMaxAngle
variable int RightMinAngle
variable int RightMaxAngle
variable int FishMoveDistance

;**********Add BSS************
variable bool DoReleaseNone
variable bool DoReleaseKnown
variable bool ComboSetA
variable bool ComboSetB
variable bool ComboSetC
variable bool ComboSetD
variable string ComboPh1
variable string ComboPh2
variable string ComboPh3
variable string ComboPh4


;===================================================
;===         Executed at end of program         ====
;===================================================
function atexit()
{
	;-------------------------------------------
	; Make sure we can get the name of the toon
	;-------------------------------------------
	if ( ${Me.FName.Equal[NULL]} || ${Me.FName.Length} <= 0 )
	{
		echo "ERROR: unable to save data! (perhaps you logged off or crashed before 1st exiting this script to correctly save your data under your toons name?)" 
	}
	else
	{
		;-------------------------------------------
		; Save Configuration Settings
		;-------------------------------------------
		call SaveSettings
	}

	;-------------------------------------------
	; Adjust the UI panel
	;-------------------------------------------
	UIElement[VGFish]:SetWidth[160]
	UIElement[VGFish]:SetHeight[80]
	UIElement[Main@VGFish]:Select

	;-------------------------------------------
	; UnLoad the UI panel
	;-------------------------------------------
	ui -unload "${Script.CurrentDirectory}/VGFish.xml"

	;-------------------------------------------
	; Announce we have ended
	;-------------------------------------------
	echo "[${Time}] --> VGFish Script Ended"
	VG:ExecBinding[moveforward,release]

}
;
;---------------------------------------------------
;===================================================
;===              Main Routine                  ====
;===================================================
;---------------------------------------------------
function main()
{
	;-------------------------------------------
	; Wait 10 seconds while ISXVG reloads
	;-------------------------------------------
	ext -require isxvg
	wait 100 ${ISXVG.IsReady}
	if !${ISXVG.IsReady}
	{
		echo "[${Time}] --> Unable to load ISXVG, exiting script"
		endscript vgfish
	}

	;-------------------------------------------
	; Announce we have started
	;-------------------------------------------
	echo "[${Time}] --> VGFish Script Started"

	;-------------------------------------------
	; Make sure we can get the name of the toon
	;-------------------------------------------
	if ( ${Me.FName.Equal[NULL]} || ${Me.FName.Length} <= 0 )
	{
		echo "ERROR: unable to load data! (perhaps you launched this before you logged in?)"
		return
	}

	;-------------------------------------------
	; Load Configuration Settings
	;-------------------------------------------
	call LoadSettings

	;-------------------------------------------
	; Load the UI panel
	;-------------------------------------------
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/VGFish.xml"

	;-------------------------------------------
	; Adjust the UI panel
	;-------------------------------------------
	UIElement[VGFish]:SetWidth[160]
	UIElement[VGFish]:SetHeight[80]
	UIElement[Main@VGFish]:Select

	;-------------------------------------------
	; Populate our UI
	;-------------------------------------------
	call LoadXML

	;-------------------------------------------
	; Heart of the program where everything happens
	;
	; Only 4 things we check for:
	; 1) Pause
	; 2) No Target
	; 3) Target Exist 
	; 4) Drowning
	;-------------------------------------------

	while ${isRunning}
	{
		;-------------------------------------------
		; Paused?
		;-------------------------------------------
		call mainPaused

		;-------------------------------------------
		; No Target?
		;-------------------------------------------
		call mainNoTargetExist

		;-------------------------------------------
		; Have a Target?
		;-------------------------------------------
		call mainTargetExist

		;-------------------------------------------
		; Drowning?
		;-------------------------------------------
		call mainDrowning
	}
}




;===================================================
;===================================================
;===      S E T T I N G S   B E L O W           ====
;===================================================
;===================================================


;===================================================
;===================================================
;===    M A I N   R O U T I N E S   B E L O W   ====
;===================================================
;===================================================


;===================================================
;===================================================
;===    S U B - R O U T I N E S   B E L O W     ====
;===================================================
;===================================================


;===================================================
;===================================================
;===    G L O B A L   A T O M S   B E L O W     ====
;===================================================
;===================================================


