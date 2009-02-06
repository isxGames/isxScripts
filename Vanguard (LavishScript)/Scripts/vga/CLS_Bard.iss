;********************************************
function BardSong()
{
	if ${Me.Class.Equal[Bard]}
	{
	If ${fight.ShouldIAttack} && !${Me.Effect[${Me.FName}'s Bard Song - "${FightSong}"](exists)}
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
	If !${fight.ShouldIAttack} && !${Me.Effect[${Me.FName}'s Bard Song - "${RunSong}"](exists)}
		{
  	             	Me.Inventory[${Drum}]:Equip
			wait 3
			Songs[${RunSong}]:Perform
		}
	}
}