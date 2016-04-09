variable string AUTORUN = "num lock"
variable string MOVEFORWARD = "w"
variable string MOVEBACKWARD = "s"
variable string STRAFELEFT = "q"
variable string STRAFERIGHT = "e"
variable string TURNLEFT = "a"
variable string TURNRIGHT = "d"
variable int BackupTime
variable int StrafeTime
variable int obstaclecount

function StartRunning()
{
    if !${Me.IsMoving}
		press "${AUTORUN}"
}

function StopRunning()
{
    press "${MOVEBACKWARD}"
    wait 1
    press "${MOVEBACKWARD}"
    wait 1
    press "${MOVEBACKWARD}"
}

function HandleObstacle()
{
	variable float newheading

	;backup a little
    press -release ${MOVEFORWARD}	
    wait 1
	press -hold ${MOVEBACKWARD}		
	wait ${Math.Calc64[${BackupTime}]}
    press -release ${MOVEBACKWARD}

	;randomly pick a direction
	if "${Math.Rand[10]}>5"
	{
        press -hold ${STRAFELEFT}			    
		wait ${Math.Calc64[${StrafeTime}]}
        press -release ${STRAFELEFT}	
		call StopRunning
		wait 2
	}
	else
	{
        press -hold ${STRAFERIGHT}	
		wait ${Math.Calc64[${StrafeTime}]}
        press -release ${STRAFERIGHT}	
		call StopRunning
		wait 2
	}

	;Start moving forward again
	call StartRunning
	wait ${Math.Calc64[${BackupTime}+5]}
}

function main(string sAUTORUN, string sMOVEFORWARD, string sMOVEBACKWARD, string sSTRAFELEFT, string sSTRAFERIGHT, int iBackupTime=15, int iStrafeTime=15)
{
    variable int Attempt = 1
    
    AUTORUN:Set[${sAUTORUN}]
    MOVEFORWARD:Set[${sMOVEFORWARD}]
    MOVEBACKWARD:Set[${sMOVEBACKWARD}]
    STRAFELEFT:Set[${sSTRAFELEFT}]
    STRAFERIGHT:Set[${sSTRAFERIGHT}]    
    
	; How far do you want to move back for, if your stuck? (10 = 1 second)
	BackupTime:Set[${iBackupTime}]
	; How far do you want to strafe for, after backing up? (10 = 1 second)
	StrafeTime:Set[${iStrafeTime}]    
	
	
	
	do
	{
	    call HandleObstacle   
	}
	while ${Attempt:Inc} <= 1
}