;-------------------------------------------
; Only these variables should be used!
;-------------------------------------------
;

; Adjusted Angle for MyHeading to one of these closest directions:  N, NW, W, SW, S, SE, E, NE
variable	int		AdjAngleFacing

; Must set this immiediately after casting
variable	int		MyHeadingAtCasting

; Adjusted Angle (MyHeading adjusted to North)
variable	int		AdjAngle

; Must set this when fish stopped moving
variable	int		FishLastX
variable	int		FishLastY

; Must calculate new points when fist stopped moving
variable 	float		NorthPointX
variable 	float		NorthPointY
variable 	float		SouthPointX
variable 	float		SouthPointY
variable 	float		WestPointX
variable 	float		WestPointY
variable 	float		EastPointX
variable 	float		EastPointY

; Distance between Point and FishLastX
variable	int		NorthPointDistance
variable	int		SouthPointDistance
variable	int		WestPointDistance
variable	int		EastPointDistance

; Distance Fish needs to move to trigger direction
variable	int		TriggerDistance		=	1.5
variable	int		TriggerDistanceOveride	=	2

; Bool variables
variable 	bool		DoFishHeading	
variable	bool		DoTriggerDistance	
variable	bool		DoSound

; Temp Variables
variable	int		TempX
variable	int		TempY

; Last Fish health
variable	int		FishHealth



;===================================================
;===      mainTargetExist Routine               ====
;===================================================
function mainTargetExist()
{
	;-------------------------------------------
	; Return if No Target exists
	;-------------------------------------------
	if !${Me.Target(exists)} || ${Paused} || !${isRunning}
	{
		return
	}

	;-------------------------------------------
	; First, Release Unknown or Fish - MMOAddict & Zanadros
	;-------------------------------------------
	If ((${DoReleaseUnknown} && ${Me.Target.Name.Equal[Unknown]} && ${Pawn[${Me.Target}].Name.Equal[Unknown]}) || (${DoReleaseKnown} && (!(${Me.Target.Name.Equal[Unknown]} && ${Pawn[${Me.Target}].Name.Equal[Unknown]})) || (${Me.Target.Name.Equal[Fish]} && ${Pawn[${Me.Target}].Name.Equal[Fish]}))
	{
		;-------------------------------------------
		; 1st, Must wait long enough for Fish to change name
		;-------------------------------------------
		wait 30 !${Me.Target.Name.Equal[Fish]}
		wait 3

		;-------------------------------------------
		; 2nd, If FishName is still Fish or Unknown then clear targets
		;-------------------------------------------
		if ((${DoReleaseUnknown} && ${Me.Target.Name.Equal[Unknown]} && ${Pawn[${Me.Target}].Name.Equal[Unknown]}) || (${DoReleaseKnown} && (!(${Me.Target.Name.Equal[Unknown]} && ${Pawn[${Me.Target}].Name.Equal[Unknown]})) || (${Me.Target.Name.Equal[Fish]} && ${Pawn[${Me.Target}].Name.Equal[Fish]}))
		{
			actionlog "Released ${Me.Target.Name}"
			actionlog "Release Unknown ${DoReleaseUnknown}"
			actionlog "Release Known ${DoReleaseKnown}"

			;-------------------------------------------
			; 1st, Lets clear our target
			;-------------------------------------------
			VGExecute /cleartargets

			;-------------------------------------------
			; 2nd, Reset our Recast Timer to 0, wait 3.5 seconds, and return
			;-------------------------------------------
			TimerRecast:Set[0]
			wait 35 (${Paused} || !${isRunning})
			return
		}
	}

	;-------------------------------------------
	; Third, if we got this far then lets find a Combo for the target!
	;-------------------------------------------
	if ${Combo.Equal["xxxx"]}
	{
		variable int i
		for (i:Set[1] ; ${i} <= 50 ; i:Inc)
		{
			if ${Me.Target.Name.Find[${Fishes[${i}].Name}]}
			{
				FishName:Set[${Fishes[${i}].Name}]
				Combo1:Set[${Fishes[${i}].Combo1}]
				Combo2:Set[${Fishes[${i}].Combo2}]
				Combo3:Set[${Fishes[${i}].Combo3}]
				Combo4:Set[${Fishes[${i}].Combo4}]
				Combo:Set[${Combo1}${Combo2}${Combo3}${Combo4}]
				
				actionlog "Found Combo (${Combo}) for ${FishName}"
			}
		}

		if ${Combo.Equal["xxxx"]} && ${DoSound} && !${Me.Target.Name.Equal[Fish]} && !${Me.Target.Name.Equal[Unknown]}
		{
			DoSound:Set[FALSE]
			call PlaySound ALARM
			wait 10
			call PlaySound ALARM
		}
	}



	;-------------------------------------------
	; Fourth, If Health=0 then lets attempt to loot it
	;-------------------------------------------
	if ${Me.TargetHealth}==0
	{
		;-------------------------------------------
		; Lets Make sure the Fish's health is 0 before proceeding
		;-------------------------------------------
		wait 15
		if ${Me.TargetHealth}>0
		{
			return
		}

		;-------------------------------------------
		; First, Lets loot our catch if distance < 20m
		;-------------------------------------------
		if ${Me.Target.Distance}<40
		{
			actionlog "Looting"
			Command:Set["Looting"]
			if ${Me.IsLooting}
			{
				Loot:LootAll
				wait 5
			}
			if ${Me.Target(exists)} && ${Me.Target.ContainsLoot}
			{
				VGExecute /lootall
				wait 5
			}
		}

		;-------------------------------------------
		; Second, Lets clear our target if target has no loot (potential bug if Fish is alive with 0HP with loot)
		;-------------------------------------------
		if ${Me.Target(exists)} && !${Me.Target.ContainsLoot}
		{
			actionlog "Looting - clearing target"
			VGExecute /cleartargets
		}

		;-------------------------------------------
		; Third, Reset our Recast Timer to 0, wait 3.5 seconds, and Return
		;-------------------------------------------
		TimerRecast:Set[0]
		wait 35 (${Paused} || !${isRunning})
		return
	}

	;-------------------------------------------
	; Fifth, If Health=1 then Reel in the Fish
	;-------------------------------------------
	if ${Me.TargetHealth}==1 && !${Command.Equal[Reeling in Fish]}
	{
		Command:Set["Reeling in Fish"]
		actionlog "Reeling in Fish"
	}

	;-------------------------------------------
	; Sixth, If Health>1 then Lets catch the fish!
	;-------------------------------------------
	if ${Me.TargetHealth}>1
	{
		;-------------------------------------------
		; 1st, If we have a new Fish then reset points and variables
		;-------------------------------------------
		if ${LastTargetID}!=${Me.Target.ID}
		{
			;-------------------------------------------
			; Add this after Casting Line and put a check here for !doCasting... this will do for now
			;-------------------------------------------
			MyHeadingAtCasting:Set[${Me.Heading}]

			;-------------------------------------------
			; 1st, Update LastTargetID so not to repeat this routine
			;-------------------------------------------
			LastTargetID:Set[${Me.Target.ID}]

			;-------------------------------------------
			; 2nd, Wait till fish has stopped moving
			;-------------------------------------------
			;while ${Math.Distance[${Me.Target.X},${Me.Target.Y},${TempX},${TempY}]} > 0 && !${Paused} && ${isRunning}
			;{
			;	TempX:Set[${Me.Target.X}]
			;	TempY:Set[${Me.Target.Y}]
			;	wait 3
			;}

			;-------------------------------------------
			; 3rd, Reset new points and distances
			;-------------------------------------------
			call SetupNewPoints
			FishLastX:Set[${Me.Target.X}]
			FishLastY:Set[${Me.Target.Y}]
			NorthPointDistance:Set[${Math.Distance[${FishLastX},${FishLastY},${NorthPointX},${NorthPointY}]}]
			SouthPointDistance:Set[${Math.Distance[${FishLastX},${FishLastY},${SouthPointX},${SouthPointY}]}]
			WestPointDistance:Set[${Math.Distance[${FishLastX},${FishLastY},${WestPointX},${WestPointY}]}]
			EastPointDistance:Set[${Math.Distance[${FishLastX},${FishLastY},${EastPointX},${EastPointY}]}]

			;-------------------------------------------
			; 4th, Debugging information
			;-------------------------------------------
			actionlog "Snagged ${Me.Target.Name} at ${Me.Target.Distance}m"
		}

		;-------------------------------------------
		; 2nd, If Fish moves > TriggerDistance then decide what to do
		;-------------------------------------------

		variable int Trigger
		Trigger:Set[1.5]
		if ${DoTriggerDistance}
			Trigger:Set[${TriggerDistanceOveride}]

		if ${Math.Distance[${Me.Target.X},${Me.Target.Y},${FishLastX},${FishLastY}]} > ${Math.Calc[${Trigger} * 100]}
		{

			debuglog "-----Start------------"
			debuglog "FishHealth=${Me.TargetHealth}"
			debuglog "DoFishHeading=${DoFishHeading}"

			Command:Set["Fish Moved"]

			;-------------------------------------------
			; 1st, Determine and execute what we are doing
			;-------------------------------------------

			movelog "--------------"

			if ${DoFishHeading}
			{
				movelog "Preference is Fish Heading"
				call FishMovingWhere
				call FishHeadingWhere
			}
			if !${DoFishHeading}
			{
				movelog "Preference is Fish Moving"
				call FishHeadingWhere
				call FishMovingWhere
			}

			FishHealth:Set[${Me.TargetHealth}]

			switch ${Return}
			{
			case Up
				movelog "Executed Up"
				call FishCombo ${UP}
				break
			case Down
				movelog "Executed Down"
				call FishCombo ${DOWN}
				break
			case Left
				movelog "Executed Left"
				call FishCombo ${LEFT}
				break

			case Right
				movelog "Executed Right"
				call FishCombo ${RIGHT}
				break
			case None
				break
			}

			;-------------------------------------------
			; 2nd, Wait till Fish has stopped moving
			;-------------------------------------------
			while ${Math.Distance[${Me.Target.X},${Me.Target.Y},${TempX},${TempY}]} > 0 && !${Paused} && ${isRunning}
			{
				TempX:Set[${Me.Target.X}]
				TempY:Set[${Me.Target.Y}]
				wait 4 
			}

			;-------------------------------------------
			; 3rd, Debugging information
			;-------------------------------------------

			if ${FishHealth} > ${Me.TargetHealth}
			{
				movelog "Success!"
			}
			if ${FishHealth} < ${Me.TargetHealth}
			{
				movelog "Failed!"
			}

			debuglog "FishMoved=${Math.Distance[${Me.Target.X},${Me.Target.Y},${FishLastX},${FishLastY}]}"

			debuglog "NorthPointDistance=${NorthPointDistance}"
			debuglog "SouthPointDistance=${SouthPointDistance}"
			debuglog "WestPointDistance=${WestPointDistance}"
			debuglog "EastPointDistance=${EastPointDistance}"

			debuglog "FishLastX=${FishLastX}"
			debuglog "FishLastY=${FishLastY}"

			debuglog "NorthPointX=${NorthPointX}"
			debuglog "NorthPointY=${NorthPointY}"
	
			debuglog "SouthPointX=${SouthPointX}"
			debuglog "SouthPointY=${SouthPointY}"

			debuglog "WestPointX=${WestPointX}"
			debuglog "WestPointY=${WestPointY}"

			debuglog "EastPointX=${EastPointX}"
			debuglog "EastPointY=${EastPointY}"

			debuglog "TargetX=${Me.Target.X}"
			debuglog "TargetY=${Me.Target.Y}"

			debuglog "DiffX=${Math.Calc[${FishLastX} - ${Me.Target.X}]}"
			debuglog "DiffY=${Math.Calc[${FishLastY} - ${Me.Target.Y}]}"

			;-------------------------------------------
			; 4th, Fish stopped moving so recalculate new points and distances
			;-------------------------------------------
			call SetupNewPoints
			FishLastX:Set[${Me.Target.X}]
			FishLastY:Set[${Me.Target.Y}]
			NorthPointDistance:Set[${Math.Distance[${FishLastX},${FishLastY},${NorthPointX},${NorthPointY}]}]
			SouthPointDistance:Set[${Math.Distance[${FishLastX},${FishLastY},${SouthPointX},${SouthPointY}]}]
			WestPointDistance:Set[${Math.Distance[${FishLastX},${FishLastY},${WestPointX},${WestPointY}]}]
			EastPointDistance:Set[${Math.Distance[${FishLastX},${FishLastY},${EastPointX},${EastPointY}]}]

			debuglog "FishHealth=${Me.TargetHealth}"
			debuglog "-----End--------------"
		}
	}
}

;===================================================
;===================================================
;===    S U B - R O U T I N E S   B E L O W     ====
;===================================================
;===================================================

;===================================================
;===         FishHeadingWhere Routine            ====
;===================================================
function FishHeadingWhere()
{
	;-------------------------------------------
	; Variables Used
	;-------------------------------------------
	variable	int	tempNorthDistance
	variable	int	tempSouthDistance
	variable	int	tempWestDistance
	variable	int	tempEastDistance

	;-------------------------------------------
	; 1st, Let find the correct Angle from 0-359
	;-------------------------------------------
	AdjAngle:Set[${Math.Calc[${Me.Target.Heading} - ${Me.Heading}]}]
	while ${AdjAngle} > 180
	{
		AdjAngle:Set[${Math.Calc[${AdjAngle} - 360]}]
	}
	while ${AdjAngle} < 0
	{
		AdjAngle:Set[${Math.Calc[${AdjAngle} + 360]}]
	}

	debuglog "Me.Heading = ${Me.Heading}"
	debuglog "Target.Heading = ${Me.Target.Heading}"
	debuglog "Me.Target.HeadingTo = ${Me.Target.HeadingTo}"
	debuglog "AdjAngle (FishMovingWhere) = ${AdjAngle}"

	;-------------------------------------------
	; 2nd, Let debug which direction the fish is heading (used to prove that Me.Target.Heading is not reliable)
	;-------------------------------------------
	if (${AdjAngle}>315 && ${AdjAngle}<360) || (${AdjAngle}>=0 && ${AdjAngle}<=45)
	{
		movelog "Up - Me.Target.Heading"
		return "Up"
	}
	if ${AdjAngle}>135 && ${AdjAngle}<=225
	{
		movelog "Down - Me.Target.Heading"
		return "Down"
	}
	if ${AdjAngle}>225 && ${AdjAngle}<=315
	{
		movelog "Left - Me.Target.Heading"
		return "Left"
	}
	if ${AdjAngle}>45 && ${AdjAngle}<=135
	{
		movelog "Right - Me.Target.Heading"
		return "Right"
	}
}



;===================================================
;===         FishMovingWhere Routine            ====
;===================================================
function FishMovingWhere()
{
	;-------------------------------------------
	; Variables used (20m from target)
	;-------------------------------------------
	variable 	int	i
	variable	int	tempNorthDistance
	variable	int	tempSouthDistance
	variable	int	tempWestDistance
	variable	int	tempEastDistance
	variable 	string direction

	;-------------------------------------------
	; Get current distance fish moved towards N,S,W,E
	;-------------------------------------------
	tempNorthDistance:Set[${Math.Distance[${Me.Target.X},${Me.Target.Y},${NorthPointX},${NorthPointY}]}]
	tempSouthDistance:Set[${Math.Distance[${Me.Target.X},${Me.Target.Y},${SouthPointX},${SouthPointY}]}]
	tempWestDistance:Set[${Math.Distance[${Me.Target.X},${Me.Target.Y},${WestPointX},${WestPointY}]}]
	tempEastDistance:Set[${Math.Distance[${Me.Target.X},${Me.Target.Y},${EastPointX},${EastPointY}]}]
	debuglog "tempNorthDistance=${tempNorthDistance}"
	debuglog "tempSouthDistance=${tempSouthDistance}"
	debuglog "tempWestDistance=${tempWestDistance}"
	debuglog "tempEastDistance=${tempEastDistance}"

	
	;-------------------------------------------
	; Determine the shortest distance to N,S,W,E
	;-------------------------------------------
	direction:Set[Up]
	i:Set[${tempNorthDistance}]

	if ${tempSouthDistance}<${i}
	{
		i:Set[${tempSouthDistance}]
		direction:Set[Down]
	}	

	if ${tempWestDistance}<${i}
	{
		i:Set[${tempWestDistance}]
		direction:Set[Left]
	}
	if ${tempEastDistance}<${i}
	{
		i:Set[${tempEastDistance}]
		direction:Set[Right]
	}

	;-------------------------------------------
	; Show this in our log which direction was found
	;-------------------------------------------
	if ${direction.Equal[Up]} 
	{
		movelog "Up - Distance moved"
	}
	if ${direction.Equal[Down]} 
	{
		movelog "Down - Distance moved"
	}
	if ${direction.Equal[Left]} 
	{
		movelog "Left - Distance moved"
	}
	if ${direction.Equal[Right]} 
	{
		movelog "Right - Distance moved"
	}
	
	;-------------------------------------------
	; Return Up,Down,Left, or Right
	;-------------------------------------------
	return ${direction}
}

;===================================================
;===       Define Points for N, S, W, E         ====
;===================================================
function SetupNewPoints()
{
	;-------------------------------------------
	; Variables used (20m from target)
	;-------------------------------------------
	variable int iDist = 2000
	variable float iX = ${Me.Target.X}
	variable float iY = ${Me.Target.Y}
	variable float Cos
	variable float Sin
	variable float DistX
	variable float DistY

	;-------------------------------------------
	; Interesting, the direction the fish moves
	; is based upon your heading.  lmao
	;-------------------------------------------
	AdjAngle:Set[${Me.Heading}]

	;-------------------------------------------
	; 1st, Calculate North point
	;-------------------------------------------
	AdjAngle:Set[${Math.Calc[${AdjAngle} - 90]}]
	Cos:Set[${Math.Cos[${AdjAngle}]}]
	Sin:Set[${Math.Sin[${AdjAngle}]}]
	DistX:Set[${Math.Calc[${iDist}*${Cos}]}]
	DistY:Set[${Math.Calc[${iDist}*${Sin}]}]
	NorthPointX:Set[${Math.Calc[${DistX}+${iX}]}]
	NorthPointY:Set[${Math.Calc[${DistY}+${iY}]}]

	;-------------------------------------------
	; 2nd, Calculate West point
	;-------------------------------------------
	AdjAngle:Set[${Math.Calc[${AdjAngle} - 90]}]
	Cos:Set[${Math.Cos[${AdjAngle}]}]
	Sin:Set[${Math.Sin[${AdjAngle}]}]
	DistX:Set[${Math.Calc[${iDist}*${Cos}]}]
	DistY:Set[${Math.Calc[${iDist}*${Sin}]}]
	WestPointX:Set[${Math.Calc[${DistX}+${iX}]}]
	WestPointY:Set[${Math.Calc[${DistY}+${iY}]}]

	;-------------------------------------------
	; 3rd, Calculate South point
	;-------------------------------------------
	AdjAngle:Set[${Math.Calc[${AdjAngle} - 90]}]
	Cos:Set[${Math.Cos[${AdjAngle}]}]
	Sin:Set[${Math.Sin[${AdjAngle}]}]
	DistX:Set[${Math.Calc[${iDist}*${Cos}]}]
	DistY:Set[${Math.Calc[${iDist}*${Sin}]}]
	SouthPointX:Set[${Math.Calc[${DistX}+${iX}]}]
	SouthPointY:Set[${Math.Calc[${DistY}+${iY}]}]

	;-------------------------------------------
	; 4th, Calculate East point
	;-------------------------------------------
	AdjAngle:Set[${Math.Calc[${AdjAngle} - 90]}]
	Cos:Set[${Math.Cos[${AdjAngle}]}]
	Sin:Set[${Math.Sin[${AdjAngle}]}]
	DistX:Set[${Math.Calc[${iDist}*${Cos}]}]
	DistY:Set[${Math.Calc[${iDist}*${Sin}]}]
	EastPointX:Set[${Math.Calc[${DistX}+${iX}]}]
	EastPointY:Set[${Math.Calc[${DistY}+${iY}]}]

	return
}


;===================================================
;===           FishCombo Routine                ====
;===================================================
function FishCombo(string aDirection)
{
	variable string i

	call ConvertKeypress2Combo "${aDirection}"
	i:Set[${Return}]

	movelog "Keypress is (${aDirection}) and return is (${Return})"

	;-------------------------------------------
	; Dirty method for now - and it works!
	;-------------------------------------------
	call FindNameInFishList "${FishName}"
	if (${Return})
	{
		if ${Fishes[${Return}].Combo1.Equal[${i}]}
		{
			if ${DoLogFishMovement}
			{
				actionlog "COMBO used on ${FishName}"
			}

			call ConvertCombo2keypress "${Combo1}"
			movelog "Key pressed is (${Return})"
			press "${Return}"
			wait 3
			call ConvertCombo2keypress "${Combo2}"
			movelog "Key pressed is (${Return})"
			press "${Return}"
			wait 3
			call ConvertCombo2keypress "${Combo3}"
			movelog "Key pressed is (${Return})"
			press "${Return}"
			wait 3
			call ConvertCombo2keypress "${Combo4}"
			movelog "Key pressed is (${Return})"
			press "${Return}"
			wait 3

			return
		}
	}

	movelog "Key pressed is (${aDirection})"
	press "${aDirection}"
	wait 3
}

function ConvertKeypress2Combo(string i)
{

	if ${i.Equal[${UP}]}
	{
		return "u"
	}
	if ${i.Equal[${DOWN}]}
	{
		return "d"
	}
	if ${i.Equal[${LEFT}]}
	{
		return "l"
	}
	if ${i.Equal[${RIGHT}]}
	{
		return "r"
	}
	movelog "1-Invalid Key (${i})"
}

function ConvertCombo2keypress(string i)
{

	if ${i.Equal[u]}
	{
		return "${UP}"
	}
	if ${i.Equal[d]}
	{
		return "${DOWN}"
	}
	if ${i.Equal[l]}
	{
		return "${LEFT}"
	}
	if ${i.Equal[r]}
	{
		return "${RIGHT}"
	}
	movelog "2-Invalid Key (${i})"
}

;===================================================
;===          PlaySound Routine                 ====
;===================================================
function PlaySound(string Filename)
{
	System:APICall[${System.GetProcAddress[WinMM.dll,PlaySound].Hex},Filename.String,0,"Math.Dec[22001]"]
}


