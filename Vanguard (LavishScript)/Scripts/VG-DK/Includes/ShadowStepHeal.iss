;===================================================
;===         ShadowStepHeal Routine             ====
;===================================================
function:bool ShadowStepHeal()
{
	;; Return if we do not want to use ShadowStep
	if !${doShadowStep} || ${Me.HealthPct}>70
		return FALSE

	;; Return if these abilities do not exist
	if !${Me.Ability[${ShadowStep}](exists)} || !${Me.Ability[${Harrow}](exists)}
	{
		return FALSE
	}

	; check if we have enough energy/endurance
	if ${Me.Ability[${ShadowStep}].EnergyCost}>${Me.Energy} || ${Me.Ability[${Harrow}].EnduranceCost}>${Me.Endurance}
		return FALSE

	;; Return if neither of these abilities are ready
	if ${Me.Ability[${ShadowStep}].TimeRemaining}>0 || ${Me.Ability[${Harrow}].TimeRemaining}>0
	{
		return FALSE
	}

	; turn off auto attack
	call StopMeleeAttacks
	
	;; wait
	while ${VG.InGlobalRecovery}>0
	{
		waitframe
	}
	;vgecho ShadowStep=${Me.Ability[${ShadowStep}].IsReady}, Harrow=${Me.Ability[${Harrow}].IsReady}

	;; Let's move closer so that we can ShadowStep our target
	call MoveCloser ${Me.Target.X} ${Me.Target.Y} 30
	
	if ${Me.Target.Distance}>30
		return FALSE

	;; lets combo cast these
	if ${Me.Target.HaveLineOfSightTo}
	{
		Me.Ability[${ShadowStep}]:Use
		wait 2
		Me.Ability[${Harrow}]:Use
		wait 2
		EchoIt "ShadowStepHeal"
		return TRUE
	}
	return FALSE
}
