;===================================================
;===          BUFF AREA SUBROUTINE              ====
;===================================================

function BuffArea()
{
	variable string temp
	variable int TotalPawns
	variable index:pawn CurrentPawns
	variable index:string PC
	TotalPawns:Set[${VG.GetPawns[CurrentPawns]}]
	doBuffArea:Set[FALSE]
	PerformAction:Set[BuffArea]
	
	;-------------------------------------------
	; Cycle through all PC in area and add them to our list to be buffed
	;-------------------------------------------
	for (i:Set[1] ;  ${i}<=${TotalPawns} && ${CurrentPawns.Get[${i}].Distance}<25 ; i:Inc)
	{
		if ${CurrentPawns.Get[${i}].Type.Equal[pc]} || ${CurrentPawns.Get[${i}].Type.Equal[Group Member]}
		{
			if ${CurrentPawns.Get[${i}].HaveLineOfSightTo} && ${CurrentPawns.Get[${i}].Level}>43
			{
				PC:Insert[${CurrentPawns.Get[${i}].Name}]
				EchoIt "*Adding ${CurrentPawns.Get[${i}].Name}"
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


