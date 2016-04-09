;***Verison 1.01***
/**
******Usage******
OgreMapControllerOb:LoadMap[<map to load>]
OgreMapControllerOb:UnLoadMap[<map to unload>]

Generally you will want to use OgreMapControllerOb:LoadMap[${Zone}]

*********What this script does***********
This script loads or unloads LavishNav points into memory to be used. 
This allows multiple scripts to use the same points without loading and unloading.
For example, if you have a 50k map (approximately 20m), it would need to be loaded for every
script that uses the map and unloaded with each one. Using 1 central map this saves the loading/unloading.

When a script invokes the loading, the script name is added to the collection. When the script is done with it,
it calls the unload which removes the script from the collection. If there are no scripts using the collection,
the map is then unloaded.

Version 1.01, 11/16/09 by Kannkor (Hotshot)
Loads LSO files, if no LSO file exists it loads an XML

Version 1.00, 11/02/2009 by Kannkor (Hotshot)
Loading/unloading of LavishNav into memory.
**/

variable OgreMapControllerObject OgreMapControllerOb
#if !${ScriptsUsingMap(exists)}
	variable(globalkeep) collection:string ScriptsUsingMap
#endif

variable filepath ZoneFilePath=${LavishScript.HomeDirectory}/scripts/EQ2OgreCommon/ZoneFiles/
;${ZoneFilePath.FileExists[${ZoneVar}.xml]}

objectdef OgreMapControllerObject
{
	variable string ScriptName
	variable string MapFile="${LavishScript.HomeDirectory}/scripts/EQ2OgreCommon/zonefiles/"
	method Initialize()
	{
		ScriptName:Set[${Script.Filename}]
	}
	method LoadMap(string MapToLoad)
	{
		if ${LavishNav.FindRegion[${MapToLoad}].ID}>0
		{
			Debug:Echo["Adding ${ScriptName} to the collection since the map is already loaded.."]
		}
		else
		{
			Debug:Echo["Loading map: ${MapToLoad}"]
			;LavishNav.Tree:AddChild[universe,${MapToLoad},-unique]
			if ${ZoneFilePath.FileExists[${MapToLoad}.lso]}
			{
				Debug:Echo["Loading LSO file: ${ZoneFilePath}${MapToLoad}"]
				;LavishNav.FindRegion[${MapToLoad}]:Import[-lso,${ZoneFilePath}${MapToLoad}.lso]
				LavishNav.Tree:Import[-lso,${ZoneFilePath}${MapToLoad}.lso]
			}
			elseif ${ZoneFilePath.FileExists[${MapToLoad}.xml]}
			{
				Debug:Echo["Loading XML file: ${ZoneFilePath}${MapToLoad}"]
				;LavishNav.FindRegion[${MapToLoad}]:Import[${ZoneFilePath}${MapToLoad}.xml]
				LavishNav.Tree:Import[${ZoneFilePath}${MapToLoad}.xml]
			}
			else
			{
				Debug:Echo["No LSO or XML file found. Creating a new file."]
				LavishNav.Tree:AddChild[universe,${MapToLoad},-unique]
			}
		}

		ScriptsUsingMap:Set[${ScriptName},${MapToLoad}]
	}

	method UnLoadMap(string MapToLoad)
	{
		if ${ScriptsUsingMap.Element[${ScriptName}](exists)}
		{
			;Debug:Echo["Removing ${ScriptName} from the collection"]
			ScriptsUsingMap:Erase[${ScriptName}]
		}
		else
			Debug:Echo["${ScriptName} is not showing as currently using the map."]

		if ${LavishNav.FindRegion[${MapToLoad}].ID}>0
		{
			if ${ScriptsUsingMap.Used}<=0
			{
				;Debug:Echo["There are no scripts using the map, so lets unload it."]
				LNavRegion[${MapToLoad}]:Remove
			}
			else
			{
				;Debug:Echo["There are other maps using the script so we won't unload it. # of scripts using it: ${ScriptsUsingMap.Used}"]
			}
		}
		else
		{
			Debug:Echo["${MapToLoad} isn't loaded. Either the load was never called, or something else cleared it already."]
		}
	}
}