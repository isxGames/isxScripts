;===================================================
;===         ShadowStepHeal Routine             ====
;===================================================
function:bool ShadowStepHeal()
{
	;-------------------------------------------
	;Return if target is FURIOUS or not valid target - don't want to get killed!
	;-------------------------------------------
	if !${Me.Target.HaveLineOfSightTo} || !${Me.Target(exists)}
		return

	; check if we have enough energy/endurance
	if ${Me.Ability[${ShadowStep}].EnergyCost}>${Me.Energy} || ${Me.Ability[${Harrow}].EnduranceCost}>${Me.Endurance}
	return

	;; Return if these abilities do not exist
	if !${Me.Ability[${ShadowStep}](exists)} || !${Me.Ability[${Harrow}](exists)}
	{
		return
	}

	if !${Me.Ability[${ShadowStep}].IsReady} || ${Me.Ability[${Harrow}].TimeRemaining}>0
	{
		return
	}
	
	; turn off auto attack
	if ${GV[bool,bIsAutoAttacking]}
	{
		Me.Ability[Auto Attack]:Use
		waitframe
	}
	wait 10 !${GV[bool,bIsAutoAttacking]}

	;; Let's move closer so that we can ShadowStep our target
	call MoveCloser ${Me.Target.X} ${Me.Target.Y} 30
	
	if ${Me.Target.Distance}>30
		return

	;; lets combo cast these
	if ${Me.Ability[${ShadowStep}].IsReady} && ${Me.Ability[${Harrow}].TimeRemaining}==0 && ${Me.Target.HaveLineOfSightTo}
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
