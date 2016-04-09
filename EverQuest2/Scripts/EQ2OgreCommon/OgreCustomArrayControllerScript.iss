;***Verison 1.03***
/**
Version 1.03 - Kannkor
	* Because of scripts starting/stopping on the same frame, it was causing issues when you would reload the bot because this script 
	tried to delete itself and start iself with global variables on the same frame causing issues. Now, when CCAA thinks it's empty, 
	it waits 10 seconds to check again, if it is indeed empty, it then ends itself. This should take care of all these issues. 
Version 1.02(a) - Kannkor
	* Updated information on how to use
Version 1.01 - Kannkor
	* Made this script end when no scripts are using this script. The check is on the Unload event incase you load it without using it 
	for a few frames.
	* Note: If you unload your script, ensure you have a check before you try to load it again.

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
OgreCustomArrayControllerOb:Load[${Script.Filename},distance(default 10)]
Example: OgreCustomArrayControllerOb:Load[${Script.Filename},150]
**Note: Don't change the variable, only the distance**
OgreCustomArrayControllerOb:UnLoad[${Script.Filename}]
OgreCustomArrayControllerOb:Update
	Update will update the CAA, only if the Interval time has passed, otherwise the CAA is deemed up to date.
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
			;echo ${Time} Command: EQ2 - CreateCustomActorArray[byDist,${DistanceToUse}]
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
			timedcommand 100 OgreCustomArrayControllerOb:CleanUp
			;echo No more scripts using ${Script.Filename}.
			;Script:End
		}
		echo Debug: CustomArrayController: Distance updated ( ${DistanceToUse} )
	}
	method CleanUp()
	{
		if !${ScriptsUsingCustomArrayController.FirstKey(exists)}
		{
			echo No more scripts using ${Script.Filename}.
			Script:End
		}
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

