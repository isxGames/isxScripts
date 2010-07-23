;===================================================
;===              USE AN ABILITY                ====
;===================================================
function:bool UseAbility(string ABILITY, TEXT=" ")
{
	;; does ability exist?
	if !${Me.Ability[${ABILITY}](exists)}
	{
		;EchoIt "${ABILITY} does not exist"
		return FALSE
	}

	if ${Me.Ability[${ABILITY}].IsReady}
	{
		;; Check if mob is immune
		call Check4Immunites "${ABILITY}"
		if ${Return}
		{
			;EchoIt "Immune to ${ABILITY}"
			return FALSE
		}
	
		;; do we have energy to use ability?
		if ${Me.Ability[${ABILITY}].EnergyCost(exists)} && ${Me.Ability[${ABILITY}].EnergyCost}>${Me.Energy}
		{
			EchoIt "Not enought Energy for ${ABILITY}"
			return FALSE
		}
		;; do we have endurance to use ability?
		if ${Me.Ability[${ABILITY}].EnduranceCost(exists)} && ${Me.Ability[${ABILITY}].EnduranceCost}>${Me.Endurance} 
		{
			EchoIt "Not enough Endurance for ${ABILITY}"
			return FALSE
		}
		;; is target in range to use ability?
		if ${Me.Ability[${ABILITY}].Range}<${Me.Target.Distance} && ${Me.Ability[${ABILITY}].IsOffensive}
		{
			EchoIt "(${Me.Target.Distance} meters) too far away to use ${ABILITY}"
			return FALSE
		}	
		;; are we waiting to use ability?
		if ${Me.Ability[${ABILITY}].TimeRemaining}>0
		{
			EchoIt "TimeRemaining - ${ABILITY}"
			return FALSE
		}
		
		;; execute ability
		EchoIt "UseAbility - ${ABILITY} ${TEXT}"
		CurrentAction:Set[Casting ${ABILITY}]
		Me.Ability[${ABILITY}]:Use
		wait 5
		return TRUE
	}
	return FALSE
}		
