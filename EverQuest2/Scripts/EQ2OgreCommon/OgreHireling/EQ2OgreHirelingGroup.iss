;Version 1.01
;This script cycles through the character names in the list below and runs the hireling script on them once.
;***NOTE*** This requires files included with OgreBot (adventure bot).
;Created by Kannkor (HotShot)
;Version 1.01 - Kannkor
;	Changed default to T9


variable string HirelingCharInfo[10]
variable int OptionNum=9
variable int DefaultTimeToWait=72000
;72000 should be 2 hours
variable int TimeToWait=72000
;This one may change in the script
function main(int TempNum=9)
{
	variable int X=0
	variable int TotalX=0
	HirelingCharInfo[${X:Inc}]:Set[Toonname1]
	HirelingCharInfo[${X:Inc}]:Set[Toonname2]
	HirelingCharInfo[${X:Inc}]:Set[Toonname3]
	HirelingCharInfo[${X:Inc}]:Set[Toonname4]
	HirelingCharInfo[${X:Inc}]:Set[Toonname5]
	
	TotalX:Set[${X}]
	OptionNum:Set[${TempNum}]


	while 1
	{
		X:Set[0]
		while ${X:Inc} <= ${TotalX}
		{
			call ToonToLogin ${HirelingCharInfo[${X}]}
			runscript ogre hire ${OptionNum} FALSE
			wait 10
			while ${Script[EQ2OgreHireling](exists)}
				wait 100
		}
		;Lets camp out for the 2 hour wait
		EQ2Execute /camp
		echo Waiting 2 hours..
		wait ${TimeToWait}
	}
	echo EQ2OgreHirelingGroup is complete.
}
atom atext()
{
	if ${Script[EQ2OgreHireling](exists)}
		Script[EQ2OgreHireling]:End
}
function ToonToLogin(string ToonName)
{
	if ${ToonName.Length}<=0
	{
		echo No Toonname supplied to ToonToLogin
		Script:End
	}
	if ${Me.Name.Equal[${ToonName}]}
	{
		;Means we're already logged in
		return
	}
	elseif !${Zone.Name.Equal[LoginScene]}
	{
		;Means we're logged in, but NOT on the correct toon
		;Lets try camping!
		echo We're trying to get to ( ${ToonName} ) but we're on ${Me.Name} and we're not at the login screen ( ${Zone.Name} )
		EQ2Execute /camp
		wait 400 ${Zone.Name.Equal[LoginScene]}
	}

	;If we make it this far, we should be at the login scene
	if !${Zone.Name.Equal[LoginScene]}
	{
		echo Unable to get to login screen ( ${Zone.Name} ). Ending script.
		Script:End
	}
	elseif ${Zone.Name.Equal[LoginScene]}
	{
		;Lets try to login!
		runscript ogre login ${ToonName}
		wait 100
		;Above is just to save CPU cycles
		wait 5000 ${Me.Name.Equal[${ToonName}]}
		;Below: Make sure we have FPS incase the "loading" is taking a while
		wait 100 ${Display.FPS}>1
		;Short 2 second wait before clicking happens
		wait 20
	}
	else
	{
		echo Should not be possible to be here. Error report: ToonToLogin #1
		Script:End
	}

	if !${Me.Name.Equal[${ToonName}]}
	{
		echo Tried to login and waited 60 seconds, still not logged in. Game believes we are on: ${Me.Name} and we want to be on ${ToonName}. Ending script.
		Script:End
	}
}