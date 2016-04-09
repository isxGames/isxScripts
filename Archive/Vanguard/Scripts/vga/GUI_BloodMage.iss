function BloodMage_GUI()
{
	variable int i
	variable int rCount

	;;; Populate Combo Boxes ;;;
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if (${Me.Ability[${i}].Name.Find[Mental Transmutation]})
		UIElement[cmbHealthToEnergySpell@bloodmagefrm@ClassFrm@Class@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		elseif (${Me.Ability[${i}].Name.Find[Despoil]} || ${Me.Ability[${i}].Name.Find[Entwining Vein]})
		{
			UIElement[cmbBMSingleTargetLifeTap1@bloodmagefrm@ClassFrm@Class@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[cmbBMSingleTargetLifeTap2@bloodmagefrm@ClassFrm@Class@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		}
		elseif (${Me.Ability[${i}].Name.Find[Scarlet Ritual]})
		UIElement[cmbBMBloodUnionDumpDPSSpell@bloodmagefrm@ClassFrm@Class@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		elseif (${Me.Ability[${i}].Name.Find[Flesh Mender's Ritual]})
		UIElement[cmbBMBloodUnionSingleTargetHOT@bloodmagefrm@ClassFrm@Class@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
	}

	;;; Select Proper Item in Combo Boxes ;;;
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[cmbHealthToEnergySpell@bloodmagefrm@ClassFrm@Class@ABot@vga_gui].Items}
	{
		if ${UIElement[cmbHealthToEnergySpell@bloodmagefrm@ClassFrm@Class@ABot@vga_gui].Item[${rCount}].Text.Equal[${BMHealthToEnergySpell}]}
		UIElement[cmbHealthToEnergySpell@bloodmagefrm@ClassFrm@Class@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[cmbBMBloodUnionDumpDPSSpell@bloodmagefrm@ClassFrm@Class@ABot@vga_gui].Items}
	{
		if ${UIElement[cmbBMBloodUnionDumpDPSSpell@bloodmagefrm@ClassFrm@Class@ABot@vga_gui].Item[${rCount}].Text.Equal[${BMBloodUnionDumpDPSSpell}]}
		UIElement[cmbBMBloodUnionDumpDPSSpell@bloodmagefrm@ClassFrm@Class@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[cmbBMSingleTargetLifeTap1@bloodmagefrm@ClassFrm@Class@ABot@vga_gui].Items}
	{
		if ${UIElement[cmbBMSingleTargetLifeTap1@bloodmagefrm@ClassFrm@Class@ABot@vga_gui].Item[${rCount}].Text.Equal[${BMSingleTargetLifeTap1}]}
		UIElement[cmbBMSingleTargetLifeTap1@bloodmagefrm@ClassFrm@Class@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[cmbBMSingleTargetLifeTap2@bloodmagefrm@ClassFrm@Class@ABot@vga_gui].Items}
	{
		if ${UIElement[cmbBMSingleTargetLifeTap2@bloodmagefrm@ClassFrm@Class@ABot@vga_gui].Item[${rCount}].Text.Equal[${BMSingleTargetLifeTap2}]}
		UIElement[cmbBMSingleTargetLifeTap2@bloodmagefrm@ClassFrm@Class@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[cmbBMBloodUnionSingleTargetHOT@bloodmagefrm@ClassFrm@Class@ABot@vga_gui].Items}
	{
		if ${UIElement[cmbBMBloodUnionSingleTargetHOT@bloodmagefrm@ClassFrm@Class@ABot@vga_gui].Item[${rCount}].Text.Equal[${BMBloodUnionSingleTargetHOT}]}
		UIElement[cmbBMBloodUnionSingleTargetHOT@bloodmagefrm@ClassFrm@Class@ABot@vga_gui]:SelectItem[${rCount}]
	}
}


