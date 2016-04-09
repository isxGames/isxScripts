/*
	FaceClass class (named such to avoid conflicts with /Face command and tlos)

	Originally written CyberTech (cybertech@gmail.com) and modified for use with EQ2 by Amadeus
	
*/

;;;; Note:  It appears as though with EQ2 this class is unecessary.  Even if you 'face' instantly, it appears
;;;;        to others that you are still turning slowly.  However, this file will remain here in case anyone
;;;;        wishes to use it and/or for learning purposes.
#ifndef _EQ2FaceClass_
#define _EQ2FaceClass_

objectdef EQ2FaceClass
{
	/*
		Public Functions:
			FacePawn ${Actor.ID} ##
			FacePoint ${X} ${Z} ##
				(Where ## is how precisely you want to face this point or pawn)

	*/

	variable float DestX = 0
	variable float DestY = 0
	variable float DestZ = 0
	variable bool Facing = FALSE
	variable bool ImmediateFace = FALSE
	variable float RequiredHeading = ${Me.Heading}
	variable int AngleDiff = 0
	variable int AngleDiffAbs = 0
	variable int FrameCounter = 0	
	variable float IntervalInSeconds = 0.6
	
	method Initialize()
	{
		Event[OnFrame]:AttachAtom[This:Pulse]
	}
	
	method Output(string Text)
	{
	    echo "EQ2FaceClass:: ${Text}"
	}
	
	method Debug(string Text)
	{
	    echo "EQ2FaceClass-Debug:: ${Text}"
	}	
	
	method Shutdown()
	{
		Event[OnFrame]:DetachAtom[This:GradualFace]
	}
	
	method Reset()
	{
		This.Facing:Set[FALSE]
	}
	
	method Pulse()
	{
	    This.FrameCounter:Inc
	    if ${This.FrameCounter} >= ${Math.Calc64[${Display.FPS} * ${This.IntervalInSeconds}]}
	    {   
     	    if (${This.Facing})
        	    This:GradualFace       
        	This.FrameCounter:Set[0]
        }
	}

	/* User-Callable Functions Start */
	method FaceActor(int ActorID, bool ImmediateFace=FALSE)
	{
		if !${Actor[id,${ActorID}](exists)}
		{
			return
		}

		This:FacePoint[${Actor[id,${ActorID}].Loc},${ImmediateFace}]
	}

	method FacePoint(float X, float Y, float Z, bool ImmediateFace=FALSE)
	{
		variable point3f Location
		Location:Set[${X},${Y},${Z}]
		
		This:Debug["FacePoint( float ${X}, float ${Y}, float ${Z}, bool ${ImmediateFace})"]
		This.DestX:Set[${Location.X}]
		This.DestY:Set[${Location.Y}]
		This.DestZ:Set[${Location.Z}]
		This.ImmediateFace:Set[${ImmediateFace}]
		This:FaceSlow
	}

	/* *************************** */
	/* User-Callable Functions End */
	/* *************************** */

	method GradualFace()
	{
	    ;; This method is called every pulse that ${This.Facing} is TRUE
		This:Debug["GradualFace()"]

		/*	When were "close enough" to facing the point while at the point.  
			This grows the further away you are, and shrinks as you get closer.
		*/
		declarevariable Precision int local ${Math.Rand[6]:Inc[10]}	
					
		variable float ChangeAmount = 0.10		/* The amount to turn, in percents. */

		variable int NewHeading
		declarevariable MyHeading int local ${Me.Heading.Round}
		declarevariable DistanceToTarget float local ${Math.Distance[${Me.X}, ${Me.Y}, ${Me.Z}, ${This.DestX}, ${This.DestY}, ${This.DestZ}]}
			
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

		This:Debug[ Distance: ${DistanceToTarget.Round} Heading: ${Me.Heading.Round} NewHeading: ${NewHeading} HeadingToPoint: ${This.RequiredHeading} AngleDiff: ${This.AngleDiff}]
		
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
		This.RequiredHeading:Set[${Me.HeadingTo[${This.DestX},${This.DestY},${This.DestZ}]}]
	}

	method CalcRelativeAngle()
	{

		declarevariable result float local ${Math.Calc[${This.RequiredHeading} - ${Me.Heading}]}

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
		return ${Math.Calc[${Me.X} * ${This.DestX} + ${Me.Z} * ${This.DestZ}]}
	}

	/*	Returns the perp-dot product of two 2-d vectors.
		The value returned is the dot product of right and the vector (-y,x) perpendicular to left.
	*/
	member:float PerpDotProduct()
	{
		return ${Math.Calc[${Me.X} * ${This.DestZ} - ${Me.Z} * ${This.DestX}]}
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
#endif /* _EQ2FaceClass_ */