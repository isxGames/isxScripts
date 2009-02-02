;********************************************
function BardSong()
{
	if ${Me.Class.Equal[Bard]}
	{
	If ${fight.ShouldIAttack}
		{
     	 	If !${Me.Inventory[Bone Saw].CurrentEquipSlot.Equal[Primary Hand]}
       		{
        	Me.Inventory[Bone Saw]:Equip[Primary Hand]
        	Waitframe
        	}
      		If !${Me.Inventory[Djarn's Longsword of Accuracy].CurrentEquipSlot.Equal[Secondary Hand]}
        	{
         	Me.Inventory[Djarn's Longsword of Accuracy]:Equip[Secondary Hand]
         	Waitframe
        	}
		Songs[DPS]:Perform
		}
	If !${fight.ShouldIAttack}
		{
		If ${Me.Inventory[Drum of Separation].CurrentEquipSlot.Equal[None]}
             	{
               	Wait 10
               	Me.Inventory[Drum of Separation]:Equip
		wait 3
		}
   		Songs[Run]:Perform
		}
	}
}