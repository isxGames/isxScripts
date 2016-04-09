/*

               NOTE -=-=- WARNING -_-_- WARNING -=-=- NOTE

  This code is no longer generic. It depends on Variables that are set in VGCraft

          DO NOT USE THIS CODE IN YOUR OWN SCRIPT... get the original!

               NOTE -=-=- WARNING -_-_- WARNING -=-=- NOTE
*/


/* credits:
	This script has been written, rewritten, and contributed to by many people.
	Most notably by Fippy, scubaski, and don'tdoit.  Not possible without Lax and Amadeus.  <3
	Get Innerspace: www.lavishsoft.com
	Get ISXVGCraft:: www.isxgames.com
	Feel free to use and redistribute in a non-commercial manner as long as you keep the above (and add to them when necessary) in place.
	If you remember working on this (from wowhunter days or before), let me know and i'll change my credits lines.
*/

/* Version:
	v1.0 - Initial Release
	v1.1 - Fixed a bug with a ' instead of a ;
*/

variable(script) bool hitObject = FALSE
variable(script) bool hitNPC = FALSE

atom(script) VG_onHitObstacle(string ObstacleName)
{
	; Toon ran into something
	call DebugOut "VG:Hit Object: ${ObstacleName}"

	hitObject:Set[TRUE]
	VG:ExecBinding[moveforward,release]

}

atom(script) VG_onTouchPawn(string PawnName, int PawnID)
{
	; Toon ran into an NPC
	call DebugOut "VG:Hit NPC: ${PawnName} :: ${PawnID}"

	hitNPC:Set[TRUE]
	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward,release]
}

;
; This function moves you to within Precision yards
; of the specified X Y loc
;

function moveToPoint(float X, float Y, float Precision, bool doStop)
{
	declare SavX float local ${Me.X}
	declare SavY float local ${Me.Y}
	declare SavZ float local ${Me.Z}

	;set BailOut timer (4 minutes)
	declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*240)]}

	;Event[VG_onHitObstacle]:AttachAtom[VG_onHitObstacle]

	;Turn to face the desired loc
	if ( ${doSlowTurn} )
		call faceloc ${X} ${Y} 15 1
	else
		Face ${X} ${Y}

	
	;Check that we are not already there!
	if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision}
	{
		Do
		{
			;ensure we are still facing our target loc
			Face ${X} ${Y}

			;press and hold the forward button 
			VG:ExecBinding[moveforward]

			;wait for half a second to give our pc a chance to move
			wait 3

			;check to make sure we have moved if not then try and avoid the
			;obstacle thats in our path
			if ${hitObject} && (${Math.Distance[${Me.X},${Me.Y},${X},${Y}]} < ${Precision})
			{
				call Obstacle2
				hitObject:Set[FALSE]
				;return FALSE
			}
			elseif ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]} < 1
			{
				call Obstacle2
				call DebugOut "VG:ERROR: moveToPoint: we are stuck!"
				;VG:ExecBinding[moveforward,release]
				;return FALSE

			}
			;store our current location for future checking
			SavX:Set[${Me.X}]
			SavY:Set[${Me.Y}]
			SavZ:Set[${Me.Z}]
		}
		while (${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Precision}) && (${isMoving}) && (${LavishScript.RunningTime}<${BailOut})
		
		;Made it to our target loc
		if ${doStop}
			VG:ExecBinding[moveforward,release]

	}

	if ${doStop}
	{
		VG:ExecBinding[moveforward,release]
		while ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}<100
		{
			VG:ExecBinding[movebackward]
			face ${X} ${Y}
		}
		VG:ExecBinding[movebackward,release]
	}
		

	;Event[VG_onHitObstacle]:DetachAtom[VG_onHitObstacle]

	return TRUE
}

;
; This function moves you to within MaxDist yards
; of the specified Object and no closer than MinDist
; if specified.
function:bool moveToTargetedObject(string ObjectID, float MaxDist, float MinDist, bool moveBack)
{
	;echo ${Pawn[id,${ObjectID}]} Max: ${MaxDist} Min: ${MinDist}
	declare SavX float local ${Me.X}
	declare SavY float local ${Me.Y}
	declare SavZ float local ${Me.Z}
	declare BailOut int local ${Math.Calc[${LavishScript.RunningTime}+(1000*30)]}
	declare StuckCheck bool local FALSE
	declare StuckCheckTime int local

	;Event[VG_onHitObstacle]:AttachAtom[VG_onHitObstacle]
	;Event[VG_onTouchPawn]:AttachAtom[VG_onTouchPawn]
	
	;Check our arguments are sensible

	if ${MinDist} > ${MaxDist}
	{
		echo Invalid arguments min distance must be less than max
		return FALSE
	}
		
	if (${MinDist} < 0) || (${MaxDist} < 0)
	{
		echo Invalid value for min or max distance
		return FALSE
	}

	if !${Me.Target(exists)}
	{
		call ErrorOut "VG:ERROR: moveToTargedObject: No Object Targeted"
		return FALSE
	}

	if ( ${doSlowTurn} )
		call faceloc ${Me.Target.X} ${Me.Target.Y} 15 1
	else
		Face ${X} ${Y}

	
	do
	{
		SavX:Set[${Me.X}]
		SavY:Set[${Me.Y}]
		SavZ:Set[${Me.Z}]
		
		; Ensure we are still facing our target loc
		if ( ${doSlowTurn} )
			call faceloc ${Me.Target.X} ${Me.Target.Y} 15 1
		else
			Face ${Me.Target.X} ${Me.Target.Y}

		if ${VG.CheckCollision[${Me.Target.X},${Me.Target.Y},${Me.Target.Z}](exists)}
		{
			VG:ExecBinding[moveforward,release]
			VG:ExecBinding[movebackward,release]
			call DebugOut "VG:moveToTargedObject: CheckCollision returned true!"
			return FALSE
		}

		;If too far away run forward
		if ${Me.Target.Distance} > ${MaxDist}
		{
			;echo Too far closing
			;echo ${Me.Target.Distance} is GT ${MaxDist}
			;press and hold the forward button 
			VG:ExecBinding[movebackward,release]
			VG:ExecBinding[moveforward]
		}

		if ( ${moveBack} )
		{
			;If too close then run backward
			if ${Me.Target.Distance}<${MinDist}
			{
				;echo Too close backing up
				;echo ${Me.Target.Distance} is LT ${MinDist}
				;press and hold the backward button 
				VG:ExecBinding[moveforward,release]
				VG:ExecBinding[movebackward]
			}
		}
		
		;If we are close enough stop running
		if (${Me.Target.Distance} > ${MinDist}) && (${Me.Target.Distance} < ${MaxDist})
		{
			VG:ExecBinding[moveforward,release]
			VG:ExecBinding[movebackward,release]
			StuckCheck:Set[FALSE]
		}
		
		;wait for half a second to give our pc a chance to move
		wait 3

		navi:AutoBox
		navi:ConnectOnMove

		;	echo ${Me.Target.Name} ${Me.Target.Distance}

		; Check to make sure we have moved if not then try and avoid the
		; obstacle thats in our path

		if (${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]} < 1) || ${hitObject}
		{
			; echo Distdiff ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]}

			; I think i might be stuck so save off the current time
			if !${StuckCheck}
			{
				;echo I might be stuck
				StuckCheck:Set[TRUE]
				StuckCheckTime:Set[${LavishScript.RunningTime}]
			} 
			else
			{
				; If I am still stuck after 8 seconds then try and avoid the obstacle.
				if ${Math.Calc[${LavishScript.RunningTime}-${StuckCheckTime}]}>5000
				{
					;echo Yep I am stuck trying to free myself
					call Obstacle
					StuckCheck:Set[FALSE]
					hitObject:Set[FALSE]
				}
			}
		}
		
		; If I have moved away from my saved spot reset my stuck toggle
		if ${StuckCheck} && (${Math.Distance[${Me.X},${Me.Y},${Me.Z},${SavX},${SavY},${SavZ}]} > 3)
		{
			;echo I am no longer stuck
			StuckCheck:Set[FALSE]
		}
		
	}
	while (${Me.Target.Distance}>${MaxDist} || ${Me.Target.Distance} < ${MinDist}) && ${isMoving} && (${LavishScript.RunningTime} < ${BailOut})

	;Event[VG_onHitObstacle]:DetachAtom[VG_onHitObstacle]
	;Event[VG_onTouchPawn]:DetachAtom[VG_onTouchPawn]

	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward,release]

	if ( ${doSlowTurn} )
		call faceloc ${Me.Target.X} ${Me.Target.Y} 15 1
	else
		Face ${Me.Target.X} ${Me.Target.Y}

	if (${LavishScript.RunningTime} > ${BailOut})
	{
		call DebugOut "VG:moveToTargedObject: BailOut time exceeded!"
	}

	return TRUE

}

;
; Use strafing to get around an obstacle
;
function Obstacle()
{
	;echo Stuck, backing up

	;backup a little
	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward]
	wait 10
	VG:ExecBinding[movebackward,release]

	;randomly pick a direction
	if "${Math.Rand[10]}>5"
	{
	;echo Strafing Left
		VG:ExecBinding[StrafeLeft]
		wait 5
		VG:ExecBinding[strafeleft,release]
		wait 20
	}
	else
	{
		;echo Strafing Right
		VG:ExecBinding[straferight]
		wait 5
		VG:ExecBinding[straferight,release]
		wait 20
	}
;	echo Advancing
	;Start moving forward again
	VG:ExecBinding[moveforward]
}

;
; Turn to get around an obstacle
;
function Obstacle2()
{
	;echo Stuck, backing up

	;backup a little
	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward]
	wait 20
	VG:ExecBinding[movebackward,release]

	;randomly pick a direction
	if "${Math.Rand[10]}>5"
	{
		;echo Running Left
		;turn left a bit
		;echo ${Me.Heading} ${Math.Calc[((${Me.Heading}+-15)+360)%360]}
		face ${Math.Calc[((${Me.Heading}+-45)+360)%360]}
		VG:ExecBinding[moveforward]
		wait 30
	}
	else
	{
		;echo Running Right
		;turn right a bit
		;echo ${Me.Heading} ${Math.Calc[((${Me.Heading}+15)+360)%360]}
		face ${Math.Calc[((${Me.Heading}+45)+360)%360]}
		VG:ExecBinding[moveforward]
		wait 30
	}
	;echo Advancing
	;Start moving forward again
	VG:ExecBinding[moveforward]
}
