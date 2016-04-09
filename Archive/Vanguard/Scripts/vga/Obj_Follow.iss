objectdef obj_Follow
{
	;; Variables used
	variable float DestX
	variable float DestY
	variable float DestZ
	variable int Distance
	variable int Delay=${Script.RunningTime}

	variable int64 FollowID

	variable bool doFollow = FALSE
	variable bool isFollowing = FALSE

	;===================================================
	;===             User Routines                  ====
	;===================================================

	;-----------------------------------------------
	; Example:  Follow:FollowPawn[${Me.DTarget.ID},FALSE]
	;-----------------------------------------------
	method FollowPawn(int64 PawnID)
	{
		if !${Pawn[id,${PawnID}](exists)}
		{
			return
		}

		This.FollowID:Set[${PawnID}]
		This:Start
	}


	;-----------------------------------------------
	; Example:  Follow:Stop
	;-----------------------------------------------
	method Stop()
	{
		if ${This.isFollowing}
		{
			if ${Pawn[id,${This.FollowID}](exists)}
			{
				Pawn[id,${This.FollowID}]:Target
				VGExecute /Follow
			}
			This.isFollowing:Set[FALSE]
		}
		This.doFollow:Set[FALSE]
	}

	;-----------------------------------------------
	; Example:  Follow:isFollowing
	;-----------------------------------------------
	member:bool isFollowing()
	{
		if ${This.isFollowing}
		{
			return TRUE
		}
		return FALSE
	}


	;===================================================
	;===     YOU MAY CALL THIS BUT PREFER NOT       ====
	;===================================================
	;-----------------------------------------------
	; Example:  Follow:Start
	;-----------------------------------------------
	method Start()
	{
		if !${This.isFollowing}
		{
			if ${Pawn[id,${This.FollowID}](exists)}
			{
				;; go ahead and set our DTarget
				Pawn[id,${This.FollowID}]:Target

				if ${Me.DTarget.ID}!=${This.FollowID}
				{
					return
				}

				VGExecute /Follow

				;; update our location
				variable point3f aLoc
				aLoc:Set[${X},${Y},${Z}]
				This.DestX:Set[${aLoc.X}]
				This.DestY:Set[${aLoc.Y}]
				This.DestZ:Set[${aLoc.Z}]

				;; update our Delay timer
				This.Delay:Set[${Script.RunningTime}]

				;; say we are following
				This.isFollowing:Set[TRUE]
			}
		}
		;; turn on our check follow
		This.doFollow:Set[TRUE]
	}


	;===================================================
	;===          DO NOT USE THESE ROUTINES         ====
	;===================================================
	method Initialize()
	{
		Event[OnFrame]:AttachAtom[This:CheckFollow]
	}

	method Shutdown()
	{
		This:Stop
		Event[OnFrame]:DetachAtom[This:CheckFollow]
	}

	method Reset()
	{
		This.doFollow:Set[FALSE]
		This.isFollowing:Set[FALSE]
	}

	method CheckFollow()
	{
		;; Stop if we do not want to move
		if !${This.doFollow}
		{
			This:Stop
			return
		}

		;; Stop if we lost target
		if !${Pawn[id,${This.FollowID}](exists)}
		{
			This:Stop
			return
		}

		;; Must make sure we are following!
		if !${This.isFollowing}
		{
			This:Start
			return
		}

		;; Wait 1 second and check our distance
		if (${Math.Calc[${Math.Calc[${Script.RunningTime}-${This.Delay}]}/1000]} > 1)
		{
			;; if we didn't move then we want to reset - good chance we stopped following
			if ${Math.Distance[${Me.X}, ${Me.Y}, ${Me.Z}, ${This.DestX}, ${This.DestY}, ${This.DestZ}]} < 2
			{
				;; Reset only if we are more than 3 meters away
				if ${Math.Distance[${Me.X}, ${Me.Y}, ${Me.Z}, ${Pawn[id,${This.FollowID}].X}, ${Pawn[id,${This.FollowID}].Y}, ${Pawn[id,${This.FollowID}].Z}]} > 300
				{
					;; Reset only if we are more than 3 meters away
					if ${Math.Distance[${Me.X}, ${Me.Y}, ${Me.Z}, ${Pawn[id,${This.FollowID}].X}, ${Pawn[id,${This.FollowID}].Y}, ${Pawn[id,${This.FollowID}].Z}]} < 4950
					{
						This:Reset
						return
					}
				}
			}

			;; update our location
			variable point3f aLoc
			aLoc:Set[${Me.X},${Me.Y},${Me.Z}]
			This.DestX:Set[${aLoc.X}]
			This.DestY:Set[${aLoc.Y}]
			This.DestZ:Set[${aLoc.Z}]

			;; update our delay timer
			This.Delay:Set[${Script.RunningTime}]

			;echo "FOLLOW:  isFollowing=${This.isFollowing}, doFollow=${This.doFollow}"
		}

	}
}


variable obj_Follow obj_Follow

