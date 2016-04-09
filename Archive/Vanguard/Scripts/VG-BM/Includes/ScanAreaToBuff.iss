;===================================================
;===          SCAN AREA TO BUFF                 ====
;===================================================
function ScanAreaToBuff()
{
	;; Check other players 10m and buff them if needed
	for (i:Set[1] ; ${i}<=${VG.PawnCount} ; i:Inc)
	{
		if ${Pawn[${i}].Type.Equal[pc]} || ${Pawn[${i}].Type.Equal[Group Member]}
		{
			if ${Pawn[${i}].Distance}<20 && ${Pawn[${i}].HaveLineOfSightTo} 
			{
				;; For now, we aren't gonna buff low level toons
				if ${Pawn[${i}].Level}<35
				{
					continue
				}
	
				;; Offensive target our PC
				VGExecute "/targetoffensive ${Pawn[${i}].Name}"
				wait 10 ${Me.TargetBuff[${ConstructsAugmentation}](exists)} || ${Me.TargetBuff[Inspirit](exists)}
				

				;; Use ALL-IN-ONE BUFF
				if ${Pawn[${i}].Level}>=35 && ${Pawn[${i}].Level}<=43
				{
					if ${Me.TargetBuff[Inspirit](exists)}
					{
						VGExecute "/cleartargets"
						wait 5 !${Me.TargetBuff[Inspirit](exists)}
						continue
					}
					if !${Me.TargetBuff[Inspirit](exists)}
					{
						Pawn[${i}]:Target
						waitframe
						CurrentAction:Set[Buffing ${Me.DTarget.Name}]
						call UseAbility "${FavorOfTheLifeGiver}" "BUFFED ${Me.DTarget.Name}"
						while ${Me.IsCasting} && ${VG.InGlobalRecovery}
						{
							waitframe
						}
						CurrentAction:Set[Waiting]
						VGExecute "/cleartargets"
						waitframe
						continue
					}
				}

				;; Use the LVL 51+ BUFF
				if ${Me.TargetBuff[${ConstructsAugmentation}](exists)}
				{
					VGExecute "/cleartargets"
					wait 5 !${Me.TargetBuff[${ConstructsAugmentation}](exists)}
					continue
				}

				if !${Me.TargetBuff[${ConstructsAugmentation}](exists)}
				{
					Pawn[${i}]:Target
					waitframe
					CurrentAction:Set[Buffing ${Me.DTarget.Name}]
					call UseAbility "${ConstructsAugmentation}" "BUFFED ${Me.DTarget.Name}"
					while ${Me.IsCasting} && ${VG.InGlobalRecovery}
					{
						waitframe
					}
					CurrentAction:Set[Waiting]
					VGExecute "/cleartargets"
					waitframe
				}
			}
		}
	}

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
	
	;; Recast this
	Pawn[Me]:Target
	CurrentAction:Set[Waiting]
	call UseAbility "${SeraksMantle}"
	while ${Me.IsCasting} || ${VG.InGlobalRecovery}>0
	{
		waitframe
	}

	;; Recast this
	Pawn[Me]:Target
	CurrentAction:Set[Waiting]
	call UseAbility "${ConstructsAugmentation}"
	while ${Me.IsCasting} || ${VG.InGlobalRecovery}>0
	{
		waitframe
	}
	CurrentAction:Set[Waiting]
}
