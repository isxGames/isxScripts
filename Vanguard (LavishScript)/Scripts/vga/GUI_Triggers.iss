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
	UIElement[cmbWeaknessT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	UIElement[cmbCritT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	UIElement[AbilReadyT1cmb@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	UIElement[BuffT1cmb@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	UIElement[MobDeBuffT1cmb@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	UIElement[cmbMobBuffT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	UIElement[cmbSwapStanceT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	UIElement[cmbSwitchSongsT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	UIElement[cmbSWPrimaryT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	UIElement[cmbSWSecondaryT1@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	UIElement[UseItemsT1cmb@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems
	UIElement[MobUseAbilT1cmb@1Frm@1@TriggersSubTab@TriggersFrm@Triggers@ABot@vga_gui]:ClearItems

	for (i:Set[1] ; ${i}<=${Me.Effect.Count} ; i:Inc)
	{
		if ${Me.Effect[${i}].IsVisibleOnUI}
			{
			UIElement[BWCombo@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Me.Effect[${i}].Name}]
			UIElement[DBWCombo@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Me.Effect[${i}].Name}]
			UIElement[TBWCombo@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Me.Effect[${i}].Name}]
			}
	}
}

