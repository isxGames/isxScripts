/*
	GameSpecificScripts.iss
	
	Turns the current executable path into a filename, without extension, then
	calls all scripts in Innerspace\Scripts\<filename>\*.iss
	
	Intended to allow drop-in of scripts to startup extensions or perform other
	configuration/settings details, without hard-coding such changes in the
	Innerspace game profile.
	
	This script should work as-is in any subdirectories of Innerspace\Scripts:
		Scripts\init-session and 
		Scripts\init-uplink
		
	This allows extension authors to place their startup scripts in:
		Scripts\init-session\<GAME>\*.iss or
		Scripts\init-uplink\<GAME>\*.iss or
		
	This script will first run any "DefaultStartup_*.iss" files found
	in the directories specified above, and then run any other scripts.
	
	Note that this may also be of use to Inner Space users who wish to have
	a script with default keybinds, aliases, window settings, etc, start
	for a given game.
		
	-- CyberTech (cybertech@gmail.com)
*/

function main()
{
	declarevariable Executable string ${LavishScript.Executable.Path.Upper.Replace[" ", "_"]}

	; Convert the executable "path\filename.ext" into "FILENAME"
	while (${Executable.Find["\\"]})
		Executable:Set[${Executable.Right[-${Executable.Find["\\"]}]}]
	while (${Executable.Find["/"]})
		Executable:Set[${Executable.Right[-${Executable.Find["/"]}]}]
	if (${Executable.Find["."]})
		Executable:Set[${Executable.Left[${Math.Calc[${Executable.Find["."]} - 1]}]}]

	declarevariable ExecutableScriptPath filepath "${Script.CurrentDirectory}/${Executable}"

	if !${ExecutableScriptPath.PathExists}
	{
		Script:End
	}

	variable filelist GameScripts
	GameScripts:GetFiles[${ExecutableScriptPath}/\*.iss]

	variable int Count=1
	for (${Count}<=${GameScripts.Files};Count:Inc)
	{
		; First, run the DefaultStartup_*.iss, on the assumption it's going to load extensions etc
		; Note that these will end up in alphabetical order, so the user COULD have more than one
		if ${GameScripts.File[${Count}].Filename.Find["DefaultStartup_"]}
		{
			echo "${Script.Filename}: Launching ${GameScripts.File[${Count}].FullPath.Right[-${Math.Calc[1+${LavishScript.HomeDirectory.Length}]}]}"
			waitscript "${GameScripts.File[${Count}].FullPath}"
		}
	}

	Count:Set[1]
	for (${Count}<=${GameScripts.Files};Count:Inc)
	{
		; Then load anything else the user may have dropped in the directory (keybinds, aliases, bot loaders, etc)
		if !${GameScripts.File[${Count}].Filename.Find["DefaultStartup_"]}
		{
			echo "${Script.Filename}: Launching ${GameScripts.File[${Count}].FullPath.Right[-${Math.Calc[1+${LavishScript.HomeDirectory.Length}]}]}"
			waitscript "${GameScripts.File[${Count}].FullPath}"
		}
	}
}