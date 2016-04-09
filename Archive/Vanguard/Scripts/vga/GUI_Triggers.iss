;********************************************
/* Add item to the UseAbilT1 list */
;********************************************
atom(global) AddUseAbilT1(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[UseAbilT1]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveUseAbilT1(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		UseAbilT1.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildUseAbilT1()
{
	variable iterator Iterator
	UseAbilT1:GetSettingIterator[Iterator]
	UIElement[UseAbilT1List@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[UseAbilT1List@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the UseItemsT11 list */
;********************************************
atom(global) AddUseItemsT1(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[UseItemsT1]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveUseItemsT1(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		UseItemsT1.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildUseItemsT1()
{
	variable iterator Iterator
	UseItemsT1:GetSettingIterator[Iterator]
	UIElement[UseItemsT1List@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[UseItemsT1List@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the MobDeBuffT1 list */
;********************************************
atom(global) AddMobDeBuffT1(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[MobDeBuffT1]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveMobDeBuffT1(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		MobDeBuffT1.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildMobDeBuffT1()
{
	variable iterator Iterator
	MobDeBuffT1:GetSettingIterator[Iterator]
	UIElement[MobDeBuffT1List@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[MobDeBuffT1List@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the BuffT1 list */
;********************************************
atom(global) AddBuffT1(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[BuffT1]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveBuffT1(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		BuffT1.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildBuffT1()
{
	variable iterator Iterator
	BuffT1:GetSettingIterator[Iterator]
	UIElement[BuffT1List@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[BuffT1List@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the AbilReadyT1 list */
;********************************************
atom(global) AddAbilReadyT1(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[AbilReadyT1]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveAbilReadyT1(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		AbilReadyT1.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildAbilReadyT1()
{
	variable iterator Iterator
	AbilReadyT1:GetSettingIterator[Iterator]
	UIElement[AbilReadyT1List@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[AbilReadyT1List@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;******************************CombatLists***********************
function PopulateTriggersLists()
{
	variable int i
	for (i:Set[1] ; ${i}<=${Me.Effect.Count} ; i:Inc)
	{
		if ${Me.Effect[${i}].IsVisibleOnUI}
		{
			UIElement[BuffT1cmb@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Me.Effect[${i}].Name}]
		}
	}
	for (i:Set[1] ; ${i}<=${Me.TargetBuff} ; i:Inc)
	{
		UIElement[cmbMobBuffT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Me.TargetBuff[${i}].Name}]
	}
	for (i:Set[1] ; ${i}<=${Me.TargetDebuff} ; i:Inc)
	{
		UIElement[MobDeBuffT1cmb@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Me.TargetDebuff[${i}].Name}]
	}
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		UIElement[cmbCritT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[AbilReadyT1cmb@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[MobUseAbilT1cmb@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
	}
	for (i:Set[1] ; ${i} <= ${Me.Form} ; i:Inc)
	{
		UIElement[cmbSwapStanceT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Me.Form[${i}].Name}]
	}
	for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
	{
		UIElement[cmbSWPrimaryT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Me.Inventory[${i}].Name}]
		UIElement[cmbSWSecondaryT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Me.Inventory[${i}].Name}]
		UIElement[UseItemsT1cmb@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Me.Inventory[${i}].Name}]

	}
	for (i:Set[1] ; ${i} <= ${Songs} ; i:Inc)
	{
		UIElement[cmbSwitchSongsT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[${Songs[${i}].Name}]
	}
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Afflicted]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Armor Chink]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Bleeding]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Blindness]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Burning]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Chilled]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Dazed]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Enraged]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Flesh Rend]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Inflamed]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Lethargic]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Mental Lapse]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Mesmerized]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Shaken]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Soul Wracked]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Staggered]
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:AddItem[Vulnerable]
}



