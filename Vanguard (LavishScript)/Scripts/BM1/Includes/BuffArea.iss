;===================================================
;===          BUFF AREA SUBROUTINE              ====
;===================================================
variable index:string PC

function BuffArea()
{
	doBuffArea:Set[FALSE]
	variable string temp

	;-------------------------------------------
	; Cycle through all PC in area and and them to our list to be buffed
	;-------------------------------------------
	for (i:Set[1] ; ${i}<=${VG.PawnCount} && ${Pawn[${i}].Distance}<25 ; i:Inc)
	{
		if ${Pawn[${i}].Type.Equal[pc]} || ${Pawn[${i}].Type.Equal[Group Member]}
		{
			if ${Pawn[${i}].HaveLineOfSightTo} && ${Pawn[${i}].Level}>43
			{
				PC:Insert[${Pawn[${i}].Name}]
				;EchoIt "*Adding ${Pawn[${i}].Name}"
			}
		}
	}

	;-------------------------------------------
	; Cycle through all PC and buff them
	;-------------------------------------------
	for (i:Set[1] ; ${PC[${i}](exists)} ; i:Inc)
	{
		temp:Set[${PC[${i}]}]
		if !${Pawn[exactname,${temp}](exists)}
		{
			;PC:Remove[${i}]
			;PC:Collapse
			continue
		}

		EchoIt "[${i}] Checking buffs on ${temp}"

		;; Offensive target our PC
		VGExecute "/targetoffensive ${temp}"
		wait 15 ${Me.TargetBuff[${ConstructsAugmentation}](exists)}

		;; Use the LVL 51+ BUFF
		if ${Me.TargetBuff[${ConstructsAugmentation}](exists)}
		{
			VGExecute "/cleartargets"
			wait 15 !${Me.TargetBuff[${ConstructsAugmentation}](exists)}
			;PC:Remove[${i}]
			;PC:Collapse
			continue
		}
		;; cast the buff if it does not exist
		if !${Me.TargetBuff[${ConstructsAugmentation}](exists)}
		{
			Pawn[exactname,${temp}]:Target
			wait 5 ${Me.DTarget.Name.Find[${temp}]}
			call UseAbility "${ConstructsAugmentation}"
			if ${Return}
			{
				EchoIt "[${i}] Buffed: ${Me.DTarget.Name}"
				VGExecute "/cleartargets"
				wait 3
				;PC:Remove[${i}]
				;PC:Collapse
				continue
			}
		}
		;; sometimes it does not take so try again
		Pawn[${PC[${i}]}]:Target
		wait 5 ${Me.DTarget.Name.Find[${temp}]}
		call UseAbility "${ConstructsAugmentation}"
		if ${Return}
		{
			EchoIt "[${i}] Buffed: ${Me.DTarget.Name}"
			VGExecute "/cleartargets"
			wait 3
			;PC:Remove[${i}]
			;PC:Collapse
			continue
		}
		;PC:Remove[${i}]
		;PC:Collapse
	}

	;-------------------------------------------
	; Establish Blood Feast - Get 10% of damage from allies returned back to me as health
	;-------------------------------------------
	if ${Me.Ability[Blood Feast](exists)} && !${Me.Effect[Blood Feast](exists)}
	{
		wait 10 ${Me.Ability[Blood Feast].IsReady}
		call UseAbility "Blood Feast"
		if ${Return}
		{
			wait 10 ${Me.Effect[Blood Feast](exists)}
		}
	}

	;; Recast this
	Pawn[Me]:Target
	wait 1
	call UseAbility "${SeraksMantle}"
	while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
	{
		wait 1
	}

	;; Recast this
	Pawn[Me]:Target
	wait 1
	call UseAbility "${ConstructsAugmentation}"
	while ${Me.IsCasting} || !${Me.Ability["Torch"].IsReady}
	{
		wait 1
	}
	PC:Clear
}


