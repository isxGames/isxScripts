;EQ2Autocamp.iss script by Morgur
; Usage - 'run autocamp x'  where 'x' is the amount of time to wait before logging out.
; 1 = 1 hour (60 minutes), .5 = half hour, 1.5 = hour and a half. Decimal values are supported ie. 1.8, 4.3, 1.5, .3, .5, etc..
; Example:  'run autocamp 2.5'  will autolog the character out after two and a half hours
; The default is 1 hour if no time is specified or 0 is specified. 
; For example 'run autocamp' will automatically use a 1 hour logout timer. However, 0.1 (360 seconds/6 minutes), 0.001, etc..
; or decimal values less than a whole hour will work fine.
;
; Tabification and minor code cleanup by Valerian
; Added options to command line. Can now specify camptype and camptoon when running the script.

function main(float quittimehours=1, int camptype=3, string camptoon="")
{
	variable float quittime
	variable int starttime
	variable int timestamp

	;camptype 1 = desktop   2 = exit   3 = login/select (default)   4 = camp over to specific toon
	;camptoon - toon name to camp over to if camptype is set to 4

	if ${quittimehours} <= 0
		quittimehours:Set[1]

	quittime:Set[${Math.Calc[${quittimehours}*(60*60)]}]
	starttime:Set[${Time.Timestamp}]
	timestamp:Set[${Time.Timestamp}-${starttime}]


	echo ***LOGOUT COUNTDOWN IS SET FOR ${quittimehours} HOURS***
	;echo STARTING COUNTERS: Logout Time = ${quittime} Seconds - Starting Stamp ${starttime} - Time Delta ${timestamp}

	do
	{
		wait 3000
		;checks the logout time every 5 minutes, change the wait from 3000 to lower if you want it to check more frequently
		timestamp:Set[${Time.Timestamp}-${starttime}]
		echo LOGOUT COUNTDOWN: Current Runtime is ${timestamp} seconds - Logout time set to ${quittime} seconds or ${quittimehours} hours
	}
	while ${timestamp} < ${quittime}

	do
	{
		if ${timestamp} >= ${quittime}
		{
			if ${Me.IsMoving} == TRUE || ${Me.CastingSpell} == TRUE || ${Me.InCombat} == TRUE
			{
				echo Cannot camp right now because you are - moving, casting or in combat...
				wait 100
			}
			else
			{
				echo The script run time ${timestamp} is greater than the Logout Timer ${quittime} ... 
				switch ${camptype}
				{
				case 4
					EQ2Execute /camp ${camptoon}
					echo ==Camping to ${camptoon}==
					break
				case 2
					echo ==Exiting==
					EQ2Execute /exit
					break
				case 1
					EQ2Execute /camp desktop
					echo ==Camping to Desktop==
					break
				case 3
				default
					EQ2Execute /camp
					echo ==Camping to Character Select==
					break
				}
				wait 250
				if ${Me.InGameWorld}==FALSE
					endscript autocamp
				echo ************CAMPING INTERRUPTED!!!************
			}
		}
	}
	while 1
}
