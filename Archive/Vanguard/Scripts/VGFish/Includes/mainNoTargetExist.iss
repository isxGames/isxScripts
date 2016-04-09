;===================================================
;===      mainNoTargetExist Routine             ====
;===================================================
function mainNoTargetExist()
{
	;-------------------------------------------
	; Return if No Target exists
	;-------------------------------------------
	if ${Me.Target(exists)} || ${Paused} || !${isRunning}
	{
		return
	}

	;-------------------------------------------
	; Ensure we have Bait ready else pause the bot
	;-------------------------------------------
	if ${DoAutoBait}
	{
		call AutoLoadBait
		if !${Return}
		{
			return
		}
	}

	;-------------------------------------------
	; If we are looting, then finish looting it
	;-------------------------------------------
	if ${Me.IsLooting}
	{
		wait 15
		if ${Me.IsLooting}
		{
			Loot:LootAll
			wait 5
		}
		VGExecute /lootall
		wait 15
	}

	;-------------------------------------------
	; Set Combo to Unknown and show we are waiting!
	;-------------------------------------------
	DoSound:Set[TRUE]
	Combo:Set["xxxx"]
	if !${Command.Equal[Waiting]}
	{
		actionlog "Waiting"
		Command:Set["Waiting"]
	}

	;-------------------------------------------
	; Lets Cast our Line!  MMOAddict & Zandros
	;-------------------------------------------
	if ${DoCastLine} && ${LavishScript.RunningTime}>${TimerRecast}
	{
		;-------------------------------------------
		; First, lets set our Distance to 54
		;-------------------------------------------
		variable int Distance
		Distance:Set[54]

		;-------------------------------------------
		; Second, Lets Find a Fish and its distance
		;-------------------------------------------
		if ${DoFindFish}
		{
			call FindUsFish
			if ${Return}
			{
				Distance:Set[${Return}]
				if ${Distance}>54
				{
					Distance:Set[54]
				}
			}
		}

		;-------------------------------------------
		; Third, Cast our Line: 1m is average of .8th a sec
		;-------------------------------------------
		actionlog "Casting to fish at ${Distance}m away"

		Distance:Set[${Math.Calc[${Distance}*(.8)]}]
		if ${Distance}>36
		{
			Distance:Set[36]
		}

		if ${Distance}<20
		Distance:Inc[10]

		debuglog "Wait time is ${Distance}ms"

		VGExecute /fishing

		; Wait long enough for VG to think we're fishing
		wait 7
		waitframe

		; let's drop the line near the fish
		wait ${Distance} (${Paused} || !${isRunning})
		VGExecute /fishing
		wait 20 (${Paused} || !${isRunning})

		if ${Me.Target(exists)}
		{
			actionlog "Caught ${Me.Target.Name} at ${Me.Target.Distance}m away"
		}

		;-------------------------------------------
		; Fourth, Lets set our Recast Timer:  Default is 5 min
		;-------------------------------------------
		TimerRecast:Set[${Math.Calc[${LavishScript.RunningTime}+(1000*300)]}]
		if ${DoShortenCast} && ${ShortenCastDelay} > 0
		{
			TimerRecast:Set[${Math.Calc[${LavishScript.RunningTime}+(1000*${ShortenCastDelay})]}]
		}

		;-------------------------------------------
		; Beer break until we catch something or finished drinking our beer
		;-------------------------------------------
		while !${Me.Target(exists)} && !${Paused} && ${isRunning} && !${DoTrollLine} && ${LavishScript.RunningTime} < ${TimerRecast} && !${Me.IsDrowning}
		{
		}

		;-------------------------------------------
		; Fifth, Troll Line - Drag the bait closer to us
		;-------------------------------------------
		if ${DoTrollLine} && ${TrollLineTimes}>0 && ${TrollLineWaitTime}>0 && ${LavishScript.RunningTime}<${TimerRecast}
		{
			;-------------------------------------------
			; First, lets set our variables and Timer
			;-------------------------------------------

			variable int i
			variable float X
			variable float Y
			variable int trollint
			trollint:Set[1]

			;-------------------------------------------
			; Second, Loop this until we are done
			;-------------------------------------------
			while ${trollint}<=${TrollLineTimes} && !${Me.Target(exists)} && !${Paused} && ${isRunning}
			{
				;-------------------------------------------
				; First, Set our Troll Timer
				;-------------------------------------------
				TimerTroll:Set[${Math.Calc[${LavishScript.RunningTime}+(1000*${TrollLineWaitTime})]}]
				debuglog "Troll Line attempt #${trollint} waiting on ${TrollLineWaitTime} seconds"

				;-------------------------------------------
				; Second, Wait till Timer is up or Target exists
				;-------------------------------------------
				While ${LavishScript.RunningTime}<${TimerTroll} && !${Me.Target(exists)} && !${Paused} && ${isRunning} && !${Me.IsDrowning}
				{
				}

				;-------------------------------------------
				; Third, Lets bring that line in a little closer to us!
				;-------------------------------------------

				; Store our current location
				X:Set[${Me.X}]
				Y:Set[${Me.Y}]

				press -hold "${DOWN}"
				wait 10 ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]} > 1 
				;wait 10 (${Me.X}!=${X} || ${Me.Y}!=${Y})
				press -release "${DOWN}"

				; Check and see if we moved
				if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]} > 1
				{
					actionlog "WE MOVED - RESETTING"
					vgecho "WE MOVED (${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}m) - RESETTING"
					trollint:Set[${TrollLineTimes}]
				}

				;-------------------------------------------
				; Fourth, Increase Troll Line attempts
				;-------------------------------------------
				trollint:Inc
			}

			;-------------------------------------------
			; Third, reset our Recast Timer to 0
			;-------------------------------------------
			TimerRecast:Set[0]
			if ${Me.Target(exists)}
			{
				clearlog
			}
		}
	}
}


;===================================================
;===================================================
;===    S U B - R O U T I N E S   B E L O W     ====
;===================================================
;===================================================


;===================================================
;===    AutoBait Routine - MMOAddict & Zandros  ====
;===================================================
function:bool AutoLoadBait()
{
	if !${Me.Inventory[${Bait}]:Equip[Secondary Hand](exists)}
	{
		if ${Me.Inventory[${Bait}](exists)}
		{
			actionlog "Loading ${Bait} into Secondary Hand"
			Me.Inventory[${Bait}]:Equip[Secondary Hand]
			Waitframe
			return TRUE
		}
		actionlog "No more bait: ${Bait}"
		Paused:Set[TRUE]
		return FALSE
	}
	if !${Me.Inventory[${FishingPole}]:Equip[Primary Hand](exists)}
	{
		if  ${Me.Inventory[${FishingPole}](exists)}
		{
			actionlog "Equipting ${FishingPole} into Primary Hand"
			Me.Inventory[${FishingPole}]:Equip[Primary Hand]
			Waitframe
			return TRUE
		}
		actionlog "No such item to equip: ${FishingPole}"
		Paused:Set[TRUE]
		return FALSE
	}
	return TRUE
}

;===================================================
;===  FindAFish Routine - MMOAddict & Zandros   ====
;===================================================
function FindUsFish()
{
	variable int iCount
	iCount:Set[1]
	do
	{
		if ${Pawn[${iCount}].Name.Equal[Fish]} && ${Pawn[${iCount}].Distance} > ${MinFindFish} && ${Pawn[${iCount}].Distance} < ${MaxFindFish} && ${Pawn[${iCount}].HaveLineOfSightTo}
		{
			;-------------------------------------------
			; Turn slowly to the target only if outside 10 degrees 
			;-------------------------------------------
			call facemob ${Pawn[${iCount}].ID} 5
			wait 5
			VG:ExecBinding[moveforward,release]
			VG:ExecBinding[movebackward,release]
			VG:ExecBinding[turnleft,release]
			VG:ExecBinding[turnright,release]
			debuglog "Turning to face Fish at ${Pawn[${iCount}].Distance}m away"
			return ${Pawn[${iCount}].Distance}
		}
	}
	while ${iCount:Inc} <= ${VG.PawnCount}
	return 0
}

