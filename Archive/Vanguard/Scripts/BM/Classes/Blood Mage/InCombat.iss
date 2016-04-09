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
	; Immunity - cast them if mob is targeting us
	;-------------------------------------------
	call Immunity
	if ${Return}
		return

	;-------------------------------------------
	; Establish Blood Feast - Get 10% of damage from allies returned back to me as health
	;-------------------------------------------
	if ${Me.Ability[Blood Feast](exists)} && !${Me.Effect[Blood Feast](exists)}
	{
		waitframe
		wait 10 ${Me.Ability[Blood Feast].IsReady}
		call UseAbility "Blood Feast"
		if ${Return}
			wait 10 ${Me.Effect[Blood Feast](exists)}
	}

	;-------------------------------------------
	; Establish Ritual of Awakening - +20% spell haste
	;-------------------------------------------
	if ${Me.BloodUnion}>1 && ${Me.Ability[Ritual of Awakening](exists)} && !${Me.Effect[Ritual of Awakening](exists)}
	{
		waitframe
		wait 10 ${Me.Ability[Ritual of Awakening].IsReady}
		call UseAbility "Ritual of Awakening"
		if ${Return}
			wait 10 ${Me.Effect[Ritual of Awakening](exists)}
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
	; Things we want to do if everyone is in safe zone
	;-------------------------------------------
	if ${low}>${AttackHealRatio}
	{
		;; Routine to Regen our mana
		call RegenMana
		if ${Return}
			return

		;; Routine to DisEnchant Enchantments and set FURIOUS flag
		call DisEnchant
		if ${Return}
			return
	}

	;-------------------------------------------
	; Make sure we are targeting our tank's target
	;-------------------------------------------
	if  ${Me.IsGrouped} && ${Me.Encounter}>0
		VGExecute /assist "${Tank}"

	;-------------------------------------------
	; Routine to handle Furious and HOTs
	;-------------------------------------------
	call Furious
	if ${Return}
		return
		

	;-------------------------------------------
	; Check #1 - Return if we are not in combat
	;-------------------------------------------
	if !${Me.InCombat} || ${Me.Target.IsDead} || ${GV[bool,bHarvesting]}
		return

	;-------------------------------------------
	; Check #2 - Return to allow tank to gain aggro
	;-------------------------------------------
	if ${Me.IsGrouped} && ${Me.TargetHealth}>${StartAttack} 
		return
		
	;-------------------------------------------
	; Check #3 - Return if target is not attackable
	;-------------------------------------------
	if !${Me.Target(exists)} || !${Me.Target.HaveLineOfSightTo} || !${Me.Target.IsAttackable} || ${Me.Target.Distance}>25
		return
		
	;-------------------------------------------
	; Let's Attack the target, lifetap will work outside healing range
	;-------------------------------------------
	call AttackTarget
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
		;; Set DTarget to Target's target
		VGExecute /assistoffensive

		;; Put 1st HOT
		if ${Me.BloodUnion}>2 && ${Me.Ability[${FleshMendersRitual}].IsReady} && !${Me.DTarget.Name.Find[${Me.FName}]}
		{
			wait 3
			call UseAbility "${FleshMendersRitual}" "Sanguine Focus"
			if ${Return}
			{
				if ${doEcho}
					echo "[${Time}][VG:BM] --> 1st HOT: ${Me.DTarget.Name}"
				return TRUE
			}
		}

		;; Put 2nd HOT on Target's target
		if ${doHotTimer}
		{
			wait 3
			call UseAbility "${TransfusionOfSerak}" "Sanguine Focus"
			if ${Return}
			{
				if ${doEcho}
					echo "[${Time}][VG:BM] --> 2nd HOT: ${Me.DTarget.Name}"
				TimedCommand 150 Script[BM].Variable[doHotTimer]:Set[TRUE]
				doHotTimer:Set[FALSE]
				return TRUE
			}
		}

		;; Use Entwining Vein - Its the one ability that doesn't kill you during FURIOUS
		if ${FURIOUS} && ${Me.Target.Distance}<25
		{
			VGExecute /assistoffensive
			call UseAbility "${EntwiningVein}" "Focus of Gelenia"
			if ${Return}
				return TRUE
		}
	}
	return FALSE
}

/* Immunity */
function:bool Immunity()
{
	;; Must pass our check
	if !${Me.IsGrouped} && ${Me.HealthPct}>20
		return FALSE

	;; #1 - SHIELD - Total immunity because we just pissed off the Mob
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
	
	;; #2 - SHIELD - Partial immunity to Physical and Arcane
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
	;Return if target is FURIOUS or not valid target - don't want to get killed!
	;-------------------------------------------
	if ${FURIOUS} || !${Me.Target.HaveLineOfSightTo} || !${Me.Target(exists)} || !${Me.Target.IsAttackable} || ${Me.Target.Distance}>25
		return
		
	;-------------------------------------------
	; Check for crits
	;-------------------------------------------
	call Crits
	if ${Return}
		return

	;-------------------------------------------
	; Final Blow at 30% OF Target's Health
	;-------------------------------------------
	if ${Me.TargetHealth}<40
	{
		call UseAbility "${ScarletRitual}" "Focus of Gelenia"
		if ${Return}
			return
	}

/*
 * -----------------------------------------------
 * Lets do our LIFETAPS
 * -----------------------------------------------
 */
 	;-------------------------------------------
	; Execute this once every 2 seconds allows our DOTs to get loaded
	;-------------------------------------------
	if ${doLifeTap}
	{
		;-------------------------------------------
		; If DTarget is me, use Despoil
		;-------------------------------------------
		if !${Me.IsGrouped} || ${Group[${gn}].Name.Equal[${Me.FName}]} || !${Me.Ability[${EntwiningVein}](exists)}
		{
			call UseAbility "${Despoil}" "Focus of Gelenia"
			if ${Return}
			{
				SetLiFeTap
				return
			}
		}
	
		;-------------------------------------------
		; If DTarget is someone else, use Entwining Vein on the lowest health
		;-------------------------------------------
		if ${Me.DTargetHealth}>90
			vgexecute /assistoffensive
		call UseAbility "${EntwiningVein}" "Focus of Gelenia"
		if ${Return}
		{
			SetLiFeTap
			return
		}
	}
	
/*
 * -----------------------------------------------
 * Lets load up our DOTS
 * -----------------------------------------------
 */
	;-------------------------------------------
	; Do our Dots - Toggle doDots for DPS
	;-------------------------------------------
	if ${doDots}
	{
		call UseAbility "${BloodLettingRitual}" "Focus of Gelenia"
		if ${Return}
			return

		call UseAbility "${UnionOfBlood}" "Focus of Gelenia"
		if ${Return}
			return

		call UseAbility "${ExplodingCyst}" "Focus of Gelenia"
		if ${Return}
			return

		call UseAbility "${BurstingCyst}" "Focus of Gelenia"
		if ${Return}
			return
	}
}

;; Calculate LifeTap
atom SetLiFeTap() 
{
	variable float y
	if ${doLifeTap}
	{
		y:Set[${Me.Ability[${Despoil}].CastTime}*10]
	
		;; Add 2 seconds if we are casting Dots
		if ${doDots}
			y:Inc[30]
		;; Add 1/2 second if we are not casting any Dots
		if !${doDots}
			y:Inc[5]

		doLifeTap:Set[FALSE]
		TimedCommand ${y.Int} Script[BM].Variable[doLifeTap]:Set[TRUE]
	}
}
		

/* CRITS - CHAINS & COUNTERS */
function:bool Crits()
{
	;-------------------------------------------
	; Do our Counters first
	;-------------------------------------------
	if ${Me.Ability[${Dissolve}].TriggeredCountdown}>0
	{
		call UseAbility "${Dissolve}"
		if ${Return}
			return TRUE
	}
	if ${Me.Ability[${Metamorphism}].TriggeredCountdown}>0
	{
		call UseAbility "${Metamorphism}"
		if ${Return}
			return TRUE
	}

	;-------------------------------------------
	; Do our Chains - Toggle doDots for DPS
	;-------------------------------------------
	if ${Me.HealthPct}>80
	{
		if ${doDots} && ${Me.Ability[${Exsanguinate}].TriggeredCountdown}>0
		{
			call UseAbility "${Exsanguinate}" "Focus of Gelenia"
			if ${Return}
				return TRUE
		}
		if ${doDots} && ${Me.Ability[${FleshRend}].TriggeredCountdown}>0
		{
			call UseAbility "${FleshRend}" "Focus of Gelenia"
			if ${Return}
				return TRUE
		}
	}
	if ${Me.Ability[${BloodTribute}].TriggeredCountdown}>0
	{
		call UseAbility "${BloodTribute}" "Focus of Gelenia"
		if ${Return}
			return TRUE
	}
	return FALSE
}