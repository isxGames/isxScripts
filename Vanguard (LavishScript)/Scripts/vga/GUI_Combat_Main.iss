;********************************************
/* Add item to Counter list */
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
		Counter.FindSetting[${aName}]:Remove
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
/* Add item to the TurnOffDuringBuff list */
;********************************************
atom(global) AddTurnOffDuringBuff(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[TurnOffDuringBuff]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveTurnOffDuringBuff(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		TurnOffDuringBuff.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildTurnOffDuringBuff()
{
	variable iterator Iterator
	TurnOffDuringBuff:GetSettingIterator[Iterator]
	UIElement[TurnOffDuringBuffList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[TurnOffDuringBuffList@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
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
;******************************CombatLists***********************
function PopulateCombatMainLists()
{
	variable int i

	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		UIElement[DispellCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[PushStanceCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[CounterSpell1Combo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[CounterSpell2Combo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
	}

	variable iterator Iterator
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
	variable int rCount
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[DispellCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Items}
	{
		if ${UIElement[DispellCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Item[${rCount}].Text.Equal[${DispellSpell}]}
		UIElement[DispellCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[PushStanceCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Items}
	{
		if ${UIElement[PushStanceCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Item[${rCount}].Text.Equal[${PushStanceSpell}]}
		UIElement[PushStanceCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[CounterSpell1Combo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Items}
	{
		if ${UIElement[CounterSpell1Combo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Item[${rCount}].Text.Equal[${CounterSpell1}]}
		UIElement[CounterSpell1Combo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[CounterSpell2Combo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Items}
	{
		if ${UIElement[CounterSpell2Combo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Item[${rCount}].Text.Equal[${CounterSpell2}]}
		UIElement[CounterSpell2Combo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:SelectItem[${rCount}]
	}

	for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
	{
		if (${Me.Inventory[${i}].Name(exists)})
		{
			UIElement[ClickiesCombo@CombatCFrm@CombatMain@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Inventory[${i}].Name}]
		}
	}
}



