;-----------------------------------------------------------------------------------------------
; moveto.iss Version 2.1.05  Updated: 05/11/07
;
; Written by: Blazer
; Updated by: Pygar & cr4zyb4rd
;
; Revision History
; ----------------
; 2.1.05
;		* Incorporated a missing diff.
; v2.1.04 (Pygar)
;		* Moved aggro check into its own include
; v2.1.03 (cr4zyb4rd)
;	* Code cleanup: Lots of "dead" code removed, variables renamed/redefined, loops tightened
;	* Removed "facecount", the existing code wasn't checking it correctly and it wasn't to
;	  blame for the "jerking" issues anyway.  We always want to face the goal unless we're
;	  navigating an obstacle.
; v2.1.02 (Pygar)
;	*created a running state object to manage starting and stopping of movement
;	*adjusted math in some delays
;	*minor cleanup
;	*we need to address swimming isses
; v2.1.01 - * Defined Straffe and Turn Keys (Pygar)
;	 * Added wait on first obstruction call so that it wouldn't always return the same position
;	   when the next check stuck was fired. The 90 degree initial direction change should work
;	   reliably now.  Adjust Strafe timmers if they do not.
;	 * Added StopOnAggro arguement  Will return AGGRO and halt movement when true.
;	 * Adjusted some timers to make movement more subtle
;	 * Adjusted Strafe to use 'Strafe Arcs' on every other stuck check
;
; v2.0 - * Some fixes to declaration of variables since the last IS update. (Pygar)
;
; v1.8 - * Will do a weight check in case your encumbered too much and will move accordingly.
;	 * Added another paramater to moveto. This will allow you to specify the maximum number
;	   of attempts it tries to get out of a stuck position.
;	   Excluding this paramater will default the value to 3.
;	 * For the first attempt, it will turn 90 degrees to try and avoid an obstacle instead of
;	   moving back.
; v1.7 - * Added an optional paramater which can disable the ${forward} control. This will allow
;	   the main script to control the movement instead.
;	 * Modified the way the function handles getting stuck. If you get stuck a 2nd or 3rd time,
;	   it will move back and strafe with a longer wait time.
; v1.6 - * Modified the ${forward} key to use 'num lock' instead. You may need to change that
;	   to your auto run key.
;	   Unless you are strafing, or moving back (aka stuck) you will be able to type in chat
;	   while your char is moving.
; v1.5 - * More tweaks. and
;	 * Added 'checklag' which you can adjust depending how fast your pc is.
;	   If you are getting stuck when you shouldnt be, you can increase this value.
;	 * Added 'timerback' and 'timerstrafe' which sets the timer on how long you want to move
;	   back for or strafing.
;	 * Added 'faceount' which is the number of times it goes through the loop before it faces.
;
; v1.4 - * Some minor tweaks to work with the location update changes.
;
; v1.3 - * Some minor tweaks.
;
; v1.0 - * Initial Release
;-----------------------------------------------------------------------------------------------

; PROVIDES:
; MobCheck.iss include
; #defines for movement keys.
;
; function moveto(float X,float Z, float Precision, int keepmoving, int Attempts, int StopOnAggro)
; function CheckMovingAggro()
; function Obstacle(int delay)
; function StopRunning()
; function StartRunning()



#define _moveto_

#ifndef _MobCheck_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Common/MobCheck.iss"
#endif

;===================================================
;===        Keyboard Configuration              ====
;===================================================
#includeoptional ${LavishScript.HomeDirectory}/Scripts/EQ2Common/MovementKeys.iss
#ifndef _MOVE_KEYS_
variable string autorun="num lock"
variable string forward=w
variable string backward=s
variable string strafeleft=q
variable string straferight=e
variable string turnleft=a
variable string turnright=d
#endif /* _MOVE_KEYS_ */


variable int BackupTime
variable int StrafeTime

;
; This function moves you to within Precision yards
; of the specified X Z loc
; (Y is the vertical axis in EQ2)
;
variable int StopOnAggro

function moveto(float X,float Z, float Precision, int keepmoving, int Attempts, int lStopOnAggro)
{
	StopOnAggro:Set[${lStopOnAggro}]
	variable float SavX=${Me.X}
	variable float SavZ=${Me.Z}
	variable int obstaclecount=0
	variable int failedattempts=0
	variable int checklag
	variable int maxattempts=${If[${Attempts},${Attempts},3]}

	call CheckMovingAggro

	; Set the number of iterations before it determines its stuck
	checklag:Set[4]

	; How far do you want to move back for, if your stuck? (10 = 1 second)
	BackupTime:Set[5]

	; How far do you want to strafe for, after backing up? (10 = 1 second)
	StrafeTime:Set[5]

	if !${Attempts}
	{
		maxattempts:Set[3]
	}
	else
	{
		maxattempts:Set[${Attempts}]
	}

	; Check that we are not already there!
	if ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}>${Precision}
	{
		call CheckMovingAggro
		;Make sure we're moving
		call StartRunning
		do
		{
			call CheckMovingAggro
			face ${X} ${Z}

			; this wait is the main "timing chain" for the whole loop, and what
			; probably needs adjusted if we account for runspeed/swimming/etc
			wait 4

			; Check to make sure we have moved if not then try and avoid the
			; obstacle thats in our path
			; obstaclecount is used mainly if there is lag.
			if ${Math.Distance[${Me.X},${Me.Z},${SavX},${SavZ}]}<2
			{
				obstaclecount:Inc

				; This might be caused by lag or not updating our co-ordinates
				if ${obstaclecount}==${checklag}
				{
					wait 1
				}

				; We are probably stuck
				if ${obstaclecount}>${Math.Calc64[${checklag}+1]}
				{
					obstaclecount:Set[0]
					call Obstacle ${failedattempts}
					if (${failedattempts}==${maxattempts})
					{
					    call CheckMovingAggro
						; Main script will handle this situation
						if ${keepmoving}
						{
							call StartRunning
						}
						else
						{
							call StopRunning
						}
						return "STUCK"
					}
					failedattempts:Inc
				}
			}
			else
			{
				obstaclecount:Set[0]
			}

			; Store our current location for future checking
			SavX:Set[${Me.X}]
			SavZ:Set[${Me.Z}]
		}
		while ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}>${Precision}

	}

	; Made it to our target loc
	if ${keepmoving}
	{
		call StartRunning
	}
	else
	{
		call StopRunning
	}

	return "SUCCESS"
}

function CheckMovingAggro()
{
	;Stop Moving and pause if we have aggro
	if ${MobCheck.Detect} && ${StopOnAggro}
	{
		;Save our current heading in case it changes during aggro
		variable float saveheading=${Me.Heading}
		;Echo Aggro Detected Pausing
		call StopRunning

		do
		{
			;echo waiting 1 second in moveto
			wait 10
		}
		while ${MobCheck.Detect} || ${Me.ToActor.Health}<90 || ${Me.IsHated}

		Echo Scanning Loot in moveto
		EQ2:CreateCustomActorArray[byDist,15]

		if ${CustomActor[chest,radius,15](exists)} || ${CustomActor[corpse,radius,15](exists)}
		{
			;echo Loot Nearby, waiting 5 seconds...
			wait 50
		}

		echo Resuming Movement in moveto
		face ${saveheading}
		call StartRunning
	}
}

;
; Use strafing to get around an obstacle
;
function Obstacle(int delay)
{
	variable float newheading

	call CheckMovingAggro

	if ${delay}>0
	{
		;backup a little
        press -release ${forward}
        wait 1
		press -hold ${backward}
		wait ${Math.Calc64[${BackupTime}*${delay}]}
        press -release ${backward}

		if ${delay}==1 || ${delay}==3 || ${delay}==5
		{
			;randomly pick a direction
			if "${Math.Rand[10]}>5"
			{
			    call CheckMovingAggro
                press -hold ${strafeleft}
				call StartRunning
				wait ${Math.Calc64[${StrafeTime}*${delay}]}
                press -release ${strafeleft}
				call StopRunning
				wait 2
			}
			else
			{
			    call CheckMovingAggro
                press -hold ${straferight}
				call StartRunning
				wait ${Math.Calc64[${StrafeTime}*${delay}]}
                press -release ${straferight}
				call StopRunning
				wait 2
			}
		}
		else
		{
			;randomly pick a direction
			if "${Math.Rand[10]}>5"
			{
			    call CheckMovingAggro
                press -hold ${strafeleft}
				wait ${Math.Calc64[${StrafeTime}*${delay}]}
                press -release ${strafeleft}
				wait 2
			}
			else
			{
			    call CheckMovingAggro
                press -hold ${straferight}
				wait ${Math.Calc64[${StrafeTime}*${delay}]}
                press -release ${straferight}
				wait 2
			}
		}
		;Start moving ${forward} again
		call StartRunning
		wait ${Math.Calc64[${BackupTime}*${delay}+5]}
	}
	else
	{
	    call CheckMovingAggro
		if ${Math.Rand[10]}>5
		{
			newheading:Set[${Math.Calc[${Me.Heading}+90]}]
		}
		else
		{
			newheading:Set[${Math.Calc[${Me.Heading}-90]}]
		}
		if ${newheading}>360
		{
			newheading:Dec[360]
		}
		if ${newheading}<1
		{
			newheading:Inc[360]
		}

		face ${newheading}
		wait ${Math.Calc64[${StrafeTime}*${delay}]}
	}
}

;Very Basic object to manage auto-run states
function StopRunning()
{
	eq2execute /target_none
	if ${Me.IsMoving}
	{
		do
		{
    	    press "${autorun}"
			wait 5
		}
		while ${Me.IsMoving}
	}
}

function StartRunning()
{
    variable int Count
    Count:Set[0]

	if !${Me.IsMoving} && !${Me.IsHated}
	{
		do
		{
		    if ${Count} > 20
		    {
		        ;; we must be stuck....
		        press ${backward}
		        press -hold ${backward}
		        wait 5
		        press -release ${backward}
		        Count:Set[0]
		    }
    	    press "${autorun}"
			wait 2
			Count:Inc[2]
		}
		while !${Me.IsMoving} && !${Me.IsHated}
	}
}