function main(string ExecuteCommand, string Param)
{
	if !${OgreRelayGroup(exists)}
		declarevariable OgreRelayGroup string globalkeep ogre_everquest2
	variable int EQ2OgreCounter
	variable int EQ2OgreSuccessfulCounter
	if ${UIElement[${LstBoxOgreZoneResetResetZoneListID}].Items} > 0
	{
		EQ2OgreCounter:Set[0]
		EQ2OgreSuccessfulCounter:Set[0]
		if ${ExecuteCommand.Equal[Local]}
			runscript "${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreZoneReset/EQ2OgreZoneResetController" ToggleZoneReuse Nothing
		elseif ${ExecuteCommand.Equal[relay]}
			relay ${OgreRelayGroup} runscript "\${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreZoneReset/EQ2OgreZoneResetController" ToggleZoneReuse Nothing
		elseif ${ExecuteCommand.Equal[irc]}
			irc !c all -ToggleZoneReset
		wait 5
		while ${EQ2OgreCounter:Inc} <= ${UIElement[${LstBoxOgreZoneResetResetZoneListID}].Items} && ${EQ2OgreSuccessfulCounter} <= ${UIElement[${LstBoxOgreZoneResetResetZoneListID}].Items}
		{
			if ${UIElement[${LstBoxOgreZoneResetResetZoneListID}].OrderedItem[${EQ2OgreCounter}](exists)}
			{
				EQ2OgreSuccessfulCounter:Inc
				;echo ${UIElement[${LstBoxOgreZoneResetResetZoneListID}].OrderedItem[${EQ2OgreCounter}]}
				if ${ExecuteCommand.Equal[Local]}
					runscript "${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreZoneReset/EQ2OgreZoneResetController" ResetLocal "${UIElement[${LstBoxOgreZoneResetResetZoneListID}].OrderedItem[${EQ2OgreCounter}]}"
				elseif ${ExecuteCommand.Equal[relay]}
					relay ${OgreRelayGroup} runscript "\${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreZoneReset/EQ2OgreZoneResetController" ResetLocal "${UIElement[${LstBoxOgreZoneResetResetZoneListID}].OrderedItem[${EQ2OgreCounter}]}"
				elseif ${ExecuteCommand.Equal[irc]}
					{
						irc !c all -ResetZone "${UIElement[${LstBoxOgreZoneResetResetZoneListID}].OrderedItem[${EQ2OgreCounter}].Text.Escape}"
					}
				else
					echo Missing where to route the command too. Please use the UI file to reset zones. If you are getting this in error, please post on the forums or contact Kannkor. Error message: EQ2OgreZoneResetXMLCall
				wait 5
			}
		}
	}
	else
		echo You must select some zones to reset first.
}

