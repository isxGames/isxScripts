function Harvest()
{
	;; Return if we do not want to initiate harvesting
	if !${doAutoAssist} || ${Me.InCombat}
	{
		return
	}

	variable int i = 0

	if ${Me.IsGrouped}
	{
		;; Let's go find someone who is harvesting nearby
		if !${Me.Target(exists)}
		{
			for ( i:Set[1] ; ${Group[${i}].ID(exists)} ; i:Inc )
			{
				;if ${Pawn[id,${Group[${i}].ID}].CombatState}
				if ${Pawn[id,${Group[${i}].ID}].CombatState}>0 && ${Pawn[id,${Group[${i}].ID}].Distance}<5
				{
					vgecho "Harvest Assist"
					CurrentAction:Set[HarvestAssist ${Group[${i}].Name}]
					VGExecute "/cleartargets"
					VGExecute "/assist ${Group[${i}].Name}"
					
			
					;; Must wait a tad bit!
					wait 5
					break
				}
			}
		}
	}
	
	
	
	variable string leftofname
	leftofname:Set[${Me.Target.Name.Left[6]}]
	if "(${Me.Target.Type.Equal[Resource]} || ${Me.Target.IsHarvestable}) && ${Me.Target.Distance}<5 && ${Me.ToPawn.CombatState}==0 && !${leftofname.Equal[remain]}"
	{
		vgecho "Initiate Harvesting"
		VGExecute /autoattack
		wait 10
	}

	if !${GV[bool,bHarvesting]} && ${Me.Ability[Auto Attack].Toggled}
	{
		vgecho "Stop Harvesting"
		VGExecute /autoattack
		VGExecute "/cleartargets"
		wait 10
	}	
}
