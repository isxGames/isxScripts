objectdef Obj_Commands
{
	;; identify the Passive Ability
	variable string PassiveAbility = "Racial Inheritance:"

	;; initialize when objectdef is created
	method Initialize()
	{
		variable int i
		for (i:Set[1] ; ${Me.Ability[${i}](exists)} ; i:Inc)
		{
			if ${Me.Ability[${i}].Name.Find[Racial Inheritance:]}
				This.PassiveAbility:Set[${Me.Ability[${i}].Name}]
		}
	}

	;; called when script is shut down
	method Shutdown()
	{
	}

	;; external command
	member:bool AreWeReady()
	{
		if ${Me.Ability[${This.PassiveAbility}].IsReady}
			return TRUE
		return FALSE
	}
	
	member:bool AreWeEating()
	{
		for (i:Set[1]; ${Me.Effect[${i}](exists)}; i:Inc)
		{
			if ${Me.Effect[${i}].IsBeneficial}
			{
				if ${Me.Effect[${i}].Description.Find[Health:]} && ${Me.Effect[${i}].Description.Find[Energy:]} && ${Me.Effect[${i}].Description.Find[over]} && ${Me.Effect[${i}].Description.Find[seconds]}
					return TRUE
			}
		}
		return FALSE
	}
}
	
