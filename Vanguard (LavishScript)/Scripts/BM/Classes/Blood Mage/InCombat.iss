/* MUST HAVE - INCOMBAT */
function InCombat()
{
	;-------------------------------------------
	; Return if we are not in combat and reset FURIOUS
	;-------------------------------------------
	if !${Me.InCombat} || ${Me.Target.IsDead} || ${isPaused} || ${GV[bool,bHarvesting]}
	{
		FURIOUS:Set[FALSE]
		return
	}

	;-------------------------------------------
	; Check for crits 
	;-------------------------------------------
	call Crits
	if ${Return}
		return

	;-------------------------------------------
	; Immunity - cast them if mob targets us
	;-------------------------------------------
	call Immunity
	if ${Return}
		return

	;-------------------------------------------
	; Establish Ritual of Awakening - +20% spell haste
	;-------------------------------------------
	if ${Me.BloodUnion}>1
	{
		call UseAbility "Ritual of Awakening"
		if ${Return}
			return
	}

	;-------------------------------------------
	; Find lowest member's health that's below 95% 
	;-------------------------------------------
	call FindLowestHealth

	;-------------------------------------------
	; If target's health is below AttackHealRatio then heal it if its within range
	;-------------------------------------------
	if ${low}<${AttackHealRatio} && ${Group[${gn}].Distance}<25
	{
		call HealDTarget
		return
	}

	;-------------------------------------------
	; Regenerate our mana
	;-------------------------------------------
	if ${low}>${AttackHealRatio}
	{
		call RegenMana
		if ${Return}
			return
	}

	;-------------------------------------------
	; Routine to DisEnchant Enchantments and set FURIOUS flag
	;-------------------------------------------
	call DisEnchant
	if ${Return}
		return

	;-------------------------------------------
	; Make sure we are targeting our tank's target
	;-------------------------------------------
	if  ${Me.IsGrouped} && ${Me.Encounter}>0
	{
		VGExecute /assist "${Tank}"
	}

	;-------------------------------------------
	; Routine to handle Furious and HOTs
	;-------------------------------------------
	call Furious
	if ${Return}
		return
		
	;-------------------------------------------
	; Check for crits 
	;-------------------------------------------
	call Crits
	if ${Return}
		return
	
	;-------------------------------------------
	; Let's Attack the target and lifetap will work outside healing range
	;-------------------------------------------
	if ${gn}>0 || !${Me.IsGrouped} || ${AttackNow}
	{
		call AttackTarget
	}
}

/* FURIOUS */
function:bool Furious()
{
	;-------------------------------------------
	; Must pass our checks
	;-------------------------------------------
	if !${Me.InCombat} || !${Me.Target(exists)} || ${isPaused}
	{
		FURIOUS:Set[FALSE]
		return FALSE
	}
	
	;-------------------------------------------
	; FURIOUS - HOTS ON DTARGET
	;-------------------------------------------
	if (${FURIOUS} || ${doHOT}) 
	{
		;-------------------------------------------
		; Put 1st HOT on Target's target
		;-------------------------------------------
		if ${Me.BloodUnion}>2
		{
			VGExecute /assistoffensive
			if !${Me.DTarget.Name.Find[${Me.FName}]}
			{
				call UseAbility "${FleshMendersRitual}" "Sanguine Focus"
				if ${Return}
					return TRUE
			}
		}

		;-------------------------------------------
		; Put 2nd HOT on Target's target
		;-------------------------------------------
		VGExecute /assistoffensive
		call UseAbility "${TransfusionOfSerak}" "Sanguine Focus"
		if ${Return}
			return TRUE

		;-------------------------------------------
		; Use Entwining Vein - Its the only ability that doesn't kill you during FURIOUS
		;-------------------------------------------
		if ${FURIOUS}
		{
			VGExecute /assistoffensive
			call UseAbility "${FleshMendersRitual}" "Focus of Gelenia"
			if ${Return}
				return TRUE
		}
	}
	return FALSE
}

/* Immunity */
function:bool Immunity()
{
	;-------------------------------------------
	; We only want 
	;-------------------------------------------
	if !${Me.IsGrouped} && ${Me.HealthPct}>20
		return FALSE
		
	;-------------------------------------------
	; #1 - SHIELD - Total immunity because we just pissed off the Mob
	;-------------------------------------------
	if ${Me.ToT.Name.Find[${Me.FName}]} && ${BloodVials} && ${Me.Ability[${LifeHusk}].IsReady} && !${Me.Effect[${ShelteringRune}](exists)}
	{
		Pawn[me]:Target
		call UseAbility "${LifeHusk}" "Sanguine Focus"
		if ${Return}
		{
			BloodVials:Dec
			return TRUE
		}
	}

	;-------------------------------------------
	; #2 - SHIELD - Partial immunity to Physical and Arcane
	;-------------------------------------------
	if ${Me.ToT.Name.Find[${Me.FName}]} && ${Me.Ability[${ShelteringRune}].IsReady} && !${Me.Effect[${LifeHusk}](exists)}
	{
		Pawn[me]:Target
		call UseAbility "ShelteringRune" "Sanguine Focus"
		if ${Return}
			return TRUE
	}
	return FALSE
}

/* ATTACK OUR TARGET */
function AttackTarget()
{
	;-------------------------------------------
	;Return if target is FURIOUS - don't want to get killed!
	;-------------------------------------------
	if ${FURIOUS}
		return
		
	;-------------------------------------------
	; Let tanks get aggro before attacking
	;-------------------------------------------
	if (${Me.IsGrouped} && ${Me.TargetHealth}>${StartAttack})
		return

	;-------------------------------------------
	; Attack only valid targets
	;-------------------------------------------
	if !${Me.Target(exists)} || !${Me.Target.IsAttackable} || !${Me.Target.HaveLineOfSightTo} || ${isPaused}
		return

	;-------------------------------------------
	; Check for crits
	;-------------------------------------------
	call Crits
	if ${Return}
		return

	;-------------------------------------------
	; Final Blow
	;-------------------------------------------
	if ${Me.BloodUnion}>3 && ${Me.TargetHealth}<30
	{
		call UseAbility "${ScarletRitual}" "Focus of Gelenia"
		if ${Return}
			return
	}
	
/*
 * -----------------------------------------------
 * Lets load up our DOTS
 * -----------------------------------------------
 */
	;-------------------------------------------
	; Might as well toss some DOTs on the target
	;-------------------------------------------
	if ${doDots}
	{
		call UseAbility "${UnionOfBlood}" "Focus of Gelenia"
		if ${Return}
			return

		if ${${Me.BloodUnion}}>1
		{
			call UseAbility "${BloodLettingRitual}" "Focus of Gelenia"
			if ${Return}
				return
		}

		call UseAbility "${ExplodingCyst}" "Focus of Gelenia"
		if ${Return}
			return

		call UseAbility "${BurstingCyst}" "Focus of Gelenia"
		if ${Return}
			return
	}
/*
 * -----------------------------------------------
 * Lets do our LIFETAPS
 * -----------------------------------------------
 */
  	;-------------------------------------------
	; If DTarget is me, use Despoil
	;-------------------------------------------
	if !${Me.IsGrouped} || ${Group[${gn}].Name.Equal[${Me.FName}]} || !${Me.Ability[${EntwiningVein}](exists)}
	{
		call UseAbility "${Despoil}" "Focus of Gelenia"
		if ${Return}
			return
	}
	
	;-------------------------------------------
	; If DTarget is someone else, use Entwining Vein on the lowest health
	;-------------------------------------------
	
	if ${Me.DTargetHealth}>90
		vgexecute /assistoffensive
	call UseAbility "${EntwiningVein}" "Focus of Gelenia"
}

/* CRITS - CHAINS & COUNTERS */
function:bool Crits()
{
	;-------------------------------------------
	; return if FURIOUS is up
	;-------------------------------------------
	if ${FURIOUS} || !${Me.Target.HaveLineOfSightTo} || ${isPaused}
		return FALSE

	;-------------------------------------------
	; Do our Counters first
	;-------------------------------------------
	if ${Me.Ability[${Dissolve}].TriggeredCountdown}>0
	{
		call IsCasting
	
		call UseAbility "${Dissolve}"
		if ${Return}
			return TRUE
	}
	if ${Me.Ability[${Metamorphism}].TriggeredCountdown}>0
	{
		call IsCasting
			
		call UseAbility "${Metamorphism}"
		if ${Return}
			return TRUE
	}

	;-------------------------------------------
	; Do our Chains
	;-------------------------------------------
	if ${Me.HealthPct}>80
	{
		if ${doDots} && ${Me.Ability[${Exsanguinate}].TriggeredCountdown}>0
		{
			call IsCasting
			
			call UseAbility "${Exsanguinate}" "Focus of Gelenia"
			if ${Return}
				return TRUE
		}
		if ${doDots} && ${Me.HealthPct}>80 && ${Me.Ability[${FleshRend}].TriggeredCountdown}>0
		{
			call IsCasting
		
			call UseAbility "${FleshRend}" "Focus of Gelenia"
			if ${Return}
				return TRUE
		}
	}
	if ${Me.Ability[${BloodTribute}].TriggeredCountdown}>0
	{
		call IsCasting
			
		call UseAbility "${BloodTribute}" "Focus of Gelenia"
		if ${Return}
			return TRUE
	}
	return FALSE
}

