/*
	Code by don'tdoit
  Math in function Angle by ${Allen}

	Put into your scripts/common folder.
	To use add this to the top of your script:
		#include ./common/faceslow.iss
	Then:
		call facemob ${yourMobIDvar} ##
		or
		call faceloc ${X} ${Y} ##
	where ## is the precision of how close you want to face.
	
	Version:
	v1.0 - initial release

*/

variable bool AngDebug = FALSE
variable float Dist
variable int Angle
variable int StartAngle
variable float AbsAngle /* Absolute angle of mob starting from North */
variable float MobRise /* Find absolute (x,y) values of mob with our location considered (0,0) */
variable float MobRun
variable int Quadrant /* quadrant relative to our location with us facing "north" :: either 1,2,3,4,0 for origin*/
variable float maxRight
variable float maxLeft
variable float mobX
variable float mobY

function facemob(int64 MobID,float precision)
{
	if ${Pawn[id,${MobID}](exists)}
	{
		mobX:Set[${Pawn[id,${MobID}].X}]
		mobY:Set[${Pawn[id,${MobID}].Y}]
	}
	maxRight:Set[${Math.Calc[180-${precision}]}]
	maxLeft:Set[${Math.Calc[180+${precision}]}]
	call faceslow ${mobX} ${mobY} ${maxRight} ${maxLeft} 5
}

function faceloc(float locX, float locY, float precision, int faceTimeOut)
{
	maxRight:Set[${Math.Calc[180-${precision}]}]
	maxLeft:Set[${Math.Calc[180+${precision}]}]

	;call DebugOut "VG:faceloc: locX: ${locX}  facY: ${locY}  maxR: ${maxRight}  maxL: ${maxLeft}  :: ${faceTimeOut}"

	call faceslow ${locX} ${locY} ${maxRight} ${maxLeft} ${faceTimeOut}
}

function faceslow(float facX, float facY, float Rt, float Lt, int iFacTimeOut)
{
	;set BailOut timer (5 seconds)
	variable time bailOut

	;bailOut:Set[${Math.Calc[${Time.Timestamp} + ${iFacTimeOut}]}]
	bailOut:Set[${Time.Timestamp}]

	;call DebugOut "VG:FaceSlow: facX: ${facX}  facY: ${facY}  Rt: ${Rt}  Lt: ${Lt}  :: ${bailOut.Timestamp} :: ${Time.Timestamp}"

	do
	{
		call Angle ${facX} ${facY}

		if ${AngDebug}
		{
			call DebugOut "Angle: ${Angle}, AbsAngle: ${AbsAngle}"
		}
		if (${AbsAngle} <= 360 && ${AbsAngle} > ${Lt})
		{
			VG:ExecBinding[turnleft]
			;VG:ExecBinding[moveforward,release]
		}
		if (${AbsAngle} >= 0 && ${AbsAngle} < ${Rt})
		{
			VG:ExecBinding[turnright]
			;VG:ExecBinding[moveforward,release]
		}
		waitframe
	}
	while (${AbsAngle} > ${Lt} || ${AbsAngle} < ${Rt}) && ${isRunning} && (${Math.Calc[${Time.Timestamp} - ${bailOut.Timestamp}]} < ${iFacTimeOut})

	VG:ExecBinding[turnleft,release]
	VG:ExecBinding[turnright,release]

	; Make sure we are facing the right way
	Face ${facX} ${facY}

	if (${Math.Calc[${Time.Timestamp} - ${bailOut.Timestamp}]} > ${iFacTimeOut})
		call DebugOut "VGCraft:: faceslow timeout!"
}

function Angle(float angX, float angY)
{
	Dist:Set[${Math.Distance[${Me.X},${Me.Y},${angX},${angY}]}]
	if ( ${Dist} <= 0 )
		Dist:Set[1]
	Angle:Set[${Math.Acos[(${angY} - ${Me.Y})/${Dist}]}]
	MobRise:Set[${Math.Calc[${angY} - ${Me.Y}]}]
	MobRun:Set[${Math.Calc[${angX} - ${Me.X}]}]

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
}