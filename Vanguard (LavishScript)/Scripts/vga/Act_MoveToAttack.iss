;********************************************
function MoveToTarget()
{
	if ${doMoveToTarget}
	{
		if ${Me.Target.Distance} > 4
			{
			actionlog "Moving to Melee"
			call movetoobject ${Me.Target.ID} 4 1
			}
		if ${Me.Target.Distance} < 5 && ${DoAttackPosition}
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
				{
				call OtherSide Front
				}
			if ${AttackPosition.TargetAngle} > 45 && ${AttackPosition.TargetAngle} < 135 && ${AttackPosition.TargetSide.Equal[Left]}		
				{
				call SlideL Front
				}
			if ${AttackPosition.TargetAngle} > 135
				return
			if ${AttackPosition.TargetAngle} > 45 && ${AttackPosition.TargetAngle} < 135 && ${AttackPosition.TargetSide.Equal[Right]}	
				{ 
				call SlideR Front
				}
			}
		if ${DoAttackPositionLeft}
			{
			if ${AttackPosition.TargetAngle} < 45
				{ 
				echo slider to left
				call SlideL Left
				}
			if ${AttackPosition.TargetAngle} > 45 && ${AttackPosition.TargetAngle} < 135 && ${AttackPosition.TargetSide.Equal[Left]}
				{ 
				return
				}
			if ${AttackPosition.TargetAngle} > 135
				{ 
				echo slide left to left
				call SlideR Left
				}
			if ${AttackPosition.TargetAngle} > 45 && ${AttackPosition.TargetAngle} < 135 && ${AttackPosition.TargetSide.Equal[Right]}	
				{ 
				echo otherside to left
				call OtherSide Left
				}
			}
		if ${DoAttackPositionRight}
			{
			if ${AttackPosition.TargetAngle} < 45
				call SlideR Right
			if ${AttackPosition.TargetAngle} > 45 && ${AttackPosition.TargetAngle} < 135 && ${AttackPosition.TargetSide.Equal[Left]}
				call OtherSide Right
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
				call OtherSide Back
			if ${AttackPosition.TargetAngle} > 45 && ${AttackPosition.TargetAngle} < 135 && ${AttackPosition.TargetSide.Equal[Right]}
				call SlideL Back
			}
}
;********************************************
function SlideR(string SlideTo)
{
	If ${SlideTo.Equal[Back]}
		{
		while ${AttackPosition.TargetAngle} > 45
			{
			VG:ExecBinding[straferight]
			wait 1
			face ${Me.Target.X} ${Me.Target.Y}
			wait 1
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
			}
		VG:ExecBinding[straferight,release]
		}
}
;********************************************
function OtherSide(string SlideTo)
{
	If ${SlideTo.Equal[Back]}
		{
		face ${Me.Target.X} ${Me.Target.Y}
		while ${AttackPosition.TargetAngle} > 45
			{
			VG:ExecBinding[moveforward]
			wait 4
			face ${Me.Target.X} ${Me.Target.Y}
			wait 1
			}
		VG:ExecBinding[moveforward,release]
		face ${Me.Target.X} ${Me.Target.Y}
		}
	If ${SlideTo.Equal[Right]}
		{
		face ${Me.Target.X} ${Me.Target.Y}
		while ${AttackPosition.TargetSide.Equal[Left]}
			{
			VG:ExecBinding[moveforward]
			wait 4
			face ${Me.Target.X} ${Me.Target.Y}
			wait 1
			}
		wait 2
		VG:ExecBinding[moveforward,release]
		face ${Me.Target.X} ${Me.Target.Y}
		}
	If ${SlideTo.Equal[Front]}
		{
		face ${Me.Target.X} ${Me.Target.Y}
		echo need to move to front from opposite side
		while ${AttackPosition.TargetAngle} < 135
			{
			VG:ExecBinding[moveforward]
			wait 4
			face ${Me.Target.X} ${Me.Target.Y}
			wait 1
			}
		VG:ExecBinding[moveforward,release]
		face ${Me.Target.X} ${Me.Target.Y}
		}
	If ${SlideTo.Equal[Left]}
		{
		face ${Me.Target.X} ${Me.Target.Y}
		while ${AttackPosition.TargetSide.Equal[Right]}
			{
			VG:ExecBinding[moveforward]
			wait 4
			face ${Me.Target.X} ${Me.Target.Y}
			wait 1
			}
		VG:ExecBinding[moveforward,release]
		face ${Me.Target.X} ${Me.Target.Y}
		}
}
;********************************************
function SlideL(string SlideTo)
{
	If ${SlideTo.Equal[Back]}
		{
		while ${AttackPosition.TargetAngle} > 45		
			{
			VG:ExecBinding[strafeleft]
			wait 1
			face ${Me.Target.X} ${Me.Target.Y}
			wait 1
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
			}
		VG:ExecBinding[strafeleft,release]
		}
}
