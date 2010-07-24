;===================================================
;===               FOLLOW                       ====
;===================================================
function Follow()
{
	if !${doFollow}
	{
		Move:Stop
		return
	}

	if !${Me.InCombat}
	{
		if ${Pawn[name,${FollowName}](exists)}
		{
			if ${Pawn[name,${FollowName}].Distance}>5 && ${Pawn[name,${FollowName}].Distance}<100
			{
				Face:Pawn[${Pawn[id,${FollowID}].ID},FALSE]
				Move:Pawn[${Pawn[id,${FollowID}].ID},4]
				return
			}
			Move:Stop
		}
		return
	}
	if ${Me.InCombat}
	{
		if ${Pawn[name,${FollowName}](exists)}
		{
			if ${Pawn[name,${FollowName}].Distance}>15 && ${Pawn[name,${FollowName}].Distance}<100
			{
				Face:Pawn[${Pawn[id,${FollowID}].ID},FALSE]
				Move:Pawn[${Pawn[id,${FollowID}].ID},10]
				return
			}
			Move:Stop
		}
		return
	}
}
