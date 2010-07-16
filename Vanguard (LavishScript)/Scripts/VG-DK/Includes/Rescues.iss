;===================================================
;===            RESCUES                         ====
;===================================================
function Rescues()
{
	;if !${doRescues} || !${Me.InCombat} || ${TargetsTarget.Equal[No Target]}
	if !${doRescues} || !${Me.InCombat} || !${Me.Target(exists)}
	{
		return
	}

	;; Always assist offensive target - sets DTarget
	VGExecute /assistoffensive
	
	if !${Me.ToT.Name.Find[${Me.FName}]} && !${Me.TargetBuff["Immunity: Force Target"](exists)}
	{
	
		;; allow time to update
		waitframe

		; Force target to attack me for 10s or 5 attacks
		call UseAbility "${SeethingHatred}" "- RESCUED ${Me.ToT.Name}"
		if ${Return}
		{
			return
		}

		; Force target to attack me for 4s or 2 attacks and adds HATRED
		call UseAbility "${Scourge}" "- RESCUED ${Me.ToT.Name}"
		if ${Return}
		{
			return
		}

		; Force all targets to attack me for 10s or 4-8 attacks
		call UseAbility "${NexusOfHatred}" "- RESCUED ${Me.ToT.Name}"
		if ${Return}
		{
			return
		}
	}
}
