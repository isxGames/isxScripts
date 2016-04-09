function main(string ExecuteCommand, string Param)
{
	variable int EQ2OgreCounter
	variable int EQ2OgreSuccessfulCounter
	if ${UIElement[${LstBoxOgreZoneResetResetZoneListID}].Items} > 0
	{
		EQ2OgreCounter:Set[0]
		EQ2OgreSuccessfulCounter:Set[0]
		if ${ExecuteCommand.Equal[Local]}
			runscript "${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreZoneReset/EQ2OgreZoneResetController" ToggleZoneReuse Nothing
		elseif ${ExecuteCommand.Equal[relay]}
			relay all runscript "\${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreZoneReset/EQ2OgreZoneResetController" ToggleZoneReuse Nothing

		wait 5
		while ${EQ2OgreCounter:Inc} < 10 && ${EQ2OgreSuccessfulCounter} < ${UIElement[${LstBoxOgreZoneResetResetZoneListID}].Items}
		{
			if ${UIElement[${LstBoxOgreZoneResetResetZoneListID}].Item[${EQ2OgreCounter}](exists)}
			{
				EQ2OgreSuccessfulCounter:Inc
				;echo ${UIElement[${LstBoxOgreZoneResetResetZoneListID}].Item[${EQ2OgreCounter}]}
				if ${ExecuteCommand.Equal[Local]}
					runscript "${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreZoneReset/EQ2OgreZoneResetController" ResetLocal "${UIElement[${LstBoxOgreZoneResetResetZoneListID}].Item[${EQ2OgreCounter}]}"
				elseif ${ExecuteCommand.Equal[relay]}
					relay all runscript "\${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreZoneReset/EQ2OgreZoneResetController" ResetLocal "${UIElement[${LstBoxOgreZoneResetResetZoneListID}].Item[${EQ2OgreCounter}]}"
				else
					echo Missing where to route the command too. Please use the UI file to reset zones. If you are getting this in error, please post on the forums or contact Kannkor. Error message: EQ2OgreZoneResetXMLCall
				wait 5
			}
		}
	}
	else
		echo You must select some zones to reset first.
}

