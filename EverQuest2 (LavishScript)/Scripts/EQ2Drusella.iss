#define QUIT f7

function main()
{
	echo Drusella Control Script Activated
	echo Press F7 to quit

	squelch bind quit "QUIT" "Script:End"

	do
	{
		if ${Actor[Drusella](exists)}
		{
			Actor[Drusella]:InitializeEffects

			if ${Actor[Drusella].Effect[Drusella's Necromantic Aura](exists)}
			{
				Echo - Drusella is protected!
				Script[EQ2Bot]:Pause

				do
				{
					Actor[Drusella]:InitializeEffects
					wait 5
				}
				while ${Actor[Drusella].Effect[Drusella's Necromantic Aura](exists)}

				Script[EQ2Bot]:Resume
			}

		}
	}
	while 1
}

function atexit()
{
	Script[EQ2Bot]:Resume
	echo Drusella Control Script Ending...
}