
function main()
{

	
	while 1
	{
		ExecuteQueued
		
		Me:CreateCustomInventoryArray[nonbankonly]
	}
	waitframe
}

function RefreshInventoryQueue()
{
	call RefreshInventory
	wait 10
	call RefreshInventory
	wait 10
	call RefreshInventory
}

function RefreshInventory()
{
	variable int ArrayPosition=1
	UIElement[FullInventoryListBox@Potions_Frame@bjxpbotsettings]:ClearItems
	call AddItemtoInvList 

	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize}
	{
		if !${Me.CustomInventory[${ArrayPosition}].IsContainer} 
		{
			if ${Me.CustomInventory[${ArrayPosition}].InInventory}
			{
				if ${Me.CustomInventory[${ArrayPosition}].Heirloom} || ${Me.CustomInventory[${ArrayPosition}].NoTrade}
				{
					if ${Me.CustomInventory[${ArrayPosition}].NoValue}
					{
						call AddItemtoInvList "${Me.CustomInventory[${ArrayPosition}].Name}"
					}	
				}	
		  	}
		}
	}
}
function AddItemtoInvList(string textline)
{
	UIElement[FullInventoryListBox@Potions_Frame@bjxpbotsettings]:AddItem[${textline}]
}

function atexit()
{

}
