#define _EXTNAME ISXEVE
#define _EXECUTABLE "ExeFile.exe"

function main()
{
	variable string ExtName = _EXTNAME
	variable string Executable = _EXECUTABLE

	if !${LavishScript.Executable.Find[${Executable}](exists)}
	{
		Script:End
	}

	; Need to use the defines here, as ${} isn't processed in alias.
	alias 1 ext _EXTNAME
	alias 2 ext -unload _EXTNAME
	alias 3 run EVEBot dev
	alias 4 endscript *
	alias 6 echo ${MyShip.Module[HiSlot1].Charge}
	
	bind toggle3d F12 EVE:Toggle3DDisplay
}