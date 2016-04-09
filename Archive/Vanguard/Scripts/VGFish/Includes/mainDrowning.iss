;===================================================
;===             mainPause Routine              ====
;===================================================
function mainDrowning()
{
	;-------------------------------------------
	; If we are drowning then we fell off the boat
	;-------------------------------------------
	if ${Me.IsDrowning}
	{
		;-------------------------------------------
		; Get back onto the boat skipper!
		;-------------------------------------------

		press -hold "U"
		wait 5
		press -release "U"
		wait 30

		;-------------------------------------------
		; Reset Timers and update saved location
		;-------------------------------------------
		TimerRecast:Set[0]
	}
}

