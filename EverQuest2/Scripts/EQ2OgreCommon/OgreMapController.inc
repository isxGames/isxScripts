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
/**
To do: Make on the initialize to capture the script name and use it in the unload / shutdown to free up atexit calling.
**/
variable OgreMapControllerObject OgreMapControllerOb
#if !${ScriptsUsingMap(exists)}
	variable(globalkeep) collection:string ScriptsUsingMap
#endif

variable filepath ZoneFilePath=${LavishScript.HomeDirectory}/scripts/EQ2OgreCommon/ZoneFiles/
;${ZoneFilePath.FileExists[${ZoneVar}.xml]}

objectdef OgreMapControllerObject
{
	variable string MapFile="${LavishScript.HomeDirectory}/scripts/EQ2OgreCommon/zonefiles/"
	method LoadMap(string MapToLoad)
	{
		if ${LavishNav.FindRegion[${MapToLoad}].ID}>0
		{
			echo Adding ${Script.Filename} to the collection since the map is already loaded..
		}
		else
		{
			echo Loading map: ${MapToLoad}
			;LavishNav.Tree:AddChild[universe,${MapToLoad},-unique]
			if ${ZoneFilePath.FileExists[${MapToLoad}.lso]}
			{
				echo Loading LSO file: ${ZoneFilePath}${MapToLoad}
				;LavishNav.FindRegion[${MapToLoad}]:Import[-lso,${ZoneFilePath}${MapToLoad}.lso]
				LavishNav.Tree:Import[-lso,${ZoneFilePath}${MapToLoad}.lso]
			}
			elseif ${ZoneFilePath.FileExists[${MapToLoad}.xml]}
			{
				echo Loading XML file: ${ZoneFilePath}${MapToLoad}
				;LavishNav.FindRegion[${MapToLoad}]:Import[${ZoneFilePath}${MapToLoad}.xml]
				LavishNav.Tree:Import[${ZoneFilePath}${MapToLoad}.xml]
			}
			else
			{
				echo No LSO or XML file found. Creating a new file.
				LavishNav.Tree:AddChild[universe,${MapToLoad},-unique]
			}
		}

		ScriptsUsingMap:Set[${Script.Filename},${MapToLoad}]
	}

	method UnLoadMap(string MapToLoad)
	{
		if ${ScriptsUsingMap.Element[${Script.Filename}](exists)}
		{
			;echo Removing ${Script.Filename} from the collection
			ScriptsUsingMap:Erase[${Script.Filename}]
		}
		else
			echo ${Script.Filename} is not showing as currently using the map.

		if ${LavishNav.FindRegion[${MapToLoad}].ID}>0
		{
			if ${ScriptsUsingMap.Used}<=0
			{
				;echo There are no scripts using the map, so lets unload it.
				LNavRegion[${MapToLoad}]:Remove
			}
			else
			{
				;echo There are other maps using the script so we won't unload it. # of scripts using it: ${ScriptsUsingMap.Used}
			}
		}
		else
		{
			echo ${MapToLoad} isn't loaded. Either the load was never called, or something else cleared it already.
		}
	}
}