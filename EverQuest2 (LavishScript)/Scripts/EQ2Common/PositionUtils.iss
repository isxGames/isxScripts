; PositionUtils.iss
;
; Script-defined object type for positioning around actors.
;


#ifndef _PositionUtils_
#define _PositionUtils_

objectdef EQ2Position
{
	; Returns angle 0-180 degrees:
	; 0 == Behind
	; 180 == In front
	; 90 == Directly beside (either side)
	member:float Angle(uint ActorID)
	{
		variable float Retval
		variable float Heading=${Actor[${ActorID}].Heading}
		variable float HeadingTo=${Actor[${ActorID}].HeadingTo}
		Retval:Set[${Math.Calc[${Math.Cos[${Heading}]} * ${Math.Cos[${HeadingTo}]} + ${Math.Sin[${Heading}]} * ${Math.Sin[${HeadingTo}]}]}]
		Retval:Set[${Math.Acos[${Retval}]}]
		return ${Retval}
	}

	; Returns which side of the Actor I am on, Left or Right.
	member:string Side(uint ActorID)
	{
		variable float Side
		variable float Heading=${Actor[${ActorID}].Heading}
		variable float HeadingTo=${Actor[${ActorID}].HeadingTo}
		Side:Set[${Math.Calc[${Math.Cos[${Heading}+90]} * ${Math.Cos[${HeadingTo}]} + ${Math.Sin[${Heading}+90]} * ${Math.Sin[${HeadingTo}]}]}]
		if ${Side}>0
			return Left
		else
			return Right
	}

	; This member will return a point in 3d space at any angle of attack from the
	; Actor passed to it. The returned point will be on the same side as the player's
	; current position, or directly behind/in front of the Actor. Angle should be
	; 0 to 180 (or -0 to -180 if you wish to get a point on the opposite side.)
	member:point3f PointAtAngle(uint ActorID, float Angle, float Distance = 3)
	{
		variable float Heading=${Actor[${ActorID}].Heading}
		Returning.Y:Set[${Actor[${ActorID}].Y}]

		if ${This.Side[${ActorID}].Equal[Right]}
		{
			Angle:Set[-(${Angle})]
		}
		Returning.X:Set[-${Distance} * ${Math.Sin[-(${Heading}+(${Angle}))]} + ${Actor[${ActorID}].X}]
		Returning.Z:Set[${Distance} * ${Math.Cos[-(${Heading}+(${Angle}))]} + ${Actor[${ActorID}].Z}]
		return
	}

	; and this member will return a point in 3d space at any angle of attack from the
	; Actor passed to it, predicting that Actor's position based on their current speed
	; and direction, and the time argument passed to this function.
	member:point3f PredictPointAtAngle(uint ActorID, float Angle, float Seconds=1, float Distance=3)
	{
		variable point3f Velocity

		Velocity:Set[${Actor[${ActorID}].Velocity}]

		Returning:Set[${This.PointAtAngle[${ActorID},${Angle},${Distance}]}]

		Returning.X:Inc[${Velocity.X}*${Seconds}]
		Returning.Y:Inc[${Velocity.Y}*${Seconds}]
		Returning.Z:Inc[${Velocity.Z}*${Seconds}]
		return
	}

	member:float GetBaseMaxRange(uint ActorID)
	{
		return ${Math.Calc[${Actor[${ActorID}].CollisionRadius} * ${Actor[${ActorID}].CollisionScale}]}
	}

	member:float GetMeleeMaxRange(uint ActorID, float PercentMod = 0, float MeleeRange = 2)
	{
		PercentMod:Set[${Math.Calc[(100+${PercentMod})/100]}]
		MeleeRange:Set[${Math.Calc[${MeleeRange}*${PercentMod}]}]
		return ${Math.Calc[${Actor[${ActorID}].CollisionRadius} * ${Actor[${ActorID}].CollisionScale} + ${MeleeRange}]}
	}

	member:float GetSpellMaxRange(uint ActorID, float PercentMod = 0, float SpellRange = 30)
	{
		PercentMod:Set[${Math.Calc[(100+${PercentMod})/100]}]
		SpellRange:Set[${Math.Calc[${SpellRange}*${PercentMod}]}]
		return ${Math.Calc[${Actor[${ActorID}].CollisionRadius} * ${Actor[${ActorID}].CollisionScale} + ${SpellRange}]}
	}

	member:float GetCAMaxRange(uint ActorID, float PercentMod = 0, float CARange = 5)
	{
		PercentMod:Set[${Math.Calc[(100+${PercentMod})/100]}]
		CARange:Set[${Math.Calc[${CARange}*${PercentMod}]}]
		return ${Math.Calc[${Actor[${ActorID}].CollisionRadius} * ${Actor[${ActorID}].CollisionScale} + ${CARange}]}
	}

	member:point3f FindDestPoint(uint ActorID, float minrange, float maxrange, float destangle)
	{
		variable float myspeed
		variable point3f destpoint
		variable point3f destminpoint
		variable point3f destmaxpoint
		;
		; ok which point is closer our min range or max range, will vary depending on our vector to mob
		;
		myspeed:Set[${Math.Calc[${Actor[${ActorID}].Distance2D}/${Me.ToActor.Speed}]}]
		destminpoint:Set[${This.PredictPointAtAngle[${ActorID},${destangle},${myspeed},${minrange}]}]
		destmaxpoint:Set[${This.PredictPointAtAngle[${ActorID},${destangle},${myspeed},${maxrange}]}]

		if ${Math.Distance[${Me.ToActor.Loc},${destminpoint}]}<${Math.Distance[${Me.ToActor.Loc},${destmaxpoint}]}
			destpoint:Set[${destminpoint}]
		else
			destpoint:Set[${destmaxpoint}]

		return ${destpoint}
	}
}



#ifndef _IncludePositionUtils_
function main()
{
	declare PositionUtils EQ2Position global
	while 1
	{
		if ${QueuedCommands}
			ExecuteQueued
		waitframe
	}
}
#else /* _IncludePositionUtils_ */

variable EQ2Position Position

#endif /* _IncludePositionUtils_ */

#endif /* _PositionUtils_ */
