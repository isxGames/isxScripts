


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
	UIElement[Evade1List@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[Evade1List@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
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
	UIElement[Evade2List@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[Evade2List@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}  
;******************************CombatLists***********************
function PopulateEvadeLists()
{
	variable int i

	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
			UIElement[Evade1Combo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[Evade2Combo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[Involn1Combo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[Involn2Combo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[FDCombo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
	}
	variable iterator Iterator
	Evade1:GetSettingIterator[Iterator]
	UIElement[Evade1List@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[Evade1List@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	Evade2:GetSettingIterator[Iterator]
	UIElement[Evade2List@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[Evade2List@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	variable int rCount
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[Involn1Combo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Items}
	{
		if ${UIElement[Involn1Combo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Item[${rCount}].Text.Equal[${Involn1}]}
			UIElement[Involn1Combo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[Involn2Combo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Items}
	{
		if ${UIElement[Involn2Combo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Item[${rCount}].Text.Equal[${Involn2}]}
			UIElement[Involn2Combo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[FDCombo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Items}
	{
		if ${UIElement[FDCombo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Item[${rCount}].Text.Equal[${FD}]}
			UIElement[FDCombo@EvadeCFrm@Evade@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:SelectItem[${rCount}]
	}

}
;=================================================
function LoadEvade()
{


}
;=================================================
function SaveEvade()
{


}
