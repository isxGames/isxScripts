variable bool doTurnOffAttack
variable bool doDispell
variable bool doStancePush
variable bool doClickies
variable bool doCounter

;********************************************
/* Add item to the TurnOffAttack list */
;********************************************
atom(global) AddTurnOffAttack(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[TurnOffAttack]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveTurnOffAttack(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		TurnOffAttack.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildTurnOffAttack()
{
	variable iterator Iterator
	TurnOffAttack:GetSettingIterator[Iterator]
	UIElement[TurnOffAttackList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[TurnOffAttackList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}  
;********************************************
/* Add item to the Dispell list */
;********************************************
atom(global) AddDispell(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[Dispell]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveDispell(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Dispell.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildDispell()
{
	variable iterator Iterator
	Dispell:GetSettingIterator[Iterator]
	UIElement[DispellList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DispellList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}  
;********************************************
/* Add item to the StancePush list */
;********************************************
atom(global) AddStancePush(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[StancePush]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveStancePush(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		StancePush.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildStancePush()
{
	variable iterator Iterator
	StancePush:GetSettingIterator[Iterator]
	UIElement[StancePushList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[StancePushList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}  
;********************************************
/* Add item to the Clickies list */
;********************************************
atom(global) AddClickies(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[Clickies]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveClickies(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Clickies.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildClickies()
{
	variable iterator Iterator
	Clickies:GetSettingIterator[Iterator]
	UIElement[ClickiesList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ClickiesList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}  
;********************************************
/* Add item to the Counter list */
;********************************************
atom(global) AddCounter(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[Counter]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveCounter(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Clickies.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildCounter()
{
	variable iterator Iterator
	Counter:GetSettingIterator[Iterator]
	UIElement[CounterList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[CounterList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
} 
;******************************CombatLists***********************
function PopulateCombatMainLists()
{
	variable int i

	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].Type.Equal[Spell]}
			{
			UIElement[TurnOffAttackCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[DispellCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[StancePushCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
UIElement[CounterCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			}
	}
	for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
	{
		     UIElement[ClickiesCombo@CombatMain@CombatSubTab@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Inventory[${i}].Name}]
	}
	variable iterator Iterator
	Clickies:GetSettingIterator[Iterator]
	UIElement[ClickiesList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ClickiesList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	StancePush:GetSettingIterator[Iterator]
	UIElement[StancePushList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[StancePushList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	Dispell:GetSettingIterator[Iterator]
	UIElement[DispellList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DispellList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	TurnOffAttack:GetSettingIterator[Iterator]
	UIElement[TurnOffAttackList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[TurnOffAttackList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	Counter:GetSettingIterator[Iterator]
	UIElement[CounterList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[CounterList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}

}
;=================================================
function LoadCombatMain()
{
Clickies:Set[${LavishSettings[VGA].FindSet[Clickies]}]
Dispell:Set[${LavishSettings[VGA].FindSet[Dispell]}]
StancePush:Set[${LavishSettings[VGA].FindSet[StancePush]}]
TurnOffAttack:Set[${LavishSettings[VGA].FindSet[TurnOffAttack]}]
Counter:Set[${LavishSettings[VGA].FindSet[Counter]}]

doClickies:Set[${SpellSR.FindSetting[doClickies]}]
doDispell:Set[${SpellSR.FindSetting[doDispell]}]
doStancePush:Set[${SpellSR.FindSetting[doStancePush]}]
doTurnOffAttack:Set[${SpellSR.FindSetting[doTurnOffAttack]}]
doCounter:Set[${SpellSR.FindSetting[doCounter]}]

}
;=================================================
function SaveCombatMain()
{
SpellSR:AddSetting[doClickies,${doClickies}]
SpellSR:AddSetting[doDispell,${doDispell}]
SpellSR:AddSetting[doStancePush,${doStancePush}]
SpellSR:AddSetting[doTurnOffAttack,${doTurnOffAttack}]
}
