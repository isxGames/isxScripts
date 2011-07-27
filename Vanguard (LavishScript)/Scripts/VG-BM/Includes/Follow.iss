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
				vgecho Following [${FollowName}]
				wait 1
				variable bool WeAreNotMoving = TRUE
				while !${isPaused} && ${doFollow} && ${Pawn[name,${FollowName}](exists)} && ${Pawn[name,${FollowName}].Distance}>=4 && ${Pawn[name,${FollowName}].Distance}<45
				{
					Pawn[name,${FollowName}]:Face
					VG:ExecBinding[moveforward]
					WeAreNotMoving:Set[FALSE]
				}
				vgecho Stoped Following [${FollowName}]
				;; if we are not moving then start moving
				if !${WeAreNotMoving}
				{
					VG:ExecBinding[moveforward,release]
				}
			}
		}
	}
}
