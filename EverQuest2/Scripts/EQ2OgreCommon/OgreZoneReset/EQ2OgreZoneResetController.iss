function main(string ExecuteCommand, string Param)
{
	if ${Script[EQ2OgreZoneReset](exists)}
		Script[EQ2OgreZoneReset]:QueueCommand[call "${ExecuteCommand}" "${Param}"]
	else
		runscript "${LavishScript.HomeDirectory}/Scripts/EQ2OgreCommon/OgreZoneReset/EQ2OgreZoneReset" "${ExecuteCommand}" "${Param}"

}

