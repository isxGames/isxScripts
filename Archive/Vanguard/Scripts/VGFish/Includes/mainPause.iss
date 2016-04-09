;===================================================
;===             mainPause Routine              ====
;===================================================
function mainPaused()
{
	;-------------------------------------------
	; If we are Paused, then freeze everything
	;-------------------------------------------
	if ${Paused} && ${isRunning}
	{
		;-------------------------------------------
		; Show that we are Paused
		;-------------------------------------------
		actionlog "Paused"
		Command:Set["Paused"]
		UIElement[Run Button@Main@FishTabs@VGFish]:SetText[Paused]

		;-------------------------------------------
		; Sit and wait
		;-------------------------------------------
		while ${Paused} && ${isRunning}
		{
			wait 10
			waitframe
		}

		;-------------------------------------------
		; Show that we are Waiting
		;-------------------------------------------
		actionlog "Waiting"
		Command:Set["Waiting"]
		FlushQueued

		;-------------------------------------------
		; Reset Timers and update saved location
		;-------------------------------------------
		TimerRecast:Set[0]
	}
}

