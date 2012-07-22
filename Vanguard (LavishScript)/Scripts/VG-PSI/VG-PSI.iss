;-------------------------------------------------------
; VG-PSI.iss Version 1.0 Updated: 2010/04/20 by Zandros
;-------------------------------------------------------
;
;===================================================
;===              INCLUDES                      ====
;===================================================
#include ./VG-PSI/Check4Immunites.iss
#include ./VG-PSI/Obj_Face.iss
#include ./VG-PSI/Obj_Move.iss
;
;===================================================
;===               DEFINES                      ====
;===================================================
#define ALARM "${Script.CurrentDirectory}/ping.wav"
;
;===================================================
;===           DEFINE OUR OBJECTIVES            ====
;===================================================
variable obj_Face Face
variable obj_Move Move

;===================================================
;===         VARIABLES USED BY UI               ====
;===================================================
variable string Version = "1.1"
variable bool doEcho = TRUE
variable bool isPaused = TRUE
variable bool isRunning = TRUE
variable int StartAttack = 99
variable string Tank
variable string CurrentAction = "Loading Variables"
variable string TargetsTarget = "No Target"

variable int ParseDamage = 0
variable int DPS = 0
variable int DamageDone = 0

variable int Mindfire = 0
variable int TelekineticBlast = 0
variable int TemporalFracture = 0
variable int TemporalShift = 0
variable int CompressionSphere = 0
variable int PsychicSchism = 0
variable int MentalBlast = 0
variable int PsionicBlast = 0
variable int ThoughtPulse = 0
variable int Corporeal = 0
variable int Dementia = 0
variable int ThoughtSurge = 0
variable int Chronoshift = 0
variable int CRIT = 0
variable int EPIC = 0

;variable string TargetImmunity
;variable bool doArcane
;variable bool doPhysical
;variable bool doMental
variable string CombatForm
variable string NonCombatForm
variable string PushHateTo
variable string RemoveHateFrom = ${Me.FName}
variable bool doPushHate = FALSE
variable bool doRemoveHate = TRUE
variable bool doNukes = TRUE
variable bool doDots = TRUE
variable bool doAE = FALSE
variable bool doBuffs = FALSE
variable bool doFaceSlow = TRUE
variable bool doLootAll = FALSE
variable bool doTemporalShift = TRUE
variable bool doCompressionSphere = TRUE
variable bool doPsychicSchism = TRUE
variable bool doDementia = TRUE
variable bool doThoughtSurge = FALSE
variable bool doChronoshift = FALSE
variable bool doMentalBlast = FALSE
variable bool doThoughtPulse = TRUE
variable bool doCorporealHammer = TRUE
variable bool doPsionicBlast = TRUE
variable bool doCorporealSmash = FALSE
variable bool doAcceptRez = TRUE
variable bool doAcceptGroupInvite = TRUE
variable bool doFollow = FALSE
variable bool doFullThrottle = TRUE
variable string FollowName = "No name set"
variable int64 FollowID = 0
variable string StartFollowText
variable string StopFollowText
variable string KillLevitationText
variable string BuffEveryoneText
variable string Mez1Name
variable int64 Mez1ID = 0
variable string Mez2Name
variable int64 Mez2ID = 0
variable string Mez3Name
variable int64 Mez3ID = 0
;
;===================================================
;===       VARIABLES USED BY SCRIPT             ====
;===================================================
variable int i
variable int SpellCounter = 0
variable int StartAttackTime = 0
variable int EndAttackTime = 0
variable int TimeFought = 0
variable bool ResetParse = TRUE
variable bool doRepair = TRUE

variable bool doForm = TRUE
variable bool FURIOUS = FALSE
variable int LastDowntimeCall=${Script.RunningTime}
variable int NextUpdateDisplay = ${Script.RunningTime}

;; Cursed
variable string Cursed = "None"
variable bool RemoveCurseRequest = FALSE

/*
;; Push Hate
variable string MemoryShift = "Memory Shift IV"
;; Remove Hate
variable string MindWipe = "Mind Wipe V"
;; Dots
variable string Dot1 = "Temporal Shift VII"
variable string Dot2 = "Compression Sphere IX"
variable string Dot3 = "Psychic Schism V"
;; AE
variable string AE1 = "Dementia V"
variable string AE2 = "Thought Surge III"
variable string AE3 = "Chronoshift IV"
;; Nukes
variable string Nuke1 = "Corporeal Smash"
variable string Nuke2 = "Corporeal Hammer III"
variable string Nuke3 = "Psionic Blast IV"
variable string Nuke4 = "Thought Pulse VIII"
variable string Nuke5 = "Mental Blast V"
;; Chains
variable string Chain1 = "Mindfire V"
variable string Chain2 = "Telekinetic Blast IV"
variable string Chain3 = "Temporal Fracture VI"
;; Counters
variable string Counter1 = "Nullifying Field"
variable string Counter2 = "Psychic Mutation"
;; Regen Dots
variable string RegenDot1 = "Compression Sphere VIII"
variable string RegenDot2 = "Psychic Schism IV"
;; Defense
variable string Defense1 = "Psionic Barrier IV"
variable string Defense2 = "Diamond Skin"
variable string Defense3 = "Mass Amnesia"
*/

;
;===================================================
;===            MAIN SCRIPT                     ====
;===================================================
function main()
{
	EchoIt "Started VG-PSI Script"

	;; Set Tank based upon DTarget
	if !${Me.DTarget.ID(exists)}
	{
		Pawn[me]:Target
		wait 5
	}
	Tank:Set[${Me.DTarget.Name}]

	;; Load our Settings
	LoadXMLSettings	

	;; Reload the UI
	ui -reload "${LavishScript.CurrentDirectory}/Interface/VGSkin.xml"
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/VG-PSI.xml"
	
	;; Setup and Declare Abilities
	;; === PUSH HATE ===
	SetHighestAbility "MemoryShift" "Memory Shift"
	;; === REMOVE HATE ===
	SetHighestAbility "MindWipe" "Mind Wipe"
	;; === DOTS ===
	SetHighestAbility "Dot1" "Temporal Shift"
	SetHighestAbility "Dot2" "Compression Sphere"
	SetHighestAbility "Dot3" "Psychic Schism"
	;; === AE ===
	SetHighestAbility "AE1" "Dementia"
	SetHighestAbility "AE2" "Thought Surge"
	SetHighestAbility "AE3" "Chronoshift"
	;; === NUKES ===
	SetHighestAbility "Nuke1" "Corporeal Smash"
	SetHighestAbility "Nuke2" "Corporeal Hammer"
	SetHighestAbility "Nuke3" "Psionic Blast"
	SetHighestAbility "Nuke4" "Thought Pulse"
	SetHighestAbility "Nuke5" "Mental Blast"
	;; === CHAINS ===
	SetHighestAbility "Chain1" "Mindfire"
	SetHighestAbility "Chain2" "Telekinetic Blast"
	SetHighestAbility "Chain3" "Temporal Fracture"
	;; === COUNTERS ===
	SetHighestAbility "Counter1" "Nullifying Field"
	SetHighestAbility "Counter2" "Psychic Mutation"
	;; === DEFENSE ===
	SetHighestAbility "Defense1" "Psionic Barrier"
	SetHighestAbility "Defense2" "Diamond Skin"
	SetHighestAbility "Defense3" "Mass Amnesia"
	;; === MEZ ===
	SetHighestAbility "TimeTrick" "Time Trick"
	
	;; === REGEN DOTS ===
	;;
	;; MANUALLY MODIFY REGEN DOT TO WHAT YOU WANT TO USE!
	;;
	SetHighestAbility "RegenDot1" "Compression Sphere VIII"
	SetHighestAbility "RegenDot2" "Psychic Schism IV"
	
	;; Turn on our event monitors
	Event[VG_OnIncomingText]:AttachAtom[ChatEvent]
	Event[VG_OnIncomingCombatText]:AttachAtom[CombatText]
	Event[VG_onHitObstacle]:AttachAtom[Bump]
	Event[OnFrame]:AttachAtom[UpdateDisplay]

	
	;-------------------------------------------
	; LOOP THIS INDEFINITELY
	;-------------------------------------------
	while ${isRunning}
	{
		;; Execute any queued commands
		if ${QueuedCommands}
		{
			ExecuteQueued
			FlushQueued
		}
		
		;; Take down that pesky POTA barrier
		call OpenPotaBarrier
		
		if !${isPaused} 
		{
			;; Counters, Crits, and anything else
			call CriticalRoutines

			;; Execute main routines
			if ${Math.Calc[${Math.Calc[${Script.RunningTime}-${LastDowntimeCall}]}/1000]}>1 || ${doFullThrottle}
			{
				call MainRoutines
				LastDowntimeCall:Set[${Script.RunningTime}]
			}
		}
		else
		{
			wait 3
		}
	}
}

;===================================================
;=== CALLED ONCE EVERY SECOND AFTER ANY ACTIONS ====
;===================================================
function MainRoutines()
{
	;; Update our current action
	if ${Me.IsCasting}
	{
		CurrentAction:Set[Casting ${Me.Casting}]
	}
			
	;; Check to see if we want to counter a spell
	call HandleCounters

	;; Auto Accept Group Invites
	call GroupInviteAccept
	
	;; Clear our Target
	call ClearTargets
	
	;; Follow our Tank
	call Follow

	;; Sweet, repair our equipment whether we need to or not
	;; Essence of Replenishment
	if ${Pawn[Essence of Replenishment](exists)}
	{
		if ${doRepair}
		{
			if ${Pawn[Essence of Replenishment].Distance}<5
			{
				if ${Me.Inventory[CurrentEquipSlot,Primary Hand].Durability}<99
				{
					Pawn[Essence of Replenishment]:Target
					wait 10 ${Me.Target.Name.Find[Replenishment]}
					if ${Me.Target.Name.Find[Replenishment]}
					{
						Merchant:Begin[Repair]
						wait 3
						Merchant:RepairAll
						Merchant:End
						vgecho Repaired equipment
						VGExecute "/cleartargets"
					}
				}
			}
		}
		TimedCommand 150 Script[VG-BM].Variable[doRepair]:Set[TRUE]
		doRepair:Set[FALSE]
	}

	;; Merchant Djinn
	if ${Pawn[Merchant Djinn](exists)}
	{
		if ${doRepair}
		{
			if ${Pawn[Merchant Djinn].Distance}<5
			{
				if ${Me.Inventory[CurrentEquipSlot,Primary Hand].Durability}<99
				{
					Pawn[Merchant Djinn]:Target
					wait 10 ${Me.Target.Name.Find[Merchant Djinn]}
					if ${Me.Target.Name.Find[Merchant Djinn]}
					{
						Merchant:Begin[Repair]
						wait 3
						Merchant:RepairAll
						Merchant:End
						vgecho Repaired equipment
						VGExecute "/cleartargets"
					}
				}
			}
		}
		TimedCommand 150 Script[VG-BM].Variable[doRepair]:Set[TRUE]
		doRepair:Set[FALSE]
	}

	;; Reparitron 5703
	if ${Pawn[Reparitron 5703](exists)}
	{
		if ${doRepair}
		{
			if ${Pawn[Reparitron 5703].Distance}<5
			{
				if ${Me.Inventory[CurrentEquipSlot,Primary Hand].Durability}<99
				{
					Pawn[Reparitron 5703]:Target
					wait 10 ${Me.Target.Name.Find[Reparitron 5703]}
					if ${Me.Target.Name.Find[Reparitron 5703]}
					{
						Merchant:Begin[Repair]
						wait 3
						Merchant:RepairAll
						Merchant:End
						vgecho Repaired equipment
						VGExecute "/cleartargets"
					}
				}
			}
		}
		TimedCommand 150 Script[VG-BM].Variable[doRepair]:Set[TRUE]
		doRepair:Set[FALSE]
	}
	
	;; Merchant
	if ${Me.Target.Type.Equal[Merchant]}
	{
		if ${doRepair}
		{
			if ${Me.Inventory[CurrentEquipSlot,Primary Hand].Durability}<99
			{
				Merchant:Begin[Repair]
				wait 3
				Merchant:RepairAll
				Merchant:End
				vgecho Repaired equipment
				VGExecute "/cleartargets"
			}
		}
		TimedCommand 150 Script[VG-BM].Variable[doRepair]:Set[TRUE]
		doRepair:Set[FALSE]
	}

	;; Change forms
	call ChangeForm
	
	;; slight pause
	waitframe
	
	;; Return if we are still casting or abilities are not ready
	if ${Me.IsCasting} || !${Me.Ability["Using Weaknesses"].IsReady}
	{
		return
	}

	;; Update our current action
	CurrentAction:Set[Waiting]
	
	;; Attack our target!
	call AttackTarget
}

;===================================================
;===           CRITICAL ROUTINES                ====
;===================================================
function CriticalRoutines()
{
	if ${Me.Target(exists)} && !${Me.Target.Type.Equal[Corpse]} && !${Me.Target.IsDead}
	{
		call HandleCounters
		call HandleChains
		call TargetOnMe
	}
	call RemoveCurse
}

;===================================================
;===          REMOVE ANY CURSES                 ====
;===================================================
function RemoveCurse()
{
	;; event handler controls this
	if !${RemoveCurseRequest}
	{
		return
	}
	
	;; Make sure we have the ability
	if !${Me.Ability[Spellbind Void](exists)} || !${Me.Ability[Spellbind Void].IsReady}
	{
		return
	}

	;; Check if within distance
	if ${Pawn[${Cursed}].Distance}<10
	{
		call UseAbility "Spellbind Void"
		if ${Return}
		{
			RemoveCurseRequest:Set[FALSE]
			EchoIt "RemoveCurse:  SUCCESSFUL removed Curse: ${Cursed}"
		}
	}
}

;===================================================
;===          TARGET ON ME                      ====
;===================================================
function TargetOnMe()
{
	if ${Me.IsGrouped}
	{
		if ${Me.ToT.Name.Find[${Me.FName}]}
		{
			if ${Me.Target.Distance}<10
			{
				;; Mass wipe aggro onto self
				while ${Me.IsCasting} || !${Me.Ability["Using Weaknesses"].IsReady}
				{
					waitframe
				}
				call UseAbility "${Defense3}"
				while ${Me.IsCasting} || !${Me.Ability["Using Weaknesses"].IsReady}
				{
					waitframe
				}
				
				if ${Me.ToT.Name.Find[${Me.FName}]}
				{
					;; get our barrier up!
					while ${Me.IsCasting} || !${Me.Ability["Using Weaknesses"].IsReady}
					{
						waitframe
					}
					if !${Me.Effect[${Defense1}](exists)}
					{
						call UseAbility "${Defense1}"
						while ${Me.IsCasting} || !${Me.Ability["Using Weaknesses"].IsReady}
						{
							waitframe
						}
					}
					
					;; get our secondary barrier up if need be
					if !${Me.Effect[${Defense1}](exists)} && !${Me.Effect[${Defense2}](exists)}
					{
						call UseAbility "${Defense2}"
						while ${Me.IsCasting} || !${Me.Ability["Using Weaknesses"].IsReady}
						{
							waitframe
						}
					}
				}
			}
		}
		return
	}
}
		
		

;===================================================
;===          SCAN AREA TO BUFF                 ====
;===================================================
function ScanAreaToBuff()
{
	;; Recast this
	Pawn[Me]:Target
	call UseAbility "True Sight"
	wait 5
	while ${Me.IsCasting} || !${Me.Ability["Using Weaknesses"].IsReady}
	{
		waitframe
	}
	
	;; Recast this
	Pawn[Me]:Target
	call UseAbility "Union of Thought VI"
	wait 5
	while ${Me.IsCasting} || !${Me.Ability["Using Weaknesses"].IsReady}
	{
		waitframe
	}

	;; Recast this
	Pawn[Me]:Target
	call UseAbility "Mass Mental Focus"
	wait 5
	while ${Me.IsCasting} || !${Me.Ability["Using Weaknesses"].IsReady}
	{
		waitframe
	}

	;; Check other players 10m and buff them if needed
	for (i:Set[1] ; ${i}<=${VG.PawnCount} ; i:Inc)
	{
		if ${Pawn[${i}].Type.Equal[pc]} || ${Pawn[${i}].Type.Equal[Group Member]}
		{
			if ${Pawn[${i}].Distance}<20 && ${Pawn[${i}].HaveLineOfSightTo} 
			{
				;; For now, we aren't gonna buff low level toons
				if ${Pawn[${i}].Level}<35
				{
					continue
				}
				
				;; Offensive target our PC
				VGExecute "/targetoffensive ${Pawn[${i}].Name}"
				wait 5 ${Me.TargetBuff[Mass Mental Focus](exists)} || ${Me.TargetBuff[Mass Second Sight](exists)}

				;; Use ALL-IN-ONE BUFF
				if ${Pawn[${i}].Level}>=35 && ${Pawn[${i}].Level}<=43
				{
					if ${Me.TargetBuff[Mass Second Sight](exists)}
					{
						VGExecute "/cleartargets"
						wait 5 !${Me.TargetBuff[Mass Second Sight](exists)}
						continue
					}
					if !${Me.TargetBuff[Mass Second Sight](exists)}
					{
						Pawn[${i}]:Target
						waitframe
						CurrentAction:Set[Buffing ${Me.DTarget.Name}]
						call UseAbility "Favor of the Clairvoyant" "BUFFED ${Me.DTarget.Name}"
						wait 5
						while ${Me.IsCasting} || !${Me.Ability["Using Weaknesses"].IsReady}
						{
							waitframe
						}
						VGExecute "/cleartargets"
						waitframe
						continue
					}
				}

				;; Use the LVL 51+ BUFF
				if ${Me.TargetBuff[Mass Mental Focus](exists)}
				{
					VGExecute "/cleartargets"
					wait 5 !${Me.TargetBuff[Mass Mental Focus](exists)}
					continue
				}

				if !${Me.TargetBuff[Mass Mental Focus](exists)}
				{
					Pawn[${i}]:Target
					waitframe
					CurrentAction:Set[Buffing ${Me.DTarget.Name}]
					call UseAbility "Mass Mental Focus" "BUFFED ${Me.DTarget.Name}"
					wait 5
					while ${Me.IsCasting} || !${Me.Ability["Using Weaknesses"].IsReady}
					{
						waitframe
					}
					VGExecute "/cleartargets"
					waitframe
				}
			}
		}
	}
}


;===================================================
;===        FOLLOW TANK SUB-ROUTINE             ====
;===================================================
function FollowTank()
{
	if ${doFollow}
	{
		if ${Pawn[name,${FollowName}](exists)}
		{
			;; did target move out of rang?
			if ${Pawn[name,${FollowName}].Distance}>=4
			{
				variable bool DidWeMove = FALSE
				;; start moving until target is within range
				while !${isPaused} && ${doFollow} && ${Pawn[name,${FollowName}](exists)} && ${Pawn[name,${FollowName}].Distance}>=1 && ${Pawn[name,${FollowName}].Distance}<45
				{
					if ${Pawn[name,${FollowName}].Distance}<=5
					{
						VGExecute /walk
					}
					Pawn[name,${FollowName}]:Face
					VG:ExecBinding[moveforward]
					DidWeMove:Set[TRUE]
					wait .25
				}
				;; if we moved then we want to stop moving
				if ${DidWeMove}
				{
					VG:ExecBinding[moveforward,release]
				}
			}
		}
	}
	VGExecute /run
}



;===================================================
;===               FOLLOW                       ====
;===================================================
function Follow()
{
	call FollowTank
	return
	
	if ${doFollow}
	{
		if !${Me.InCombat}
		{
			if ${Pawn[name,${FollowName}](exists)}
			{
				if ${Pawn[name,${FollowName}].Distance}>7 && ${Pawn[name,${FollowName}].Distance}<100
				{
					Face:Pawn[${Pawn[id,${FollowID}].ID},FALSE]
					Move:Pawn[${Pawn[id,${FollowID}].ID},5]
				}
			}
		}

		;; Call this once, if pawn is moving then call it many times
		;; To set a distance to stop at... use the following example:  Move:MovePawn[${Pawn[id,${FollowID}].ID},3]
		
		if ${Me.InCombat} && ${Me.Target(exists)} && ${Me.TargetHealth}<95
		{	
			Face:Pawn[${Me.Target.ID}]
			if ${Me.Target.Distance}>10
			{
				Move:Pawn[${Me.Target.ID},5]
			}
			elseif ${Me.Target.Distance.Int}<=1
			{
				VGExecute /walk
				while ${Me.Target(exists)} && ${Me.Target.Distance.Int}<=1
				{
					Face:Pawn[${Me.Target.ID}]
					VG:ExecBinding[movebackward]
				}
				VG:ExecBinding[movebackward,release]
				VGExecute /run
			}
			else
			{
				;; call this once or as many times you want
				Move:Stop
			}
		}
		;elseif !${Me.InCombat} && ${Pawn[id,${FollowID}].Distance}>10
		;{
		;	Face:Pawn[${Pawn[id,${FollowID}].ID},FALSE]
		;	Move:Pawn[${Pawn[id,${FollowID}].ID},5]
		;}
	}
	else
	{
		;; call this once or as many times you want
		Move:Stop
	}
}

;===================================================
;===          GROUP INVITE ACCEPT               ====
;===================================================
function GroupInviteAccept()
{
	if ${Me.GroupInvitePending}
	{
		if ${doAcceptGroupInvite}
		{
			vgexecute /groupacceptinvite
		}
	}
} 

;===================================================
;===     CALLED ROUTINE VIA ATOM - BUMP         ====
;===================================================
function OpenDoor()
{
	VG:ExecBinding[UseDoorEtc]
}

;===================================================
;===       NOW CONTROLLED BY ATOM - BUMP        ====
;===================================================
function OpenPotaBarrier()
{
	;;  - drop that Pota barrier!
	if ${Pawn[Kheolim's Barrier].Distance}<3
	{
		Pawn[Kheolim's Barrier]:DoubleClick
	}
}

;===================================================
;===           SYNCHRONIZE TARGET               ====
;===================================================
function Synchronize(int64 TargetID)
{
	;; Make sure TargetID exists
	if !${Pawn[id,${TargetID}](exists)}
	{
		EchoIt "Syncronize - TargetID does not exist"
		return
	}
	
	;; wait till we are ready to cast
	while ${Me.IsCasting} || !${Me.Ability["Using Weaknesses"].IsReady}
	{
		waitframe
	}
	
	Pawn[id,${TargetID}]:Target
	wait 3
	
	EchoIt "Synchronizing - ${Me.Target.Name}"
	call UseAbility "Synchronize"
}

;===================================================
;===        SYNCHRONIZE TANKS TARGET            ====
;===================================================
function SynchronizeTanksTarget()
{
	;; Target Tanks Target
	VGExecute /assist "${Tank}"
	wait 3
	
	if !${Me.Target(exists)} || ${Me.Target.Type.Equal[Corpse]} || ${Me.Target.IsDead}
	{
		EchoIt "Synchronize - Invalid target!"
		return
	}
	
	;; wait till we are ready to cast
	while ${Me.IsCasting} || !${Me.Ability["Using Weaknesses"].IsReady}
	{
		waitframe
	}
	
	EchoIt "Synchronizing - ${Me.Target.Name}"
	call UseAbility "Synchronize"
}


;===================================================
;===           MEZMERIZE TARGET                 ====
;===================================================
function Mezmerize(int64 TargetID)
{
	;; Make sure TargetID exists
	if !${Pawn[id,${TargetID}](exists)}
	{
		EchoIt "Mezmerize - TargetID does not exist"
		return
	}
	
	;; wait till we are ready to cast
	while ${Me.IsCasting} || !${Me.Ability["Using Weaknesses"].IsReady}
	{
		waitframe
	}
	
	Pawn[id,${TargetID}]:Target
	wait 3
	
	EchoIt "Mezmerize - ${Me.Target.Name}"
	call UseAbility "${TimeTrick}"
}

;===================================================
;===       CHANGE TO CORRECT FORM               ====
;===================================================
function ChangeForm()
{
	if !${Me.InCombat} && !${Me.CurrentForm.Name.Equal[${NonCombatForm}]}
	{
		while !${Me.CurrentForm.Name.Equal[${NonCombatForm}]}
		{
			if ${doForm} && !${Me.CurrentForm.Name.Equal[${NonCombatForm}]}
			{
				Me.Form[${NonCombatForm}]:ChangeTo
				TimedCommand 20 Script[VG-PSI].Variable[doForm]:Set[TRUE]
				doForm:Set[FALSE]
			}
		}
		EchoIt "** New Form = ${Me.CurrentForm.Name}"
	}
	;; Ensure we are in combat form
	if ${Me.InCombat} && !${Me.CurrentForm.Name.Equal[${CombatForm}]}
	{
		while !${Me.CurrentForm.Name.Equal[${CombatForm}]}
		{
			if ${doForm} && !${Me.CurrentForm.Name.Equal[${CombatForm}]}
			{
				Me.Form[${CombatForm}]:ChangeTo
				TimedCommand 20 Script[VG-PSI].Variable[doForm]:Set[TRUE]
				doForm:Set[FALSE]
			}
		}
		EchoIt "** New Form = ${Me.CurrentForm.Name}"
	}
}

;===================================================
;===          HANDLE COUNTERS                   ====
;===================================================
function HandleCounters()
{
	if ${Me.Ability[${Counter1}].IsReady}
	{
		if ${Me.Ability[${Counter1}].TimeRemaining}==0 || ${Me.Ability[${Counter1}].TriggeredCountdown}>0
		{
			if ${Me.IsCasting}
			{
				EchoIt "StopCasting ${Me.Casting}"
			}
			while ${Me.IsCasting}
			{
				VGExecute "/stopcasting"
				wait 3
			}
			while !${Me.Ability["Using Weaknesses"].IsReady}
			{
				waitframe
			}
			CurrentAction:Set[Countering ${Me.TargetCasting}]
			EchoIt "${Counter1} COUNTERED ${Me.TargetCasting}"
			VGExecute "/reactioncounter 1"
			wait 4
			while !${Me.Ability["Using Weaknesses"].IsReady}
			{
				waitframe
			}
		}
	}

	if ${Me.Ability[${Counter2}].IsReady}
	{
		if ${Me.Ability[${Counter2}].TimeRemaining}==0 || ${Me.Ability[${Counter2}].TriggeredCountdown}>0
		{
			if ${Me.IsCasting}
			{
				EchoIt "StopCasting ${Me.Casting}"
			}
			while ${Me.IsCasting}
			{
				VGExecute "/stopcasting"
				wait 4
			}
			while !${Me.Ability["Using Weaknesses"].IsReady}
			{
				waitframe
			}
			CurrentAction:Set[Countering ${Me.TargetCasting}]
			EchoIt "${Counter2} COUNTERED ${Me.TargetCasting}"
			VGExecute "/reactioncounter 2"
			wait 4
			while !${Me.Ability["Using Weaknesses"].IsReady}
			{
				waitframe
			}
		}
	}
}

;===================================================
;===            HANDLE CHAINS                   ====
;===================================================
function HandleChains()
{
	if ${Me.Ability[${Chain1}].IsReady}
	{
		if ${Me.Ability[${Chain1}].TimeRemaining}==0 || ${Me.Ability[${Chain1}].TriggeredCountdown}>0
		{
			;; Check if mob is immune
			call Check4Immunites "${Chain1}"
			if !${Return}
			{
				while !${Me.Ability["Using Weaknesses"].IsReady}
				{
					waitframe
				}
				CurrentAction:Set[Chain ${Chain1}]
				EchoIt "Chain - ${Chain1}"
				VGExecute "/reactionchain 1"
				wait 4
				while !${Me.Ability["Using Weaknesses"].IsReady}
				{
					waitframe
				}
			}
		}
	}

	if ${Me.Ability[${Chain2}].IsReady}
	{
		if ${Me.Ability[${Chain2}].TimeRemaining}==0 || ${Me.Ability[${Chain2}].TriggeredCountdown}>0
		{
			;; Check if mob is immune
			call Check4Immunites "${Chain2}"
			if !${Return}
			{
				while !${Me.Ability["Using Weaknesses"].IsReady}
				{
					waitframe
				}
				CurrentAction:Set[Chain ${Chain2}]
				EchoIt "Chain - ${Chain2}"
				VGExecute "/reactionchain 2"
				wait 4
				while !${Me.Ability["Using Weaknesses"].IsReady}
				{
					waitframe
				}
			}
		}
	}

	if ${Me.Ability[${Chain3}].IsReady}
	{
		if ${Me.Ability[${Chain3}].TimeRemaining}==0 || ${Me.Ability[${Chain3}].TriggeredCountdown}>0
		{
			;; Check if mob is immune
			call Check4Immunites "${Chain3}"
			if !${Return}
			{
				while !${Me.Ability["Using Weaknesses"].IsReady}
				{
					waitframe
				}
				CurrentAction:Set[Chain ${Chain3}]
				EchoIt "Chain - ${Chain3}"
				VGExecute "/reactionchain 3"
				wait 4
				while !${Me.Ability["Using Weaknesses"].IsReady}
				{
					waitframe
				}
			}
		}
	}
}

;===================================================
;===       CLEAR TARGET IF TARGET IS DEAD       ====
;===================================================
function ClearTargets()
{
	if ${Me.Target(exists)}
	{
		;; update our display
		temp:Set[${Me.ToT.Name}]
		if ${temp.Equal[NULL]}
		{
			TargetsTarget:Set[No Target]
		}
		else
		{
			TargetsTarget:Set[${Me.ToT.Name}]
		}

		;; loot everything
		if ${doLootAll}
		{
			if ${Me.TargetHealth}<5
			{
				call LootAll
			}
		}

		
		;; execute only if target is a corpse
		if ${Me.Target.Type.Equal[Corpse]} && ${Me.Target.IsDead}
		{
			;; Stop melee attacks
			if ${GV[bool,bIsAutoAttacking]}
			{
				Me.Ability[Auto Attack]:Use
			}

			;; looting??
			while ${Me.IsLooting}
			{
				CurrentAction:Set[Looting]
				waitframe
			}
			
			;; harvesting??
			while ${GV[bool,bHarvesting]} && ${Me.Target(exists)}
			{
				CurrentAction:Set[Harvesting]
				waitframe
			}
			
			;; loot everything
			if ${doLootAll}
			{
				call LootAll
			}
			
			;; clear target
			CurrentAction:Set[Clearing Targets]
			VGExecute "/cleartargets"
			call ChangeForm
			EchoIt "---------------------------------"

			;; wait long enough
			wait 5
			
			;; update stats
			FURIOUS:Set[FALSE]
			SpellCounter:Set[0]
		}
	}
	else
	{
		;; update display
		TargetsTarget:Set[No Target]
		TargetImmunity:Set[No Target]
	}

}

;===================================================
;===     ACTIONS TO PERFORM WHILE IN COMBAT     ====
;===================================================
function AttackTarget()
{
	;-------------------------------------------
	; Always make sure we are targeting the tank's target
	;-------------------------------------------
	if ${Pawn[name,${Tank}](exists)}
	{
		;; Do not assist Tank if Tank is not in combat
		if ${Pawn[name,${Tank}].CombatState}==0
		{
			return
		}
		if ${Pawn[name,${Tank}].Distance}<40
		{
			;; Assist the Tank
			VGExecute "/assist ${Tank}"
			;; Pause... health sometimes reports NULL or 0
			if ${Me.Target(exists)} && ${Me.TargetHealth}<1
			{
				wait 2
				waitframe
			}
		}
	}

	;-------------------------------------------
	; Check #1 - Return if we do not have a target
	;-------------------------------------------
	if !${Me.Target(exists)}
	{
		return
	}
	
	;-------------------------------------------
	; Check #2 - Return if target is dead or we are harvesting
	;-------------------------------------------
	if ${Me.Target.IsDead} || ${GV[bool,bHarvesting]}
	{
		return
	}

	;-------------------------------------------
	; Check #3 - Return if we can't see the target or target is too far away
	;-------------------------------------------
	if !${Me.Target.HaveLineOfSightTo} || ${Me.Target.Distance}>=30
	{
		return
	}

	;-------------------------------------------
	; Check #4 - Return if target is not in combat
	;-------------------------------------------
	if !${Me.Target.CombatState}==1
	{
		return
	}

	if ${doPushHate} && ${Me.IsGrouped}
	{
		if ${Me.Ability[${MemoryShift}].IsReady} && ${Pawn[name,${PushHateTo}](exists)} && ${Me.Ability[${MemoryShift}].TimeRemaining}==0
		{
			Pawn[name,${PushHateTo}]:Target
			VGExecute /assist "${PushHateTo}"
			wait 3
			waitframe
			if ${Me.DTarget.Name.Find[${PushHateTo}]}
			{
				if ${Group.Count} >6
				{
					;VGExecute "/raid <Red=> Pushing hate onto <Yellow=>${PushHate}"
				}
				if ${Group.Count}>1 && ${Group.Count}<=6
				{
					;VGExecute "/group <Red=> Pushing hate onto <Yellow=>${PushHate}"
				}
				call UseAbility "${MemoryShift}" "- Pushed hate onto ${Me.DTarget.Name}"
				
				;VGExecute "/raid <Red=> Pushing hate onto <Yellow=>${Me.DTarget.Name.Token[1," "]}"
				return
			}
		}
	}
	
	;-------------------------------------------
	; Check #5 - Return to allow tank to gain aggro
	;-------------------------------------------
	if ${Me.TargetHealth}>${StartAttack}
	{
		return
	}

	if ${doRemoveHate} && ${Me.IsGrouped}
	{
		if ${Me.Ability[${MindWipe}].IsReady} && ${Pawn[name,${RemoveHateFrom}](exists)} && ${Me.Ability[${MindWipe}].TimeRemaining}==0 && ${Me.TargetHealth}<90
		{
			Pawn[${RemoveHateFrom}]:Target
			VGExecute /assist "${RemoveHateFrom}"
			wait 3
			waitframe
			if ${Me.DTarget.Name.Find[${RemoveHateFrom}]}
			{
				call UseAbility "${MindWipe}" "- 30% less hate onto ${Me.DTarget.Name}"
				return
			}
		}
	}
	
	;-------------------------------------------
	; Check #6 - Set FURIOUS if buff is up
	;-------------------------------------------
	if ${Me.TargetBuff[Furious](exists)}
	{
		return
	}
	
	;-------------------------------------------
	; Check #7 - Return if target is FURIOUS
	;-------------------------------------------
	if ${FURIOUS}
	{
		return
	}
		
	;-------------------------------------------
	; Check #8 - Return if Weakened and we are Chaos
	;-------------------------------------------
	if ${Me.TargetBuff[Weakened].Description.Find[Chaos]}
	{
		return
	}

	;; ======== SAFE TO DO OUR ATTACK ROUTINES ========
	
	;-------------------------------------------
	; Face our target!
	;-------------------------------------------
	if ${doFaceSlow} && ${Me.Target.Distance}<30
	{
		Face:Pawn[${Me.Target.ID}]
	}
		
	;-------------------------------------------
	; Get our Regen Dots up
	;-------------------------------------------
	if ${Me.EnergyPct}<60 && (!${Me.TargetMyDebuff[${RegenDot1}](exists)} || !${Me.TargetMyDebuff[${RegenDot2}](exists)}) && !${Me.Target.Name.Equal[VAHSREN THE LIBRARIAN]}
	{
		;; Manage 1st Regen Dot
		if !${Me.TargetMyDebuff[${RegenDot1}](exists)}
		{
			;; Check if mob is immune to regen dot
			call Check4Immunites "${RegenDot1}"
			if !${Return}
			{
				EchoIt "** Regenerate Energy using DOT ${RegenDot1}"
				if !${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]}
				{
					while !${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]} && ${Me.Target(exists)} && !${Me.Target.IsDead}
					{
						if ${doForm} && !${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]}
						{
							Me.Form["Concentration: Thought Thief"]:ChangeTo
							TimedCommand 20 Script[VG-PSI].Variable[doForm]:Set[TRUE]
							doForm:Set[FALSE]
						}
					}
					EchoIt "** New Form = ${Me.CurrentForm.Name}"
				}
				if ${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]}
				{
					if !${Me.TargetMyDebuff[${RegenDot1}](exists)} && ${Me.Target(exists)} && !${Me.Target.IsDead}
					{
						call UseAbility "${RegenDot1}"
						if ${Return}
						{
							wait 10 ${Me.TargetMyDebuff[${RegenDot1}](exists)}
							while !${Me.Ability["Using Weaknesses"].IsReady}
							{
								waitframe
							}
							EchoIt "** Regenerating Energy"
							return
						}
					}
				}
			}
		}
		;; Manage 2nd Regen Dot
		if !${Me.TargetMyDebuff[${RegenDot2}](exists)}
		{
			;; Check if mob is immune to regen dot
			call Check4Immunites "${RegenDot2}"
			if !${Return}
			{
				EchoIt "** Regenerate Energy using DOT ${RegenDot2}"
				if !${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]}
				{
					while !${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]} && ${Me.Target(exists)} && !${Me.Target.IsDead}
					{
						if ${doForm} && !${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]}
						{
							Me.Form["Concentration: Thought Thief"]:ChangeTo
							TimedCommand 20 Script[VG-PSI].Variable[doForm]:Set[TRUE]
							doForm:Set[FALSE]
						}
					}
					EchoIt "** New Form = ${Me.CurrentForm.Name}"
				}
				if ${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]}
				{
					if !${Me.TargetMyDebuff[${RegenDot2}](exists)} && ${Me.Target(exists)} && !${Me.Target.IsDead}
					{
						call UseAbility "${RegenDot2}"
						if ${Return}
						{
							wait 10 ${Me.TargetMyDebuff[${RegenDot2}](exists)}
							while !${Me.Ability["Using Weaknesses"].IsReady}
							{
								waitframe
							}
							EchoIt "** Regenerating Energy"
							return
						}
					}
				}
			}
		}
	}

	;-------------------------------------------
	; Got our Regen Dot up and blast target for fast energy
	; FIX -- What if target is immune to mind altering effects such as VAHSREN THE LIBRARIAN?
	;-------------------------------------------
	if ${Me.EnergyPct}<30 && !${Me.Target.Name.Equal[VAHSREN THE LIBRARIAN]}
	{
		EchoIt "** Regenerate Energy using NUKE ${Nuke5}"
		while ${Me.EnergyPct}<80 && ${Me.Target(exists)} && !${Me.Target.IsDead}
		{
			if !${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]}
			{
				while !${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]} && ${Me.Target(exists)} && !${Me.Target.IsDead}
				{
					if ${doForm} && !${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]}
					{
						Me.Form["Concentration: Thought Thief"]:ChangeTo
						TimedCommand 20 Script[VG-PSI].Variable[doForm]:Set[TRUE]
						doForm:Set[FALSE]
					}
				}
				EchoIt "** New Form = ${Me.CurrentForm.Name}"
			}
			if ${Me.CurrentForm.Name.Equal["Concentration: Thought Thief"]}
			{
				;; Regen Dot #1
				call UseAbility "${RegenDot1}"
				
				;; Regen Dot #2
				call UseAbility "${RegenDot2}"

				;; Mental Blast for regen
				call UseAbility "${Nuke5}"
					
				;; Wait till ability finish casting
				while !${Me.Ability["Using Weaknesses"].IsReady} || ${Me.IsCasting}
				{
					waitframe
				}
			}
		}
		return
	}

	;-------------------------------------------
	;; Ensure we are in the correct form
	;-------------------------------------------
	call ChangeForm
		
	;===================================================
	;===     PRIORITY ABILITIES COMES FIRST         ====
	;===================================================

	;; Temporal Shift every 8s (slows mob down)
	if ${doTemporalShift} && ${doDots}
	{  
		call UseAbility "${Dot1}"
		if ${Return}
			return
	}

	;; Corporeal Smash ever 24s
	if ${doCorporealSmash} && ${doNukes}
	{
		call UseAbility "${Nuke1}"
		if ${Return}
			return
	}

	;; Corporeal Hammer ever 24s
	if ${doCorporealHammer} && ${doNukes}
	{
		call UseAbility "${Nuke2}"
		if ${Return}
			return
	}
	
	if ${doCorporealHammer} && ${doNukes}
	{
		call UseAbility "${Nuke2}"
		if ${Return}
			return
	}
/*	
	if !${Me.TargetMyDebuff["Mindspy: Banish"](exists)}
	{
		call UseAbility "Mindspy: Banish"
		if ${Return}
			return
	}
	
	if ${Me.TargetMyDebuff["Mindspy: Banish"](exists)}
	{
		call UseAbility "Mindspy: Gust of Wind"
		if ${Return}
			return
	}
	
*/	

	;; Thought Pulse every 8s
	;if ${doThoughtPulse} && ${doNukes}
	;{
	;	call UseAbility "${Nuke4}"
	;	if ${Return}
	;			return
	;}
		
	;===================================================
	;===      CYCLE THROUGH THESE ABILITIES         ====
	;=== REARRANGE THESE IN THE ORDER OF PREFERENCE ====
	;===================================================
	if ${SpellCounter}>8
	SpellCounter:Set[0]

	while ${SpellCounter}<9
	{
		SpellCounter:Inc
		
		;; Compression Sphere every 20s
		if ${SpellCounter}==1 && ${doCompressionSphere} && ${doDots}
		{
			if !${Me.TargetMyDebuff[${Dot2}](exists)}
			{
				call UseAbility "${Dot2}"
				if ${Return}
					return
			}
		}

		;; Dementia every 8s (One of our highest DPS abilities!)
		if ${SpellCounter}==2 && ${doDementia} && ${doAE}
		{
			if !${Me.TargetMyDebuff[${AE1}](exists)}
			{
				;if ${Me.Target.ID}==${Pawn[npc,AggroNPC,from,target,radius,15].ID}
				;{
					call UseAbility "${AE1}"
				if ${Return}
						return
				;}
			}
		}
			
		;; Psychic Schism every 8s
		if ${SpellCounter}==3 && ${doPsychicSchism} && ${doDots}
		{
			if !${Me.TargetMyDebuff[${Dot3}](exists)}
			{
			call UseAbility "${Dot3}"
				if ${Return}
					return
			}
		}
			
		;; Thought Pulse every 8s
		if ${SpellCounter}==4 && ${doThoughtPulse} && ${doNukes}
		{
			call UseAbility "${Nuke4}"
			if ${Return}
					return
		}
			
		;; Psionic Blast as much as possible
		if ${SpellCounter}==5 && ${doPsionicBlast} && ${doNukes}
		{
		call UseAbility "${Nuke3}"
			if ${Return}
				return
		}

		;; Psionic Blast as much as possible
		if ${SpellCounter}==6 && ${doMentalBlast} && ${doNukes}
		{
			call UseAbility "${Nuke5}"
			if ${Return}
				return
		}

		;; Thought Surge every 8s
		if ${SpellCounter}==7 && ${doThoughtSurge} && ${doAE}
		{
			if !${Me.TargetMyDebuff[${AE2}](exists)}
			{
				call UseAbility "${AE2}"
				if ${Return}
					return
			}
		}

		;; Chronoshift every 2s
		if ${SpellCounter}==8 && ${doChronoshift} && ${doAE}
		{
			call UseAbility "${AE3}"
			if ${Return}
				return
		}
	}
}		

;===================================================
;===              LOOT ALL ON CORPSE            ====
;===================================================
function LootAll()
{
	if ${Me.Target.Distance}>4
		return

	CurrentAction:Set[Looting]
	EchoIt "Looting: ${Me.Target.Name}"

	;	if ${Me.Target(exists)}
	;		call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4

	;; Start Loot Window
	Loot:BeginLooting
	if ${VG.FPS}<10
	{
		wait 2
	}
	else
	{
		wait 1
	}

	if !${Loot.NumItems}
		wait 2
			
	;; Begin Looting
	if ${Loot.NumItems}
	{
		;; Try looting 1 item at a time
		variable int a
		for ( a:Set[1] ; ${a}<=${Loot.NumItems} ; a:Inc )
		{
			EchoIt "*Looting ${Loot.Item[${a}]}"
			Loot.Item[${a}]:Loot
		}
			
		;; Then loot everything
		Loot:LootAll
	}

	;; End Looting
	if ${Me.IsLooting}
	{
		Loot:EndLooting
	}

	;; Loot whatever
	;VGExecute /loot
}

;===================================================
;===              USE AN ABILITY                ====
;===================================================
function:bool UseAbility(string ABILITY, TEXT=" ")
{
	;; does ability exist?
	if !${Me.Ability[${ABILITY}](exists)}
	{
		EchoIt "${ABILITY} does not exist"
		return FALSE
	}

	if ${Me.Ability[${ABILITY}].IsReady}
	{
		;; Check if mob is immune
		call Check4Immunites "${ABILITY}"
		if ${Return}
		{
			EchoIt "Immune to ${ABILITY}"
			return FALSE
		}
	
		;; is mob immune or healed by ability
		;;if ${LearnedImmunitiesList.Element["${Me.Target.Name}"].Equal[${ABILITY}]}
		;;	return FALSE

		;; does ability exist in my buff?
		;if ${Me.Effect[${ABILITY}](exists)}
		;{
		;	return FALSE
		;}
	
		;; are we waiting to use ability?
		if ${Me.Ability[${ABILITY}].TimeRemaining}>0
		{
			EchoIt "TimeRemaining - ${ABILITY}"
			return FALSE
		}
	
		;; do we have energy to use ability?
		if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		{
			EchoIt "Not enought Energy for ${ABILITY}"
			return FALSE
		}
		
		;; is target in range?
		if !${Me.Ability[${ABILITY}].TargetInRange}
		{
			EchoIt "Target not in range for ${ABILITY}"
			return FALSE
		}
		
		;; execute ability
		EchoIt "UseAbility - ${ABILITY} ${TEXT}"
		CurrentAction:Set[Casting ${ABILITY}]
		Me.Ability[${ABILITY}]:Use
		wait 5
		;while !${Me.Ability["Using Weaknesses"].IsReady} || ${Me.IsCasting} || ${VG.InGlobalRecovery}>0
		;{
		;	waitframe
		;}
		;waitframe
		;LastDowntimeCall:Set[${Script.RunningTime}]
		return TRUE
	}
	return FALSE
}		

;===================================================
;===  Scan area for my tombstone and loot it    ====
;===================================================
function LootMyTombstone()
{
	;; allow time to relocate after accepting rez
	wait 20
	
	;; clear our target
	VGExecute "/cleartargets"
	wait 5 !${Me.Target(exists)}
	
	;; target our nearest corpse
	VGExecute "/targetmynearestcorpse"
	wait 20 ${Me.Target(exists)}
	
	;; drag it closer if we are still out of range
	if ${Me.Target.Distance}>5 && ${Me.Target.Distance}<21
	{
		VGExecute "/corpsedrag"
		wait 10 ${Me.Target.Distance}<=5
	}
	
	;; loot our tombstone and clear our target
	VGExecute "/lootall"
	VGExecute "/cleartargets"
	wait 5 !${Me.Target(exists)}
	
	EchoIt "Looted my tombstone"
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;===================================================
;===     ATOM - CALLED AT END OF SCRIPT         ====
;===================================================
function atexit()
{
	;; stop moving incase we are moving
	VG:ExecBinding[moveforward,release]
	VGExecute /run

	;; Save our Settings
	SaveXMLSettings	

	;; Unload our UI
	ui -unload "${Script.CurrentDirectory}/VG-PSI.xml"
	
	;; Say we are done
	EchoIt "Stopped VG-PSI Script"
}

;===================================================
;===       ATOM - ECHO A STRING OF TEXT         ====
;===================================================
atom(script) EchoIt(string aText)
{
	if ${doEcho}
	{
		echo "[${Time}][VG-PSI]: ${aText}"
	}
}

;===================================================
;===          ATOM - PLAY A SOUND               ====
;===================================================
atom(script) PlaySound(string Filename)
{	
	System:APICall[${System.GetProcAddress[WinMM.dll,PlaySound].Hex},Filename.String,0,"Math.Dec[22001]"]
}

;===================================================
;===    ATOM - OPEN A DOOR THAT YOU BUMPED      ====
;===================================================
atom Bump(string aObstacleActorName, float fX_Offset, float fY_Offset, float fZ_Offset)
{
	if (${aObstacleActorName.Find[Mover]})
	{
		Script[VG-PSI]:QueueCommand[call OpenDoor]
	}
}

;===================================================
;===       ATOM - SET HIGHEST ABILITIES         ====
;===================================================
atom(script) SetHighestAbility(string AbilityVariable, string AbilityName)
{
	declare L int local 9
	declare ABILITY string local ${AbilityName}
	declare AbilityLevels[9] string local

	AbilityLevels[1]:Set[I]
	AbilityLevels[2]:Set[II]
	AbilityLevels[3]:Set[III]
	AbilityLevels[4]:Set[IV]
	AbilityLevels[5]:Set[V]
	AbilityLevels[6]:Set[VI]
	AbilityLevels[7]:Set[VII]
	AbilityLevels[8]:Set[VIII]
	AbilityLevels[9]:Set[IX]

	;-------------------------------------------
	; Return if Ability already exists - based upon current level
	;-------------------------------------------
	if ${Me.Ability["${AbilityName}"](exists)} && ${Me.Ability[${ABILITY}].LevelGranted}<=${Me.Level}
	{
		EchoIt " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY}"
		declare	${AbilityVariable}	string	script "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Find highest Ability level - based upon current level
	;-------------------------------------------
	do
	{
		if ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"](exists)} && ${Me.Ability["${AbilityName} ${AbilityLevels[${L}]}"].LevelGranted}<=${Me.Level}
		{
			ABILITY:Set["${AbilityName} ${AbilityLevels[${L}]}"]
			break
		}
	}
	while (${L:Dec}>0)

	;-------------------------------------------
	; If Ability exist then return
	;-------------------------------------------
	if ${Me.Ability["${ABILITY}"](exists)} && ${Me.Ability["${ABILITY}"].LevelGranted}<=${Me.Level}
	{
		EchoIt " --> ${AbilityVariable}:  Level=${Me.Ability[${ABILITY}].LevelGranted} - ${ABILITY}"
		declare	${AbilityVariable}	string	script "${ABILITY}"
		return
	}

	;-------------------------------------------
	; Otherwise, new Ability is named "None"
	;-------------------------------------------
	EchoIt " --> ${AbilityVariable}:  None"
	declare	${AbilityVariable}	string	script "None"
	return
}

;===================================================
;===     ATOM - Load Variables from XML         ====
;===================================================
atom(script) LoadXMLSettings()
{
	;; Create the Save directory incase it doesn't exist
	variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-PSI/Save"
	mkdir "${savePath}"

	;; Define our SSR
	variable settingsetref VG-PSI_SSR
	
	;;Load Lavish Settings 
	LavishSettings[VG-PSI]:Clear
	LavishSettings:AddSet[VG-PSI]
	LavishSettings[VG-PSI]:AddSet[MySettings]
	LavishSettings[VG-PSI]:Import[${savePath}/MySettings.xml]	
	VG-PSI_SSR:Set[${LavishSettings[VG-PSI].FindSet[MySettings]}]

	;;Set values for MySettings
	StartAttack:Set[${VG-PSI_SSR.FindSetting[StartAttack,99]}]
	doPushHate:Set[${VG-PSI_SSR.FindSetting[doPushHate,FALSE]}]
	doRemoveHate:Set[${VG-PSI_SSR.FindSetting[doRemoveHate,TRUE]}]
	doNukes:Set[${VG-PSI_SSR.FindSetting[doNukes,TRUE]}]
	doDots:Set[${VG-PSI_SSR.FindSetting[doDots,TRUE]}]
	doAE:Set[${VG-PSI_SSR.FindSetting[doAE,FALSE]}]
	doBuffs:Set[${VG-PSI_SSR.FindSetting[doBuffs,FALSE]}]
	doFaceSlow:Set[${VG-PSI_SSR.FindSetting[doFaceSlow,TRUE]}]
	doLootAll:Set[${VG-PSI_SSR.FindSetting[doLootAll,FALSE]}]
	doTemporalShift:Set[${VG-PSI_SSR.FindSetting[doTemporalShift,TRUE]}]
	doCompressionSphere:Set[${VG-PSI_SSR.FindSetting[doCompressionSphere,TRUE]}]
	doPsychicSchism:Set[${VG-PSI_SSR.FindSetting[doPsychicSchism,TRUE]}]
	doDementia:Set[${VG-PSI_SSR.FindSetting[doDementia,FALSE]}]
	doThoughtSurge:Set[${VG-PSI_SSR.FindSetting[doThoughtSurge,FALSE]}]
	doChronoshift:Set[${VG-PSI_SSR.FindSetting[doChronoshift,FALSE]}]
	doMentalBlast:Set[${VG-PSI_SSR.FindSetting[doMentalBlast,TRUE]}]
	doThoughtPulse:Set[${VG-PSI_SSR.FindSetting[doThoughtPulse,TRUE]}]
	doCorporealHammer:Set[${VG-PSI_SSR.FindSetting[doCorporealHammer,TRUE]}]
	doPsionicBlast:Set[${VG-PSI_SSR.FindSetting[doPsionicBlast,TRUE]}]
	doCorporealSmash:Set[${VG-PSI_SSR.FindSetting[doCorporealSmash,TRUE]}]
	
	StartFollowText:Set[${VG-PSI_SSR.FindSetting[StartFollowText,""]}]
	StopFollowText:Set[${VG-PSI_SSR.FindSetting[StopFollowText,""]}]
	KillLevitationText:Set[${VG-PSI_SSR.FindSetting[KillLevitationText,""]}]
	BuffEveryoneText:Set[${VG-PSI_SSR.FindSetting[BuffEveryoneText,""]}]
}

;===================================================
;===      ATOM - Save Variables to XML          ====
;===================================================
atom(script) SaveXMLSettings()
{
	;; Create the Save directory incase it doesn't exist
	variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-PSI/Save"
	mkdir "${savePath}"

	;; Define our SSR
	variable settingsetref VG-PSI_SSR
	
	;; Load Lavish Settings 
	LavishSettings[VG-PSI]:Clear
	LavishSettings:AddSet[VG-PSI]
	LavishSettings[VG-PSI]:AddSet[MySettings]
	LavishSettings[VG-PSI]:Import[${savePath}/MySettings.xml]	
	VG-PSI_SSR:Set[${LavishSettings[VG-PSI].FindSet[MySettings]}]

	;; Save MySettings
	VG-PSI_SSR:AddSetting[StartAttack,${StartAttack}]
	VG-PSI_SSR:AddSetting[doPushHate,${doPushHate}]
	VG-PSI_SSR:AddSetting[doRemoveHate,${doRemoveHate}]
	VG-PSI_SSR:AddSetting[doNukes,${doNukes}]
	VG-PSI_SSR:AddSetting[doDots,${doDots}]
	VG-PSI_SSR:AddSetting[doAE,${doAE}]
	VG-PSI_SSR:AddSetting[doBuffs,${doBuffs}]
	VG-PSI_SSR:AddSetting[doFaceSlow,${doFaceSlow}]
	VG-PSI_SSR:AddSetting[doLootAll,${doLootAll}]
	VG-PSI_SSR:AddSetting[doTemporalShift,${doTemporalShift}]
	VG-PSI_SSR:AddSetting[doCompressionSphere,${doCompressionSphere}]
	VG-PSI_SSR:AddSetting[doPsychicSchism,${doPsychicSchism}]
	VG-PSI_SSR:AddSetting[doDementia,${doDementia}]
	VG-PSI_SSR:AddSetting[doThoughtSurge,${doThoughtSurge}]
	VG-PSI_SSR:AddSetting[doChronoshift,${doChronoshift}]
	VG-PSI_SSR:AddSetting[doMentalBlast,${doMentalBlast}]
	VG-PSI_SSR:AddSetting[doThoughtPulse,${doThoughtPulse}]
	VG-PSI_SSR:AddSetting[doCorporealHammer,${doCorporealHammer}]
	VG-PSI_SSR:AddSetting[doPsionicBlast,${doPsionicBlast}]
	VG-PSI_SSR:AddSetting[doCorporealSmash,${doCorporealSmash}]

	VG-PSI_SSR:AddSetting[StartFollowText,${StartFollowText}]
	VG-PSI_SSR:AddSetting[StopFollowText,${StopFollowText}]
	VG-PSI_SSR:AddSetting[KillLevitationText,${KillLevitationText}]
	VG-PSI_SSR:AddSetting[BuffEveryoneText,${BuffEveryoneText}]

	;; Save to file
	LavishSettings[VG-PSI]:Export[${savePath}/MySettings.xml]
}

variable bool doCounters = TRUE

;===================================================
;===      ATOM - CATCH THEM COUNTERS!           ====
;===================================================
atom(script) Counters()
{
	if ${doCounters}
	{
		if ${Me.Ability[${Counter1}].IsReady}
		{
			if ${Me.Ability[${Counter1}].TimeRemaining}==0 || ${Me.Ability[${Counter1}].TriggeredCountdown}>0
			{
				VGExecute "/reactioncounter 1"
				EchoIt "${Counter1} COUNTERED ${Me.TargetCasting}"

				;; Set delay of 1 second
				TimedCommand 10 Script[VG-PSI].Variable[doCounters]:Set[TRUE]
				doCounters:Set[FALSE]
				return
			}
		}
		if ${Me.Ability[${Counter2}].IsReady}
		{
			if ${Me.Ability[${Counter2}].TimeRemaining}==0 || ${Me.Ability[${Counter2}].TriggeredCountdown}>0
			{
				VGExecute "/reactioncounter 2"
				EchoIt "${Counter2} COUNTERED ${Me.TargetCasting}"

				;; Set delay of 1 second
				TimedCommand 10 Script[VG-PSI].Variable[doCounters]:Set[TRUE]
				doCounters:Set[FALSE]
				return
			}
		}
	}
}

;===================================================
;===      ATOM - UPDATE OUR GUI DISPLAY         ====
;===================================================
atom(script) UpdateDisplay()
{
	;; Update once per second
	if (${Math.Calc[${Math.Calc[${Script.RunningTime}-${NextUpdateDisplay}]}/1000]} < .5)
	{
		return
	}
	NextUpdateDisplay:Set[${Script.RunningTime}]

	if ${Me.InCombat} && !${Me.Target.IsDead}
	{
		;; Catch them Counters
		Counters

		;; update Timer
		EndAttackTime:Set[${Script.RunningTime}]
	}
	
	;; Main
	UIElement[Text-Status@VG-PSI]:SetText[ Current Action:  ${CurrentAction}]
	UIElement[Text-Immune@VG-PSI]:SetText[ Target's Immunity:  ${TargetImmunity}]
	UIElement[Text-TOT@VG-PSI]:SetText[ Target's Target:  ${TargetsTarget}]

	;; Stats - Parser
	;;if !${Me.InCombat} && ${Me.Encounter}==0 && (${Me.Target.CombatState}==0 || ${Me.TargetHealth}>99)
	if !${Me.InCombat} && ${Me.Target.CombatState}==0
	{
		ResetParse:Set[TRUE]
	}

	UIElement[DPS@Stats@Tabs@VG-PSI]:SetText[Current DPS = ${DPS}]
	UIElement[TotalDamage@Stats@Tabs@VG-PSI]:SetText[Total Damage = ${DamageDone}]
	UIElement[CRIT@Stats@Tabs@VG-PSI]:SetText[CRIT = ${CRIT}]
	UIElement[EPIC@Stats@Tabs@VG-PSI]:SetText[EPIC = ${EPIC}]

	UIElement[TemporalShift@Stats@Tabs@VG-PSI]:SetText[Temp Shift = ${TemporalShift}]
	UIElement[CompressionSphere@Stats@Tabs@VG-PSI]:SetText[Comp Sphere = ${CompressionSphere}]
	UIElement[PsychicSchism@Stats@Tabs@VG-PSI]:SetText[PsychicSchism = ${PsychicSchism}]

	UIElement[Dementia@Stats@Tabs@VG-PSI]:SetText[Dementia = ${Dementia}]
	UIElement[ThoughtSurge@Stats@Tabs@VG-PSI]:SetText[ThoughtSurge = ${ThoughtSurge}]
	UIElement[Chronoshift@Stats@Tabs@VG-PSI]:SetText[Chronoshift = ${Chronoshift}]

	UIElement[Mindfire@Stats@Tabs@VG-PSI]:SetText[Mindfire = ${Mindfire}]
	UIElement[TelekineticBlast@Stats@Tabs@VG-PSI]:SetText[Tele Blast = ${TelekineticBlast}]
	UIElement[TemporalFracture@Stats@Tabs@VG-PSI]:SetText[Temp Frac = ${TemporalFracture}]

	UIElement[MentalBlast@Stats@Tabs@VG-PSI]:SetText[Mental Blast = ${MentalBlast}]
	UIElement[ThoughtPulse@Stats@Tabs@VG-PSI]:SetText[Thought Pulse = ${ThoughtPulse}]
	UIElement[PsionicBlast@Stats@Tabs@VG-PSI]:SetText[Psionic Blast = ${PsionicBlast}]
	UIElement[CorporealSmash@Stats@Tabs@VG-PSI]:SetText[Corporeal Hammer/Smash = ${Corporeal}]

	variable int MS = 0
	variable int MIN = 0
	variable int SEC = 0
	variable int TIME = 0
		
	;; Calculate total milliseconds
	MS:Set[${Math.Calc[${EndAttackTime}-${StartAttackTime}]}]
	
	if ${MS}>0
	{
		;; Calculate total seconds
		TIME:Set[${Math.Calc[(${EndAttackTime}-${StartAttackTime})/1000]}]

		;; Calculate total minutes
		MIN:Set[${Math.Calc[${TIME}/60]}]

		;; Calculate our seconds
		SEC:Set[${Math.Calc[${TIME}%60].Int}]
	}

	UIElement[TotalTime@Stats@Tabs@VG-PSI]:SetText["Total Time = ${MIN.LeadingZeroes[2]} minutes, ${SEC.LeadingZeroes[2]} seconds"]
	
	
	;UIElement[DPS@Stats@Tabs@VG-PSI]:SetText[Current DPS = ${DPS}]
	;UIElement[TotalDamage@Stats@Tabs@VG-PSI]:SetText[Current Total Damage = ${DamageDone}]
	;UIElement[Last-DPS@Stats@Tabs@VG-PSI]:SetText[Previous DPS = ${LastDPS}]
	;UIElement[Last-TotalDamage@Stats@Tabs@VG-PSI]:SetText[Previous Total Damage = ${LastDamageDone}]
	
	;; MEZ
	if ${Me.Encounter[1].ID(exists)}
	{
		UIElement[Mezmerize Encounter-1@MEZ@Tabs@VG-PSI]:SetText[MEZ - ${Me.Encounter[1].Name}]
	}
	else
	{
		UIElement[Mezmerize Encounter-1@MEZ@Tabs@VG-PSI]:SetText[MEZ - No 1st Encounter]
	}
	if ${Me.Encounter[2].ID(exists)}
	{
		UIElement[Mezmerize Encounter-2@MEZ@Tabs@VG-PSI]:SetText[MEZ - ${Me.Encounter[2].Name}]
	}
	else
	{
		UIElement[Mezmerize Encounter-2@MEZ@Tabs@VG-PSI]:SetText[MEZ - No 2nd Encounter]
	}

	;; Misc
	UIElement[Follow Name@Misc@Tabs@VG-PSI]:SetText[Follow:  ${FollowName}]
	UIElement[PushHateTo Name@Misc@Tabs@VG-PSI]:SetText[PushHateTo:  ${PushHateTo}]
	UIElement[RemoveHateFrom Name@Misc@Tabs@VG-PSI]:SetText[RemoveHateFrom:  ${RemoveHateFrom}]
	
	;; Update our immunity Display
	call Check4Immunites
}

;===================================================
;===       ATOM - Monitor Chat Event            ====
;===================================================
atom(script) ChatEvent(string aText, string ChannelNumber, string ChannelName)
{
	;; Snap to face target
	if (${aText.Find["no line of sight to your target"]})
	{
		if ${doFace} && ${Me.Target(exists)}
		{
			face ${Math.Calc[${Me.Target.HeadingTo}+${Math.Rand[6]}-${Math.Rand[12]}]}
		}
	}

	;; Clear target if lacking harvesting skill
	if (${aText.Find["You do not have enough skill to begin harvesting this resource"]})
	{
		if ${Me.Target(exists)}
		VGExecute /cleartargets
	}

	;; Check if target is no longer FURIOUS
	if ${ChannelNumber}==7 && ${aText.Find[is no longer FURIOUS]}
	{
		if ${Me.Target(exists)} && ${aText.Find[${Me.Target.Name}]} && ${Me.TargetHealth}<30
		{
			vgecho "FURIOUS - RESUME ATTACKING"
			FURIOUS:Set[FALSE]
		}
	}

	; Check if target went into FURIOUS - Has delays for notification
	if ${ChannelNumber}==7 && ${aText.Find[becomes FURIOUS]}
	{
		if ${Me.Target(exists)} && ${aText.Find[${Me.Target.Name}]} && ${Me.TargetHealth}<30
		{
			;; Turn on FURIOUS flag and stop attack
			vgecho "FURIOUS -- STOP ATTACKS"
			FURIOUS:Set[TRUE]

			;; Turn off attacks!
			if ${GV[bool,bIsAutoAttacking]}
			{
				Me.Ability[Auto Attack]:Use
			}
		}
	}

	;; Accept Rez
	if ${ChannelNumber}==32 && ${doAcceptRez} && ${aText.Find[is trying to resurrect you with]}
	{
		VGExecute "/rezaccept"
		Script[VG-PSI]:QueueCommand[call LootMyTombstone]
	}

	
	;; Ping us on tells or anything with our name in it
	if ${ChannelNumber}==15 && ${aText.Find[From ]}
	{
		EchoIt "${aText}"
		PlaySound ALARM
	}

	if ${aText.Find[${StartFollowText}]}
	{
		doFollow:Set[TRUE]
		UIElement[doFollow@Main@Tabs@VG-PSI]:SetChecked
		UIElement[doFollow@Misc@Tabs@VG-PSI]:SetChecked
	}
	
	if ${aText.Find[${StopFollowText}]}
	{
		doFollow:Set[FALSE]
		UIElement[doFollow@Main@Tabs@VG-PSI]:UnsetChecked
		UIElement[doFollow@Misc@Tabs@VG-PSI]:UnsetChecked
	}

;; ${ChannelNumber}==15
	if ${aText.Find[${KillLevitationText}]}
	{
		Me.Effect[Gift of Alcipus]:Remove
		Me.Effect[Death March]:Remove
		Me.Effect[Briel's Trill of the Clouds]:Remove
		Me.Effect[Boon of Alcipus]:Remove
		Me.Effect[Mind Over Body]:Remove
	}

	if ${aText.Find[${BuffEveryoneText}]}
	{
		Script[VG-PSI]:QueueCommand[call ScanAreaToBuff]
	}
	
}

;===================================================
;===    ATOM - Monitor Combat Text Messages     ====
;===================================================
atom CombatText(string aText, int aType)
{
	;redirect -append "${LavishScript.CurrentDirectory}/Scripts/VG-PSI/Save/CombatText.txt" echo "[${Time}][${aType}][${aText}]"
	;redirect -append "${LavishScript.CurrentDirectory}/Scripts/VG-PSI/Save/CombatText${aType}.txt" echo "[${Time}][${aType}][${aText}]"

	;;if ${aText.Find[heals]} || ${aText.Find[healing]} || ${aText.Find[immune]}
	if ${aText.Find[healing for]} || ${aText.Find[absorbes your]}
	{
		if ${aText.Find[${Me.Target.Name}]}
		{

			PlaySound ALARM
		
			;; Create the Save directory incase it doesn't exist
			variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-PSI/Save"
			mkdir "${savePath}"

			;; dump to file
			redirect -append "${savePath}/LearnedImmunities.txt" echo "[${Time}][${aType}][${Me.Target.Name}][${aText.Token[2,">"].Token[1,"<"]}] -- [${aText}]"

			;; display the info
			echo ${Me.Target.Name} absorbed/healed/immune to ${aText.Token[2,">"].Token[1,"<"]}
			vgecho Immune: ${aText.Token[2,">"].Token[1,"<"]}
		}
	}
	
	;; Handle curses
	if ${Text.Find["Major Curse:"]} || ${Text.Find["Greater Curse:"]}
	{
		if ${Me.IsGrouped}
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${Text.Find[${Group[${i}].Name}]}
				{
					RemoveCurseRequest:Set[TRUE]
					Cursed:Set[${Group[${i}].Name}]
					break
				}
			}
		}
		elseif ${Text.Find[${Me.FName}]}
		{
			RemoveCurseRequest:Set[TRUE]
			Cursed:Set[${Me.FName}]
		}
	}
	
	if ${aType} == 26 && !${aText.Find[damage to You]}
	{
		if ${aText.Find[additional <]}
		{
			;; Update our total damage
			ParseDamage:Set[${aText.Mid[${aText.Find[additional <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
			DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
			if ${aText.Find[Epic]}
			{
				EPIC:Set[${Math.Calc[${EPIC}+${ParseDamage}]}]
			}
			if ${aText.Find[Critical Hit]}
			{
				CRIT:Set[${Math.Calc[${CRIT}+${ParseDamage}]}]
			}
			CalculateDPS "${aText}"
		}
		elseif ${aText.Find[for <]}
		{
			;; Update our total damage
			ParseDamage:Set[${aText.Mid[${aText.Find[for <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
			DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
			CalculateDPS "${aText}"
		}
		elseif ${aText.Find[deals <]}
		{
			;; Update our total damage
			ParseDamage:Set[${aText.Mid[${aText.Find[deals <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
			DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
			CalculateDPS "${aText}"
		}
		elseif ${aText.Find[draw <]}
		{
			;; Update our total damage
			ParseDamage:Set[${aText.Mid[${aText.Find[draw <highlight>]},${aText.Length}].Token[2,>].Token[1,<]}]
			DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
			CalculateDPS "${aText}"
		}
		elseif ${aText.Find[damage shield]}
		{
			;; Update our total damage
			ParseDamage:Set[${aText.Mid[${aText.Find[for]}	,${aText.Length}].Token[2,r].Token[1,d]}]
			DamageDone:Set[${Math.Calc[${DamageDone}+${ParseDamage}]}]
			CalculateDPS "${aText}"
		}
	}
}

;===================================================
;===    ATOM - Parser to calculate DPS          ====
;===================================================
atom(script) CalculateDPS(string aText)
{
	;; Set start timer
	if ${ResetParse}
	{
		ResetParse:Set[FALSE]
		DPS:Set[0]
		DamageDone:Set[${ParseDamage}]
		CRIT:Set[0]
		EPIC:Set[0]
		StartAttackTime:Set[${Script.RunningTime}]

		Mindfire:Set[0]
		TelekineticBlast:Set[0]
		TemporalFracture:Set[0]

		TemporalShift:Set[0]
		CompressionSphere:Set[0]
		PsychicSchism:Set[0]

		Dementia:Set[0]
		ThoughtSurge:Set[0]
		Chronoshift:Set[0]

		MentalBlast:Set[0]
		ThoughtPulse:Set[0]
		PsionicBlast:Set[0]
		Corporeal:Set[0]
	}
	
	;; Calculate and update DPS
	EndAttackTime:Set[${Script.RunningTime}]
	TimeFought:Set[${Math.Calc[${EndAttackTime}-${StartAttackTime}]}]
	if ${TimeFought}>999
	{
		DPS:Set[${Math.Calc[${DamageDone}/${Math.Calc[${TimeFought}/1000]}].Round}]
	}
	else
	{
		DPS:Set[${DamageDone}]
	}
	
	if ${aText.Find[Mindfire]}
	{
		Mindfire:Set[${Math.Calc[${Mindfire}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Telekinetic Blast]}
	{
		TelekineticBlast:Set[${Math.Calc[${TelekineticBlast}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Temporal Fracture]}
	{
		TemporalFracture:Set[${Math.Calc[${TemporalFracture}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Mental Blast]}
	{
		MentalBlast:Set[${Math.Calc[${MentalBlast}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Thought Pulse]}
	{
		ThoughtPulse:Set[${Math.Calc[${ThoughtPulse}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Corporeal]}
	{
		Corporeal:Set[${Math.Calc[${Corporeal}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Psionic Blast]}
	{
		PsionicBlast:Set[${Math.Calc[${PsionicBlast}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Dementia]}
	{
		Dementia:Set[${Math.Calc[${Dementia}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Thought Surge]}
	{
		ThoughtSurge:Set[${Math.Calc[${ThoughtSurge}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Chronoshift]}
	{
		Chronoshift:Set[${Math.Calc[${Chronoshift}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Temporal Shift]}
	{
		TemporalShift:Set[${Math.Calc[${TemporalShift}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Compression Sphere]}
	{
		CompressionSphere:Set[${Math.Calc[${CompressionSphere}+${ParseDamage}]}]
	}
	elseif ${aText.Find[Psychic Schism]}
	{
		PsychicSchism:Set[${Math.Calc[${PsychicSchism}+${ParseDamage}]}]
	}
	
}