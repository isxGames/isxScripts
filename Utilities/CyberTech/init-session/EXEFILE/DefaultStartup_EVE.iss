#define _EXTNAME ISXEVE
#define _EXECUTABLE "ExeFile.exe"
#define WAITLOADTIMER 30

/*
	Start a given extension (configured above) for a given executable.
	Checks to ensure the extension is not already loaded, or loading,
	and runs until Extension.IsReady is true.

	-- CyberTech (cybertech@gmail.com)
*/
function main()
{
	variable string ExtName = _EXTNAME
	variable string Executable = _EXECUTABLE
	variable int WaitLoadTimer = WAITLOADTIMER

	if !${LavishScript.Executable.Find[${Executable}](exists)}
	{
		Script:End
	}

	if !${${ExtName}(exists)}
	{
		;call LoadExtension ${ExtName} ${WaitLoadTimer}
	}
}

function LoadExtension(string ExtName, int WaitLoadTimer)
{
	variable int Timer = 0

	if ${${ExtName}(exists)} && ${${ExtName}.IsReady}
	{
		; Extension is already loaded - nothing to do
		return
	}

	if ${${ExtName}(exists)}
	{
		; Extension is still loading - give it some time
		wait 50 ${${ExtName}.IsReady}
	}

	while (!${${ExtName}(exists)} && !${${ExtName}.IsReady})
	{
		; Extension wasn't finished loading in time, or wasn't loaded at all. Load it.
		if !${${ExtName}.IsLoading} && !${${ExtName}.IsReady}
		{
			echo "${Script.Filename}:LoadExtension: Loading Extension ${ExtName}"
			if ${${ExtName}(exists)}
			{
				extension -unload ${ExtName}
			}
			wait 20
			extension ${ExtName}
			wait 100 ${${ExtName}.IsReady}
		}

		Timer:Set[0]
		do
		{
			if ${${ExtName}.IsReady}
			{
				Script:End
			}

			Timer:Inc
			wait 10
		}
		while (${Timer} < ${WaitLoadTimer})
		echo "${Script.Filename}:LoadExtension: Loading extension ${ExtName} timed out (${WaitLoadTimer} seconds), retrying"
	}
}

