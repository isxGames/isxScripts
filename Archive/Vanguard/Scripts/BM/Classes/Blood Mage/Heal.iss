/* Heal self and DTarget */
function:bool HealDTarget()
{
	;-------------------------------------------
	; #1 - CRIT HEAL IS ALWAYS A MUST!
	;-------------------------------------------
	if ${Me.Ability[${BloodTribute}].TriggeredCountdown}>0 && ${Me.Target.HaveLineOfSightTo}
	{
		call UseAbility "${BloodTribute}" "Focus of Gelenia"
		if ${Return}
			return TRUE
	}

	;-------------------------------------------
	; #2 - ENDRURANCE TO HEALTH - Reduces the damage we do but gives us instant health
	;-------------------------------------------
	if ${Me.HealthPct}<80 && ${Me.EndurancePct}>90 && !${Me.InCombat}
	{
		call UseAbility "${PhysicalTransmutation}" "Sanguine Focus"
		if ${Return}
			return TRUE
	}

	;-------------------------------------------
	; #3 - HEAL SELF - If we go down then we can't heal
	;-------------------------------------------
	if ${Me.HealthPct}<${AttackHealRatio} && ${Me.Ability[${InfuseHealth}].IsReady} && ${Me.Ability[${Despoil}].IsReady}
	{
		;; Use our LifeTap 1st
		if ${Me.HealthPct}>50
		{
			call UseAbility "${Despoil}" "Focus of Gelenia"
			if ${Return}
				return TRUE
		}
		
		;; Otherwise, bust out the heal
		Pawn[me]:Target
		call UseAbility "${InfuseHealth}" "Sanguine Focus"
		if ${Return}
			return TRUE
	}

	;-------------------------------------------
	; #4 - INSTANT HEAL ON DTARGET - Will wipe out all BloodUnion
	;-------------------------------------------
	if ${Me.IsGrouped} && ${Me.BloodUnion}>4 && !${Group[${gn}].Name.Equal[${Me.FName}]} && ${Group[${gn}].Health}>0 && ${Group[${gn}].Health}<40 && ${Me.Ability[Ritual of Gelenia].IsReady}
	{
		Pawn[id,${Group[${gn}].ID}]:Target
		call UseAbility "Ritual of Gelenia"
		if ${Return}
			return TRUE
	}

	;-------------------------------------------
	; #5 - BIG HEAL ON DTARGET - Will draw aggro
	;-------------------------------------------
	if !${Group[${gn}].Name.Equal[${Me.FName}]} && ${Group[${gn}].Health}>0 && ${Group[${gn}].Health}<${AttackHealRatio} && ${Me.Ability[${BloodGift}].IsReady}
	{
		Pawn[id,${Group[${gn}].ID}]:Target
		call UseAbility "${BloodGift}" "Sanguine Focus"
		if ${Return}
			return TRUE
	}
	return FALSE
}