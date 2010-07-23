;===================================================
;===          HANDLE COUNTERS                   ====
;===================================================
function HandleCounters()
{
	if !${doCounters}
	{
		return
	}
	
	if ${Me.TargetBuff[Furious](exists)} || ${Me.TargetBuff[Furious Rage](exists)} || ${Me.Effect[Aura of Death](exists)} || ${FURIOUS}	
	{
		return
	}
	
	;; This goes first since it has a cooldown timer
	if ${doVengeance}
	{
		if ${Me.Ability[${Vengeance}].IsReady}
		{
			if ${Me.Ability[${Vengeance}].TimeRemaining}==0 && ${Me.Ability[${Vengeance}].TriggeredCountdown}>0
			{
				Me.Ability[${Vengeance}]:Use
				VGExecute "/reactioncounter 2"
				CurrentAction:Set[Counterattack - ${Vengeance}]
				EchoIt "Counterattack - ${Vengeance}"
				wait 5
			}
		}
	}
	
	;; This will eat up you endurance FAST leaving nothing for the good stuff
	if ${doRetaliate} && ${Me.EndurancePct}>50
	{
		if ${Me.Ability[${Retaliate}].IsReady}
		{
			if ${Me.Ability[${Retaliate}].TimeRemaining}==0 && ${Me.Ability[${Retaliate}].TriggeredCountdown}>0
			{
				Me.Ability[${Retaliate}]:Use
				VGExecute "/reactioncounter 1"
				CurrentAction:Set[Counterattack - ${Retaliate}]
				EchoIt "Counterattack - ${Retaliate}"
				wait 5
			}
		}
	}
}
