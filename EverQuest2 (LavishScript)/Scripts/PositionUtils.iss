; PositionUtils.iss
;
; Script-defined object type for positioning around actors.
;


objectdef EQ2Position
{
	; Returns angle 0-180 degrees:
	; 0 == Behind
	; 180 == In front
	; 90 == Directly beside (either side)
	member:float Angle(uint ActorID)
	{
		variable float RetVal
		RetVal:Set[${Math.Calc[${Math.Cos[${Actor[${ActorID}].Heading}]} * ${Math.Cos[${Actor[${ActorID}].HeadingTo}]} + ${Math.Sin[${Actor[${ActorID}].Heading}]} * ${Math.Sin[${Actor[${ActorID}].HeadingTo}]}]}]
		RetVal:Set[${Math.Acos[${RetVal}]}]
		return ${RetVal}
	}

	; Returns which side of the Actor I am on, Left or Right.
	member:string Side(uint ActorID)
	{
		variable float Side
		Side:Set[${Math.Calc[${Math.Cos[${Actor[${ActorID}].Heading}+90]} * ${Math.Cos[${Actor[${ActorID}].HeadingTo}]} + ${Math.Sin[${Actor[${ActorID}].Heading}+90]} * ${Math.Sin[${Actor[${ActorID}].HeadingTo}]}]}]
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
		RetVal.Y:Set[${Actor[${ActorID}].Y}]

		if ${This.Side[${ActorID}].Equal[Right]}
		{
			Angle:Set[-(${Angle})]
		}
		RetVal.X:Set[-${Distance} * ${Math.Sin[-(${Actor[${ActorID}].Heading}+(${Angle}))]} + ${Actor[${ActorID}].X}]
		RetVal.Z:Set[${Distance} * ${Math.Cos[-(${Actor[${ActorID}].Heading}+(${Angle}))]} + ${Actor[${ActorID}].Z}]
		return ${RetVal.X} ${RetVal.Y} ${RetVal.Z}
	}

	member:float GetBaseMaxRange(uint ActorID)
	{
		return ${Math.Calc[${Actor[${ActorID}].CollisionRadius} * ${Actor[${ActorID}].CollisionScale}]}
	}

	member:float GetMeleeMaxRange(uint ActorID, float MeleeRange = 2.5)
	{
		return ${Math.Calc[${Actor[${ActorID}].CollisionRadius} * ${Actor[${ActorID}].CollisionScale} + ${MeleeRange}]}
	}

	member:float GetSpellMaxRange(uint ActorID, float SpellRange = 30)
	{
		return ${Math.Calc[${Actor[${ActorID}].CollisionRadius} * ${Actor[${ActorID}].CollisionScale} + ${SpellRange}]}
	}

	member:float GetCAMaxRange(uint ActorID, float CARange = 5)
	{
		return ${Math.Calc[${Actor[${ActorID}].CollisionRadius} * ${Actor[${ActorID}].CollisionScale} + ${CARange}]}
	}
}

variable EQ2Position Position

