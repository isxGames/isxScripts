;-------------------------------------------------------
; VG-DK.iss Version 1.0 Updated: 2010/07/04 by Zandros
;-------------------------------------------------------
;
;===================================================
;===              INCLUDES                      ====
;===================================================
;#include ./VG-DK/Objects/Obj_Face.iss
;#include ./VG-DK/Objects/Obj_Move.iss

#include ./VG-DK/Includes/Variables.iss
#include ./VG-DK/Includes/Abilities.iss
#include ./VG-DK/Includes/AutoRepair.iss
#include ./VG-DK/Includes/Check4Immunites.iss
#include ./VG-DK/Includes/Buffs.iss
#include ./VG-DK/Includes/Consumables.iss
#include ./VG-DK/Includes/Loot.iss
#include ./VG-DK/Includes/Hunt.iss
#include ./VG-DK/Includes/FindTarget.iss
#include ./VG-DK/Includes/MoveCloser.iss
#include ./VG-DK/Includes/FaceSlow.iss
#include ./VG-DK/Includes/Rescues.iss
#include ./VG-DK/Includes/HandleCounters.iss
#include ./VG-DK/Includes/HandleChains.iss
#include ./VG-DK/Includes/ShadowStepHeal.iss

;===================================================
;===            MAIN SCRIPT                     ====
;===================================================
function main()
{
	EchoIt "Started VG-DK Script"

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
	ui -reload -skin VGSkin "${Script.CurrentDirectory}/VG-DK.xml"
	
	;; Find highest abilities
	call SetupAbilities
	
	;; Turn on our event monitors
	Event[OnFrame]:AttachAtom[HandleChains]
	Event[OnFrame]:AttachAtom[UpdateDisplay]
	Event[VG_OnIncomingText]:AttachAtom[ChatEvent]
	Event[VG_OnIncomingCombatText]:AttachAtom[CombatText]
	Event[VG_onHitObstacle]:AttachAtom[Bump]

	;-------------------------------------------
	; LOOP THIS INDEFINITELY
	;-------------------------------------------
	while ${isRunning}
	{
		;; sometimes, health will report 0 so lets wait (do not remove that waitframe)
		waitframe
		if ${Me.Target(exists)}
		{
			if ${Me.TargetHealth}==0 && !${Me.Target.IsDead}
			{
				wait 10 ${Me.TargetHealth} && ${Me.Target(exists)}
			}
		}
		
		;; Update our current action
		if ${Me.IsCasting}
		{
			CurrentAction:Set[Casting ${Me.Casting}]
		}
		if !${Me.IsCasting} && ${Me.Ability["Torch"].IsReady}
		{
			CurrentAction:Set[Waiting]
		}
		
		;; Set the move backward flag
		if !${Me.InCombat}
		{
			doBackup:Set[TRUE]
		}
		
		;; Execute any queued commands
		if ${QueuedCommands}
		{
			ExecuteQueued
			FlushQueued
		}
		
		;; Take down that pesky POTA barrier
		call OpenPotaBarrier

		;; execute main routine
		if !${isPaused} 
		{
			;; Reset TargetBuff counter
			if !${Me.Target(exists)}
			{
				TargetBuffs:Set[0]
			}
			
			;; Targetbuff counter increased so set the doDisEnchant flag
			if ${Me.TargetBuff}>${TargetBuffs}
			{
				doDisEnchant:Set[TRUE]
			}
			
			;; Update our Targetbuff counter
			TargetBuffs:Set[${Me.TargetBuff}]

			;; Call our routines
			call CriticalRoutines
			call MainRoutines
		}
	}
}

;===================================================
;===           CRITICAL ROUTINES                ====
;===================================================
function CriticalRoutines()
{
	if ${Me.Target(exists)} && !${Me.Target.Type.Equal[Corpse]} && !${Me.Target.IsDead}
	{
		call Rescues
		HandleChains
		call HandleCounters
	}
}

;===================================================
;=== Heart of the script so we must prioritize  ====
;===================================================
function MainRoutines()
{
	variable int i
	variable int x = 0
	variable int y = 0
	variable bool doAssistCheck = TRUE

	;; Be sure to switch into correct form
	call ChangeForm

	;; Repair our Equipment
	call AutoRepair

	;; Ensure buffs are up
	call BuffUp

	;; Ensure we remove certain buffs
	call CancelBuffs
	
	;; Loot and Clear Targets
	call ClearTargets
	
	;; This will cycle targets in your encounter list
	call CycleTargets
	
	;; Hunt for a target
	call Hunt

	if !${Me.IsGrouped} && ${Me.Target(exists)}
	{
		;; find a closer Encounter if my target moved 10 meters away
		if ${Me.Target.Distance}>10 && ${Me.Encounter}
		{
			x:Set[1000]
			y:Set[1]
			for (i:Set[1] ; ${i}<=${Me.Encounter} ; i:Inc )
			{
				if ${Me.Encounter[${i}].Distance}<${x}
				{
					x:Set[${Me.Encounter[${i}].Distance}]
					y:Set[${i}]
				}
			}
			Pawn[ID,${Me.Encounter[${y}].ID}]:Target
			wait 5
		}
	}

	;; AutoAssist anyone in combat when I am not in combat
	if !${Me.InCombat} && ${Me.IsGrouped} && ${doAutoAssist}
	{
		for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
		{
			if ${Pawn[id,${Group[${i}].ID}].CombatState}
			{
				CurrentAction:Set[Assisting ${Group[${i}].Name}]
				VGExecute "/cleartargets"
				VGExecute "/assist ${Group[${i}].Name}"
				VGExecute "/assistoffensive"
				doAssistCheck:Set[FALSE]
				
				;; Must wait a tad bit!
				wait 5
			}
		}
		
		;; Target nearest encounter
		if !${Me.Target(exists)} && ${Me.Encounter}
		{
			x:Set[1000]
			y:Set[1]
			for (i:Set[1] ; ${i}<=${Me.Encounter} ; i:Inc )
			{
				if ${Me.Encounter[${i}].Distance}<${x}
				{
					x:Set[${Me.Encounter[${i}].Distance}]
					y:Set[${i}]
				}
			}
			Pawn[ID,${Me.Encounter[${y}].ID}]:Target
			doAssistCheck:Set[FALSE]
			wait 5
		}
	}
	
	if ${doAssistCheck}
	{
		;-------------------------------------------
		; Always make sure we are targeting the tank's target
		;-------------------------------------------
		if ${Pawn[name,${Tank}](exists)}
		{
			;; Do not assist Tank if Tank is not in combat
			if ${Pawn[name,${Tank}].CombatState}==0 && !${doHunt}
			{
				return
			}
			if ${Pawn[name,${Tank}].Distance}<40
			{
				;; Assist the Tank
				VGExecute "/assist ${Tank}"
				;; Always assist offensive target
				VGExecute /assistoffensive
				;; Pause... health sometimes reports NULL or 0
				if ${Me.Target(exists)} && ${Me.TargetHealth}<1
				{
					wait 5
				}
			}
		}
	}
	
	;; Return if target is not in Combat unless we are hunting
	if ${Me.Target.CombatState}==0 && !${doHunt}
	{
		return
	}
	
	;; Return if target is not in Combat unless we are hunting
	if ${Me.Target.CombatState}==0 && !${doHunt}
	{
		return
	}
	
	;; We don't fight dead things or while harvesting or can't see target
	if !${Me.Target(exists)} || ${Me.Target.Type.Equal[Corpse]} || ${Me.Target.IsDead} || ${GV[bool,bHarvesting]} || !${Me.Target.HaveLineOfSightTo}
	{
		return
	}
	
	;-------------------------------------------
	; EMERGENCY - SAVE OUR BACON ROUTINE
	;-------------------------------------------
	if ${Me.HealthPct}<30
	{
		;; Get our Immunity shield up if we are severely wounded
		call UseAbility "${AphoticShield}"
		if ${Return}
			return
	}

	;-------------------------------------------
	; REGAIN HEALTH, ENDURANCE, AND ENERGY ROUTINES
	;-------------------------------------------
	; === Use any consumables in our inventory ===
	call Consumables
	
	;; Let's face the target
	call FaceTarget
	
	if ${doDisEnchant} && ${doMisc} && ${doDespoil}
	{
		call UseAbility "${Despoil}"
		if ${Return}
		{
			doDisEnchant:Set[FALSE]
		}
	}

	; === Return if target is FURIOUS ===
	if ${Me.TargetBuff[Furious](exists)} || ${Me.TargetBuff[Furious Rage](exists)} || ${Me.Effect[Aura of Death](exists)} || ${FURIOUS}
	{
		if ${Me.Ability[${OminousFate}].TimeRemaining}==0 && ${Me.Target.HaveLineOfSightTo}
		{
			;; Stuns target for 4 seconds
			Me.Ability[${OminousFate}]:Use
			wait 2
			EchoIt "UseAbility - ${OminousFate}"

			;; Blocks incoming attack
			Me.Ability[${BleakFoeman}]:Use
			wait 2
			EchoIt "UseAbility - ${BleakFoeman}"
		}

		;; wait for refresh
		wait 3
		
		;; Stop attacks
		if ${Me.Ability[Auto Attack].Toggled}
		{
			Me.Ability[Auto Attack]:Use
		}
		
		;; Keep increasing hate for those that like plowing furious
		if ${doHatred} && ${doProvoke} && ${Me.IsGrouped}
		{
			;; Increase Hatred
			call UseAbility "${Provoke}"
		}
		return
	}

	if ${doRanged} && ${doMove} && ${Me.Target.Distance}>15 && !${isPaused}
	{
		call MoveCloser ${Me.Target.X} ${Me.Target.Y} 13
	}
	if ${doRanged} && ${Me.Target.Distance}>4
	{
		call UseAbility "Ranged Attack"
		if ${Return}
		{
			while !${Me.Ability["Torch"].IsReady}
			{
				waitframe
			}
		}
	}
	if ${doMove} && ${Me.Target.Distance}>5 && !${isPaused}
	{
		call MoveCloser ${Me.Target.X} ${Me.Target.Y} 3
	}
	if ${doMove} && !${isPaused}
	{
		call MoveCloser ${Me.Target.X} ${Me.Target.Y} 3
	}
	
	;; === Stun opponent when they start to run away ===
	if ${Me.TargetHealth}<80
	{
		variable float result
		result:Set[${Math.Calc[${Pawn[id,${Me.Target.ID}].Heading} - ${Me.Heading}]}]
		while ${result} > 180
		{
			result:Set[${Math.Calc[${result} - 360]}]
		}
		while ${result} < -180
		{
			result:Set[${Math.Calc[${result} + 360]}]
		}
		result:Set[${Math.Abs[${result}]}]
		if ${result}<95 
		{
			;if ${Me.Ability[${OminousFate}].IsReady} && ${Me.Ability[${OminousFate}].TimeRemaining}==0 && ${Me.Ability[${OminousFate}].EnergyCost}<${Me.Energy}
			if ${Me.Ability[${OminousFate}].TimeRemaining}==0 && ${Me.Ability[${OminousFate}].EnergyCost}<${Me.Energy}
			{
				Me.Ability[${OminousFate}]:Use
				wait 2
				EchoIt "UseAbility - ${OminousFate}"
			}
			if ${Me.Ability[${Harrow}].TimeRemaining}==0 && ${Me.Endurance}>28
			{
				Me.Ability[${Harrow}]:Use
				wait 2
				EchoIt "UseAbility - ${Harrow}"
				return
			}
			if ${doMisc} && ${doAbyssalChains} && ${doSnare}
			{
		
				if ${Me.Ability[${AbyssalChains}].TimeRemaining}==0 && ${Me.Ability[${AbyssalChains}].EnergyCost}<${Me.Energy} && !${Me.TargetMyDebuff[${AbyssalChains}](exists)}
				{
					call Check4Immunites "${AbyssalChains}"
					if !${Return}
					{
						TimedCommand 10 Script[VG-DK].Variable[doSnare]:Set[TRUE]
						doSnare:Set[FALSE]
						Me.Ability[${AbyssalChains}]:Use
						wait 2
						EchoIt "UseAbility - ${AbyssalChains}"
						return
					}
				}
			}
		}
	}

	;; === Drain target's endurance and returns it to us -- 40 second cooldown ===
	if ${Me.Endurance}>=10 && ${Me.Endurance}<30 && !${Me.TargetMyDebuff[${RavagingDarkness}](exists)}
	{
		call UseAbility "${RavagingDarkness}"
		if ${Return}
			return
	}

	; === Use our heal if we got it! ===
	if ${Me.HealthPct}<70 && ${doShadowStep}
	{
		call ShadowStepHeal
		if ${Return}
			return
	}

	;; === Build our Dread ===
	if ${GV[int,ProgressiveFormPhase]}<4
	{
		;; Symbol to generate more Dread
		;call CastBuff "${SymbolOfWrath}"
		; 30 energy, 2s wait
		call UseAbility "${DreadfulVisage}"
		if ${Return}
		{
			while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
			{
				waitframe
			}
		}
	}	
	
	;-------------------------------------------
	; BUILD HATRED ROUTINES
	;-------------------------------------------
	if ${doHatred}
	{
		for ( i:Set[1] ; ${i}<=${VG.PawnCount} && ${Pawn[${i}].Distance}<10 ; i:Inc )
		{
			;; Find out how many pawns near me that is in combat
			if ${Pawn[${i}].CombatState}>0 && ${Pawn[${i}].Type.Equal[AggroNPC]}
			{
				x:Inc
			}
		}
		if ${doScytheOfDoom} && ${Me.HealthPct}<70 && ${Me.EndurancePct}>48 && ${x}>1
		{
			;; frontal AE that heals
			if ${Me.Ability[${ScytheOfDoom}].IsReady}
			{
				CurrentAction:Set[${ScytheOfDoom}]
				if ${doBackup}
				{
					doBackup:Set[FALSE]
					VG:ExecBinding[moveforward,release]
					VG:ExecBinding[movebackward]
					wait 5
					VG:ExecBinding[movebackward,release]
					wait 5
				}
				EchoIt "UseAbility - ${ScytheOfDoom} - Total Targets=${x}"
				CurrentAction:Set[${ScytheOfDoom}]
				Me.Ability[${ScytheOfDoom}]:Use
				wait 5
				return
			}
		}
		if ${doTorture} && !${Me.TargetMyDebuff[${Torture}](exists)}
		{
			;; DOT - Damage and increase hatred
			call UseAbility "${Torture}"
			if ${Return}
				return
		}
		if ${doProvoke} && ${Me.IsGrouped}
		{
			;; Increase Hatred
			call UseAbility "${Provoke}"
			if ${Return}
				return
		}
		if ${doBlackWind} && ${Me.EndurancePct}>50 && ${Me.IsGrouped} && ${x}>1
		{
			;; frontal AE that increases hatred
			call UseAbility "${BlackWind}"
			if ${Return}
				return
		}
	}

	;-------------------------------------------
	; EMERGENCY - SAVE OUR BACON ROUTINE
	;-------------------------------------------
	; === Blocks 25% damage for 4-5 hits -- 1 minute cooldown ===
	call CastBuff "${DarkWard}"
	
	;-------------------------------------------
	; MELEE ROUTINES
	;-------------------------------------------
	if ${doMelee}
	{
		if ${doSlay} && ${Me.TargetHealth}<20 && ${Me.EndurancePct}>=30
		{
			;; Only usable below 20% health
			call UseAbility "${Slay}"
			if ${Return}
				return
		}
		if ${doBacklash} && ${Me.EndurancePct}>=25
		{
			;; 15 Endurance
			call UseAbility "${Backlash}"
			if ${Return}
				return
		}
		if ${doMutilate} && ${Me.EndurancePct}>=40
		{
			;; 40 Endurance
			call UseAbility "${Mutilate}"
			if ${Return}
				return
		}
		if ${doMalice} && ${Me.EndurancePct}>=40
		{
			;; 24 Endurance
			call UseAbility "${Malice}"
			if ${Return}
				return
		}
		;; This is your crit maker here!!
		if ${doVexingStrike} && ${Me.EndurancePct}>=50
		{
			;; 20 Endurance
			call UseAbility "${VexingStrike}"
			if ${Return}
				return
		}
	}

	; === Use our heal if we got it! ===
	if ${Me.HealthPct}<70 && ${doShadowStep}
	{
		call UseAbility "${Cull}"
		if ${Return}
			return
	}
}



;===================================================
;=== CYCLE THROUGH OUR TARGETS ONCE EVERY 10sec ====
;===================================================
function CycleTargets()
{
	if !${doAutoAssist} || !${doAutoAssistReady}
	{
		return
	}

	;; set our variable
	variable int i
	
	;; Use this once Me.Encounter reports correctly
	if ${Me.Encounter}>0
	{
		for ( i:Set[1] ; ${i}<=${Me.Encounter} ; i:Inc )
		{
			;; Hit target's that are not targetting me
			if ${Me.Encounter[${i}].Distance}<5 && !${Me.FName.Equal[${Me.Encounter[${i}].Target}]} && ${Me.Encounter[${i}].Health}>10
			{
				EchoIt "CycleTargets - Switching to ${Me.Encounter[${i}].Name} who's on ${Me.Encounter[${i}].Target}"
			
				;; change targets to target not targeting me
				Pawn[ID,${Me.Encounter[${i}].ID}]:Target
				wait 5

				;; face our target
				face ${Pawn[ID,${Me.Target.ID}].X} ${Pawn[ID,${Me.Target.ID}].Y}

				;; Make sure we have nothing that will interfere with the next ability
				while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
				{
					waitframe
				}

				;; Push Hatred onto target -- if this doesn't pull the mob then our Rescue will
				call UseAbility "${Provoke}"
				call UseAbility "${VexingStrike}"
				
				doAutoAssistReady:Set[FALSE]
				TimedCommand 100 Script[VG-DK].Variable[doAutoAssistReady]:Set[TRUE]
			}
		}
	}
}


;===================================================
;===     DPS - BUST OUT OUR MAXIMUM DPS         ====
;===================================================
function DPS()
{
	EchoIt "=== D P S ==="
	CurrentAction:Set[DPS Called]

	;; Stop attacks
	if ${Me.Ability[Auto Attack].Toggled}
	{
		Me.Ability[Auto Attack]:Use
	}

	;; Ensure we are in combat form
	if !${Me.CurrentForm.Name.Equal[Ebon Blade]}
	{
		Me.Form[Ebon Blade]:ChangeTo
		TimedCommand 40 Script[VG-DK].Variable[doForm]:Set[TRUE]
		doForm:Set[FALSE]
		wait 10 ${Me.CurrentForm.Name.Equal[Ebon Blade]}
		EchoIt "** New Form = ${Me.CurrentForm.Name}"
	}
	
	if ${Me.Target.Distance}>=5
	{
		EchoIt "Need to be within 5 meters to max out Dread (Terror Incarnate)"
	}

	;; wait and use DPS crits
	call IsReady
	
	;; Max out our Dread so we can use BANE!
	if ${GV[int,ProgressiveFormPhase]}<4 && ${Me.Target.Distance}<5
	{
		if ${Me.Ability[${TerrorIncarnate}].IsReady}
		{
			EchoIt "UseAbility ${TerrorIncarnate}"
			Me.Ability[${TerrorIncarnate}]:Use
			wait 3
		}
	}

	;; wait and use DPS crits
	call IsReady

	;; Increase damage by 100% for 30 sec
	call CastBuff "${HatredIncarnate}"

	;; wait and use DPS crits
	call IsReady
	
	;; Use Blood Mage's Quickening Jolt for crit
	if ${Me.Ability[Quickening Jolt](exists)} && ${Me.Ability[Quickening Jolt].TimeRemaining}==0 && ${Me.Ability[Quickening Jolt].IsReady}
	{
		EchoIt "UseAbility - Quickening Jolt"
		CurrentAction:Set[Quickening Jolt]
		Me.Ability[Quickening Jolt]:Use
		wait 1
	}

	;; wait and use DPS crits
	call IsReady
	
	;; Check if mob is immune to Spiritual
	call Check4Immunites "${WordOfDoomAlthen}"
	if !${Return}
	{
		;; Cast Bane 
		if ${Me.Ability[${Bane}].IsReady}
		{
			EchoIt "UseAbility - ${Bane}"
			Me.Ability[${Bane}]:Use
			wait 3
		}
		
		;; wait and use DPS crits
		call IsReady
		
		;; Cast our Word of Doom series from highest to lowest
		if ${Me.Ability[${AncientWordOfDoom}].IsReady}
		{
			EchoIt "UseAbility - ${AncientWordOfDoom}"
			Me.Ability[${AncientWordOfDoom}]:Use
			wait 3
		}

		if ${Me.Ability[${WordOfDoomHarDaalMur}].IsReady}
		{
			EchoIt "UseAbility - ${WordOfDoomHarDaalMur}"
			Me.Ability[${WordOfDoomHarDaalMur}]:Use
			wait 3
		}

		if ${Me.Ability[${WordOfDoomCeimDor}].IsReady}
		{
			EchoIt "UseAbility - ${WordOfDoomCeimDor}"
			Me.Ability[${WordOfDoomCeimDor}]:Use
			wait 3
		}

		if ${Me.Ability[${WordOfDoomAmarthic}].IsReady}
		{
			EchoIt "UseAbility - ${WordOfDoomAmarthic}"
			Me.Ability[${WordOfDoomAmarthic}]:Use
			wait 3
		}

		if ${Me.Ability[${WordOfDoomAlthen}].IsReady}
		{
			EchoIt "UseAbility - ${WordOfDoomAlthen}"
			Me.Ability[${WordOfDoomAlthen}]:Use
			wait 3
		}

		;; wait and use DPS crits
		call IsReady
		
		;; Damage and hate
		if ${Me.Ability[${IncantationOfHate}].IsReady}
		{
			EchoIt "UseAbility - ${IncantationOfHate}"
			Me.Ability[${IncantationOfHate}]:Use
			wait 3
		}
	}

	;; wait and use DPS crits
	call IsReady
	
	if ${Me.TargetHealth}<20
	{
		; Only available under 20%
		call UseAbility "${Slay}"
	}
	
	if ${Me.EndurancePct}>=40
	{
		;; 40 Endurance
		call UseAbility "${Mutilate}"
		if ${Return}
			return
	}
	if ${Me.EndurancePct}>=24
	{
		;; 24 Endurance
		call UseAbility "${Malice}"
		if ${Return}
			return
	}
}

function IsReady()
{
	VGExecute "/reactionchain 5"
	VGExecute "/reactionchain 1"
	VGExecute "/reactionchain 4"

	;; Make sure we have nothing that will interfere with the next ability
	while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
	{
		waitframe
	}

	VGExecute "/reactionchain 5"
	VGExecute "/reactionchain 1"
	VGExecute "/reactionchain 4"

		;; Make sure we have nothing that will interfere with the next ability
	while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
	{
		waitframe
	}
}


;===================================================
;===      TURN SLOWLY TO FACE YOUR TARGET       ====
;===    Adjust the speed in your VG settings    ====
;===================================================
function FaceTarget()
{
	if !${Me.Target(exists)}
	{
		return
	}

	if ${doFace}
	{
		call facemob "${Me.Target.ID}"
		face ${Me.Target.X} ${Me.Target.Y}
	}
	
	
	;Face:Pawn[${Me.DTarget.ID},FALSE]
	return
	
}

;===================================================
;===          REMOVE CERTAIN BUFFS              ====
;===================================================
function CancelBuffs()
{
	if !${doCancelBuffs}
	{
		return
	}

	if ${Me.Effect[Superior Gift of Peace](exists)}
	{
		Me.Effect[Superior Gift of Peace]:Remove
		wait 5
	}
	if ${Me.Effect[Blessing of Tranquility](exists)}
	{
		Me.Effect[Blessing of Tranquility]:Remove
		wait 5
	}
	if ${Me.Effect[Gift of Peace](exists)}
	{
		Me.Effect[Gift of Peace]:Remove
		wait 5
	}
	if ${Me.Effect[Stormcaller's Fury VI](exists)}
	{
		Me.Effect[Stormcaller's Fury VI]:Remove
		wait 5
	}
	if ${Me.Effect[Stormcaller's Fury V](exists)}
	{
		Me.Effect[Stormcaller's Fury V]:Remove
		wait 5
	}
	if ${Me.Effect[Stormcaller's Fury IV](exists)}
	{
		Me.Effect[Stormcaller's Fury IV]:Remove
		wait 5
	}
	if ${Me.Effect[Stormcaller's Fury III](exists)}
	{
		Me.Effect[Stormcaller's Fury III]:Remove
		wait 5
	}
	if ${Me.Effect[Stormcaller's Fury II](exists)}
	{
		Me.Effect[Stormcaller's Fury II]:Remove
		wait 5
	}
	if ${Me.Effect[Stormcaller's Fury I](exists)}
	{
		Me.Effect[Stormcaller's Fury I]:Remove
		wait 5
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
;===       CHANGE TO CORRECT FORM               ====
;===================================================
function ChangeForm()
{
	if ${doForm}
	{
		;; Ensure we are not in combat form
		if !${Me.InCombat} && !${Me.CurrentForm.Name.Equal[${NonCombatForm}]}
		{
			Me.Form[${NonCombatForm}]:ChangeTo
			TimedCommand 40 Script[VG-DK].Variable[doForm]:Set[TRUE]
			doForm:Set[FALSE]
			wait 10 ${Me.CurrentForm.Name.Equal[${NonCombatForm}]}
			EchoIt "** New Form = ${Me.CurrentForm.Name}"
			return
		}
		;; Ensure we are in combat form
		if ${Me.InCombat} && !${Me.CurrentForm.Name.Equal[${CombatForm}]}
		{
			Me.Form[${CombatForm}]:ChangeTo
			TimedCommand 40 Script[VG-DK].Variable[doForm]:Set[TRUE]
			doForm:Set[FALSE]
			wait 10 ${Me.CurrentForm.Name.Equal[${CombatForm}]}
			EchoIt "** New Form = ${Me.CurrentForm.Name}"
			return
		}
	}
}

function Jump()
{
	if ${doJump}
	{
		;VG:ExecBinding[moveforward,release]
		if ${Math.Rand[10]}<5
		{
			VG:ExecBinding[StrafeRight,release]
			VG:ExecBinding[StrafeLeft]
			wait 2.5
		}
		if ${Math.Rand[10]}>5
		{
			VG:ExecBinding[StrafeLeft,release]
			VG:ExecBinding[StrafeRight]
			wait 2.5
		}
		VG:ExecBinding[StrafeLeft,release]
		VG:ExecBinding[StrafeRight,release]
		VG:ExecBinding[Jump]
		wait 2
		VG:ExecBinding[Jump,release]
		doJump:Set[FALSE]
	}
}


;===================================================
;===       CLEAR TARGET IF TARGET IS DEAD       ====
;===================================================
function ClearTargets()
{
	;; loot everything
	if ${doLoot}
	{
		call Loot
	}



	if ${Me.Target(exists)}
	{
		;; loot everything
		if ${doLoot}
		{
			if ${Me.TargetHealth}<5
			{
				call Loot
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
			if ${doLoot}
			{
				call Loot
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
}

;===================================================
;===              USE AN ABILITY                ====
;===================================================
function:bool UseAbility(string ABILITY, TEXT=" ")
{

	;; does ability exist?
	if !${Me.Ability[${ABILITY}](exists)}
	{
		;EchoIt "${ABILITY} does not exist"
		return FALSE
	}

	if ${Me.Ability[${ABILITY}].IsReady}
	{
		;; Check if mob is immune
		call Check4Immunites "${ABILITY}"
		if ${Return}
		{
			;EchoIt "Immune to ${ABILITY}"
			return FALSE
		}
	
		;; do we have energy to use ability?
		if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		{
			EchoIt "Not enought Energy for ${ABILITY}"
			return FALSE
		}
		;; do we have endurance to use ability?
		if ${Me.Ability[${ABILITY}].EnduranceCost(exists)} && ${Me.Ability[${ABILITY}].EnduranceCost}>${Me.Endurance} 
		{
			EchoIt "Not enough Endurance for ${ABILITY}"
			return FALSE
		}
		;; is target in range to use ability?
		if ${Me.Ability[${ABILITY}].Range}<${Me.Target.Distance} && ${Me.Ability[${ABILITY}].IsOffensive}
		{
			EchoIt "(${Me.Target.Distance} meters) too far away to use ${ABILITY}"
			return FALSE
		}	
		;; are we waiting to use ability?
		if ${Me.Ability[${ABILITY}].TimeRemaining}>0
		{
			EchoIt "TimeRemaining - ${ABILITY}"
			return FALSE
		}
		
		;; execute ability
		EchoIt "UseAbility - ${ABILITY} ${TEXT}"
		CurrentAction:Set[Casting ${ABILITY}]
		Me.Ability[${ABILITY}]:Use
		wait 5
		HandleChains
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
	;; Save our Settings
	SaveXMLSettings	

	;; Unload our UI
	ui -unload "${Script.CurrentDirectory}/VG-DK.xml"
	
	;; Say we are done
	EchoIt "Stopped VG-DK Script"
	
	;; Make sure we stop moving
	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward,release]
}

;===================================================
;===       ATOM - ECHO A STRING OF TEXT         ====
;===================================================
atom(script) EchoIt(string aText)
{
	if ${doEcho}
	{
		echo "[${Time}][VG-DK]: ${aText}"
	}
}

;===================================================
;===          ATOM - PLAY A SOUND               ====
;===================================================
atom(script) PlaySound(string Filename)
{
	if ${doSound}
	{	
		System:APICall[${System.GetProcAddress[WinMM.dll,PlaySound].Hex},Filename.String,0,"Math.Dec[22001]"]
	}
}

;===================================================
;===    ATOM - OPEN A DOOR THAT YOU BUMPED      ====
;===================================================
atom Bump(string aObstacleActorName, float fX_Offset, float fY_Offset, float fZ_Offset)
{
	if (${aObstacleActorName.Find[Mover]})
	{
		Script[VG-DK]:QueueCommand[call OpenDoor]
		return
	}
	
	doJump:Set[TRUE]
}


;===================================================
;===     ATOM - Load Variables from XML         ====
;===================================================
atom(script) LoadXMLSettings()
{
	;; Create the Save directory incase it doesn't exist
	variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-DK/Save"
	mkdir "${savePath}"

	;; Define our SSR
	variable settingsetref VG-DK_SSR
	
	;;Load Lavish Settings 
	LavishSettings[VG-DK]:Clear
	LavishSettings:AddSet[VG-DK]
	LavishSettings[VG-DK]:AddSet[MySettings]
	LavishSettings[VG-DK]:Import[${savePath}/MySettings.xml]	
	VG-DK_SSR:Set[${LavishSettings[VG-DK].FindSet[MySettings]}]

	;;Set values for MySettings
	CombatForm:Set[${VG-DK_SSR.FindSetting[CombatForm,"Armor of Darkness"]}]
	NonCombatForm:Set[${VG-DK_SSR.FindSetting[NonCombatForm,"Armor of Darkness"]}]
	doFace:Set[${VG-DK_SSR.FindSetting[doFace,TRUE]}]
	doMove:Set[${VG-DK_SSR.FindSetting[doMove,FALSE]}]
	doAutoAssist:Set[${VG-DK_SSR.FindSetting[doAutoAssist,TRUE]}]
	doAutoRez:Set[${VG-DK_SSR.FindSetting[doAutoRez,TRUE]}]
	doAutoRepair:Set[${VG-DK_SSR.FindSetting[doAutoRepair,TRUE]}]
	doConsumables:Set[${VG-DK_SSR.FindSetting[doConsumables,FALSE]}]
	doSprint:Set[${VG-DK_SSR.FindSetting[doSprint,FALSE]}]
	Speed:Set[${VG-DK_SSR.FindSetting[Speed,100]}]
	doCancelBuffs:Set[${VG-DK_SSR.FindSetting[doCancelBuffs,TRUE]}]
	doPhysical:Set[${VG-DK_SSR.FindSetting[doPhysical,TRUE]}]
	doSpiritual:Set[${VG-DK_SSR.FindSetting[doSpiritual,TRUE]}]
	doRanged:Set[${VG-DK_SSR.FindSetting[doRanged,TRUE]}]
	doMelee:Set[${VG-DK_SSR.FindSetting[doMelee,TRUE]}]
	doSound:Set[${VG-DK_SSR.FindSetting[doSound,TRUE]}]
	doShadowStep:Set[${VG-DK_SSR.FindSetting[doShadowStep,TRUE]}]
	doHatred:Set[${VG-DK_SSR.FindSetting[doHatred,TRUE]}]
	doRescues:Set[${VG-DK_SSR.FindSetting[doRescues,TRUE]}]
	doCounters:Set[${VG-DK_SSR.FindSetting[doCounters,TRUE]}]
	doChains:Set[${VG-DK_SSR.FindSetting[doChains,TRUE]}]
	doMisc:Set[${VG-DK_SSR.FindSetting[doMisc,TRUE]}]
	doDespoil:Set[${VG-DK_SSR.FindSetting[doDespoil,TRUE]}]
	doAbyssalChains:Set[${VG-DK_SSR.FindSetting[doAbyssalChains,TRUE]}]
	doRetaliate:Set[${VG-DK_SSR.FindSetting[doRetaliate,TRUE]}]
	doVengeance:Set[${VG-DK_SSR.FindSetting[doVengeance,TRUE]}]
	doSeethingHatred:Set[${VG-DK_SSR.FindSetting[doSeethingHatred,TRUE]}]
	doScourge:Set[${VG-DK_SSR.FindSetting[doScourge,TRUE]}]
	doNexusOfHatred:Set[${VG-DK_SSR.FindSetting[doNexusOfHatred,TRUE]}]
	doHexOfIllOmen:Set[${VG-DK_SSR.FindSetting[doHexOfIllOmen,TRUE]}]
	doIncite:Set[${VG-DK_SSR.FindSetting[doIncite,TRUE]}]
	doShieldOfFear:Set[${VG-DK_SSR.FindSetting[doShieldOfFear,TRUE]}]
	doVileStrike:Set[${VG-DK_SSR.FindSetting[doVileStrike,TRUE]}]
	doWrack:Set[${VG-DK_SSR.FindSetting[doWrack,TRUE]}]
	doProvoke:Set[${VG-DK_SSR.FindSetting[doProvoke,TRUE]}]
	doTorture:Set[${VG-DK_SSR.FindSetting[doTorture,TRUE]}]
	doBlackWind:Set[${VG-DK_SSR.FindSetting[doBlackWind,TRUE]}]
	doScytheOfDoom:Set[${VG-DK_SSR.FindSetting[doScytheOfDoom,TRUE]}]
	doVexingStrike:Set[${VG-DK_SSR.FindSetting[doVexingStrike,TRUE]}]
	doMalice:Set[${VG-DK_SSR.FindSetting[doMalice,TRUE]}]
	doMutilate:Set[${VG-DK_SSR.FindSetting[doMutilate,TRUE]}]
	doRavagingDarkness:Set[${VG-DK_SSR.FindSetting[doRavagingDarkness,TRUE]}]
	doSlay:Set[${VG-DK_SSR.FindSetting[doSlay,TRUE]}]
	doBacklash:Set[${VG-DK_SSR.FindSetting[doBacklash,TRUE]}]
	doLoot:Set[${VG-DK_SSR.FindSetting[doLoot,TRUE]}]
	LootDelay:Set[${VG-DK_SSR.FindSetting[LootDelay,"0"]}]
	doRaidLoot:Set[${VG-DK_SSR.FindSetting[doRaidLoot,FALSE]}]
	doLootOnly:Set[${VG-DK_SSR.FindSetting[doLootOnly,FALSE]}]
	LootOnly:Set[${VG-DK_SSR.FindSetting[LootOnly,""]}]
	doLootEcho:Set[${VG-DK_SSR.FindSetting[doLootEcho,TRUE]}]
	doLootInCombat:Set[${VG-DK_SSR.FindSetting[doLootInCombat,TRUE]}]
	MobMinLevel:Set[${VG-DK_SSR.FindSetting[MobMinLevel,"0"]}]
	MobMaxLevel:Set[${VG-DK_SSR.FindSetting[MobMaxLevel,"0"]}]
	ConCheck:Set[${VG-DK_SSR.FindSetting[ConCheck,"0"]}]
	Distance:Set[${VG-DK_SSR.FindSetting[Distance,"100"]}]
}
;===================================================
;===      ATOM - Save Variables to XML          ====
;===================================================
atom(script) SaveXMLSettings()
{
	;; Create the Save directory incase it doesn't exist
	variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-DK/Save"
	mkdir "${savePath}"
	;; Define our SSR
	variable settingsetref VG-DK_SSR
	;; Load Lavish Settings 
	LavishSettings[VG-DK]:Clear
	LavishSettings:AddSet[VG-DK]
	LavishSettings[VG-DK]:AddSet[MySettings]
	LavishSettings[VG-DK]:Import[${savePath}/MySettings.xml]	
	VG-DK_SSR:Set[${LavishSettings[VG-DK].FindSet[MySettings]}]

	;; Save MySettings
	VG-DK_SSR:AddSetting[CombatForm,${CombatForm}]
	VG-DK_SSR:AddSetting[NonCombatForm,${NonCombatForm}]
	VG-DK_SSR:AddSetting[doFace,${doFace}]
	VG-DK_SSR:AddSetting[doMove,${doMove}]
	VG-DK_SSR:AddSetting[doAutoAssist,${doAutoAssist}]
	VG-DK_SSR:AddSetting[doAutoRez,${doAutoRez}]
	VG-DK_SSR:AddSetting[doAutoRepair,${doAutoRepair}]
	VG-DK_SSR:AddSetting[doConsumables,${doConsumables}]
	VG-DK_SSR:AddSetting[doSprint,${doSprint}]
	VG-DK_SSR:AddSetting[Speed,${Speed}]
	VG-DK_SSR:AddSetting[doCancelBuffs,${doCancelBuffs}]
	VG-DK_SSR:AddSetting[doPhysical,${doPhysical}]
	VG-DK_SSR:AddSetting[doSpiritual,${doSpiritual}]
	VG-DK_SSR:AddSetting[doRanged,${doRanged}]
	VG-DK_SSR:AddSetting[doMelee,${doMelee}]
	VG-DK_SSR:AddSetting[doSound,${doSound}]
	VG-DK_SSR:AddSetting[doShadowStep,${doShadowStep}]
	VG-DK_SSR:AddSetting[doRescues,${doRescues}]
	VG-DK_SSR:AddSetting[doCounters,${doCounters}]
	VG-DK_SSR:AddSetting[doChains,${doChains}]
	VG-DK_SSR:AddSetting[doMisc,${doMisc}]
	VG-DK_SSR:AddSetting[doDespoil,${doDespoil}]
	VG-DK_SSR:AddSetting[doAbyssalChains,${doAbyssalChains}]
	VG-DK_SSR:AddSetting[doHatred,${doHatred}]
	VG-DK_SSR:AddSetting[doRetaliate,${doRetaliate}]
	VG-DK_SSR:AddSetting[doVengeance,${doVengeance}]
	VG-DK_SSR:AddSetting[doSeethingHatred,${doSeethingHatred}]
	VG-DK_SSR:AddSetting[doScourge,${doScourge}]
	VG-DK_SSR:AddSetting[doNexusOfHatred,${doNexusOfHatred}]
	VG-DK_SSR:AddSetting[doHexOfIllOmen,${doHexOfIllOmen}]
	VG-DK_SSR:AddSetting[doIncite,${doIncite}]
	VG-DK_SSR:AddSetting[doShieldOfFear,${doShieldOfFear}]
	VG-DK_SSR:AddSetting[doVileStrike,${doVileStrike}]
	VG-DK_SSR:AddSetting[doWrack,${doWrack}]
	VG-DK_SSR:AddSetting[doProvoke,${doProvoke}]
	VG-DK_SSR:AddSetting[doTorture,${doTorture}]
	VG-DK_SSR:AddSetting[doBlackWind,${doBlackWind}]
	VG-DK_SSR:AddSetting[doScytheOfDoom,${doScytheOfDoom}]
	VG-DK_SSR:AddSetting[doVexingStrike,${doVexingStrike}]
	VG-DK_SSR:AddSetting[doMalice,${doMalice}]
	VG-DK_SSR:AddSetting[doMutilate,${doMutilate}]
	VG-DK_SSR:AddSetting[doRavagingDarkness,${doRavagingDarkness}]
	VG-DK_SSR:AddSetting[doSlay,${doSlay}]
	VG-DK_SSR:AddSetting[doBacklash,${doBacklash}]
	VG-DK_SSR:AddSetting[doLoot,${doLoot}]
	VG-DK_SSR:AddSetting[LootDelay,${LootDelay}]
	VG-DK_SSR:AddSetting[doRaidLoot,${doRaidLoot}]
	VG-DK_SSR:AddSetting[doLootOnly,${doLootOnly}]
	VG-DK_SSR:AddSetting[LootOnly,${LootOnly}]
	VG-DK_SSR:AddSetting[doLootEcho,${doLootEcho}]
	VG-DK_SSR:AddSetting[doLootInCombat,${doLootInCombat}]
	VG-DK_SSR:AddSetting[MobMinLevel,${MobMinLevel}]
	VG-DK_SSR:AddSetting[MobMaxLevel,${MobMaxLevel}]
	VG-DK_SSR:AddSetting[ConCheck,${ConCheck}]
	VG-DK_SSR:AddSetting[Distance,${Distance}]

	;; Save to file
	LavishSettings[VG-DK]:Export[${savePath}/MySettings.xml]
}

;variable bool doCounters = TRUE


;===================================================
;===      ATOM - UPDATE OUR GUI DISPLAY         ====
;===================================================
atom(script) UpdateDisplay()
{
	variable string temp

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
	}
	else
	{
		;; update display
		TargetsTarget:Set[No Target]
		TargetImmunity:Set[No Target]
	}

	;; Main
	UIElement[Text-Status@VG-DK]:SetText[ Current Action:  ${CurrentAction}]
	UIElement[Text-Immune@VG-DK]:SetText[ Target's Immunity:  ${TargetImmunity}]
	UIElement[Text-TOT@VG-DK]:SetText[ Target's Target:  ${TargetsTarget}]

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
		{
			VGExecute /cleartargets
		}
	}

	;; Check if target is no longer FURIOUS
	if ${ChannelNumber}==7 && ${aText.Find[is no longer FURIOUS]}
	{
		if ${Me.Target(exists)} && ${aText.Find[${Me.Target.Name}]} && ${Me.TargetHealth}<25
		{
			vgecho "FURIOUS - RESUME ATTACKING"
			FURIOUS:Set[FALSE]
		}
	}

	; Check if target went into FURIOUS - Has delays for notification
	if ${ChannelNumber}==7 && ${aText.Find[becomes FURIOUS]}
	{
		if ${Me.Target(exists)} && ${aText.Find[${Me.Target.Name}]} && ${Me.TargetHealth}<25
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
		Script[VG-DK]:QueueCommand[call LootMyTombstone]
	}

	
	;; Ping us on tells or anything with our name in it
	if ${ChannelNumber}==15 && ${aText.Find[From ]}
	{
		EchoIt "${aText}"
		PlaySound ALARM
	}

}

;===================================================
;===    ATOM - Monitor Combat Text Messages     ====
;===================================================
atom CombatText(string aText, int aType)
{
	;redirect -append "${LavishScript.CurrentDirectory}/Scripts/VG-DK/Save/CombatText.txt" echo "[${Time}][${aType}][${aText}]"
	;redirect -append "${LavishScript.CurrentDirectory}/Scripts/VG-DK/Save/CombatText${aType}.txt" echo "[${Time}][${aType}][${aText}]"

	;;if ${aText.Find[heals]} || ${aText.Find[healing]} || ${aText.Find[immune]}
	if ${aText.Find[healing for]} || ${aText.Find[absorbes your]}
	{
		if ${aText.Find[${Me.Target.Name}]}
		{

			PlaySound ALARM
		
			;; Create the Save directory incase it doesn't exist
			variable string savePath = "${LavishScript.CurrentDirectory}/Scripts/VG-DK/Save"
			mkdir "${savePath}"

			;; dump to file
			redirect -append "${savePath}/LearnedImmunities.txt" echo "[${Time}][${aType}][${Me.Target.Name}][${aText.Token[2,">"].Token[1,"<"]}] -- [${aText}]"

			;; display the info
			echo ${Me.Target.Name} absorbed/healed/immune to ${aText.Token[2,">"].Token[1,"<"]}
			vgecho Immune: ${aText.Token[2,">"].Token[1,"<"]}
		}
	}
	
	if ${aText.Find[is enchanted by]}
	{
		if ${Me.Target(exists)} && ${aText.Find[${Me.Target.Name}]}
		{
			;vgecho [${aText.Token[2,">"].Token[1,"<"]}]
			doDisEnchant:Set[TRUE]
		}
	}
	if ${aText.Find[ casts ]} && ${aText.Find[ on ]}
	{
		if ${Me.Target(exists)} && ${aText.Find[${Me.Target.Name}]}
		{
			;vgecho [${aText.Token[2,">"].Token[1,"<"]}]
			doDisEnchant:Set[TRUE]
		}
	}
}
