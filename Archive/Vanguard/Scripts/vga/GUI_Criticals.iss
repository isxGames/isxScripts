

;********************************************
/* Add item to the CombatCrits list */
;********************************************
atom(global) AddCombatCrits(string aName)
{
	;echo "AddCombatCrits: '${aName}"
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[CombatCrits]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveCombatCrits(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		CombatCrits.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildCombatCrits()
{
	variable iterator Iterator
	CombatCrits:GetSettingIterator[Iterator]
	UIElement[CombatCritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		;echo "BuildCombatCrits() :: ${Iterator.Key}"
		UIElement[CombatCritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the DotCrits list */
;********************************************
atom(global) AddDotCrits(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[DotCrits]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveDotCrits(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		DotCrits.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildDotCrits()
{
	variable iterator Iterator
	DotCrits:GetSettingIterator[Iterator]
	UIElement[DotCritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DotCritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the BuffCrits list */
;********************************************
atom(global) AddBuffCrits(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[BuffCrits]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveBuffCrits(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		BuffCrits.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildBuffCrits()
{
	variable iterator Iterator
	BuffCrits:GetSettingIterator[Iterator]
	UIElement[BuffCritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[BuffCritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the AOECrits list */
;********************************************
atom(global) AddAOECrits(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[AOECrits]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		echo ${aName}
	}
}
atom(global) RemoveAOECrits(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		AOECrits.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildAOECrits()
{
	variable iterator Iterator
	AOECrits:GetSettingIterator[Iterator]
	UIElement[AOECritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[AOECritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the CounterAttack list */
;********************************************
atom(global) AddCounterAttack(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[CounterAttack]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		echo ${aName}
	}
}
atom(global) RemoveCounterAttack(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		CounterAttack.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildCounterAttack()
{
	variable iterator Iterator
	CounterAttack:GetSettingIterator[Iterator]
	UIElement[CounterAttackList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[CounterAttackList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;******************************CombatLists***********************
function PopulateCritsLists()
{
	variable int i

	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		UIElement[CombatCritsCombo@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[DotCritsCombo@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[BuffCritsCombo@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[AOECritsCombo@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[CounterAttackCombo@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
	}
	variable iterator Iterator
	CombatCrits:GetSettingIterator[Iterator]
	UIElement[CombatCritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[CombatCritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	DotCrits:GetSettingIterator[Iterator]
	UIElement[DotCritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DotCritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	BuffCrits:GetSettingIterator[Iterator]
	UIElement[BuffCritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[BuffCritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	AOECrits:GetSettingIterator[Iterator]
	UIElement[AOECritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[AOECritsList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	CounterAttack:GetSettingIterator[Iterator]
	UIElement[CounterAttackList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[CounterAttackList@CritsCFrm@Crits@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}


