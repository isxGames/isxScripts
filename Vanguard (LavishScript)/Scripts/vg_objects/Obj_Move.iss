objectdef obj_Move
{
	;; Variables used
	variable float DestX
	variable float DestY
	variable float DestZ
	variable int Distance
	variable bool doMove = FALSE
	variable bool isMoving = FALSE

;===================================================
;===             User Routines                  ====
;===================================================

	;-----------------------------------------------
	; Example:  Move:MovePawn[${Me.DTarget.ID},FALSE]
	;-----------------------------------------------
	method MovePawn(int64 PawnID, int Distance=3)
	{
		if !${Pawn[id,${PawnID}](exists)}
		{
			return
		}
		This:MovePoint[${Pawn[id,${PawnID}].Location},${Distance}]
	}

	;-----------------------------------------------
	; Example:  Move:MovePoint[${Me.DTarget.Location},FALSE]
	;-----------------------------------------------
	method MovePoint(float X, float Y, float Z=0, int Distance=3)
	{
		variable point3f aLoc
		aLoc:Set[${X},${Y},${Z}]
		This.DestX:Set[${aLoc.X}]
		This.DestY:Set[${aLoc.Y}]
		This.DestZ:Set[${aLoc.Z}]
		Distance:Set[${Math.Calc[${Distance}*100].Int}]
		if ${Distance}<300
		{
			Distance:Set[300]
		}
		This.Distance:Set[${Distance}]
		This:Start
	}
	
	;-----------------------------------------------
	; Example:  Move:Start
	;-----------------------------------------------
	method Start()
	{
		This.doMove:Set[TRUE]
	}
	
	;-----------------------------------------------
	; Example:  Move:Stop
	;-----------------------------------------------
	method Stop()
	{
		This.doMove:Set[FALSE]
		if ${This.isMoving}
		{
			VG:ExecBinding[moveforward,release]
			This.isMoving:Set[FALSE]
		}
	}
	

;===================================================
;===          DO NOT USE THESE ROUTINES         ====
;===================================================
	method Initialize()
	{
		Event[OnFrame]:AttachAtom[This:MoveNow]
	}

	method Shutdown()
	{
		This:Stop
		Event[OnFrame]:DetachAtom[This:MoveNow]
	}

	method Reset()
	{
		This.doMove:Set[FALSE]
	}

	method MoveNow()
	{
		;; Stop if we do not want to move
		if !${This.doMove}
		{
			This:Stop
			return
		}

		variable float DistanceToTarget
		DistanceToTarget:Set[${Math.Distance[${Me.X}, ${Me.Y}, ${Me.Z}, ${This.DestX}, ${This.DestY}, ${This.DestZ}]}]
		
		;; Stop if we reached our destination
		if ${Math.Distance[${Me.X}, ${Me.Y}, ${Me.Z}, ${This.DestX}, ${This.DestY}, ${This.DestZ}]}<${This.Distance}
		{
			This:Stop
			return
		}
		
		;; Let's say we are moving!
		This.isMoving:Set[TRUE]
		VG:ExecBinding[moveforward]
	}
}
variable obj_Move obj_Move
