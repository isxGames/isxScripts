objectdef Obj_Commands
{
	;; identify the Passive Ability
	variable string PassiveAbility = "Racial Inheritance:"
	variable int TankGN

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
	
	member:int TankHealth(string Tank)
	{
		if ${Tank.Find[${Me.FName}]}
			return ${Me.HealthPct}
		
		if ${Me.IsGrouped}
		{
			if ${Tank.Find[${Group[${This.TankGN}].Name}]}
				return ${Group[${This.TankGN}].Health}
			
			variable int i
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				if ${Tank.Find[${Group[${i}].Name}]}
				{
					This.TankGN:Set[${i}]
					return ${Group[${This.TankGN}].Health}
				}
			}
		}
		return 100
	}
}
	
