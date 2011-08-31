;===================================================
;===            MAIN SCRIPT                     ====
;===================================================
function main()
{
	;-------------------------------------------
	; LOOP THIS INDEFINITELY
	;-------------------------------------------
	while ${Script[BM1].Variable[isRunning]}
	{
		if ${Script[BM1].Variable[doCounters]}
		{
			wait 100 !${Me.TargetCasting.Equal[None]}
			if !${Me.TargetCasting.Equal[None]}
			{
				if ${Me.Ability[${Metamorphism}].IsReady} && ${Me.Ability[${Metamorphism}].TimeRemaining}==0
				{
					vgecho "${Metamorphism}:  ${Me.TargetCasting}"
					VGExecute "/reactioncounter 2"
					wait 3
					while ${VG.InGlobalRecovery} || !${Me.Ability["Torch"].IsReady}
					{
						wait 1
					}
				}
				if ${Me.Ability[${Dissolve}].IsReady} && ${Me.Ability[${Dissolve}].TimeRemaining}==0 
				{
					vgecho "${Dissolve}:  ${Me.TargetCasting}"
					VGExecute "/reactioncounter 1"
					wait 3
					while ${VG.InGlobalRecovery} || !${Me.Ability["Torch"].IsReady}
					{
						wait 1
					}
				}
			}
		}
	}
}

