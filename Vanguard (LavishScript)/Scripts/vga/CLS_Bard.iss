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
            Me.Inventory[${Drum}]:Unequip
            wait 5
     	 		If !${Me.Inventory[${PrimaryWeapon}].CurrentEquipSlot.Equal[Primary Hand]}
       				{
        			Me.Inventory[${PrimaryWeapon}]:Equip[Primary Hand]
        			wait 4
        			}
      			If !${Me.Inventory[${SecondaryWeapon}].CurrentEquipSlot.Equal[Secondary Hand]}
        			{
         			Me.Inventory[${SecondaryWeapon}]:Equip[Secondary Hand]
         			wait 5
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
;********************************************
function Bard_Burst()
{

}
