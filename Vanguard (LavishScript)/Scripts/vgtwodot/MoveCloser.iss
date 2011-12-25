/*
MoveCloser v1.0
by:  Zandros, 27 Jan 2009

Description:
Simple routine to Move closer to location X and Y that returns TRUE or FALSE
Currently it does not avoid obstacles or handle being stuck

parameters:
X = Coordinate X
Y = Coordinate Y
Distance = Distance from target to stop moving (default is 3m)

Example Code:
call MoveCloser ${Me.Target.X} ${Me.Target.Y} 15	"Move within 15m of location"

External Routines that must be in your program:  faceloc
*/

/* Toggle this on or off in your scripts */
variable bool DoMove = TRUE

;===================================================
;===       Move Closer if target exists         ====
;===================================================
function:bool MoveCloser(float X, float Y, int Distance)
{
	;-------------------------------------------
	; Return if we don't want to move
	;-------------------------------------------
	if !${DoMove}
	return TRUE

	;-------------------------------------------
	; Convert our distance not less than 3m
	;-------------------------------------------
	Distance:Set[${Math.Calc[${Distance}*100].Int}]
	if ${Distance}<300
	Distance:Set[300]

	;-------------------------------------------
	; Set our bailout timer to 15 sec "yah, kinda short timer
	;-------------------------------------------
	variable int bailOut
	bailOut:Set[${Math.Calc[${LavishScript.RunningTime}+(7000)]}]

	;-------------------------------------------
	; Move if we are over our distance "looks natural if we move and turn at the same time"
	;-------------------------------------------
	if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Distance}
	{
		;-------------------------------------------
		; Start moving
		;-------------------------------------------
		vgecho "VG: Moving - ${Math.Distance[${Me.X},${Me.Y},${X},${Y}].Int} to ${Distance}"
		VG:ExecBinding[moveforward]
		wait 2

		;-------------------------------------------
		; Begin turning
		;-------------------------------------------
		call faceloc ${X} ${Y} 25

		;-------------------------------------------
		; Keep moving forward while facing the target
		;-------------------------------------------
		while ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Distance} && ${LavishScript.RunningTime}<${bailOut}
		{
			VG:ExecBinding[moveforward]
			face ${X} ${Y}
		}

		;-------------------------------------------
		; Stop Moving!
		;-------------------------------------------
		VG:ExecBinding[movebackward,release]
		VG:ExecBinding[moveforward,release]

		;-------------------------------------------
		; Display our message if our timer ran out
		;-------------------------------------------
		if ${LavishScript.RunningTime}>${bailOut}
		{
			vgecho "VG: Moving - BailOut timer exceeded"
			return FALSE
		}
		return TRUE
	}
}

