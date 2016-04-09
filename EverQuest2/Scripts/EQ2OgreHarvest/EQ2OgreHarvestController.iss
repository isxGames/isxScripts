function main(string ExecuteCommand)
{
	if ${Script[EQ2OgreHarvestUIData](exists)}
		Script[EQ2OgreHarvestUIData]:QueueCommand[call "${ExecuteCommand}"]
	else
		runscript "${LavishScript.HomeDirectory}/Scripts/EQ2OgreHarvest/EQ2OgreHarvestUIData" "${ExecuteCommand}"

}

