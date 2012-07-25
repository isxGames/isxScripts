;-------------------------------------------------------
; VG-DK.iss Version 1.0 Updated: 2010/07/04 by Zandros
;-------------------------------------------------------
;
;===================================================
;===              INCLUDES                      ====
;===================================================
#include ./VG-DK/Objects/Obj_Face.iss
#include ./VG-DK/Objects/Obj_Move.iss

#include ./VG-DK/Includes/Variables.iss
#include ./VG-DK/Includes/Abilities.iss
#include ./VG-DK/Includes/AutoRepair.iss
#include ./VG-DK/Includes/Check4Immunites.iss
#include ./VG-DK/Includes/Buffs.iss
#include ./VG-DK/Includes/Consumables.iss
#include ./VG-DK/Includes/LootTargets.iss
#include ./VG-DK/Includes/Hunt.iss
#include ./VG-DK/Includes/FindTarget.iss
#include ./VG-DK/Includes/MoveCloser.iss
#include ./VG-DK/Includes/FaceSlow.iss
#include ./VG-DK/Includes/HandleRescues.iss
#include ./VG-DK/Includes/HandleCounters.iss
#include ./VG-DK/Includes/HandleChains.iss
#include ./VG-DK/Includes/HandleEncounters.iss
#include ./VG-DK/Includes/ShadowStepHeal.iss
#include ./VG-DK/Includes/UseAbility.iss
#include ./VG-DK/Includes/UI.iss
#include ./VG-DK/Includes/Follow.iss
#include ./VG-DK/Includes/Harvest.iss

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
		if !${Me.IsCasting} && ${VG.InGlobalRecovery}==0
		{
			if ${doHunt} && !${Me.InCombat} && (${Me.HealthPct}<80 || ${Me.EnergyPct}<80 || ${Me.EndurancePct}<80)
			{
				CurrentAction:Set[Resting]
			}
			elseif ${doHunt} && !${Me.InCombat} && ${Me.HealthPct}>=80 && ${Me.EnergyPct}>=80 && ${Me.EndurancePct}>=80
			{
				CurrentAction:Set[Hunting]
			}
			else
			{
				CurrentAction:Set[Waiting]
			}
		}

		;; Execute any queued commands
		if ${QueuedCommands}
		{
			ExecuteQueued
			FlushQueued
		}
		
		;; execute routines
		if !${isPaused} 
		{
			call NotInCombat
			call InCombat
			call AlwaysCheck
		}
	}
}

function AlwaysCheck()
{
	;; Loot and clear dead targets that are within 5 meters
	call LootTargets

	;; Be sure to switch into correct form
	call ChangeForm

	;; Use any consumables in our inventory
	call Consumables
	
	;; Follow our Tank
	call Follow

	;; Reset TargetBuff counter
	if !${Me.Target(exists)}
		TargetBuffs:Set[0]

	;; Figure out what we going to do with our Encounters
	call HandleEncounters
	if ${Return}
		return
		
	;; Sometimes, we are not the main tank
	call AssistTank
}

function NotInCombat()
{
	;; Return if we are not in combat
	if ${Me.InCombat} 
		return
		
	;; Ensure Furious is reset
	FURIOUS:Set[FALSE]

	;; Stop all Melee Attacks
	call StopMeleeAttacks		

	;; Repair our Equipment
	call AutoRepair

	;; Ensure buffs are up
	call BuffUp

	;; Ensure we remove certain buffs like those that reduce our Hatred
	call CancelBuffs
	
	;; Assist with harvesting
	call Harvest
	
	;; Hunt for a target
	call Hunt

	;; Take down that pesky POTA barrier
	call OpenPotaBarrier
}

function InCombat()
{
	waitframe

	if !${Me.Target(exists)} || ${Me.Target.Type.Equal[Corpse]} || ${Me.Target.IsDead} || ${GV[bool,bHarvesting]} || !${Me.Target.HaveLineOfSightTo}
		return

	;; wait 1 second if health is 0 -- this will help prevent accidental attacking
	if ${Me.TargetHealth}==0
	{
		wait 10 ${Me.TargetHealth}
	}

	;; Return if target is not in Combat unless we are hunting
	if !${doHunt} && ${Me.Target.CombatState}==0
	{
		return
	}

	;; Handle any emergencies that come up
	call HandleEmergencies
	if ${Return}
		return

	;; Routine to handle Furious, Furious Rage, Aura of Death, and Frightful Aura
	call HandleFurious
	if ${Return}
		return

	if ${Me.HavePet}
		VGExecute "/pet Attack"
		
	;; We are assisting, not Tanking so let's wait
	if !${Tank.Find[${Me.FName}]}
	{
		if ${Me.TargetHealth}>=98
		{
			return
		}
	}

	;; Rescue any group members
	call HandleRescues

	;; Use ShadowStep to heal if health is below 70%
	call ShadowStepHeal
	if ${Return}
		return
	
	;; Process any Chains/Finishers and combos
	call HandleChains
	
	;; Process any counters
	call HandleCounters
	
	;; Let's face the target
	call FaceTarget
	
	;; Target turned their back on us so let's stun them, heal ourselves with harrow, and try to snare them
	call HandleBehindTarget
	if ${Return}
		return

	;; Drain target's endurance and returns it to us -- 40 second cooldown
	if ${Me.Endurance}>=10 && ${Me.Endurance}<30 && !${Me.TargetMyDebuff[${RavagingDarkness}](exists)} && ${Me.Ability[${RavagingDarkness}].TimeRemaining}==0
	{
		;; wait to use next ability
		while ${VG.InGlobalRecovery}>0
		{
			waitframe
		}
			;vgecho RavagingDarkness=${Me.Ability[${RavagingDarkness}].IsReady}
	
		call UseAbility "${RavagingDarkness}"
		if ${Return}
			return
	}

	;; Blocks 25% damage for 4-5 hits -- 1 minute cooldown
	call CastBuff "${DarkWard}"

	if ${Me.HealthPct}<40
		return
	
	;; Process all routines that deal primarily with Hatred
	call BuildHatred
	if ${Return}
		return
	
	;; Build our Dread to level 5
	call BuildDread
	if ${Return}
		return

	;; Attempt to remove new Enchantments
	call RemoveEnchantments
	if ${Return}
		return
		
	;; Debuff the target with Soul Consumption or Devour Mind/Strength
	call DeBuff
	if ${Return}
		return

	;; Process all routines that deal with Melee Attacks
	call HandleMeleeAttacks
	if ${Return}
		return
		
	;; Move within Range to attack with a bow
	call RangedAttack
	if ${Return}
		return
		
	;; SNARE target -- slow them down		
	call SnareTarget
	if ${Return}
		return

	;; Move within Range for Melee attacks
	call MoveToMeleeRange
}

;=========================================================================================
;=========================================================================================
;=========================================================================================

function StopMeleeAttacks()
{
	if !${GV[bool,bHarvesting]}
	{
		;; Method #1 - Turn off attacks!
		if ${GV[bool,bIsAutoAttacking]}
		{
			Me.Ability[Auto Attack]:Use
			wait 10 !${GV[bool,bIsAutoAttacking]}
		}
		;; Method #2 - Turn off attacks!
		if ${Me.Ability[Auto Attack].Toggled} 
		{
			Me.Ability[Auto Attack]:Use
			wait 10 !${Me.Ability[Auto Attack].Toggled} 
		}
	}
}

function AssistTank()
{
	;; We are going to assist the tank and target whatever he's targeting
	if !${Tank.Equal[${Me.FName}]}
	{
		if ${Pawn[name,${Tank}](exists)}
		{
			;; Do not assist Tank if Tank is not in combat
			if ${Pawn[name,${Tank}].CombatState}==0
				return
			if ${Pawn[name,${Tank}].Distance}<40
			{
				VGExecute "/assist ${Tank}"
				VGExecute /assistoffensive
				
				;; Pause... health sometimes reports NULL or 0
				if ${Me.Target(exists)} && ${Me.TargetHealth}<1
				{
					wait 5
				}
			}
		}
	}
}


function:bool HandleFurious()
{		
	;; Routine to handle Furious, Furious Rage, Aura of Death, and Frightful Aura
	if ${Me.TargetBuff[Furious](exists)} || ${Me.TargetBuff[Furious Rage](exists)} || ${Me.TargetBuff[Aura of Death](exists)} || ${Me.TargetBuff[Frightful Aura](exists)} || ${FURIOUS}
	{
		if ${Me.TargetHealth}>20
		{
			FURIOUS:Set[FALSE]
			return FALSE
		}
		
		if ${Me.TargetHealth}<10 && !${Me.TargetBuff[Furious](exists)} && !${Me.TargetBuff[Furious Rage](exists)} && !${Me.TargetBuff[Aura of Death](exists)} && !${Me.TargetBuff[Frightful Aura](exists)}
		{
			FURIOUS:Set[FALSE]
			return FALSE
		}

		if ${Me.HavePet}
			VGExecute "/pet backoff"
		
		if ${Me.Target.HaveLineOfSightTo}
		{
			;; STUN target up to 25 meters away
			call UseAbility "${OminousFate}"
			
			;; STOP ATTACK & Block incoming attack
			call UseAbility "${BleakFoeman}"
		}

		;; wait to allow attacks to stop after using Bleak Foeman
		wait 3
		
		;; Stop attacks
		call StopMeleeAttacks	
		
		;; Keep increasing hate for those that like plowing furious
		if ${doHatred} && ${doProvoke} && ${Me.IsGrouped}
		{
			;; Increase Hatred
			call UseAbility "${Provoke}"
		}
		return TRUE
	}
	return FALSE
}

function:bool DeBuff()
{
	;; Debuffs the target with Soul Consumption or Devour Mind/Strength
	if ${doDeBuff}
	{
		if ${Me.Ability[${SoulConsumption}](exists)}
		{
			if !${Me.Effect[${SoulConsumption}](exists)}
			{
				call UseAbility "${SoulConsumption}"
				if ${Return}
				{
					return TRUE
				}
			}
			return FALSE
		}
		if ${Me.Ability[${DevourStrength}](exists)}
		{
			if !${Me.Effect[${DevourStrength}](exists)}
			{
				call UseAbility "${DevourStrength}"
				if ${Return}
				{
					return TRUE
				}
			}
		}
		if ${Me.Ability[${DevourMind}](exists)}
		{
			if !${Me.Effect[${DevourMind}](exists)}
			{
				call UseAbility "${DevourMind}"
				if ${Return}
				{
					return TRUE
				}
			}
		}
	}
	return FALSE
}


function:bool HandleEmergencies()
{
	;-------------------------------------------
	; SAVE OUR BACON ROUTINE - 10 second immunity
	;-------------------------------------------
	if ${Me.HealthPct}<30
	{
		;; Get our Immunity shield up if we are severely wounded
		call UseAbility "${AphoticShield}"
		if ${Return}
		{
			vgecho "10 second immunity is up"
			return TRUE
		}
	}
	return FALSE
}

function:bool HandleBehindTarget()
{
	;; Target turned their back on us so let's stun them, heal ourselves with harrow, and try to snare them
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

		;; anything within 90 degrees is fair play
		if ${result}<90 
		{
			;; === STUN target ===
			call UseAbility "${OminousFate}"
			
			;; === Heal ourselves with Harrow ===
			call UseAbility "${Harrow}"
			if ${Return}
				return TRUE

				;; === SNARE target slowing them down ===
			if ${doMisc} && ${doAbyssalChains} && ${doSnare} && ${Me.HealthPct}>75
			{
				if ${Me.Ability[${AbyssalChains}].TimeRemaining}==0 && ${Me.Ability[${AbyssalChains}].EnergyCost}<${Me.Energy} && !${Me.TargetMyDebuff[${AbyssalChains}](exists)}
				{
					call UseAbility "${AbyssalChains}"
					if ${Return}
					{
						TimedCommand 30 Script[VG-DK].Variable[doSnare]:Set[TRUE]
						doSnare:Set[FALSE]
						return TRUE
					}
				}
			}
		}
	}
	return FALSE
}

function:bool BuildHatred()
{
	;-------------------------------------------
	; BUILD HATRED ROUTINES
	;-------------------------------------------
	if ${doHatred}
	{
		variable int i = 0
		variable int TotalPawnsNearby = 0
		
		for ( i:Set[1] ; ${i}<=${VG.PawnCount} && ${Pawn[${i}].Distance}<10 ; i:Inc )
		{
			;; Find out how many pawns near me that is in combat
			if ${Pawn[${i}].CombatState}>0 && ${Pawn[${i}].Type.Equal[AggroNPC]}
			{
				TotalPawnsNearby:Inc
			}
		}

		if ${doScytheOfDoom} && ${Me.HealthPct}<70 && ${Me.EndurancePct}>48 && ${TotalPawnsNearby}>1 && ${Me.Ability[${ScytheOfDoom}].TimeRemaining}==0
		{
			;; wait to use next ability
			while ${VG.InGlobalRecovery}>0
			{
				waitframe
			}
			;vgecho ScytheOfDoom=${Me.Ability[${ScytheOfDoom}].IsReady}
			
			;; frontal AE that heals (NICE)
			if ${Me.Ability[${ScytheOfDoom}].IsReady}
			{
				CurrentAction:Set[${ScytheOfDoom}]
				EchoIt "UseAbility - ${ScytheOfDoom} - Total Targets=${x}"
				CurrentAction:Set[${ScytheOfDoom}]
				Me.Ability[${ScytheOfDoom}]:Use
				wait 5
				return TRUE
			}
		}

		if ${Me.IsGrouped}
		{
			;; Damage and hate
			call UseAbility "${IncantationOfHate}"
			if ${Return}
				return TRUE
		}
		
		if ${doTorture} && !${Me.TargetMyDebuff[${Torture}](exists)}
		{
			;; DOT - Damage and increase hatred
			call UseAbility "${Torture}"
			if ${Return}
				return TRUE
		}

		if ${doProvoke} && ${Me.IsGrouped}
		{
			;; Increase Hatred
			call UseAbility "${Provoke}"
			if ${Return}
				return TRUE
		}

		if ${doBlackWind} && ${Me.EndurancePct}>50 && ${Me.IsGrouped} && ${TotalPawnsNearby}>1
		{
			;; frontal AE that increases hatred
			call UseAbility "${BlackWind}"
			if ${Return}
				return TRUE
		}
	}
	return FALSE
}

function:bool BuildDread()
{		
	;; Build our Dread to level 5
	if ${doDreadfulVisage} && ${GV[int,ProgressiveFormPhase]}<5 && ${Me.Target.CombatState}>0
	{
		call UseAbility "${DreadfulVisage}"
		if ${Return}
		{
			return TRUE
		}
	}
	return FALSE
}

function:bool RemoveEnchantments()
{
	;; === Remove an Enchantment
	if (${doDisEnchant} || ${Me.TargetBuff}>${TargetBuffs}) && ${doMisc} && ${doDespoil}
	{
		
		;; Targetbuff counter increased so set the doDisEnchant flag
		if ${Me.TargetBuff}>${TargetBuffs}
		{
			call UseAbility "${Despoil}"
			if ${Return}
			{
				;; Update our Targetbuff counter
				TargetBuffs:Set[${Me.TargetBuff}]
				doDisEnchant:Set[FALSE]
				return TRUE
			}
		}
	}
	return FALSE
}

function:bool HandleMeleeAttacks()
{
	if ${doMelee}
	{
		if ${doSlay} && ${Me.TargetHealth}<20 && ${Me.EndurancePct}>=30
		{
			;; Only usable below 20% health
			call UseAbility "${Slay}"
			if ${Return}
				return TRUE
		}
		if ${doBacklash} && ${Me.EndurancePct}>=25
		{
			;; 15 Endurance
			call UseAbility "${Backlash}"
			if ${Return}
				return TRUE
		}
		if ${doMutilate} && ${Me.EndurancePct}>=40
		{
			;; 40 Endurance
			call UseAbility "${Mutilate}"
			if ${Return}
				return TRUE
		}
		if ${doMalice} && ${Me.EndurancePct}>=40
		{
			;; 24 Endurance
			call UseAbility "${Malice}"
			if ${Return}
				return TRUE
		}
		;; This is your crit maker here!!
		if ${doVexingStrike} && ${Me.EndurancePct}>=50
		{
			;; 20 Endurance
			call UseAbility "${VexingStrike}"
			if ${Return}
				return TRUE
		}
	}
	return FALSE
}

function:bool RangedAttack()
{
	;; Move within Range to attack with a bow
	if ${doRanged} && !${isPaused}
	{
		variable int i
		
		if ${doMove}
		{
			i:Set[${Me.Ability[Ranged Attack].Range}]
			if ${i}<15
			{
				;; maximum range to move to
				i:Set[14]
			}
			if ${i}>25
			{
				;; maximum range to move to
				i:Set[24]
			}
			i:Set[${Math.Calc[${i}-3]]
			call MoveCloser ${Me.Target.X} ${Me.Target.Y} ${i}
		}
		if ${Me.Target.Distance}>4
		{
			call UseAbility "Ranged Attack"
			if !${Return}
			{
				if ${doMove}
				{
					i:Set[${Math.Calc[${i}-3]]
					call MoveCloser ${Me.Target.X} ${Me.Target.Y} ${i}
				}
				return FALSE
			}
			return TRUE
		}
	}
	return FALSE
}

function:bool SnareTarget()
{
	;; SNARE target -- slow them down
	if !${Me.IsGrouped} && ${doMisc} && ${doAbyssalChains} && ${doSnare} && ${Me.Target.CombatState}>0 && ${Me.HealthPct}>80
	{
		TimedCommand 30 Script[VG-DK].Variable[doSnare]:Set[TRUE]
		doSnare:Set[FALSE]
		call UseAbility "${AbyssalChains}"
		if ${Return}
			return TRUE
	}
	return FALSE
}

function MoveToMeleeRange()
{
	;; Move within Range for Melee attacks
	if ${doMove} && !${isPaused} && (${Me.TargetHealth}<99 || !${doRanged})
	{
		call MoveCloser ${Me.Target.X} ${Me.Target.Y} 4
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

	; Ensure we are in combat form
	;if !${Me.CurrentForm.Name.Equal[Ebon Blade]}
	;{
	;	Me.Form[Ebon Blade]:ChangeTo
	;	TimedCommand 40 Script[VG-DK].Variable[doForm]:Set[TRUE]
	;	doForm:Set[FALSE]
	;	wait 10 ${Me.CurrentForm.Name.Equal[Ebon Blade]}
	;	EchoIt "** New Form = ${Me.CurrentForm.Name}"
	;}
	
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
	while ${Me.IsCasting} || ${VG.InGlobalRecovery}>0
	{
		waitframe
	}

	VGExecute "/reactionchain 5"
	VGExecute "/reactionchain 1"
	VGExecute "/reactionchain 4"

		;; Make sure we have nothing that will interfere with the next ability
	while ${Me.IsCasting} || ${VG.InGlobalRecovery}>0
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
;===     OPEN THE DOOR                          ====
;===================================================
function OpenDoor()
{
	VG:ExecBinding[UseDoorEtc]
}

;===================================================
;===     TAKE DOWN THAT PESKY POTA BARRIER      ====
;===================================================
function OpenPotaBarrier()
{
	return
	;;  - drop that Pota barrier!
	if ${Pawn[Kheolim's Barrier].Distance}<3
	{
		Pawn[Kheolim's Barrier]:DoubleClick
		wait 5
	}
}

;===================================================
;===       CHANGE TO CORRECT FORM               ====
;===================================================
function ChangeForm()
{

	if ${doForm}
	{
		if !${Me.Form[${CombatForm}](exists)} || !${Me.Form[${NonCombatForm}](exists)}
		{
			doForm:Set[FALSE]
			return
		}
	
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
			wait 2
		}
		if ${Math.Rand[10]}>5
		{
			VG:ExecBinding[StrafeLeft,release]
			VG:ExecBinding[StrafeRight]
			wait 2
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
	
	;; Seems to jump alot but it works!
	doJump:Set[TRUE]
}

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
	
	;; Misc
	UIElement[Follow Name@Misc@Tabs@VG-DK]:SetText[Follow:  ${FollowName}]


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
			EchoIt "FURIOUS - RESUME ATTACKING"
			FURIOUS:Set[FALSE]
		}
	}

	; Check if target went into FURIOUS - Has delays for notification
	if ${ChannelNumber}==7 && ${aText.Find[becomes FURIOUS]}
	{
		if ${Me.Target(exists)} && ${aText.Find[${Me.Target.Name}]} && ${Me.TargetHealth}<=20
		{
			;; Turn on FURIOUS flag and stop attack
			vgecho "FURIOUS -- STOP ATTACKS"
			EchoIt "FURIOUS -- STOP ATTACKS"
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
	
	if ${aText.Find[You are missing the ammo needed to use this ability.]}
	{
		doRanged:Set[FALSE]
		UIElement[doRanged@Main@Tabs@VG-DK]:UnsetChecked
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
