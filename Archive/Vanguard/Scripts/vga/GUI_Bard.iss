
function Bard_GUI()
{
	variable int i

	for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
	{
		UIElement[cmbSWDrum@bardfrm@ClassFrm@Class@ABot@vga_gui]:AddItem[${Me.Inventory[${i}].Name}]
		UIElement[cmbSWSecondaryWeapon@bardfrm@ClassFrm@Class@ABot@vga_gui]:AddItem[${Me.Inventory[${i}].Name}]
		UIElement[cmbSWPrimaryWeapon@bardfrm@ClassFrm@Class@ABot@vga_gui]:AddItem[${Me.Inventory[${i}].Name}]
	}
	for (i:Set[1] ; ${i} <= ${Songs} ; i:Inc)
	{
		UIElement[cmbSWFightSong@bardfrm@ClassFrm@Class@ABot@vga_gui]:AddItem[${Songs[${i}].Name}]
		UIElement[cmbSWRunSong@bardfrm@ClassFrm@Class@ABot@vga_gui]:AddItem[${Songs[${i}].Name}]
	}

	variable int rCount
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[cmbSWRunSong@bardfrm@ClassFrm@Class@ABot@vga_gui].Items}
	{
		if ${UIElement[cmbSWRunSong@bardfrm@ClassFrm@Class@ABot@vga_gui].Item[${rCount}].Text.Equal[${RunSong}]}
		UIElement[cmbSWRunSong@bardfrm@ClassFrm@Class@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[cmbSWFightSong@bardfrm@ClassFrm@Class@ABot@vga_gui].Items}
	{
		if ${UIElement[cmbSWFightSong@bardfrm@ClassFrm@Class@ABot@vga_gui].Item[${rCount}].Text.Equal[${FightSong}]}
		UIElement[cmbSWFightSong@bardfrm@ClassFrm@Class@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[cmbSWPrimaryWeapon@bardfrm@ClassFrm@Class@ABot@vga_gui].Items}
	{
		if ${UIElement[cmbSWPrimaryWeapon@bardfrm@ClassFrm@Class@ABot@vga_gui].Item[${rCount}].Text.Equal[${PrimaryWeapon}]}
		UIElement[cmbSWPrimaryWeapon@bardfrm@ClassFrm@Class@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[cmbSWSecondaryWeapon@bardfrm@ClassFrm@Class@ABot@vga_gui].Items}
	{
		if ${UIElement[cmbSWSecondaryWeapon@bardfrm@ClassFrm@Class@ABot@vga_gui].Item[${rCount}].Text.Equal[${SecondaryWeapon}]}
		UIElement[cmbSWSecondaryWeapon@bardfrm@ClassFrm@Class@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[cmbSWDrum@bardfrm@ClassFrm@Class@ABot@vga_gui].Items}
	{
		if ${UIElement[cmbSWDrum@bardfrm@ClassFrm@Class@ABot@vga_gui].Item[${rCount}].Text.Equal[${Drum}]}
		UIElement[cmbSWDrum@bardfrm@ClassFrm@Class@ABot@vga_gui]:SelectItem[${rCount}]
	}
}



