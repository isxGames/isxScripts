;********************************************
function Bard_DownTime()
{
	If !${fight.ShouldIAttack} && !${Me.Effect[${Me.FName}'s Bard Song - "${RunSong}"](exists)}
		{
		Me.Inventory[${Drum}]:Equip			
		wait 3			
		Songs[${RunSong}]:Perform		
		}
}
;*******************************************
function Bard_PreCombat()
{

}
;********************************************
function Bard_Opener()
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
}
;********************************************
function Bard_Combat()
{

}
;********************************************
function Bard_Emergency()
{

}
;********************************************
function Bard_PostCombat()
{

}
;********************************************
function Bard_PostCasting()
{

}
