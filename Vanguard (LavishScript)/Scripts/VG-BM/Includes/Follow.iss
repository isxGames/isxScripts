;===================================================
;===               FOLLOW                       ====
;===================================================
function Follow()
{
	if ${doFollow}
	{
		if !${Me.InCombat}
		{
			if ${Pawn[name,${FollowName}](exists)}
			{
				if ${Pawn[name,${FollowName}].Distance}>7 && ${Pawn[name,${FollowName}].Distance}<100
				{
					Face:Pawn[${Pawn[id,${FollowID}].ID},FALSE]
					Move:Pawn[${Pawn[id,${FollowID}].ID},5]
				}
				else
				{
					Move:Stop
				}
			}
		}

		;; Call this once, if pawn is moving then call it many times
		;; To set a distance to stop at... use the following example:  Move:MovePawn[${Pawn[id,${FollowID}].ID},3]
		
		if ${Me.InCombat} && ${Me.Target(exists)} && ${Me.TargetHealth}<95
		{	
			Face:Pawn[${Me.Target.ID}]
			if ${Me.Target.Distance}>10
			{
				Move:Pawn[${Me.Target.ID},5]
			}
			elseif ${Me.Target.Distance.Int}<=1
			{
				VGExecute /walk
				while ${Me.Target(exists)} && ${Me.Target.Distance.Int}<=1
				{
					Face:Pawn[${Me.Target.ID}]
					VG:ExecBinding[movebackward]
				}
				VG:ExecBinding[movebackward,release]
				VGExecute /run
			}
			else
			{
				;; call this once or as many times you want
				Move:Stop
			}
		}
		;elseif !${Me.InCombat} && ${Pawn[id,${FollowID}].Distance}>10
		;{
		;	Face:Pawn[${Pawn[id,${FollowID}].ID},FALSE]
		;	Move:Pawn[${Pawn[id,${FollowID}].ID},5]
		;}
	}
	else
	{
		;; call this once or as many times you want
		Move:Stop
	}
}
