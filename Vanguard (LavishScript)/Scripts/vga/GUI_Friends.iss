;********************************************
/* Add item to the Friends list */
;********************************************
atom(global) AddFriends(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA_General].FindSet[Friends]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveFriends(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Friends.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildFriends()
{
	variable iterator Iterator
	Friends:GetSettingIterator[Iterator]
	UIElement[FriendsList@FriendsCFrm@Friends@InteractionSubTab@InteractionFrm@Interaction@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[FriendsList@FriendsCFrm@Friends@InteractionSubTab@InteractionFrm@Interaction@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}

