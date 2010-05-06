;***Verison 1.01***
/**
Version 1.01 - Kannkor
Made this script end when no scripts are using this script. The check is on the Unload event incase you load it without using it for a few frames.
Note: If you unload your script, ensure you have a check before you try to load it again.

*********What this script does***********
OgreCustomArrayControllerOb:Load[distance] - Distance is used because the lowest distance will be used (saves CPU cycles)
*********How to call this script in your other script********
	if !${Script[OgreCustomArrayControllerScript](exists)}
	{
		runscript "${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreCustomArrayControllerScript"
		waitframe
		wait ${Script[OgreCustomArrayControllerScript](exists)}
		wait frame
	}
	;Then see Usage

******Usage******
OgreCustomArrayControllerOb:Load[distance(default 10)]
OgreCustomArrayControllerOb:UnLoad
OgreCustomArrayControllerOb:Update
OgreCustomArrayControllerOb:SetUpdateInterval[delay in milliseconds - default is 500 (half second)]
Example: OgreCustomArrayControllerOb:SetUpdateInterval[250]
**/


function main()
{

	if !${OgreCustomArrayControllerOb(exists)}
		declarevariable OgreCustomArrayControllerOb OgreCustomArrayControllerObect global

	if !${ScriptsUsingCustomArrayController(exists)}
		declarevariable ScriptsUsingCustomArrayController collection:string global

	while 1
		waitframe
}

objectdef OgreCustomArrayControllerObect
{
	variable int UpdateInterval=500
	variable int DistanceToUse
	variable CustomArrayControllerTimerObject CACTimerOb
	method Update()
	{
		if ${DistanceToUse} > 0 && !${CACTimerOb.TimeLeft}
		{
			EQ2:CreateCustomActorArray[byDist,${DistanceToUse}]
			CACTimerOb:Set[${UpdateInterval}]
		}
	}
	method SetUpdateInterval(int Interval=500)
	{
		UpdateInterval:Set[${Interval}]
	}
	method Load(string ScriptName, int Distance)
	{
		;echo Load: ScriptsUsingCustomArrayController:Set[${ScriptName},${Distance}]
		ScriptsUsingCustomArrayController:Set[${ScriptName},${Distance}]
		This:UpdateDistance
	}

	method UnLoad(string ScriptName)
	{
		;echo Unload: ${ScriptsUsingCustomArrayController.Element[${ScriptName}](exists)} -- {ScriptsUsingCustomArrayController.Element[${ScriptName}]}
		if ${ScriptsUsingCustomArrayController.Element[${ScriptName}](exists)}
		{
			ScriptsUsingCustomArrayController:Erase[${ScriptName}]
			This:UpdateDistance
		}
	}
	method UpdateDistance()
	{
		DistanceToUse:Set[0]
		if ${ScriptsUsingCustomArrayController.FirstKey(exists)}
		{
			do
			{
				if ${Int[${ScriptsUsingCustomArrayController.CurrentValue}]} > ${DistanceToUse}
					DistanceToUse:Set[${Int[${ScriptsUsingCustomArrayController.CurrentValue}]}]
			}
			while ${ScriptsUsingCustomArrayController.NextKey(exists)}
		}
		else
		{
			;If there are no scripts using this object, we can close down the script.
			echo No more scripts using ${Script.Filename}.
			Script:End
		}
		echo Debug: CustomArrayController: Distance updated ( ${DistanceToUse} )
	}
}
objectdef CustomArrayControllerTimerObject
{
	variable uint EndTime

	method Set(uint Milliseconds)
	{
		EndTime:Set[${Milliseconds}+${LavishScript.RunningTime}]
	}

	member:uint TimeLeft()
	{
		if ${LavishScript.RunningTime}>=${EndTime}
			return 0
		return ${Math.Calc[${EndTime}-${LavishScript.RunningTime}]}
	}
}

