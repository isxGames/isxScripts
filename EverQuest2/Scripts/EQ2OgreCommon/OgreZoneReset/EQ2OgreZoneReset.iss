;************Verison 1.04
;****Written by Kannkor
;

/**
Version 1.04
Added an ignore list. Terrible way to implement it... but for now it'll do.
Version 1.03
-Updated to allow [Challenge]
Version 1.02
-exits if no character is logged in instead of crashing the instance

* Added new METHOD to the 'character' datatype:
  1. ResetZoneTimer[ZONENAME]
  [NOTE:  This may require to have opened the zone reuse window at least once in your current session before working properly (use /togglezonereuse)]
* Added new MEMBER to the 'eq2' datatype:
  1. PersistentZoneID[ZONENAME]           (unsigned int type)
* Added new METHOD to the 'eq2' datatype:
  1. GetPersisentZones[index:string]

**/
;// Add toon names to the below, to have them ignore reset commands.
variable string ToonsToIgnoreReset="Kannkor*Kannkor2*Kannkor3"

	
function main(string ExecuteCommand, string Param)
{
	if ${Me.Name.Equal[NULL]} || ${Zone.Name.Equal[LoginScene]} || ${ToonsToIgnoreReset.Find[${Me.Name}](exists)}
		return
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
		if ${ZoneName.Equal["Zek the Scourge Wastes: The Siege [Raid]"]}
			ZoneName:Set["Zek, the Scourge Wastes: The Siege [Raid]"]
		echo Resetting ${ZoneName}
		Me:ResetZoneTimer["${ZoneName}"]
		wait 5
	}
	else
	{
		;Means you're not logged in.. so ignoring..
	}
}