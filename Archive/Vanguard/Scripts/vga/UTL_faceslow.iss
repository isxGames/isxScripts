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

variable(script) bool AngDebug = FALSE
variable(script) float Dist
variable(script) int Angle
variable(script) float AbsAngle /* Absolute angle of mob starting from North */
variable(script) float MobRise /* Find absolute (x,y) values of mob with our location considered (0,0) */
variable(script) float MobRun
variable(script) int Quadrant /* quadrant relative to our location with us facing "north" :: either 1,2,3,4,0 for origin*/
variable(script) float maxRight
variable(script) float maxLeft
variable(script) float mobX
variable(script) float mobY

function facemob(int64 MobID,float precision)
{
	if ${Pawn[id,${MobID}](exists)}
	{
		mobX:Set[${Pawn[id,${MobID}].X}]
		mobY:Set[${Pawn[id,${MobID}].Y}]
	}
	maxRight:Set[${Math.Calc[180-${precision}]}]
	maxLeft:Set[${Math.Calc[180+${precision}]}]
	call faceslow ${mobX} ${mobY} ${maxRight} ${maxLeft}
}

function faceloc(float locX, float locY, float precision)
{
	maxRight:Set[${Math.Calc[180-${precision}]}]
	maxLeft:Set[${Math.Calc[180+${precision}]}]
	call faceslow ${locX} ${locY} ${maxRight} ${maxLeft}
}

function faceslow(float facX, float facY, float Rt, float Lt)
{
	face ${facX} ${facY}
	/*
	do
	{
	call Angle ${facX} ${facY}
	if ${AngDebug}
	{
	echo Mob Angle -> ${Angle}, AbsAngle -> ${AbsAngle}
	}
	if "${AbsAngle} <= 360 && ${AbsAngle} > ${Lt}"
	{
	VG:ExecBinding[turnleft]
	VG:ExecBinding[moveforward,release]
	}
	if "${AbsAngle} >= 0 && ${AbsAngle} < ${Rt}"
	{
	VG:ExecBinding[turnright]
	VG:ExecBinding[moveforward,release]
	}
	waitframe
	}
	while "${AbsAngle} > ${Lt} || ${AbsAngle} < ${Rt}"
	VG:ExecBinding[turnleft,release]
	VG:ExecBinding[turnright,release]
	*/
}

function Angle(float angX,float angY)
{
	Dist:Set[${Math.Distance[${Me.X},${Me.Y},${angX},${angY}]}]
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

