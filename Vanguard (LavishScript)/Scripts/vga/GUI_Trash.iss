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

