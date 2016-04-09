/*  AutoFollow v1.3 - by Zandros

Description:  External script that when called will move to a target
and end the script when destination is reached.  It will handle
obstacles by moving randomly left or right and attempts to jump over.
If all fail then it will stop moving.

Parameters:  AutoFollow TARGETNAME STOP WALK RUN
TARGETNAME = if blank will use your DTARGET
STOP = Distance you want to stop from your target (Default=2)
WALK = Distance you want to begin walking to your target (Default=10)
RUN = Distance you want to begin moving to your target (Default=25)

Example usage:
;; in this example DTarget is who we are following, we are using default settings,
;; and passing True/False will start or stop who we are following
function AutoFollow(bool StartStop)
{
	;; If true then lets start following (file located at script directory)
	if ${StartStop} && !${Script[AutoFollow](exists)}
		run "./AutoFollow"

	;; If false then lets stop following
	if !${StartStop} && ${Script[AutoFollow](exists)}
		endscript AutoFollow
}

Credits & Thanks:
Amadeus for ISXVG: http://www.isxgames.com
Lax for Innerspace: http://www.lavishsoft.com
mmoAddict for his awsome VGA script

Version History:
v1.0 - Initial, 2 hrs of coding and 1 hrs fine tuning
v1.1 - Fixed backing when target was self
v1.2 - Converted all pawns to use exact ID because it was chasing nearest pawn with similar name
v1.4 - Tweeked some settings and started to tinker with the VG's /Follow command
v1.5 - Changed input to ID instead of Name
*/

#include ./BM/Includes/FaceSlow.iss


function main(int64 TARGETID, int STOP=3, int WALK=10, int RUN=25)
{
	;-------------------------------------------
	; Set our variables
	;-------------------------------------------
	;; Set this to TRUE if you want to see messages for debugging
	declare ECHO bool script TRUE
	;; This controls atexit whether we stop moving or not
	declare MOVED bool global FALSE
	;; This is TRUE whenever we bumped an obstacle
	declare BUMP bool script FALSE
	;; These variables is set to current location
	declare X float script ${Me.X}
	declare Y float script ${Me.Y}
	declare Z float script ${Me.Z}
	;; This is our bail out timmer... currently set for 2 seconds
	declare BAILOUT int script ${Math.Calc[${LavishScript.RunningTime}+(2000)]}
	;; This is to search by ID... far more accurate than using name
	;declare TARGETID int64 script 0

	;-------------------------------------------
	; Turn on our event
	;-------------------------------------------
	Event[VG_onHitObstacle]:AttachAtom[Bump]
	
	;-------------------------------------------
	; Make sure we have a valid target
	;-------------------------------------------
	;; If blank then set it to DTarget
	if ${TARGETID==0} && ${Me.DTarget(exists)}
	{
		TARGETID:Set[${Me.DTarget.ID}]
	}
	;; If still blank then set it to Target
	if ${TARGETID==0} && ${Me.Target(exists)}
	{
		TARGETID:Set[${Me.Target.ID}]
	}

	;-------------------------------------------
	; Announce if our target does not exist
	;-------------------------------------------
	if ${TARGETID}==0
	{
		if ${ECHO}
			echo "[${Time}][VG:AutoFollow] No DTarget, No Target, or missing ID"
		endscript AutoFollow
	}

	;-------------------------------------------
	; Target does not exist so endscript
	;-------------------------------------------
	if !${Pawn[id,${TARGETID}](exists)}
	{
		if ${ECHO}
			echo "[${Time}][VG:AutoFollow] STOPPED ([${TARGET}] does not exist)"
		endscript AutoFollow
	}

	;-------------------------------------------
	; Make sure target is within 50 meters
	;-------------------------------------------
	if ${Pawn[id,${TARGETID}].Distance.Int}>50
	{
		if ${ECHO}
			echo "[${Time}][VG:AutoFollow] Target is beyond 50 meters"
		endscript AutoFollow
	}
	
	;-------------------------------------------
	; If we are out of range then lets move into range
	;-------------------------------------------
	if ${Pawn[id,${TARGETID}].Distance.Int}>=${RUN} && ${Pawn[id,${TARGETID}](exists)}
	{
		;; Echo our stats
		if ${ECHO} && ${Pawn[name,${TARGET}](exists)}
			echo "[${Time}][VG:AutoFollow] START FOLLOWING: [${Pawn[id,${TARGETID}].Name}] Stop at ${STOP}, Walk at ${WALK}, Run at ${RUN}"
			
		;; Adjust our WALK variable so that distance will report accurately
		WALK:Inc

		;; Loop this
		while ${Pawn[id,${TARGETID}].Distance.Int}>=${STOP}
		{
			;; Make sure we are set for running
			MOVED:Set[TRUE]
			VG:ExecBinding[moveforward]
				
			;; Start RUNNING
			if ${Pawn[id,${TARGETID}].Distance.Int}>${WALK} && ${Pawn[id,${TARGETID}](exists)}
				VGExecute /run
				
			;; Start WALKING
			if ${Pawn[id,${TARGETID}].Distance.Int}<=${WALK} && ${Pawn[ID,${TARGETID}](exists)}
				VGExecute /walk

			;; Face target every 1m
			if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]} > 50
			{
				call faceloc ${Pawn[id,${TARGETID}].X} ${Pawn[id,${TARGETID}].Y} 15
				;; Pawn[id,${TARGETID}]:Face
				X:Set[${Me.X}]
				Y:Set[${Me.Y}]
				Z:Set[${Me.Z}]
				BAILOUT:Set[${Math.Calc[${LavishScript.RunningTime}+(2000)]}]
			}
			else
			{
				;; BAILOUT if stopped moving
				if ${LavishScript.RunningTime}>${BAILOUT}
				{
					if ${ECHO}
					echo "[${Time}][VG:AutoFollow] BAILOUT - Got Stuck (Distance: ${Pawn[id,${TARGETID}].Distance.Int})"
					endscript AutoFollow
				}
			}

			;; handle any objects we bumped
			if ${BUMP}
				call HandleBump
		}

		;; Stop moving and reset to running
		VG:ExecBinding[moveforward,release]
		VGExecute /run

		;; We finished moving
		if ${Pawn[id,${TARGETID}](exists)} && ${ECHO}
			echo "[${Time}][VG:AutoFollow] FINISHED FOLLOWING: [${Pawn[id,${TARGETID}].Name}] (Distance: ${Pawn[id,${TARGETID}].Distance})"

		;; We lost our target
		if !${Pawn[id,${TARGETID}](exists)} && ${ECHO}
			echo "[${Time}][VG:AutoFollow] STOPPED ([${Pawn[id,${TARGETID}].Name}] no longer exists)"
	}

	;-------------------------------------------
	; Backup if too close
	;-------------------------------------------
	if ${Pawn[id,${TARGETID}].Distance.Int}<1 && ${Pawn[id,${TARGETID}](exists)} && !${TARGET.Find[${Me.FName}]} && ${Pawn[me].ID}!=${TARGETID}
	{
		;; Start moving backward
		MOVED:Set[TRUE]
		VG:ExecBinding[movebackward]
		BAILOUT:Set[${Math.Calc[${LavishScript.RunningTime}+(2000)]}]

		;; Announce we are moving BACKWARD
		if ${ECHO}
			echo "[${Time}][VG:AutoFollow] BACKWARD (Distance: ${Pawn[id,${TARGETID}].Distance.Int})"

		;; Keep moving until we approach our STOP range
		while ${Pawn[id,${TARGETID}].Distance.Int}<1 && ${Pawn[id,${TARGETID}](exists)} && ${LavishScript.RunningTime}<${BAILOUT}
		{
			call faceloc ${Pawn[id,${TARGETID}].X} ${Pawn[id,${TARGETID}].Y} 15
			;;Pawn[id,${TARGETID}]:Face
			waitframe
		}

		;; Stop moving
		VG:ExecBinding[movebackward,release]
		VGExecute /run
	}
}

;-------------------------------------------
; ATEXIT - Lets make sure we are not moving
;-------------------------------------------
function atexit()
{
	;-------------------------------------------
	; Stop Moving!
	;-------------------------------------------
	if ${MOVED}
	{
		VG:ExecBinding[movebackward,release]
		VG:ExecBinding[moveforward,release]
		VG:ExecBinding[StrafeRight,release]
		VG:ExecBinding[StrafeLeft,release]
		VGExecute /run
	}

	;-------------------------------------------
	; Remove our Event
	;-------------------------------------------
	Event[VG_onHitObstacle]:DetachAtom[Bump]
}

;-------------------------------------------
; This happens when we bump into an obstacle
;-------------------------------------------
atom Bump(string Name)
{
	;; Set our BUMP flag
	BUMP:Set[TRUE]
}

;-------------------------------------------
; Handle the bump - lame routine
;-------------------------------------------
function HandleBump()
{
	variable int WAIT = 7
	variable int RANDOM = ${Math.Rand[10]}
	X:Set[${Me.X}]
	Y:Set[${Me.Y}]
	Z:Set[${Me.Z}]

	;; Try moving LEFT then RIGHT
	if ${RANDOM}>5
	{
		;; Move LEFT
		VG:ExecBinding[StrafeLeft]
		wait ${WAIT}
		VG:ExecBinding[StrafeLeft,release]
		if ${ECHO}
			echo "[${Time}][VG:AutoFollow] OBSTACLE - Going LEFT (Moved: ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}].Int}/100]})"

		;; Move RIGHT if we didn't move
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<150
		{
			if ${ECHO}
				echo "[${Time}][VG:AutoFollow] OBSTACLE - Trying RIGHT (Moved: ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}].Int}/100]})"
			VG:ExecBinding[StrafeRight]
			wait ${WAIT}
			VG:ExecBinding[StrafeRight,release]
		}
	}

	;; Try moving RIGHT then LEFT
	if ${RANDOM}<6
	{
		;; Move RIGHT
		VG:ExecBinding[StrafeRight]
		wait ${WAIT}
		VG:ExecBinding[StrafeRight,release]
		if ${ECHO}
			echo "[${Time}][VG:AutoFollow] OBSTACLE - Going RIGHT (Moved: ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}].Int}/100]})"

		;; Move LEFT if we didn't move
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<150
		{
			if ${ECHO}
				echo "[${Time}][VG:AutoFollow] OBSTACLE - Trying LEFT (Moved: ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}].Int}/100]})"
			VG:ExecBinding[StrafeLeft]
			wait ${WAIT}
			VG:ExecBinding[StrafeLeft,release]
		}
	}

	;; If we didn't move then JUMP or BAIL
	if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<250
	{
		VG:ExecBinding[Jump]
		wait 2
		VG:ExecBinding[Jump,release]
		wait 1
		VG:ExecBinding[Jump]
		wait 2
		VG:ExecBinding[Jump,release]
		wait 1

		;; If we still didn't move then BAIL
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<175
		{
			if ${ECHO}
			echo "[${Time}][VG:AutoFollow] BAILED - Unable to move (Moved: ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}].Int}/100]})"
			endscript AutoFollow
		}

		;; Successful JUMP if we moved
		if ${ECHO}
			echo "[${Time}][VG:AutoFollow] OBSTACLE - Jumped worked (Moved: ${Math.Calc[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}].Int}/100]})"

	}
	;; Clear our BUMP flag and resume
	BUMP:Set[FALSE]
}