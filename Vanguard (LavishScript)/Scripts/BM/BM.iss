/*
BM - Blood Mage v1.6
by:  Zandros, 4 July 2009

Description:
This is tailored for Blood Mages.

Features:
Toggles for Facing, Dots, Arcane damage, Physical damage, Follow Tank, and MoveCloser to Tank during combat.
Also has an Immunity display to show what the target mob is immune to (Arcane and Physical only)
Detection for FURIOUS (There are two ways to detect and this does both!)
During FURIOUS, put HOTs on the target's offensive target
Has a Status display that shows what's going on.
*/

/* VARIABLES */
variable int i
variable int tank
variable string Tank
variable int64 TankID
variable int StartAttack = 99
variable int AttackHealRatio = 60
variable bool FURIOUS = FALSE
variable bool doForm = TRUE

/* UI Variables */
variable bool isRunning = TRUE
variable bool isPaused = TRUE
variable bool doFace = TRUE
variable bool doDots = TRUE
variable bool doBuffs = TRUE
variable bool doLoot = FALSE
variable bool doSkin = FALSE
variable bool doHarvest = FALSE
variable bool AttackNow = TRUE
variable string Status = "Setup Abilities"
variable string Immunity = None
;; Echos and Debug Info
variable bool doEcho = FALSE
variable bool doEchoTIME = FALSE
variable bool EchoFurious = FALSE
;; AutoFollow bools
variable bool doFollow = FALSE
variable bool doMoveTank = FALSE
variable bool doMoveTarget = FALSE
;; Follow (not in combat) Tank - Stop, Walk, Run
variable int FS1 = 5
variable int FW1 = 8
variable int FR1 = 12
;; Follow (in combat) Tank - Stop, Walk, Run
variable int FS2 = 10
variable int FW2 = 15
variable int FR2 = 20
;; Follow (in combat) Target - Stop, Walk, Run
variable int FS3 = 3
variable int FW3 = 5
variable int FR3 = 5


/* INCLUDES */
#include ./BM/Includes/Common.iss
#include ./BM/Includes/FaceSlow.iss
#include ./BM/Includes/MoveCloser.iss
#include ./BM/Includes/HandleCorpse.iss
#include ./BM/Includes/HarvestIt.iss
#include ./BM/Includes/FindTarget.iss
#include ./BM/Includes/FindGroupMembers.iss
#include ./BM/Classes/Blood Mage/SetupAbilities.iss


/* DEFINES */
#define ALARM	"${Script.CurrentDirectory}/Sounds/ping.wav"
#define WARNING	"${Script.CurrentDirectory}/Sounds/warning.wav"

/* MAIN ROUTINE */
function main()
{
	;-------------------------------------------
	; If we are not a Blood Mage then let them know!
	;-------------------------------------------
	if !${Me.Class.Equal[Blood Mage]}
	{
		MessageBox "I am sorry, this script is tailored for Blood Mages.  Future support for other classes will be soon."
	}

	;-------------------------------------------
	; Announce we are running
	;-------------------------------------------
	echo " "
	echo "[${Time}][VG:BM] --> BM Started"

	;-------------------------------------------
	; Load the UI panel
	;-------------------------------------------
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/BM.xml"

	;-------------------------------------------
	; Setup Abilities
	;-------------------------------------------
	call SetupAbilities
	BloodVials:Set[${Me.Inventory[Vial of Blood].Quantity}]

	;-------------------------------------------
	; Set Tank to DTarget
	;-------------------------------------------
	if !${Me.DTarget.ID(exists)}
	{
		Pawn[me]:Target
		wait 5
	}
	Tank:Set[${Me.DTarget.Name}]
	TankID:Set[${Me.DTarget.ID}]

	;-------------------------------------------
	; Start Events
	;-------------------------------------------
	Event[VG_OnIncomingText]:AttachAtom[ChatEvent]
	Event[VG_OnIncomingCombatText]:AttachAtom[IncomingCombatTextEvent]
	Event[VG_onGroupMemberCountChange]:AttachAtom[OnGroupMemberCountChange]

	;-------------------------------------------
	; Loop this while we are paused
	;-------------------------------------------
	while ${isPaused} && ${isRunning}
	{
		Status:Set[Paused]
		waitframe
	}
	Status:Set[Waiting]

	;; Set our vairables for our timer
	variable int START
	variable int END
	variable int MS
	variable int TIME
	variable int MIN = 0
	variable int SEC = 0
		
	;-------------------------------------------
	; Loop this while we exist
	;-------------------------------------------
	while ${isRunning}
	{
		START:Set[${LavishScript.RunningTime}]

		;-------------------------------------------
		; Routine to update our display of any immunities
		;-------------------------------------------
		call FunctionTimer "Immunities"

		;-------------------------------------------
		; Routine to stay close to the Tank
		;-------------------------------------------
		call FunctionTimer "Follow"

		;-------------------------------------------
		; Routine to deal with our target is a corpse
		;-------------------------------------------
		call FunctionTimer "HandleCorpse"

		;-------------------------------------------
		; Routine if not in combat
		;-------------------------------------------
		call FunctionTimer "NotInCombat"

		;-------------------------------------------
		; Routine if in combat
		;-------------------------------------------
		call FunctionTimer "InCombat"
		
		;-------------------------------------------
		; Check to see if we are paused
		;-------------------------------------------
		call FunctionTimer "Paused"

		;-------------------------------------------
		; Process any Queued Commands
		;-------------------------------------------
		call FunctionTimer "HandleQueuedCommands"
		
		;-------------------------------------------
		; Routine to catch spell casting, cool downs, harvesting, et cetera
		;-------------------------------------------
		call FunctionTimer "IsCasting"

		END:Set[${LavishScript.RunningTime}]
	
		;; Calculate total milliseconds
		MS:Set[${Math.Calc[${END}-${START}]}]
	
		;; Calculate total seconds
		TIME:Set[${Math.Calc[(${END}-${START})/1000]}]
	
		;; Calculate total minutes
		MIN:Set[${Math.Calc[${TIME}/60]}]

		;; Calculate our seconds
		SEC:Set[${Math.Calc[${TIME}%60].Int}]
		
		if ${SEC} && ${doEchoTIME}
			echo "[${Time}][VG:BM] -----> TOTAL TIME: [${MIN.LeadingZeroes[2]}m:${SEC.LeadingZeroes[2]}s:${MS.LeadingZeroes[4]}ms]"
	}
}

/* TIME A ROUTINE */
function FunctionTimer(string FUNCTION)
{
	;; Set our vairables
	variable int START
	variable int END
	variable int MS
	variable int TIME
	variable int MIN = 0
	variable int SEC = 0

	;; Time our called command "function"
	START:Set[${LavishScript.RunningTime}]
	call "${FUNCTION}"
	END:Set[${LavishScript.RunningTime}]
	
	;; Calculate total milliseconds
	MS:Set[${Math.Calc[${END}-${START}]}]
	
	;; Calculate total seconds
	TIME:Set[${Math.Calc[(${END}-${START})/1000]}]
	
	;; Calculate total minutes
	MIN:Set[${Math.Calc[${TIME}/60]}]

	;; Calculate our seconds
	SEC:Set[${Math.Calc[${TIME}%60].Int}]

	if ${SEC} && ${doEchoTIME}
		echo "[${Time}][VG:BM] --> FunctionTimer: [${MIN.LeadingZeroes[2]}m:${SEC.LeadingZeroes[2]}s:${MS.LeadingZeroes[4]}ms] [${FUNCTION}]"
}
	
/* ISCASTING */
function IsCasting()
{
	while !${Me.Ability["Using Weaknesses"].IsReady} || ${Me.IsCasting} || ${Pawn[me].IsMounted}
	{
		;; Show ability if casting
		if ${Me.IsCasting}
		{
			Status:Set[${Me.Casting}]
			if ${doFace} && ${Me.InCombat} && ${Me.Target(exists)}
				call faceloc ${Me.Target.X} ${Me.Target.Y} 55
		}
		
		;; Show if we are mounted
		if ${Pawn[me].IsMounted} && !${Me.IsCasting}
		{
			if ${Me.Ability["Using Weaknesses"].IsReady}
				Status:Set[Mounted - No Script Casting]
			if ${Me.InCombat} || ${isPaused}
				return
		}
		
		;; Show if ability is not ready
		if !${Me.Ability["Using Weaknesses"].IsReady} && (${Status.Equal[Mounted - No Script Casting]} || ${Status.Equal[Waiting]}
			Status:Set[ABILITIES NOT READY]
 		wait 1
		FlushQueued
	}
	
	;; Update our Status to show we are Waiting 
	if !${isPaused}
		Status:Set[Waiting]
}

/* USE ABILITY */
function:bool UseAbility(string ABILITY, string FORM)
{
	;; Check if ability is ready or exists
	if !${Me.Ability[${ABILITY}].IsReady} || !${Me.Ability[${ABILITY}](exists)}
		return FALSE

	;; Check if buff is on me or on mob
	if ${Me.Effect[${ABILITY}](exists)} || ${Me.TargetMyDebuff[${ABILITY}](exists)}
		return FALSE

	;; Check if we have enough energy to use ability
	if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		return FALSE

	;; Check if we got enough BloodUinion
	if ${Me.Ability[${ABILITY}].BloodUnionRequired} > ${Me.BloodUnion}
		return FALSE

	;; Check if mob is immune
	call MobImmune "${ABILITY}"
	if ${Return}
		return FALSE

	;; Wait to ensure its ready to cast that Counter
	if (${Me.Ability[${ABILITY}].IsCounter} || ${Me.Ability[${ABILITY}].IsChain}) && ${Me.Ability[${ABILITY}].TimeRemaining}<3 
	{
		;echo Before Chain=${Me.Ability[${ABILITY}].IsChain}, Counter=${Me.Ability[${ABILITY}].IsCounter}, Ready=${Me.Ability[${ABILITY}].IsReady}, TimeRemaining=${Me.Ability[${ABILITY}].TimeRemaining}, TriggeredCountdown=${Me.Ability[${ABILITY}].TriggeredCountdown}, Type=${Me.Ability[${ABILITY}].Type}, Ability=${Me.Ability[${ABILITY}]}
		
		while ${Me.Ability[${ABILITY}].IsCounter} && ${Me.Ability[${ABILITY}].IsReady} && ${Me.Ability[${ABILITY}].TimeRemaining}>0 && ${Me.Ability[${ABILITY}].TriggeredCountdown}
			wait 1
		
		;; hey, let's wait and chain these together
		while ${Me.Ability[${ABILITY}].IsChain} && ${Me.Ability[${ABILITY}].IsReady} && ${Me.Ability[${ABILITY}].TimeRemaining}>0 
			VGExecute /reactionautocounter
			
		;echo After  Chain=${Me.Ability[${ABILITY}].IsChain}, Counter=${Me.Ability[${ABILITY}].IsCounter}, Ready=${Me.Ability[${ABILITY}].IsReady}, TimeRemaining=${Me.Ability[${ABILITY}].TimeRemaining}, TriggeredCountdown=${Me.Ability[${ABILITY}].TriggeredCountdown}, Type=${Me.Ability[${ABILITY}].Type}, Ability=${Me.Ability[${ABILITY}]}
	}
		
	;echo Chain=${Me.Ability[${ABILITY}].IsChain}, Counter=${Me.Ability[${ABILITY}].IsCounter}, Ready=${Me.Ability[${ABILITY}].IsReady}, TimeRemaining=${Me.Ability[${ABILITY}].TimeRemaining}, TriggeredCountdown=${Me.Ability[${ABILITY}].TriggeredCountdown}, Type=${Me.Ability[${ABILITY}].Type}, Ability=${Me.Ability[${ABILITY}]}

	;; Lets change form
	if ${doForm} && !${FORM.Equal[""]} && ${Me.Form[${FORM}](exists)} && !${Me.CurrentForm.Name.Equal[${FORM}]}
	{
		if ${doEcho}
			echo "[${Time}][VG:BM] --> Form: ${FORM}"
		Me.Form[${FORM}]:ChangeTo
		TimedCommand 26 Script[BM].Variable[doForm]:Set[TRUE]
		doForm:Set[FALSE]
	}

	;; If form doesn't exist then change to default
	if ${doForm} && ${Me.Class.Equal[Blood Mage]} && !${FORM.Equal[""]} && !${Me.Form[${FORM}](exists)} && !${Me.CurrentForm.Name.Equal[Unfocused]}
	{
		if ${doEcho}
			echo "[${Time}][VG:BM] --> Form: Unfocused"
		Me.Form[Unfocused]:ChangeTo
		TimedCommand 26 Script[BM].Variable[doForm]:Set[TRUE]
		doForm:Set[FALSE]
	}

	if ${Me.Ability[${ABILITY}].IsReady}
	{
		;; Update our status display - fixes the problem with instant abilities not showing up
		Status:Set[${ABILITY}]

		;; Echo our Ability
		if ${doEcho}
			echo "[${Time}][VG:BM] --> UseAbility: ${ABILITY}"

		Me.Ability[${ABILITY}]:Use
		wait 3
		return TRUE
	}
	return FALSE
}


function HandleQueuedCommands()
{
	if ${QueuedCommands}
	{
		if ${Me.Target(exists)}
		{
			call MoveCloser ${Me.Target.X} ${Me.Target.Y} 20
			call MoveCloser ${Me.Target.X} ${Me.Target.Y} 20
			while ${Me.IsCasting} || !${Me.Ability["Using Weaknesses"].IsReady}
				wait 1
			call UseAbility "${Despoil}" "Focus of Gelenia"
			call UseAbility "${Despoil}" "Focus of Gelenia"
			call UseAbility "${UnionOfBlood}" "Focus of Gelenia"
			call UseAbility "${ScarletRitual}" "Focus of Gelenia"
			ExecuteQueued
		}
	}
}

/* FOLLOW */
function Follow()
{
	;; Must pass our checks
	if !${Pawn[name,${Tank}](exists)} || ${isPaused}
		return

	;; Update Tank's ID
	TankID:Set[${Pawn[name,${Tank}].ID}]

	;; We want to move closer to the Tank
	if !${Me.InCombat}
	{
		;; Move closer to the Tank if nobody is in combat
		if ${doFollow} && !${Script[AutoFollow](exists)} && ${Pawn[${Tank}].CombatState}==0
		{
			;; Feel free to change the settings to your liking
			run "./BM/Externals/AutoFollow ${TankID} ${FS1} ${FW1} ${FR1}"
			wait 5 !${Script[AutoFollow](exists)}
		}
			
		;; Move closer to the Tank if Tank is in Combat and we are not
		if ${doMoveTank} && !${Script[AutoFollow](exists)} && ${Pawn[${Tank}].CombatState}>0
		{
			run "./BM/Externals/AutoFollow ${TankID} ${FS2} ${FW2} ${FR2}"
			wait 5 !${Script[AutoFollow](exists)}
		}
	}
	
	;; We want to move closer to the target
	if ${Me.InCombat} && ${Me.Target(exists)}
	{
		;; Then move closer to the target
		if ${doMoveTarget} && !${Script[AutoFollow](exists)}
		{
			run "./BM/Externals/AutoFollow ${Me.Target.ID} ${FS3} ${FW3} ${FR3}"
			wait 5 !${Script[AutoFollow](exists)}
		}
	}
}

/* PAUSED */
function Paused()
{
	;; Let's pause if our health is 0
	if ${Me.HealthPct}==0
		isPaused:Set[TRUE]

	;; Return if we are not Paused
	if !${isPaused}
		return

	;; Set our variables to Paused
	Status:Set[Paused]
	echo "[${Time}][VG:BM] --> Paused"
	UIElement[Run Button@BM]:SetText[Paused]
	BloodVials:Set[${Me.Inventory[Vial of Blood].Quantity}]

	;; Stop following Tank
	if ${Script[AutoFollow](exists)}
		endscript AutoFollow

	;; Wait while we are paused
	while ${isPaused} && ${isRunning}
	{
		call Immunities
		wait 5
		waitframe
		if !${Me.CurrentForm.Name.Equal[Sanguine Focus]} && ${Me.HealthPct}<50
		{
			if ${doEcho}
				echo "[${Time}][VG:BM] --> Form: Sanguine Focus"
			Me.Form[Sanguine Focus]:ChangeTo
				wait 25
		}
	}
	
	;; Change our status to "Waiting"
	Status:Set[Waiting]

	echo "[${Time}][VG:BM] --> Resumed"
	FlushQueued
}

/* Play a Sound File */
function PlaySound(string Filename)
{
	System:APICall[${System.GetProcAddress[WinMM.dll,PlaySound].Hex},Filename.String,0,"Math.Dec[22001]"]
}

/* END OF ROUTINE */
function atexit()
{
	;; Remove any events
	Event[VG_OnIncomingText]:DetachAtom[ChatEvent]
	Event[VG_OnIncomingCombatText]:DetachAtom[IncomingCombatTextEvent]
	Event[VG_onGroupMemberCountChange]:DetachAtom[OnGroupMemberCountChange]
	
	;; Any Class Specific shutdowns
	call ShutDown

	;; UnLoad the UI panel
	ui -unload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	ui -unload "${Script.CurrentDirectory}/BM.xml"

	echo "[${Time}][VG:BM] --> BM Bot Ended"
}
