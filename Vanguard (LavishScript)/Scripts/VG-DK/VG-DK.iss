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
	Event[OnFrame]:AttachAtom[UpdateDisplay]
	Event[VG_OnIncomingText]:AttachAtom[ChatEvent]
	Event[VG_OnIncomingCombatText]:AttachAtom[CombatText]
	Event[VG_onHitObstacle]:AttachAtom[Bump]

	;-------------------------------------------
	; LOOP THIS INDEFINITELY
	;-------------------------------------------
	while ${isRunning}
	{
		;; This significantly improves FPS
		wait 3
	
		;; Wait until we are ready to cast and use an ability
		if ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
		{
			;; Update our current action
			if ${Me.IsCasting}
			{
				CurrentAction:Set[Casting ${Me.Casting}]
			}
			while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
			{
				waitframe
			}
		}
		else
		{
			CurrentAction:Set[Waiting]
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
		wait 1
		call Rescues
		wait 1
		call HandleChains
		wait 1
		call HandleCounters
	}
}

;===================================================
;=== Heart of the script so we must prioritize  ====
;===================================================
function MainRoutines()
{
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
	
	;; Hunt for a target
	call Hunt
	
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

	;; Do not resume if we are not in combat or target is dead!
	if !${Me.Target(exists)} || ${Me.Target.Type.Equal[Corpse]} || ${Me.Target.IsDead} || ${GV[bool,bHarvesting]} || ${Me.Target.CombatState}==0
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
	
	; === Use our heal if we got it! ===
	if ${Me.HealthPct}<70
	{
		call UseAbility "${Cull}"
		if ${Return}
			return
	}
	
	;; Let's face the target
	call FaceTarget
	

	if ${doRanged} && ${doMove} && ${Me.Target.Distance}>15 && !${isPaused}
	{
		call MoveCloser ${Me.Target.X} ${Me.Target.Y} 15
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
	if !${doRanged} && ${doMove} && ${Me.Target.Distance}>5 && !${isPaused}
	{
		call MoveCloser ${Me.Target.X} ${Me.Target.Y} 5
	}
	
	; === Return if target is FURIOUS ===
	if ${Me.TargetBuff[Furious](exists)} || ${Me.TargetBuff[Furious Rage](exists)} || ${FURIOUS}
	{
		;; wait for variables to update
		wait 5
		
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

	;; === Drain target's endurance and returns it to us -- 40 second cooldown ===
	if ${Me.Endurance}<=30 && !${Me.TargetMyDebuff[${RavagingDarkness}](exists)}
	{
		call UseAbility "${RavagingDarkness}"
		if ${Return}
			return
	}
	
	;-------------------------------------------
	; BUILD HATRED ROUTINES
	;-------------------------------------------
	if ${doHatred}
	{
		variable int i
		variable int x = 0
		for ( i:Set[1] ; ${i}<=${VG.PawnCount} && ${Pawn[${i}].Distance}<10 ; i:Inc )
		{
			;; Find out how many pawns near me that is in combat
			if ${Pawn[${i}].CombatState}>0
			{
				x:Inc
			}
		}
		if ${doScytheOfDoom} && ${Me.HealthPct}<50 && ${x}>2
		{
			;; frontal AE that heals
			call UseAbility "${ScytheOfDoom}"
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
		if ${doTorture} && !${Me.TargetMyDebuff[${Torture}](exists)}
		{
			;; DOT - Damage and increase hatred
			call UseAbility "${Torture}"
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
		waitframe
		if ${doSlay} && ${Me.TargetHealth}<20
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
		if ${doMutilate} && ${Me.EndurancePct}>=50
		{
			;; 40 Endurance
			call UseAbility "${Mutilate}"
			if ${Return}
				return
		}
		if ${doMalice} && ${Me.EndurancePct}>=44
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
}

;===================================================
;===            RESCUES                         ====
;===================================================
function Rescues()
{
	if !${doRescues} || !${Me.InCombat} || ${TargetsTarget.Equal[No Target]}
	{
		return
	}

	if !${Me.ToT.Name.Find[${Me.FName}]} && !${Me.TargetBuff["Immunity: Force Target"](exists)}
	{
		;; Set DTarget
		VGExecute /assistoffensive
		wait 3

		; Force target to attack me for 10s or 5 attacks
		call UseAbility "${SeethingHatred}" "- RESCUED ${Me.DTarget.Name}"
		if ${Return}
		{
			return
		}

		; Force target to attack me for 4s or 2 attacks and adds HATRED
		call UseAbility "${Scourge}" "- RESCUED ${Me.DTarget.Name}"
		if ${Return}
		{
			return
		}

		; Force all targets to attack me for 10s or 4-8 attacks
		call UseAbility "${NexusOfHatred}" "- RESCUED ${Me.DTarget.Name}"
		if ${Return}
		{
			return
		}
	}
}


;===================================================
;=== CYCLE THROUGH OUR TARGETS ONCE EVERY 10sec ====
;===================================================
function CycleTargets()
{
	if !${doCycleTargets} || !${doCycleTargetsReady}
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
				Pawn[ID,${Me.Encounter[${i}].ID}]:Target
				wait 5
				doCycleTargetsReady:Set[FALSE]
				TimedCommand 100 Script[VG-DK].Variable[doCycleTargetsReady]:Set[TRUE]
				
				face ${Pawn[ID,${Me.Target.ID}].X} ${Pawn[ID,${Me.Target.ID}].Y}

				if ${Me.Target.Distance}>5 && ${Me.Target.Distance}<20
				{
					Me.Ability[Ranged Attack]:Use
				}
				if ${Me.Target.Distance} < 5
				{
					call UseAbility "${Provoke}"
					if !${Return}
					{
						Me.Ability[${VexingStrike}]:Use
					}
				}
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

	call CastBuff "${HatredIncarnate}"
	
	;; Ensure we are in combat form
	if !${Me.CurrentForm.Name.Equal[Ebon Blade]}
	{
		Me.Form[Ebon Blade]:ChangeTo
		TimedCommand 40 Script[VG-DK].Variable[doForm]:Set[TRUE]
		doForm:Set[FALSE]
		wait 10 ${Me.CurrentForm.Name.Equal[Ebon Blade]}
		EchoIt "** New Form = ${Me.CurrentForm.Name}"
	}

	;; Use Blood Mage's Conduct to regain some Health
	if ${Me.Ability[Quickening Jolt](exists)} && ${Me.Ability[Quickening Jolt].TimeRemaining}==0 && ${Me.Ability[Quickening Jolt].IsReady}
	{
		EchoIt "Quickening Jolt"
		CurrentAction:Set[Quickening Jolt]
		Me.Ability[Quickening Jolt]:Use
		wait 1
	}

	;; Make sure we have nothing that will interfere with the next ability
	while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
	{
		waitframe
	}

	;; Cast our Word of Doom series
	if ${Me.Ability[${AncientWordOfDoom}].IsReady}
	{
		EchoIt "${AncientWordOfDoom}"
		Me.Ability[${AncientWordOfDoom}]:Use
		wait 3
	}

	if ${Me.Ability[${WordOfDoomHarDaalMur}].IsReady}
	{
		EchoIt "${WordOfDoomHarDaalMur}"
		Me.Ability[${WordOfDoomHarDaalMur}]:Use
		wait 3
	}

	if ${Me.Ability[${WordOfDoomCeimDor}].IsReady}
	{
		EchoIt "${WordOfDoomCeimDor}"
		Me.Ability[${WordOfDoomCeimDor}]:Use
		wait 3
	}

	if ${Me.Ability[${WordOfDoomAmarthic}].IsReady}
	{
		EchoIt "${WordOfDoomAmarthic}"
		Me.Ability[${WordOfDoomAmarthic}]:Use
		wait 3
	}

	if ${Me.Ability[${WordOfDoomAlthen}].IsReady}
	{
		EchoIt "${WordOfDoomAlthen}"
		Me.Ability[${WordOfDoomAlthen}]:Use
		wait 3
	}
	
	;; Make sure we have nothing that will interfere with the next ability
	while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
	{
		waitframe
	}

	if ${Me.TargetHealth}<20
	{
		; Only available under 20%
		call UseAbility "${Slay}" "Ebon Blade"
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
	}
	
	face ${Me.Target.X} ${Me.Target.Y}
	
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

;===================================================
;===          HANDLE COUNTERS                   ====
;===================================================
function HandleCounters()
{
	if !${doCounters}
	{
		return
	}
	
	;; This goes first since it has a cooldown timer
	if ${doVengeance}
	{
		if ${Me.Ability[${Vengeance}].IsReady}
		{
			echo Vengeance = Timereamining=${Me.Ability[${Vengeance}].TimeRemaining}, Countdown=${Me.Ability[${Vengeance}].TriggeredCountdown}
			if ${Me.Ability[${Vengeance}].TimeRemaining}==0 && ${Me.Ability[${Vengeance}].TriggeredCountdown}>0
			{
				Me.Ability[${Vengeance}]:Use
				;VGExecute "/reactioncounter 2"
				CurrentAction:Set[Counterattack - Vengeance]
				EchoIt "Counterattack - Vengeance"
				wait 5
			}
		}
	}
	
	;; This will eat up you endurance FAST leaving nothing for the good stuff
	if ${doRetaliate} && ${Me.EndurancePct}>50
	{
		if ${Me.Ability[${Retaliate}].IsReady}
		{
			;echo Vengeance = Timereamining=${Me.Ability[${Retaliate}].TimeRemaining}, Countdown=${Me.Ability[${Retaliate}].TriggeredCountdown}
			if ${Me.Ability[${Retaliate}].TimeRemaining}==0 && ${Me.Ability[${Retaliate}].TriggeredCountdown}>0
			{
				Me.Ability[${Retaliate}]:Use
				;VGExecute "/reactioncounter 1"
				CurrentAction:Set[Counterattack - Retaliate]
				EchoIt "Counterattack - Retaliate"
				wait 5
			}
		}
	}
}

;===================================================
;===    HANDLE CHAINS THAT LEADS INTO COMBOS    ====
;===================================================
function HandleChains()
{
	;; return if we do not want to do chains
	if !${doChains}
	{
		return
	}
	
	; Return if target is Furious or Furious Rage
	if ${Me.TargetBuff[Furious](exists)} || ${Me.Effect[Furious Rage](exists)} || ${FURIOUS} 
	{ 
		return
	}
	
	;; 1st - we want to increase hatred
	if ${doIncite} && ${Me.IsGrouped}
	{
		call ExecuteChain "${Incite}" 2
		call ExecuteChain "${Inflame}" 2
		call ExecuteChain "${Superior Inflame}" 2
	}
	
	;; 2nd - make sure we restore some energy
	if ${doVileStrike} && !${Me.Effect[${Anguish}](exists)} 
	{
		if ${Me.EnergyPct}<80
		{
			call ExecuteChain "${VileStrike}" 4
			call ExecuteChain "${Anguish}" 4
		}
	}
	
	;; 3rd - increase our block, damage, and AC
	if ${doShieldOfFear} && !${Me.Effect[${DarkBastion}](exists)} 
	{
		call ExecuteChain "${ShieldOfFear}" 3
		call ExecuteChain "${DarkBastion}" 3
	}
	
	;; 4th - decrease target's damage and increases your damage
	if ${doHexOfIllOmen} && !${Me.Effect[${HexOfImpendingDoom}](exists)}
	{
		if ${Me.Ability[${HexOfIllOmen}].IsReady}
		{
			CurrentAction:Set[Chain - ${HexOfIllOmen}]
			EchoIt "Chain - ${HexOfIllOmen}"
			Me.Ability[${HexOfIllOmen}]:Use
			VGExecute "/reactionchain 1"
			wait 4
			while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
			{
				waitframe
			}
		}
		if ${Me.Ability[${HexOfImpendingDoom}].IsReady}
		{
			CurrentAction:Set[Chain - ${HexOfImpendingDoom}]
			EchoIt "Chain - ${HexOfImpendingDoom}"
			Me.Ability[${HexOfImpendingDoom}]:Use
			VGExecute "/reactionchain 1"
			wait 4
			while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
			{
				waitframe
			}
		}
	}

	;; 5th - +400% weapon damage
	if ${doWrack}
	{
		call ExecuteChain "${SoulWrack}" 5
		call ExecuteChain "${Wrack}" 5
		call ExecuteChain "${Ruin}" 5
	}
}

;===================================================
;===       Execute Chain/Combo                  ====
;===================================================
function ExecuteChain(string Chain, int ReactionNumber)
{
	if ${Me.Ability[${Chain}].IsReady}
	{
		if ${Me.Ability[${Chain}].TimeRemaining}==0 && ${Me.Ability[${Chain}].TriggeredCountdown}>0
		{
			;; Check if mob is immune
			call Check4Immunites "${Chain}"
			if !${Return}
			{
				CurrentAction:Set[Chain - ${Chain}]
				EchoIt "Chain - ${Chain}"
				Me.Ability[${Chain}]:Use
				;VGExecute "/reactionchain ${ReactionNumber}"
				wait 4
				while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
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
	else
	{
		;; update display
		TargetsTarget:Set[No Target]
		TargetImmunity:Set[No Target]
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
			EchoIt "Immune to ${ABILITY}"
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
		call HandleChains
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
	}
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
	doCycleTargets:Set[${VG-DK_SSR.FindSetting[doCycleTargets,TRUE]}]
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
	doHatred:Set[${VG-DK_SSR.FindSetting[doHatred,TRUE]}]
	doRescues:Set[${VG-DK_SSR.FindSetting[doRescues,TRUE]}]
	doCounters:Set[${VG-DK_SSR.FindSetting[doCounters,TRUE]}]
	doChains:Set[${VG-DK_SSR.FindSetting[doChains,TRUE]}]
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
	VG-DK_SSR:AddSetting[doCycleTargets,${doCycleTargets}]
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
	VG-DK_SSR:AddSetting[doRescues,${doRescues}]
	VG-DK_SSR:AddSetting[doCounters,${doCounters}]
	VG-DK_SSR:AddSetting[doChains,${doChains}]
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
	VG-DK_SSR:AddSetting[MobMinLevel,${MobMinLevel}]
	VG-DK_SSR:AddSetting[MobMaxLevel,${MobMaxLevel}]
	VG-DK_SSR:AddSetting[ConCheck,${ConCheck}]
	VG-DK_SSR:AddSetting[Distance,${Distance}]

	;; Save to file
	LavishSettings[VG-DK]:Export[${savePath}/MySettings.xml]
}

;variable bool doCounters = TRUE

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
				TimedCommand 10 Script[VG-DK].Variable[doCounters]:Set[TRUE]
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
				TimedCommand 10 Script[VG-DK].Variable[doCounters]:Set[TRUE]
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
	if ${Me.InCombat} && !${Me.Target.IsDead}
	{
		;; Catch them Counters
		Counters
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
}
