#define QUIT f7

function main()
{
	echo Drusella Control Script Activated
	echo Press F7 to quit

	squelch bind quit "QUIT" "Script:End"

	do
	{
		if ${Actor[Drusella].Name(exists)}
		{
			Actor[Drusella]:InitializeEffects

			Echo EQ2Drusella - Waiting for Actor Effects to initialize on Drusella

			while ${ISXEQ2.InitializingActorEffects}
			{
				wait 2
			}

			Echo EQ2Drusella - Actor Effects Initialized

			if ${Actor[Drusella].Effect[Drusella's Necromantic Aura](exists)}
			{
				Echo EQ2Drusella - Drusella is protected!
				ScriptScript[EQ2Bot]:QueueCommand[call PauseBot]
				Echo EQ2Drusella - Eq2bot paused

				if ${Me.Pet(exists)}
					EQ2Execute /pet backoff

				do
				{
					Echo EQ2Drusella - Waiting for her Aura to fade...
					Actor[Drusella]:InitializeEffects

					Echo EQ2Drusella - Waiting for Actor Effects to initialize on Drusella

					while ${ISXEQ2.InitializingActorEffects}
					{
						wait 2
					}

					wait 5
				}
				while ${Actor[Drusella].Effect[Drusella's Necromantic Aura](exists)}

				ScriptScript[EQ2Bot]:QueueCommand[call PauseBot]
				Echo EQ2Drusella - Eq2bot Resumed
			}

		}
	}
	while 1
}

function atexit()
{
	ScriptScript[EQ2Bot]:QueueCommand[call PauseBot]
	echo Drusella Control Script Ending...
}