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
				wait 3
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

	;-------------------------------------------
	; Check #5 - Return to allow tank to gain aggro
	;-------------------------------------------
	if ${Me.TargetHealth}>${StartAttack}
	{
		return
	}

	;-------------------------------------------
	; Check #6 - Cast a HOT and return if target is FURIOUS
	;-------------------------------------------
	if ${Me.TargetBuff[Furious](exists)} || ${Me.TargetBuff[Furious Rage](exists)} || ${FURIOUS}
	{
		call UseAbility "${TransfusionOfSerak}"
		return
	}
	
	;-------------------------------------------
	; Check #7 - Return if Weakened and we are Chaos (You might want to remove this)
	;-------------------------------------------
	if ${Me.TargetBuff[Weakened].Description.Find[Chaos]}
	{
		return
	}

	;; ======== SAFE TO DO OUR ATTACK ROUTINES ========

	;-------------------------------------------
	; Establish Blood Feast - Get 10% of damage from allies returned back to me as health
	;-------------------------------------------
	if ${Me.Ability[Blood Feast](exists)} && !${Me.Effect[Blood Feast](exists)}
	{
		waitframe
		wait 10 ${Me.Ability[Blood Feast].IsReady}
		call UseAbility "Blood Feast"
		if ${Return}
		{
			wait 10 ${Me.Effect[Blood Feast](exists)}
		}
	}
	;-------------------------------------------
	; Establish Ritual of Awakening - +20% spell haste
	;-------------------------------------------
	if ${Me.BloodUnion}>1 && ${Me.Ability[${RitualOfAwakening}](exists)} && !${Me.Effect[${RitualOfAwakening}](exists)}
	{
		waitframe
		wait 10 ${Me.Ability[${RitualOfAwakening}].IsReady}
		call UseAbility "${RitualOfAwakening}"
		if ${Return}
		wait 10 ${Me.Effect[${RitualOfAwakening}](exists)}
	}
	
	;-------------------------------------------
	; Deaggro - Arcane now generates hate
	;-------------------------------------------
	if ${Me.TargetHealth}>20 && ${Me.TargetHealth}<80
	{
		if ${doDeAggro}
		{
			if ${doTimedDeaggro}
			{
				call UseAbility "${Numb}"
				if ${Return}
				{
					return
				}
				TimedCommand 250 Script[VG-BM].Variable[doTimedDeaggro]:Set[TRUE]
				doTimedDeaggro:Set[FALSE]
			}
		}
	}
	
	;-------------------------------------------
	; Face our target!
	;-------------------------------------------
	;if ${doFaceSlow} && ${Me.Target.Distance}<30
	;{
	;	Face:Pawn[${Me.Target.ID}]
	;}
		
	;-------------------------------------------
	;; Ensure we are in the correct form
	;-------------------------------------------
	call ChangeForm
		
	;===================================================
	;===     PRIORITY ABILITIES COMES FIRST         ====
	;===================================================

	;; Check to see if we want to do a crit
	;call HandleChains
	;if ${Return}
	;{
	;	return
	;}

	; Final Blow at 30% OF Target's Health
	if ${doScarletRitual}
	{
		if ${Me.TargetHealth}<30
		{
			call UseAbility "${ScarletRitual}" "Focus of Gelenia"
			if ${Return}
			{
				return
			}
		}
	}
	
	if ${Me.HealthPct}>80 && ${low}>80
	{
		if ${doAE} && ${doSeveringRitual} && !${Me.TargetMyDebuff[${SeveringRitual}](exists)}
		{
			call UseAbility "${SeveringRitual}"
			if ${Return}
			{
				return
			}
		}

		;; Load up on the Dots
		if ${doDots}
		{
			if ${doBloodLettingRitual} && !${Me.TargetMyDebuff[${BloodLettingRitual}](exists)}
			{
				call UseAbility "${BloodLettingRitual}"
				if ${Return}
				{
					return
				}
			}

			if ${doUnionOfBlood} && !${Me.TargetMyDebuff[${UnionOfBlood}](exists)}
			{
				call UseAbility "${UnionOfBlood}"
				if ${Return}
				{
					return
				}

			}
			if ${doExplodingCyst} && !${Me.TargetMyDebuff[${ExplodingCyst}](exists)}
			{
				call UseAbility "${ExplodingCyst}"
				if ${Return}
				{
					return
				}

			}
			if ${doBurstingCyst} && !${Me.TargetMyDebuff[${BurstingCyst}](exists)}
			{
				call UseAbility "${BurstingCyst}"
				if ${Return}
				{
					return
				}
			}
		}
	}

	;; Sweet - Lifetap
	if ${doLifeTaps}
	{
		;; Use Bloodthinner if we got it
		if ${doBloodthinner}
		{
			call UseAbility "${Bloodthinner}"
			if ${Return}
			{
				return
			}
/*
			wait 10 ${Me.Ability[${Bloodthinner}].IsReady}
			if ${Me.Ability[${Bloodthinner}].IsReady}
			{
				EchoIt "UseAbility - ${Bloodthinner}"
				CurrentAction:Set[Casting ${Bloodthinner}]
				Me.Ability[${Bloodthinner}]:Use
				wait 3
				while !${Me.Ability["Using Weaknesses"].IsReady} || ${Me.IsCasting} || ${VG.InGlobalRecovery}>0
				{
					waitframe
				}
				wait 3
			}
*/
		}
		
		if ${Me.IsGrouped}
		{
			;; Use Entwining Vein
			if ${doEntwiningVein}
			{
				call UseAbility "${EntwiningVein}"
				if ${Return}
				{
					return
				}
/*			
				wait 15 ${Me.Ability[${EntwiningVein}].IsReady}
				if ${Me.Ability[${EntwiningVein}].IsReady}
				{
					EchoIt "UseAbility - ${EntwiningVein}"
					CurrentAction:Set[Casting ${EntwiningVein}]
					Me.Ability[${EntwiningVein}]:Use
					wait 3
					while !${Me.Ability["Using Weaknesses"].IsReady} || ${Me.IsCasting} || ${VG.InGlobalRecovery}>0
					{
						waitframe
					}
					wait 3
					return
				}
*/

			}
			;; Use Despoil
			if ${doDespoil}
			{
				call UseAbility "${Despoil}"
				if ${Return}
				{
					return
				}
			}
		}
		else
		{
			;; Use Despoil
			if ${doDespoil}
			{
				call UseAbility "${Despoil}"
				if ${Return}
				{
					return
				}
			}
			;; Use Entwining Vein
			if ${doEntwiningVein}
			{
				call UseAbility "${EntwiningVein}"
				if ${Return}
				{
					return
				}
			}
		}
	}
}	
