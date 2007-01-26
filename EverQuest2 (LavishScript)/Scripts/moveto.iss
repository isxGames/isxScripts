;-----------------------------------------------------------------------------------------------
; moveto.iss Version 2.0  Updated: 09/04/05 
;
; Written by: Blazer
; 
; Revision History
; ----------------
; v2.0 - * Some fixes to declaration of variables since the last IS update.
;
; v1.8 - * Will do a weight check in case your encumbered too much and will move accordingly.
;	 * Added another paramater to moveto. This will allow you to specify the maximum number
;	   of attempts it tries to get out of a stuck position.
;	   Excluding this paramater will default the value to 3.
;	 * For the first attempt, it will turn 90 degrees to try and avoid an obstacle instead of
;	   moving back.
; v1.7 - * Added an optional paramater which can disable the MOVEFORWARD control. This will allow
;	   the main script to control the movement instead.
;	 * Modified the way the function handles getting stuck. If you get stuck a 2nd or 3rd time,
;	   it will move back and strafe with a longer wait time.
; v1.6 - * Modified the MOVEFORWARD key to use 'num lock' instead. You may need to change that 
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


#define MOVEFORWARD "num lock"
#define MOVEBACKWARD s
#define STRAFELEFT a
#define STRAFERIGHT d

;
; This function moves you to within Precision yards
; of the specified X Z loc
; with Z being the Y axis in EQ2
;
function moveto(float X,float Z, float Precision, int keepmoving, int Attempts)
{
	declare SavX float local ${Me.X}
	declare SavZ float local ${Me.Z}
	declare obstaclecount int local 0
	declare	failedattempts int local 0
	declare checklag int local
	declare maxattempts int local

	if !${timerback(exists)}
	{
		declare timerback int script
	}
	if !${timerstrafe(exists)}
	{
		declare timerstrafe int script
	}
	if !${facecount(exists)}
	{
		declare facecount int script
	}
	if !${vartmp(exists)}
	{
		declare vartmp int script 0
	}

	; Set the number of iterations before it determines its stuck
	checklag:Set[4]

	; How far do you want to move back for, if your stuck? (10 = 1 second)
	timerback:Set[10]

	; How far do you want to strafe for, after backing up? (10 = 1 second)
	timerstrafe:Set[10]

	; How often do you want to loop through the routine before it checks face again?
	facecount:Set[5]

	; Turn to face the desired location

	face ${X} ${Z}

	if !${Attempts}
	{
		maxattempts:Set[3]
	}
	else
	{
		maxattempts:Set[${Attempts}]
	}

	; Check Weight in case we are moving to slow
	if ${Math.Calc[${Me.Weight}/${Me.MaxWeight}*100]}>150
	{
		checklag:Set[10]
		timerback:Set[2]
		timerstrafe:Set[2]
		Precision:Set[2]
	}

	; Check that we are not already there!
	if ${Math.Distance[${Me.X},${Me.Z},${X},${Z}]}>${Precision}
	{
		; Press and hold the forward button 
		if !${keepmoving}
		{
			press MOVEFORWARD
		}
		Do
		{
			vartmp:Inc

			
			if ${facecount}<${vartmp}
			{
				face ${X} ${Z}
				vartmp:Set[0]
			}

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
				if ${obstaclecount}>${Math.Calc[${checklag}+1]}
				{
					if ${maxattempts}>4
					{
						return "STUCK"
					}
					obstaclecount:Set[0]
					call Obstacle ${failedattempts}
					if "${failedattempts}==${maxattempts}"
					{
						; Main script will handle this situation
						if !${keepmoving}
						{
							press MOVEFORWARD
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
		
		; Made it to our target loc
		if !${keepmoving}
		{
			press MOVEFORWARD
		}
	}
	return "SUCCESS"
}

;
; Use strafing to get around an obstacle
;
function Obstacle(int delay)
{
	declare newheading float local

	if ${delay}>0
	{
		;backup a little
		press MOVEFORWARD
		press -hold MOVEBACKWARD
		wait ${Math.Calc[${timerback}*${delay}]}
		press -release MOVEBACKWARD

		;randomly pick a direction
		if "${Math.Rand[10]}>5"
		{
			press -hold STRAFELEFT
			wait ${Math.Calc[${timerstrafe}*${delay}]}
			press -release STRAFELEFT
			wait 2
		}
		else
		{
			press -hold STRAFERIGHT
			wait ${Math.Calc[${timerstrafe}*${delay}]}
			press -release STRAFERIGHT
			wait 2
		}
		;Start moving forward again
		press MOVEFORWARD
		wait ${Math.Calc[${timerback}*${delay}+5]}
	}
	else
	{
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
	}
}
