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
		variable float RetVal
		variable float Heading=${Actor[${ActorID}].Heading}
		variable float HeadingTo=${Actor[${ActorID}].HeadingTo}
		RetVal:Set[${Math.Calc[${Math.Cos[${Heading}]} * ${Math.Cos[${HeadingTo}]} + ${Math.Sin[${Heading}]} * ${Math.Sin[${HeadingTo}]}]}]
		RetVal:Set[${Math.Acos[${RetVal}]}]
		return ${RetVal}
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
		variable point3f RetVal
		variable float Heading=${Actor[${ActorID}].Heading}
		RetVal.Y:Set[${Actor[${ActorID}].Y}]

		if ${This.Side[${ActorID}].Equal[Right]}
		{
			Angle:Set[-(${Angle})]
		}
		RetVal.X:Set[-${Distance} * ${Math.Sin[-(${Heading}+(${Angle}))]} + ${Actor[${ActorID}].X}]
		RetVal.Z:Set[${Distance} * ${Math.Cos[-(${Heading}+(${Angle}))]} + ${Actor[${ActorID}].Z}]
		return ${RetVal}
	}
	
	member:point3f PredictPointAtAngle(uint ActorID, float Angle, float Seconds=1, float Distance=3)
	{
		variable point3f RetVal
		variable point3f Velocity

		Velocity:Set[${Actor[${ActorID}].Velocity}]

		RetVal:Set[${This.PointAtAngle[${ActorID},${Angle},${Distance}]}]

		RetVal.X:Inc[${Velocity.X}*${Seconds}]
		RetVal.Y:Inc[${Velocity.Y}*${Seconds}]
		RetVal.Z:Inc[${Velocity.Z}*${Seconds}]
		return ${RetVal}
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
		SpellRange:Set[${Math.Calc[${MeleeRange}*${PercentMod}]}]
		return ${Math.Calc[${Actor[${ActorID}].CollisionRadius} * ${Actor[${ActorID}].CollisionScale} + ${SpellRange}]}
	}

	member:float GetCAMaxRange(uint ActorID, float PercentMod = 0, float CARange = 5)
	{
		PercentMod:Set[${Math.Calc[(100+${PercentMod})/100]}]
		CARange:Set[${Math.Calc[${MeleeRange}*${PercentMod}]}]
		return ${Math.Calc[${Actor[${ActorID}].CollisionRadius} * ${Actor[${ActorID}].CollisionScale} + ${CARange}]}
	}
}

variable EQ2Position Position

#endif
