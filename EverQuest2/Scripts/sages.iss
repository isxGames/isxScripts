function main() 
{
	variable int Count
	variable int target
	declare called[6] bool
	echo Starting sages script.
		
	do
	{
		Count:Set[1] 

		do
		{
			if ${Me.Group[${Count}](exists)} && ${Me.Group[${Count}].Noxious} < 0
			{
				echo Curing ${Me.Group[${Count}].Name}
					
				Echo Saving Current Target ${Me.Target.Name}
				target:Set[${Target.ID}]
				Me.Group[${Count}]:DoTarget
				
				echo Targeting ${Me.Group[${Count}].Name}
				wait 20 ${Target.ID}==${Me.Group[${Count}].ID}
				
				Echo Potting
				EQ2Execute "/cancel_spellcast"
				Me.Inventory[Necrotic Flashpot]:Use
				
				wait 5
				
				Echo Retargeting Actor[${target}].Name
				Actor[${target}]:DoTarget
				wait 5  ${Target.ID}==${Actor[${target}].ID}
				
			}
		}		
		while ${Count:Inc}<=6
	} 
	while 1
	
	echo Exiting sages script.
}