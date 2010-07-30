
function:bool HandleEncounters()
{
	if ${Me.Encounter}>0
	{
		variable int i
		variable int j = 0
		variable int k = 0

		;; Switch targets if an Encounter is not targeting self
		if ${Me.IsGrouped}
		{
			if ${doAutoAssist}
			{
				for ( i:Set[1] ; ${i}<=${Me.Encounter} ; i:Inc )
				{
					;; Hit target's that are not targetting me as long as my target is targting me
					if ${Me.Encounter[${i}].Distance}<5 && !${Me.FName.Equal[${Me.Encounter[${i}].Target}]} && ${Me.FName.Equal[${Me.ToT}]} && ${Me.Encounter[${i}].Health}>10
					{
						EchoIt "TargetNearestEncounter - Switching to ${Me.Encounter[${i}].Name} who's on ${Me.Encounter[${i}].Target}"
				
						;; change targets to target not targeting me
						Pawn[ID,${Me.Encounter[${i}].ID}]:Target
						wait 5

						;; face our target
						face ${Pawn[id,${Me.Target.ID}].X} ${Pawn[ID,${Me.Target.ID}].Y}
						return TRUE
					}
				}
			}
		}

		;; find a closer Encounter if target moved 10 meters away
		if !${Me.IsGrouped}
		{
			if ${Me.Target.Distance}>10
			{
				j:Set[${Me.Target.Distance}]
				k:Set[1]
				for (i:Set[1] ; ${i}<=${Me.Encounter} ; i:Inc )
				{
					if ${Me.Encounter[${i}].Distance}<${j}
					{
						j:Set[${Me.Encounter[${i}].Distance}]
						k:Set[${i}]
					}
				}
				Pawn[id,${Me.Encounter[${k}].ID}]:Target
				wait 5
				return TRUE
			}
		}
	
		;; Target nearest encounter
		if !${Me.Target(exists)}
		{
			j:Set[50]
			k:Set[1]
			for (i:Set[1] ; ${i}<=${Me.Encounter} ; i:Inc )
			{
				if ${Me.Encounter[${i}].Distance}<${j}
				{
					j:Set[${Me.Encounter[${i}].Distance}]
					k:Set[${i}]
				}
			}
			Pawn[id,${Me.Encounter[${k}].ID}]:Target
			wait 5
			return TRUE
		}
	}
	return FALSE
}

