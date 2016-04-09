;********************************************
/* Add item to the Fire list */
;********************************************
atom(global) AddFire(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA_Mobs].FindSet[Fire]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveFire(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Fire.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildFire()
{
	variable iterator Iterator
	Fire:GetSettingIterator[Iterator]
	UIElement[FireList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[FireList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the Ice list */
;********************************************
atom(global) AddIce(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA_Mobs].FindSet[Ice]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveIce(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Ice.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildIce()
{
	variable iterator Iterator
	Ice:GetSettingIterator[Iterator]
	UIElement[IceList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[IceList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the Spiritual list */
;********************************************
atom(global) AddSpiritual(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA_Mobs].FindSet[Spiritual]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveSpiritual(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Spiritual.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildSpiritual()
{
	variable iterator Iterator
	Spiritual:GetSettingIterator[Iterator]
	UIElement[SpiritualList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[SpiritualList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the Physical list */
;********************************************
atom(global) AddPhysical(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA_Mobs].FindSet[Physical]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		echo ${aName}
	}
}
atom(global) RemovePhysical(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Physical.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildPhysical()
{
	variable iterator Iterator
	Physical:GetSettingIterator[Iterator]
	UIElement[PhysicalList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[PhysicalList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the Arcane list */
;********************************************
atom(global) AddArcane(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA_Mobs].FindSet[Arcane]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		echo ${aName}
	}
}
atom(global) RemoveArcane(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Arcane.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildArcane()
{
	variable iterator Iterator
	Arcane:GetSettingIterator[Iterator]
	UIElement[ArcaneList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ArcaneList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;******************************CombatLists***********************
function PopulateMobLists()
{

	variable iterator Iterator
	Fire:GetSettingIterator[Iterator]
	UIElement[FireList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[FireList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	Ice:GetSettingIterator[Iterator]
	UIElement[IceList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[IceList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	Spiritual:GetSettingIterator[Iterator]
	UIElement[SpiritualList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[SpiritualList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	Physical:GetSettingIterator[Iterator]
	UIElement[PhysicalList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[PhysicalList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	Arcane:GetSettingIterator[Iterator]
	UIElement[ArcaneList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ArcaneList@MobsCFrm@Mobs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}



