;********************************************
/* Add item to the FireA list */
;********************************************
atom(global) AddFireA(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[FireA]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveFireA(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		FireA.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildFireA()
{
	variable iterator Iterator
	FireA:GetSettingIterator[Iterator]
	UIElement[FireAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[FireAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the IceA list */
;********************************************
atom(global) AddIceA(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[IceA]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveIceA(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		IceA.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildIceA()
{
	variable iterator Iterator
	IceA:GetSettingIterator[Iterator]
	UIElement[IceAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[IceAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the SpiritualA list */
;********************************************
atom(global) AddSpiritualA(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[SpiritualA]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveSpiritualA(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		SpiritualA.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildSpiritualA()
{
	variable iterator Iterator
	SpiritualA:GetSettingIterator[Iterator]
	UIElement[SpiritualAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[SpiritualAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the PhysicalA list */
;********************************************
atom(global) AddPhysicalA(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[PhysicalA]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		echo ${aName}
	}
}
atom(global) RemovePhysicalA(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		PhysicalA.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildPhysicalA()
{
	variable iterator Iterator
	PhysicalA:GetSettingIterator[Iterator]
	UIElement[PhysicalAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[PhysicalAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the ArcaneA list */
;********************************************
atom(global) AddArcaneA(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[ArcaneA]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		echo ${aName}
	}
}
atom(global) RemoveArcaneA(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		ArcaneA.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildArcaneA()
{
	variable iterator Iterator
	ArcaneA:GetSettingIterator[Iterator]
	UIElement[ArcaneAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ArcaneAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;******************************CombatLists***********************
function PopulateAbilitiesLists()
{
	variable int i

	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		UIElement[FireACombo@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[IceACombo@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[SpiritualACombo@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[PhysicalACombo@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[ArcaneACombo@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
	}
	variable iterator Iterator
	FireA:GetSettingIterator[Iterator]
	UIElement[FireAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[FireAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	IceA:GetSettingIterator[Iterator]
	UIElement[IceAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[IceAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	SpiritualA:GetSettingIterator[Iterator]
	UIElement[SpiritualAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[SpiritualAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	PhysicalA:GetSettingIterator[Iterator]
	UIElement[PhysicalAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[PhysicalAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	ArcaneA:GetSettingIterator[Iterator]
	UIElement[ArcaneAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ArcaneAList@AbilitiesCFrm@Abilities@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}



