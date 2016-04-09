;************Verison 1.01
;****Written by Kannkor (Hotshot)
;

/**
* Added new METHOD to the 'character' datatype:
  1. ResetZoneTimer[ZONENAME]
  [NOTE:  This may require to have opened the zone reuse window at least once in your current session before working properly (use /togglezonereuse)]
* Added new MEMBER to the 'eq2' datatype:
  1. PersistentZoneID[ZONENAME]           (unsigned int type)
* Added new METHOD to the 'eq2' datatype:
  1. GetPersisentZones[index:string]

**/


	
function main(string ExecuteCommand, string Param)
{

	call ${ExecuteCommand} "${Param}"
	while ${QueuedCommands}
		ExecuteQueued
}
function ToggleZoneReuse()
{
	variable index:string TempIndex1
	EQ2:GetPersisentZones[TempIndex1]
	if !${TempIndex1[1](exists)}
	{
		EQ2Execute /togglezonereuse
		wait 5
		EQ2Execute /togglezonereuse
	}
}
function ResetLocal(string ZoneName)
{
	if ${Me.Name(exists)} && ${ZoneName(exists)}
	{
		echo Resetting ${ZoneName}
		Me:ResetZoneTimer[${ZoneName}]
		wait 5
	}
	else
	{
		;Means you're not logged in.. so ignoring..
	}
}
