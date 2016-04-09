;********************************************
/* Add item to the Sell list */
;********************************************
atom(global) AddSell(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA_General].FindSet[Sell]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveSell(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Sell.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildSell()
{
	variable iterator Iterator
	Sell:GetSettingIterator[Iterator]
	UIElement[SellList@SellFrm@Sell@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[SellList@SellFrm@Sell@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;******************************CombatLists***********************
function PopulateSellLists()
{
	variable int i
	UIElement[SellCombo@SellFrm@Sell@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems

	for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
	{
		if ${Me.Inventory[${i}].Flags.Find[No Sell]} > 0
		{
		}
		elseif ${Me.Inventory[${i}].Flags.Find[Quest]} > 0
		{
		}
		else
		{
			UIElement[SellCombo@SellFrm@Sell@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Me.Inventory[${i}].Name}]
		}
	}
}

;********************************************
/* Add item to the Trash list */
;********************************************
atom(global) AddTrash(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA_General].FindSet[Trash]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveTrash(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Trash.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildTrash()
{
	variable iterator Iterator
	Trash:GetSettingIterator[Iterator]
	UIElement[TrashList@TrashFrm@Trash@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[TrashList@TrashFrm@Trash@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}


