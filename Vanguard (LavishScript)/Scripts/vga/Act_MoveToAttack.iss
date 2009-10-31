;********************************************
function MoveToTarget()
{
	if ${doMoveToTarget}
	{
		if ${Me.Target.Distance} > 4
			{
			actionlog "Moving to Melee"
			call movetoobject ${Me.Target.ID} 4 1
			IsFollowing:Set[FALSE]
			}
		if ${Me.Target.Distance} < 5 && ${DoAttackPosition} && ${tankpawn.Equal[${Me.TargetOfTarget}]}
			{
			call CheckAttackPosition
			}
		if ${Me.Target.Distance} < 1
			{
			while ${Me.Target.Distance} < 1
				{
				face ${Me.Target.X} ${Me.Target.Y}
				VG:ExecBinding[movebackward]	
				wait 1
				IsFollowing:Set[FALSE]				
				}
			VG:ExecBinding[movebackward,release]
			}
	}
	return
}

;********************************************
function CheckAttackPosition()
{
		if ${DoAttackPositionFront}
			{
			echo Move front ${AttackPosition.TargetAngle}
			if ${AttackPosition.TargetAngle} < 45
				call SlideL Front
			if ${AttackPosition.TargetAngle} > 45 && ${AttackPosition.TargetAngle} < 135 && ${AttackPosition.TargetSide.Equal[Left]}		
				call SlideL Front
			if ${AttackPosition.TargetAngle} > 135
				return
			if ${AttackPosition.TargetAngle} > 45 && ${AttackPosition.TargetAngle} < 135 && ${AttackPosition.TargetSide.Equal[Right]}	
				call SlideR Front
			}
		if ${DoAttackPositionLeft}
			{
			if ${AttackPosition.TargetAngle} < 45
				call SlideL Left
			if ${AttackPosition.TargetAngle} > 45 && ${AttackPosition.TargetAngle} < 135 && ${AttackPosition.TargetSide.Equal[Left]}
				return
			if ${AttackPosition.TargetAngle} > 135
				call SlideR Left
			if ${AttackPosition.TargetAngle} > 45 && ${AttackPosition.TargetAngle} < 135 && ${AttackPosition.TargetSide.Equal[Right]}	
				call SlideR Left
			}
		if ${DoAttackPositionRight}
			{
			if ${AttackPosition.TargetAngle} < 45
				call SlideR Right
			if ${AttackPosition.TargetAngle} > 45 && ${AttackPosition.TargetAngle} < 135 && ${AttackPosition.TargetSide.Equal[Left]}
				call SlideL Right
			if ${AttackPosition.TargetAngle} > 135
				call SlideL Right
			if ${AttackPosition.TargetAngle} > 45 && ${AttackPosition.TargetAngle} < 135 && ${AttackPosition.TargetSide.Equal[Right]}	
				return
			}
		if ${DoAttackPositionBack}
			{
			if ${AttackPosition.TargetAngle} < 45
				return
			if ${AttackPosition.TargetAngle} > 45 && ${AttackPosition.TargetAngle} < 135 && ${AttackPosition.TargetSide.Equal[Left]}
				call SlideR Back
			if ${AttackPosition.TargetAngle} > 135
				call SlideL Back
			if ${AttackPosition.TargetAngle} > 45 && ${AttackPosition.TargetAngle} < 135 && ${AttackPosition.TargetSide.Equal[Right]}
				call SlideL Back
			}
}
;********************************************
function SlideR(string SlideTo)
{
	Me:Sprint[30]
	If ${SlideTo.Equal[Back]}
		{
		while ${AttackPosition.TargetAngle} > 45
			{
			VG:ExecBinding[straferight]
			wait 1
			face ${Me.Target.X} ${Me.Target.Y}
			wait 1
			IsFollowing:Set[FALSE]	
			}
		VG:ExecBinding[straferight,release]
		}
	If ${SlideTo.Equal[Right]}
		{
		while ${AttackPosition.TargetAngle} < 45 || ${AttackPosition.TargetAngle} > 135
			{
			VG:ExecBinding[straferight]
			wait 1
			face ${Me.Target.X} ${Me.Target.Y}
			wait 1
			IsFollowing:Set[FALSE]
			}
		VG:ExecBinding[straferight,release]
		}
	If ${SlideTo.Equal[Front]}
		{
		while ${AttackPosition.TargetAngle} < 135
			{
			VG:ExecBinding[straferight]
			wait 1
			face ${Me.Target.X} ${Me.Target.Y}
			wait 1
			IsFollowing:Set[FALSE]
			}
		VG:ExecBinding[straferight,release]
		}
	If ${SlideTo.Equal[Left]}
		{
		while ${AttackPosition.TargetAngle} < 45 || ${AttackPosition.TargetAngle} > 135
			{
			VG:ExecBinding[straferight]
			wait 1
			face ${Me.Target.X} ${Me.Target.Y}
			wait 1
			IsFollowing:Set[FALSE]
			}
		VG:ExecBinding[straferight,release]
		}
	Me:Sprint
}

;********************************************
function SlideL(string SlideTo)
{
	Me:Sprint[30]
	If ${SlideTo.Equal[Back]}
		{
		while ${AttackPosition.TargetAngle} > 45		
			{
			VG:ExecBinding[strafeleft]
			wait 1
			face ${Me.Target.X} ${Me.Target.Y}
			wait 1
			IsFollowing:Set[FALSE]
			}
		VG:ExecBinding[strafeleft,release]
		}
	If ${SlideTo.Equal[Right]}
		{
		while ${AttackPosition.TargetAngle} < 45 || ${AttackPosition.TargetAngle} > 135
			{
			VG:ExecBinding[strafeleft]
			wait 1
			face ${Me.Target.X} ${Me.Target.Y}
			wait 1
			IsFollowing:Set[FALSE]
			}
		VG:ExecBinding[strafeleft,release]
		}
	If ${SlideTo.Equal[Front]}
		{
		while ${AttackPosition.TargetAngle} < 135
			{
			VG:ExecBinding[strafeleft]
			wait 1
			face ${Me.Target.X} ${Me.Target.Y}
			wait 1
			IsFollowing:Set[FALSE]
			}
		VG:ExecBinding[strafeleft,release]
		}
	If ${SlideTo.Equal[Left]}
		{
		while ${AttackPosition.TargetAngle} < 45 || ${AttackPosition.TargetAngle} > 135
			{
			VG:ExecBinding[strafeleft]
			wait 1
			face ${Me.Target.X} ${Me.Target.Y}
			wait 1
			IsFollowing:Set[FALSE]
			}
		VG:ExecBinding[strafeleft,release]
		}
	Me:Sprint
}
