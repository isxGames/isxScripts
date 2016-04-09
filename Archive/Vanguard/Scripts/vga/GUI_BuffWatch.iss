;********************************************
/* Add item to the TBW list */
;********************************************
atom(global) AddTBW(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA_General].FindSet[TBW]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveTBW(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		TBW.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildTBW()
{
	variable iterator Iterator
	TBW:GetSettingIterator[Iterator]
	UIElement[TBWList@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[TBWList@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the DBW list */
;********************************************
atom(global) AddDBW(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA_General].FindSet[DBW]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveDBW(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		DBW.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildDBW()
{
	variable iterator Iterator
	DBW:GetSettingIterator[Iterator]
	UIElement[DBWList@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DBWList@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the BW list */
;********************************************
atom(global) AddBW(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA_General].FindSet[BW]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveBW(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		BW.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildBW()
{
	variable iterator Iterator
	BW:GetSettingIterator[Iterator]
	UIElement[BWList@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[BWList@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;******************************CombatLists***********************
function PopulateBuffLists()
{
	variable int i
	UIElement[BWCombo@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	UIElement[TBWCombo@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	UIElement[DBWCombo@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	for (i:Set[1] ; ${i}<=${Me.Effect.Count} ; i:Inc)
	{
		if ${Me.Effect[${i}].IsVisibleOnUI}
		{
			UIElement[TBWCombo@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Me.Effect[${i}].Name}]
		}
		if ${Me.Effect[${i}].IsVisibleOnUI} && !${Me.Effect[${i}].Name.Find[Civic]}
		{
			UIElement[BWCombo@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Me.Effect[${i}].Name}]
		}
		if ${Me.Effect[${i}].IsVisibleOnUI} && ${Me.Effect[${i}].Name.Find[Civic]}
		{
			UIElement[DBWCombo@BuffWatchFrm@BuffWatch@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${Me.Effect[${i}].Name}]
		}
	}
}



