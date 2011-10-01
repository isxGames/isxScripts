objectdef obj_Face
{
	;; Variables used
	variable float DestX
	variable float DestY
	variable float DestZ
	variable bool Facing = FALSE
	variable bool ImmediateFace = TRUE
	variable int RequiredHeading
	variable int AngleDiff
	variable int AngleDiffAbs

	;===================================================
	;===             User Routines                  ====
	;===================================================

	;-----------------------------------------------
	; Example:  Face:Pawn[${Me.DTarget.ID},FALSE]
	;-----------------------------------------------
	method Pawn(int64 PawnID, bool fastFace=FALSE)
	{
		if !${Pawn[id,${PawnID}](exists)}
		{
			return
		}
		This:Point[${Pawn[id,${PawnID}].Location},${fastFace}]
	}

	;-----------------------------------------------
	; Example:  Face:Point[${Me.DTarget.Location},FALSE]
	;-----------------------------------------------
	method Point(float X, float Y, float Z=0, bool fastFace=FALSE)
	{
		variable point3f aLoc
		aLoc:Set[${X},${Y},${Z}]
		This.DestX:Set[${aLoc.X}]
		This.DestY:Set[${aLoc.Y}]
		This.DestZ:Set[${aLoc.Z}]
		This.ImmediateFace:Set[${fastFace}]
		This:FaceSlow
	}

	;-----------------------------------------------
	; Example:  Face:Stop
	;-----------------------------------------------
	method Reset()
	{
		This.Facing:Set[FALSE]
	}


	;===================================================
	;===          DO NOT USE THESE ROUTINES         ====
	;===================================================
	method Initialize()
	{
		Event[OnFrame]:AttachAtom[This:GradualFace]
	}

	method Shutdown()
	{
		Event[OnFrame]:DetachAtom[This:GradualFace]
	}

	method FaceSlow()
	{
		This:CalcHeadingToPoint
		if ${This.ImmediateFace}
		{
			;; face this angle now
			face ${This.RequiredHeading}
		}
		else
		{
			;; turn facing flag on so we can begin turning
			This.Facing:Set[TRUE]
		}
	}
	method GradualFace()
	{
		if !${This.Facing}
		{
			return
		}

		;echo FPS=${VG.FPS} Distance=${Math.Distance[${Me.X}, ${Me.Y}, ${Me.Z}, ${This.DestX}, ${This.DestY}, ${This.DestZ}]}


		;; When we are "close enough" to facing the point while at the point.
		;; This grows the further away you are, and shrinks as you get closer.
		variable int Precision = ${Math.Rand[3]:Inc[5]}
		;variable int Precision = 1
		variable float ChangeAmount = 0.1

		;; The amount to turn, in percents.
		variable int NewHeading
		variable int MyHeading
		variable float DistanceToTarget
		MyHeading:Set[${Me.Heading}]
		DistanceToTarget:Set[${Math.Distance[${Me.X}, ${Me.Y}, ${Me.Z}, ${This.DestX}, ${This.DestY}, ${This.DestZ}]}]
		This:CalcHeadingToPoint
		This:CalcRelativeAngle
		if ${This.AngleDiffAbs} <= ${Precision}
		{
			;; stop facing
			This.Facing:Set[FALSE]
			return
		}

		variable int FPS = ${VG.FPS}


		if (${DistanceToTarget} < 125)
		{
			; do 100% of the turn
			face ${This.RequiredHeading}
			return
		}
		elseif (${DistanceToTarget} < 250)
		{
			; do 50% of the turn
			ChangeAmount:Set[.5]
		}
		elseif (${DistanceToTarget} < 500)
		{
			; do 35% of the turn
			ChangeAmount:Set[.35]
		}
		elseif (${DistanceToTarget} < 1000)
		{
			; do 30% of the turn
			ChangeAmount:Set[.3]
		}
		elseif (${DistanceToTarget} < 1500)
		{
			; do 25% of the turn
			ChangeAmount:Set[.25]}]
		}
		elseif (${DistanceToTarget} < 2000)
		{
			; do 20% of the turn
			ChangeAmount:Set[.2]
		}
		elseif (${DistanceToTarget} < 2500)
		{
			; do 15% of the turn
			ChangeAmount:Set[.15]
		}
		elseif (${DistanceToTarget} < 3000)
		{
			; do 10% of the turn
			ChangeAmount:Set[.10]
		}

		if ${VG.FPS}>=20 && ${VG.FPS}<=30
		{
			ChangeAmount:Inc[.3]
		}
		elseif ${VG.FPS}>=15 && ${VG.FPS}<20
		{
			ChangeAmount:Inc[.4]
		}
		elseif ${VG.FPS}>=10 && ${VG.FPS}<15
		{
			ChangeAmount:Inc[.5]
		}
		elseif ${VG.FPS}<10
		{
			;; face this angle now
			face ${This.RequiredHeading}
			return
		}

		if ${ChangeAmount}>1
		{
			;; face this angle now
			face ${This.RequiredHeading}
			return
		}


		;vgecho "TargetDistance=${DistanceToTarget}, ChangeAmount=${ChangeAmount}"



		/*
		if (${DistanceToTarget} < 8) && (${This.AngleDiff} < 30)
		{
		; If we're really close to the location, and our angle isn't excessive, do between 90 and 100% of it
		Precision:Set[${Math.Rand[3]:Inc[4]}]
		ChangeAmount:Set[${Math.Calc[${Math.Rand[10]:Inc[90]} / 100.0]}]
		echo 1-ChangeAmount=${ChangeAmount}
		}
		elseif (${DistanceToTarget} < 10)
		{
		; If we're really close to the location, do 50-65% of it.  This avoids endlessly circling the target.
		Precision:Set[${Math.Rand[3]:Inc[4]}]
		ChangeAmount:Set[${Math.Calc[${Math.Rand[16]:Inc[50]} / 100.0]}]
		echo 2-ChangeAmount=${ChangeAmount}
		}
		elseif (${DistanceToTarget} < 25) && (${This.AngleDiff} < 40)
		{
		; If we're really close to the location, and our angle isn't excessive, do 60-70% of it
		Precision:Set[${Math.Rand[3]:Inc[4]}]
		ChangeAmount:Set[${Math.Calc[${Math.Rand[11]:Inc[60]} / 100.0]}]
		echo 3-ChangeAmount=${ChangeAmount}
		}
		elseif (${DistanceToTarget} > 40) && (${This.AngleDiff} > 100)
		{
		; If we're farther away, and we have a large angle, do 30-40% of it
		Precision:Set[${Math.Rand[10]:Inc[10]}]
		ChangeAmount:Set[${Math.Calc[${Math.Rand[11]:Inc[30]} / 100.0]}]
		echo 4-ChangeAmount=${ChangeAmount}
		}
		*/

		;echo DistanceToTarget=${DistanceToTarget}, AngleDiff=${This.AngleDiff}, Precision=${Precision}, ChangeAmount=${ChangeAmount}
		NewHeading:Set[${Math.Calc[${This.AngleDiff} * ${ChangeAmount}].Round}]

		if ${This.AngleDiff} > 0
		{
			NewHeading:Set[${Math.Calc[(${MyHeading} + ${NewHeading}]}]
			;; Face right ${ChangeAmount} degrees
			NewHeading:Set[${Math.Calc[${NewHeading} - ((${NewHeading} > 360) * 360)]}]
		}
		elseif ${This.AngleDiff} < 0
		{
			NewHeading:Set[${Math.Calc[(${MyHeading} + ${NewHeading}) % 360]}]
			;; Face left ${ChangeAmount} degrees
			NewHeading:Set[${Math.Calc[${NewHeading} + ((${NewHeading} < 0) * 360)]}]
		}
		;echo "Distance: ${DistanceToTarget.Round}, Heading: ${Me.Heading.Round}, NewHeading: ${NewHeading}, HeadingToPoint: ${This.RequiredHeading}, AngleDiff: ${This.AngleDiff}"
		if ${NewHeading} != ${Me.Heading.Round}
		{
			;; face our new angle
			face ${NewHeading}
		}
	}
	method CalcHeadingToPoint()
	{
		variable float temp1
		variable float temp2
		variable float result
		;; Angle to point = Atan2[y2-y1,x2-x1]
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
}


