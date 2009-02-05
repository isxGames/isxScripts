;********************************************
function BardSong()
{
	if ${Me.Class.Equal[Bard]}
	{
	If ${fight.ShouldIAttack}
		{
     	 	If !${Me.Inventory[${PrimaryWeapon}].CurrentEquipSlot.Equal[Primary Hand]}
       		{
        	Me.Inventory[${PrimaryWeapon}]:Equip[Primary Hand]
        	Waitframe
        	}
      		If !${Me.Inventory[${SecondaryWeapon}].CurrentEquipSlot.Equal[Secondary Hand]}
        	{
         	Me.Inventory[${SecondaryWeapon}]:Equip[Secondary Hand]
         	Waitframe
        	}
		Songs[${FightSong}]:Perform
		}
	If !${fight.ShouldIAttack}
		{
		If ${Me.Inventory[${Drum}].CurrentEquipSlot.Equal[None]}
             	{
               	Wait 10
               	Me.Inventory[${Drum}]:Equip
		wait 3
		}
   		Songs[${RunSong}]:Perform
		}
	}
}