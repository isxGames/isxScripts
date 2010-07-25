objectdef obj_Move
{
	;; Variables used
	variable float DestX
	variable float DestY
	variable float DestZ
	variable int Distance
	variable bool doMove = FALSE
	variable bool doFace = FALSE
	variable bool isMoving = FALSE

;===================================================
;===             User Routines                  ====
;===================================================

	;-----------------------------------------------
	; Example:  Move:Pawn[${Me.DTarget.ID},3,FALSE]
	;-----------------------------------------------
	method Pawn(int64 PawnID, int Distance=7, bool Face=FALSE)
	{
		if !${Pawn[id,${PawnID}](exists)}
		{
			return
		}
		This:Point[${Pawn[id,${PawnID}].Location},${Distance},${Face}]
	}

	;-----------------------------------------------
	; Example:  Move:Point[${Me.DTarget.Location},3,FALSE]
	;-----------------------------------------------
	method Point(float X, float Y, float Z=0, int Distance=7, bool Face=FALSE)
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
		This.doFace:Set[${Face}]
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

		;; Stop if we reached our destination
		if ${Math.Distance[${Me.X}, ${Me.Y}, ${Me.Z}, ${This.DestX}, ${This.DestY}, ${This.DestZ}]}<${This.Distance}
		{
			This:Stop
			return
		}
		
		;; Let's say we are moving!
		This.isMoving:Set[TRUE]
		VG:ExecBinding[moveforward]

		;; Let's face the location
		if ${doFace}
		{
			face ${This.DestX} ${This.DestY}
		}
	}
}
