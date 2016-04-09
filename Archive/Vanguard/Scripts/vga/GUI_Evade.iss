;*********************************************
/* Add item to the Rescue list */
;********************************************
atom(global) AddRescue(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[Rescue]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveRescue(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Rescue.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildRescue()
{
	variable iterator Iterator
	Rescue:GetSettingIterator[Iterator]
	UIElement[RescueList@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[RescueList@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the ForceRescue list */
;********************************************
atom(global) AddForceRescue(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[ForceRescue]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveForceRescue(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		ForceRescue.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildForceRescue()
{
	variable iterator Iterator
	ForceRescue:GetSettingIterator[Iterator]
	UIElement[ForceRescueList@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ForceRescueList@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}


;********************************************
/* Add item to the Evade1 list */
;********************************************
atom(global) AddEvade1(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[Evade1]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveEvade1(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Evade1.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildEvade1()
{
	variable iterator Iterator
	Evade1:GetSettingIterator[Iterator]
	UIElement[Evade1List@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[Evade1List@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the Evade2 list */
;********************************************
atom(global) AddEvade2(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[Evade2]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveEvade2(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Evade2.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildEvade2()
{
	variable iterator Iterator
	Evade2:GetSettingIterator[Iterator]
	UIElement[Evade2List@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[Evade2List@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;******************************CombatLists***********************
function PopulateEvadeLists()
{
	variable int i

	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		UIElement[Evade1Combo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[Evade2Combo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[Involn1Combo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[Involn2Combo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[FDCombo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[RescueCombo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[ForceRescueCombo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[pushagroCombo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
	}
	for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
	{

		UIElement[ClickieForceCombo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Inventory[${i}].Name}]
	}

	variable iterator Iterator
	Evade1:GetSettingIterator[Iterator]
	UIElement[Evade1List@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[Evade1List@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	Evade2:GetSettingIterator[Iterator]
	UIElement[Evade2List@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[Evade2List@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	Rescue:GetSettingIterator[Iterator]
	UIElement[RescueList@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[RescueList@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	ForceRescue:GetSettingIterator[Iterator]
	UIElement[ForceRescueList@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ForceRescueList@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	variable int rCount
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[Involn1Combo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Items}
	{
		if ${UIElement[Involn1Combo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Item[${rCount}].Text.Equal[${Involn1}]}
		UIElement[Involn1Combo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[Involn2Combo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Items}
	{
		if ${UIElement[Involn2Combo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Item[${rCount}].Text.Equal[${Involn2}]}
		UIElement[Involn2Combo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[FDCombo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Items}
	{
		if ${UIElement[FDCombo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Item[${rCount}].Text.Equal[${FD}]}
		UIElement[FDCombo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[pushagroCombo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Items}
	{
		if ${UIElement[pushagroCombo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Item[${rCount}].Text.Equal[${agropush}]}
		UIElement[pushagroCombo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[ClickieForceCombo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Items}
	{
		if ${UIElement[ClickieForceCombo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Item[${rCount}].Text.Equal[${ClickieForce}]}
		UIElement[ClickieForceCombo@AgroCFrm@Agro@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:SelectItem[${rCount}]
	}

}


