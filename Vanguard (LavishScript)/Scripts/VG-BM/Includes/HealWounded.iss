;===================================================
;===             HEAL WOUNDED                   ====
;===================================================
function:bool HealWounded()
{


	;; Check to see if we need to use the 10m group heal
	if ${Health.TotalGroupWounded}>2
	{
		;; AE Heal - try this first
		call UseAbility "Superior Recovering Burst"
		if ${Return}
		{
			wait 5
			return
		}
		;; AE heal - try this next
		call UseAbility "${RecoveringBurst}"
		if ${Return}
		{
			wait 5
			return
		}
		
	}


	while !${Me.CurrentForm.Name.Equal[${NonCombatForm}]}
	{
		if ${doForm} && !${Me.CurrentForm.Name.Equal[${NonCombatForm}]}
		{
			Me.Form[${NonCombatForm}]:ChangeTo
			TimedCommand 20 Script[VG-BM].Variable[doForm]:Set[TRUE]
			doForm:Set[FALSE]
		}
	}
	EchoIt "** Form = ${Me.CurrentForm.Name}"

	
	;-------------------------------------------
	; #1 - HEAL SELF - If we go down then we can't heal
	;-------------------------------------------
	if ${Me.HealthPct}<${AttackHealRatio}
	{
		if ${Me.InCombat}
		{
			;; Use our LifeTap 1st
			if ${Me.HealthPct}>50 && ${Me.Ability[${InfuseHealth}].IsReady} && ${Me.Ability[${Despoil}].IsReady}
			{
				call UseAbility "${Despoil}"
				if ${Return}
				{
					return TRUE
				}
			}
		}

		;; Otherwise, bust out the heal
		Pawn[me]:Target
		call UseAbility "${InfuseHealth}"
		if ${Return}
		{
			return TRUE
		}
	}

	;; allow time for DTarget to update
	waitframe
	
	;-------------------------------------------
	; #3 - DTarget is already setup... so let's heal the wounded member! 
	;-------------------------------------------
	if ${Group[${GroupNumber}].Class.Equal[Psionicist]}
	{
		call UseAbility "${InfuseHealth}"
		if ${Return}
		{
			wait 10
			return TRUE
		}
	}
	elseif ${Group[${GroupNumber}].Class.Equal[Sorcerer]}
	{
		call UseAbility "${InfuseHealth}"
		if ${Return}
		{
			wait 10
			return TRUE
		}
	}
	elseif ${Group[${GroupNumber}].Class.Equal[Druid]}
	{
		call UseAbility "${InfuseHealth}"
		if ${Return}
		{
			wait 10
			return TRUE
		}
	}
	elseif ${Group[${GroupNumber}].Class.Equal[Necromancer]}
	{
		call UseAbility "${InfuseHealth}"
		if ${Return}
		{
			wait 10
			return TRUE
		}
	}
	elseif ${Group[${GroupNumber}].Class.Equal[Blood Mage]}
	{
		call UseAbility "${InfuseHealth}"
		if ${Return}
		{
			wait 10
			return TRUE
		}
	}
	else
	{
		call UseAbility "${BloodGift}"
		if ${Return}
		{
			wait 10
			return TRUE
		}
	}
	
	;; if we got this far then we didn't heal anyone
	return FALSE
}
