;===================================================
;===            RESCUES                         ====
;===================================================
function HandleRescues()
{
	;if !${doRescues} || !${Me.InCombat} || ${TargetsTarget.Equal[No Target]}
	if !${doRescues} || !${Me.InCombat} || !${Me.Target(exists)}
	{
		return
	}

	;; Always assist offensive target - sets DTarget
	VGExecute /assistoffensive

	variable string temp
	
	;; update our display
	temp:Set[${Me.ToT.Name}]
	if ${temp.Equal[NULL]}
	{
		return
	}

	;; allow time to update
	waitframe
	
	if !${Me.ToT.Name.Find[${Me.FName}]} && !${Me.TargetBuff["Immunity: Force Target"](exists)}
	{

		if ${doSeethingHatred}
		{
			; Force target to attack me for 10s or 5 attacks
			call UseAbility "${SeethingHatred}" "- RESCUED ${Me.ToT.Name}"
			if ${Return}
			{
				return
			}
		}
		
		if ${doScourge}
		{
			; Force target to attack me for 4s or 2 attacks and adds HATRED
			call UseAbility "${Scourge}" "- RESCUED ${Me.ToT.Name}"
			if ${Return}
			{
				return
			}
		}

		if ${doNexusOfHatred}
		{
			; Force all targets to attack me for 10s or 4-8 attacks
			call UseAbility "${NexusOfHatred}" "- RESCUED ${Me.ToT.Name}"
			if ${Return}
			{
				return
			}
		}
	}
}
