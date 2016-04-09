/*
Code by don'tdoit
Math in function Angle by ${Allen}

Put into your scripts/common folder.
To use add this to the top of your script:
#include ./include/faceslow.iss
Then:
call facemob ${yourMobIDvar} ##
or
call faceloc ${X} ${Y} ##
where ## is the precision of how close you want to face.

Version:
v1.2 - Lessen timer and fixed random twirling
v1.1 - Tweaked to work smoother by Zandros
v1.0 - initial release
*/

/* Toggle this on or off in your scripts */
variable bool DoFaceSlow = TRUE

function:bool facemob(int64 MobID,float precision=15)
{
	;-------------------------------------------
	; return if we do not want to face slowly
	;-------------------------------------------
	if !${DoFaceSlow}
	return FALSE

	variable float mobX
	variable float mobY
	variable float maxLeft
	variable float maxRight

	;-------------------------------------------
	; Always double-check our variables
	;-------------------------------------------
	if ${precision}>180
	precision:Set[180]
	if ${Pawn[id,${MobID}](exists)}
	{
		mobX:Set[${Pawn[id,${MobID}].X}]
		mobY:Set[${Pawn[id,${MobID}].Y}]
	}
	maxLeft:Set[${Math.Calc[180+${precision}]}]
	maxRight:Set[${Math.Calc[180-${precision}]}]

	;-------------------------------------------
	; Lets start turning slowly
	;-------------------------------------------
	call faceslow ${mobX} ${mobY} ${maxRight} ${maxLeft}
	if ${Return}
	return TRUE
	return FALSE
}

function:bool faceloc(float locX, float locY, float precision=15)
{
	;-------------------------------------------
	; return if we do not want to face slowly
	;-------------------------------------------
	if !${DoFaceSlow}
	return FALSE

	variable float maxLeft
	variable float maxRight

	;-------------------------------------------
	; Always double-check our variables
	;-------------------------------------------
	if ${precision}>180
	precision:Set[180]
	maxLeft:Set[${Math.Calc[180+${precision}]}]
	maxRight:Set[${Math.Calc[180-${precision}]}]

	;-------------------------------------------
	; Lets start turning slowly
	;-------------------------------------------
	call faceslow ${locX} ${locY} ${maxRight} ${maxLeft}
	if ${Return}
	return TRUE
	return FALSE
}

function:bool faceslow(float facX, float facY, float Rt, float Lt)
{
	variable int bailOut
	variable float AbsAngle

	;-------------------------------------------
	; Always double-check our variables
	;-------------------------------------------
	bailOut:Set[${Math.Calc[${LavishScript.RunningTime}+(1500)]}]

	;-------------------------------------------
	; Modified:  Only turn if we are not within our LT/RT angle
	;-------------------------------------------
	call Angle ${facX} ${facY}
	AbsAngle:Set[${Return}]
	if (${AbsAngle} > ${Lt} || ${AbsAngle} < ${Rt})
	{
		;-------------------------------------------
		; Modified:  Keep turning until we reached within 15 degrees of target or bailout timer runs out (1.5 sec)
		;-------------------------------------------
		while (${AbsAngle}>195 || ${AbsAngle}<165)  && (${LavishScript.RunningTime}<${bailOut}) && !${isPaused}
		{
			;-------------------------------------------
			; Modified:  Get direction and start turning to within 15 degrees of target
			;-------------------------------------------
			call Angle ${facX} ${facY}
			AbsAngle:Set[${Return}]

			if (${AbsAngle} <= 360 && ${AbsAngle} > 195)
			{
				;vgecho "VG: FaceSlow - Turn Left"
				VG:ExecBinding[turnright,release]
				VG:ExecBinding[turnleft]
				while (${AbsAngle} <= 360 && ${AbsAngle} > 195)
				{
					if ${LavishScript.RunningTime}>${bailOut}
						break
					call Angle ${facX} ${facY}
					AbsAngle:Set[${Return}]
				}
				VG:ExecBinding[turnleft,release]
			}
			if (${AbsAngle} >= 0 && ${AbsAngle} < 165)
			{
				;vgecho "VG: FaceSlow - Turn Right"
				VG:ExecBinding[turnleft,release]
				VG:ExecBinding[turnright]
				while (${AbsAngle} >= 0 && ${AbsAngle} < 165)
				{
					if ${LavishScript.RunningTime}>${bailOut}
						break
					call Angle ${facX} ${facY}
					AbsAngle:Set[${Return}]
				}
				VG:ExecBinding[turnright,release]
			}

			call Angle ${facX} ${facY}
			AbsAngle:Set[${Return}]
		}

		;-------------------------------------------
		; Stop all turning!
		;-------------------------------------------
		VG:ExecBinding[turnleft,release]
		VG:ExecBinding[turnright,release]

		;-------------------------------------------
		; Return Successful
		;-------------------------------------------
		if ${LavishScript.RunningTime}>${bailOut}
		vgecho "VG: FaceSlow - BailedOut Timer Exceeded"
		return TRUE
	}
	return FALSE
}

function:float Angle(float angX, float angY)
{
	variable int Angle
	variable float Dist
	variable float AbsAngle /* Absolute angle of mob starting from North */
	variable float MobRise /* Find absolute (x,y) values of mob with our location considered (0,0) */
	variable float MobRun
	variable int Quadrant /* quadrant relative to our location with us facing "north" :: either 1,2,3,4,0 for origin*/

	Angle:Set[${Math.Calc[${angY} - ${Me.Y}]}]
	MobRise:Set[${Math.Calc[${angY} - ${Me.Y}]}]
	MobRun:Set[${Math.Calc[${angX} - ${Me.X}]}]

	;; Patch Angle if Dist>1 "Should fix the error - Nope"
	Dist:Set[${Math.Distance[${Me.X},${Me.Y},${angX},${angY}]}]
	if ${Dist}>1
	Angle:Set[${Math.Acos[(${angY} - ${Me.Y})/${Dist}]}]

	if (${MobRise} > 0 && ${MobRun} > 0)
	{
		Quadrant:Set[1]
	}
	elseif (${MobRise} > 0 && ${MobRun} < 0)
	{
		Quadrant:Set[2]
	}
	elseif (${MobRise} < 0 && ${MobRun} < 0)
	{
		Quadrant:Set[3]
	}
	elseif (${MobRise} < 0 && ${MobRun} > 0)
	{
		Quadrant:Set[4]
	}
	else
	{
		Quadrant:Set[0]
	}
	if (${Quadrant} == 2 || ${Quadrant} == 3)
	{
		Angle:Set[${Math.Calc[360 - ${Angle}]}]
	}
	AbsAngle:Set[${Math.Calc[(${Me.Heading} + ${Angle}) % 360]}]
	return ${AbsAngle}
}




















