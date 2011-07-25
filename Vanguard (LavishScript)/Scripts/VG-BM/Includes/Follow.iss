;===================================================
;===               FOLLOW                       ====
;===================================================
function Follow()
{
	if ${doFollow} && !${isPaused}
	{
		if ${Pawn[name,${FollowName}](exists)}
		{
			if ${Pawn[name,${FollowName}].Distance}>10
			{
				variable bool WeAreNotMoving = TRUE
				while !${isPaused} && ${Pawn[name,${FollowName}](exists)} && ${Pawn[name,${FollowName}].Distance}>=4 && ${Pawn[name,${FollowName}].Distance}<45
				{
					Pawn[name,${FollowName}]:Face
					VG:ExecBinding[moveforward]
					WeAreNotMoving:Set[FALSE]
				}
				;; if we are not moving then start moving
				if !${WeAreNotMoving}
				{
					VG:ExecBinding[moveforward,release]
				}
			}
		}

		if ${Me.InCombat} && ${Me.Target(exists)} && ${Me.TargetHealth}<95
		{	
			;Face:Pawn[${Me.Target.ID}]
			;if ${Me.Target.Distance.Int}<=1
			;{
			;	VGExecute /walk
			;	while ${Me.Target(exists)} && ${Me.Target.Distance.Int}<=1
			;	{
			;		Face:Pawn[${Me.Target.ID}]
			;		VG:ExecBinding[movebackward]
			;	}
			;	VG:ExecBinding[movebackward,release]
			;	VGExecute /run
			;}
		}
	}
	else
	{
		;; call this once or as many times you want
		Move:Stop
	}
}
