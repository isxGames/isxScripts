
atom(global) UpdateBuffWatch()
{
	call PopulateBuffLists

	variable iterator anIter
	DBW:GetSettingIterator[anIter]
	anIter:First
	UIElement[RDBWList@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${anIter.Key(exists)} )
	{
		if !${Me.Effect[${anIter.Key}](exists)}
		{
			UIElement[RDBWList@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${anIter.Key}]
		}
		anIter:Next
	}

	variable iterator Iterator
	BW:GetSettingIterator[Iterator]
	Iterator:First
	UIElement[RBWList@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		if !${Me.Effect[${Iterator.Key}](exists)}
		{
			UIElement[RBWList@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		}
		Iterator:Next
	}
}

atom(global) UpdateTempBuffWatch()
{
	variable iterator anIter
	TBW:GetSettingIterator[anIter]
	anIter:First
	UIElement[RTBWList@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${anIter.Key(exists)} )
	{
		if ${Me.Effect[${anIter.Key}](exists)}
		{
			UIElement[RTBWList@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${anIter.Key}]
		}
		anIter:Next
	}
}

