/*
	FaceClass class (named such to avoid conflicts with /Face command and tlos)
	
	Instantiated as Navigator.FaceClass
	
	-- CyberTech (cybertech@gmail.com)
	
*/

objectdef obj_FaceClass
{
	/*
		Public Functions:
			FacePawn ${Pawn.ID} ##
			FacePoint ${X} ${Y} ##
				(Where ## is how precisely you want to face this point or pawn)

	*/

	variable float DestX
	variable float DestY
	variable float DestZ
	variable bool Facing = FALSE
	variable bool ImmediateFace = TRUE
	variable int RequiredHeading
	variable int AngleDiff
	variable int AngleDiffAbs
	
	method Initialize()
	{
		Event[OnFrame]:AttachAtom[This:GradualFace]
	}
	
	method Shutdown()
	{
		Event[OnFrame]:DetachAtom[This:GradualFace]
	}
	
	method Reset()
	{
		This.Facing:Set[FALSE]
	}

	/* User-Callable Functions Start */
	method FacePawn(int64 PawnID, bool fastFace=FALSE)
	{
		if !${Pawn[id,${PawnID}](exists)}
		{
			return
		}

		This:FacePoint[${Pawn[id,${PawnID}].Location},${fastFace}]
	}

	method FacePoint(float X, float Y, float Z=0, bool fastFace=FALSE)
	{
		variable point3f aLoc
		aLoc:Set[${X},${Y},${Z}]
		
		DebugTrace("FacePoint(float ${X}, float ${Y}, float ${Z}, bool ${fastFace})")
		This.DestX:Set[${aLoc.X}]
		This.DestY:Set[${aLoc.Y}]
		This.DestZ:Set[${aLoc.Z}]
		This.ImmediateFace:Set[${fastFace}]
		This:FaceSlow
	}

	/* *************************** */
	/* User-Callable Functions End */
	/* *************************** */

	method GradualFace()
	{
		if !${This.Facing} || !${Navigator.Running}
		{
			return
		}

		/*	When were "close enough" to facing the point while at the point.  
			This grows the further away you are, and shrinks as you get closer.
		*/
		variable int Precision = ${Math.Rand[6]:Inc[10]}	
					
		variable float ChangeAmount = 0.10		/* The amount to turn, in percents. */
		;variable int NearDistanceThreshold = 

		variable int NewHeading
		variable int MyHeading
		variable float DistanceToTarget

		MyHeading:Set[${Me.Heading}]
		DistanceToTarget:Set[${Math.Distance[${Me.X}, ${Me.Y}, ${Me.Z}, ${This.DestX}, ${This.DestY}, ${This.DestZ}]}]
			
		This:CalcHeadingToPoint
		This:CalcRelativeAngle
					
		if ${This.AngleDiffAbs} <= ${Precision}
		{
			This.Facing:Set[FALSE]
			return
		}

		if (${DistanceToTarget} < 8) && (${This.AngleDiff} < 30)
		{
			; If we're really close to the location, and our angle isn't excessive, do between 90 and 100% of it
			Precision:Set[${Math.Rand[3]:Inc[4]}]
			ChangeAmount:Set[${Math.Calc[${Math.Rand[10]:Inc[90]} / 100.0]}]
		}
		elseif (${DistanceToTarget} < 10)
		{
			; If we're really close to the location, do 50-65% of it.  This avoids endlessly circling the target.
			Precision:Set[${Math.Rand[3]:Inc[4]}]
			ChangeAmount:Set[${Math.Calc[${Math.Rand[16]:Inc[50]} / 100.0]}]
		}
		elseif (${DistanceToTarget} < 25) && (${This.AngleDiff} < 40)
		{
			; If we're really close to the location, and our angle isn't excessive, do 60-70% of it
			Precision:Set[${Math.Rand[3]:Inc[4]}]
			ChangeAmount:Set[${Math.Calc[${Math.Rand[11]:Inc[60]} / 100.0]}]
		}
		elseif (${DistanceToTarget} > 40) && (${This.AngleDiff} > 100)
		{
			; If we're farther away, and we have a large angle, do 30-40% of it
			Precision:Set[${Math.Rand[10]:Inc[10]}]
			ChangeAmount:Set[${Math.Calc[${Math.Rand[11]:Inc[30]} / 100.0]}]
		}

		NewHeading:Set[${Math.Calc[${This.AngleDiff} * ${ChangeAmount}].Round}]
		if ${This.AngleDiff} > 0
		{	
			NewHeading:Set[${Math.Calc[(${MyHeading} + ${NewHeading}]}]	/* Face right ${ChangeAmount} degrees */
			NewHeading:Set[${Math.Calc[${NewHeading} - ((${NewHeading} > 360) * 360)]}]
		}
		elseif ${This.AngleDiff} < 0
		{
			NewHeading:Set[${Math.Calc[(${MyHeading} + ${NewHeading}) % 360]}]	/* Face left ${ChangeAmount} degrees */
			NewHeading:Set[${Math.Calc[${NewHeading} + ((${NewHeading} < 0) * 360)]}]
		}

		Navigator:EchoHUD[" Distance: ${DistanceToTarget.Round} Heading: ${Me.Heading.Round} NewHeading: ${NewHeading} HeadingToPoint: ${This.RequiredHeading} AngleDiff: ${This.AngleDiff}"]
		
		if ${NewHeading} != ${Me.Heading.Round}
		{
			face ${NewHeading}
		}
	}

	method FaceSlow()
	{
		This:CalcHeadingToPoint
		if ${This.ImmediateFace}
		{
			face ${This.RequiredHeading}
		}
		else
		{
			This.Facing:Set[TRUE]
		}
	}

	method CalcHeadingToPoint()
	{
		variable float temp1
		variable float temp2
		variable float result

		/* Angle to point = Atan2[y2-y1,x2-x1] */

		temp1:Set[${Math.Calc[${Me.Y} - ${This.DestY}]}]
		temp2:Set[${Math.Calc[${Me.X} - ${This.DestX}]}]
		result:Set[${Math.Calc[${Math.Atan[${temp1},${temp2}]} - 90]}]
		result:Set[${Math.Calc[${result} + (${result} < 0) * 360]}]

		This.RequiredHeading:Set[${result}]
	}

	method CalcRelativeAngle()
	{
		variable float result

		result:Set[${Math.Calc[${This.RequiredHeading} - ${Me.Heading}]}]

		while ${result} > 180
		{
			result:Set[${Math.Calc[${result} - 360]}]
		}
		while ${result} < -180
		{
			result:Set[${Math.Calc[${result} + 360]}]
		}
		This.AngleDiff:Set[${result}]
		This.AngleDiffAbs:Set[${Math.Abs[${This.AngleDiff}]}]
	}

	/* Game Math Functions - From http://cmldev.net/ */

	/* Returns the dot product of two n-D vectors. */
	member:float DotProduct()
	{
		return ${Math.Calc[${Me.X} * ${This.DestX} + ${Me.Y} * ${This.DestY}]}
	}

	/*	Returns the perp-dot product of two 2-d vectors.
		The value returned is the dot product of right and the vector (-y,x) perpendicular to left.
	*/
	member:float PerpDotProduct()
	{
		return ${Math.Calc[${Me.X} * ${This.DestY} - ${Me.Y} * ${This.DestX}]}
	}

	/* Signed angle between two 2D vectors. */
	member:float Signed_Angle_2D()
	{
    	return ${Math.Atan[${This.PerpDotProduct},${This.DotProduct}]}
	}

	/* Unsigned angle between two 2D vectors. */
	member:float Unsigned_Angle_2D()
	{
    	return ${Math.Abs[${This.Signed_Angle_2D}]}
    }
}
