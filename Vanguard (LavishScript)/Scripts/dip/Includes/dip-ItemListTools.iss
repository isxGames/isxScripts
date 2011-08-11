;===================================================
;===          ATOM - Add Item to List           ====
;===================================================
atom(global) AddItemList(string AddItem)
{
	if ${AddItem.Length} > 1
	{
		;; cut down on the loading times
		if !${LavishSettings[AddItem].FindSet[ItemList](exists)}
		{
			;; build and import ItemList
			LavishSettings[AddItem]:Clear
			LavishSettings:AddSet[AddItem]
			LavishSettings[AddItem]:AddSet[ItemList]
			LavishSettings[AddItem]:Import[${Script.CurrentDirectory}/Save/ItemList.xml]
		}

		;; do only if item does not exist in our item list
		if !${LavishSettings[AddItem].FindSet[ItemList].FindSetting[${AddItem}](exists)}
		{
			;; add item to settings
			LavishSettings[AddItem].FindSet[ItemList]:AddSetting[${AddItem}, ${AddItem}]
				
			;; save and clear settings
			LavishSettings[AddItem]:Export[${Script.CurrentDirectory}/Save/ItemList.xml]
			LavishSettings[AddItem]:Clear
		
			;; don't forget to clear these
			LavishSettings[SellItem]:Clear
			LavishSettings[DeleteItem]:Clear
			
			;; repopulate our window
			PopulateItemList "ItemList@Items@DipTabs@Diplo"
		}
	}
}

;===================================================
;===        ATOM - Remove item from list        ====
;===================================================
atom(global) RemoveItemList(string RemoveItem)
{
	if ${RemoveItem.Length} > 1
	{
		;; cut down on the loading times
		if !${LavishSettings[RemoveItem].FindSet[ItemList](exists)}
		{
			;; build and import ItemList
			LavishSettings[RemoveItem]:Clear
			LavishSettings:AddSet[RemoveItem]
			LavishSettings[RemoveItem]:AddSet[ItemList]
			LavishSettings[RemoveItem]:Import[${Script.CurrentDirectory}/Save/ItemList.xml]
		}

		;; do only if item exists in our item list
		if ${LavishSettings[RemoveItem].FindSet[ItemList].FindSetting[${RemoveItem}](exists)}
		{
			;; remove item to settings
			LavishSettings[RemoveItem].FindSet[ItemList].FindSetting[${RemoveItem}]:Remove
					
			;; save and clear settings
			LavishSettings[RemoveItem]:Export[${Script.CurrentDirectory}/Save/ItemList.xml]
			LavishSettings[RemoveItem]:Clear

			;; don't forget to clear these
			LavishSettings[SellItem]:Clear
			LavishSettings[DeleteItem]:Clear
		}
	}
}

;===================================================
;===        ATOM - Populate item list           ====
;===================================================
atom(global) PopulateItemList(string UIElementXML)
{
	;; build and import ItemList
	LavishSettings[PopulateItem]:Clear
	LavishSettings:AddSet[PopulateItem]
	LavishSettings[PopulateItem]:AddSet[ItemList]
	LavishSettings[PopulateItem]:Import[${Script.CurrentDirectory}/Save/ItemList.xml]
					
	;; set our settingsetref to ItemList
	variable settingsetref ItemList
	ItemList:Set[${LavishSettings[PopulateItem].FindSet[ItemList]}]

	;; set our iterator to ItemList
	variable iterator Iterator
	ItemList:GetSettingIterator[Iterator]
	
	;; clear our UIElementXML ItemList 
	UIElement[${UIElementXML}]:ClearItems
	
	;; iterate through ItemList
	while ${Iterator.Key(exists)}
	{
		UIElement[${UIElementXML}]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	LavishSettings[PopulateItem]:Clear
}

;===================================================
;===      FUNCTION - Sell Items in List         ====
;===================================================
function SellItemList()
{
	;; Sell items only if Merchant is in BuySell dialog
	if ${Me.Target.Type.Equal[Merchant]}
	{
		;; if not in BuySell dialog then...
		if !${Merchant.NumItemsForSale}>0
		{
			;; make sure we are out of bag space
			if ${Me.InventorySlotsOpen}<=5
			{
				;PlaySound ALARM
				;; open BuySell dialog with merchant
				Pawn[${Me.Target.Name}]:DoubleClick
				wait 3
				Merchant:Begin[BuySell]
				wait 5
			}
		}

		;; sell only of BuySell dialog is up
		if ${Merchant.NumItemsForSale}>0
		{
			;; cut down on the loading times
			if !${LavishSettings[SellItem].FindSet[ItemList](exists)}
			{
				;; build and import ItemList
				LavishSettings[SellItem]:Clear
				LavishSettings:AddSet[SellItem]
				LavishSettings[SellItem]:AddSet[ItemList]
				LavishSettings[SellItem]:Import[${Script.CurrentDirectory}/Save/ItemList.xml]
			}
							
			;; set our settingsetref to ItemList
			variable settingsetref ItemList
			ItemList:Set[${LavishSettings[SellItem].FindSet[ItemList]}]

			;; set our iterator to ItemList
			variable iterator Iterator
			ItemList:GetSettingIterator[Iterator]
						
			;; iterate through ItemList
			while ${Iterator.Key(exists)}
			{
				;; we only want to sell items existing in our inventory
				if ${Me.Inventory[exactname,${Iterator.Key}](exists)}
				{
					;; skip diplo papers - that will be handled separately
					if !${Me.Inventory[exactname,${Iterator.Key}].Description.Find[would have an interest in this]}>0
					{
						;; sell anything that is not Unique, No Trade, No Sell, No Rent, and Quest items in the list
						if !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[Unique]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Trade]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Rent]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Sell]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[Quest]}>0
						{
							EchoIt "Selling: ${Iterator.Key}"
							while ${Me.Inventory[exactname,${Iterator.Key}](exists)} && ${doAutoSell}
							{
								;; some items will not sell if you set the quantity to the reported quantity
								Me.Inventory[exactname,${Iterator.Key}]:Sell[1]
								wait 2
							}
						}
					}
				}
						
				;; get next iterator
				Iterator:Next
			}
		}
	}
	
	;; make sure we are out of bag space
	if ${Me.InventorySlotsOpen}<=5
	{
		PlaySound ALARM
		dipPause
	}
}

;===================================================
;===   FUNCTION - Delete No Sell listed items   ====
;===================================================
function DeleteItemList()
{
	;; cut down on the loading times
	if !${LavishSettings[DeleteItem].FindSet[ItemList](exists)}
	{
		;; build and import ItemList
		LavishSettings[DeleteItem]:Clear
		LavishSettings:AddSet[DeleteItem]
		LavishSettings[DeleteItem]:AddSet[ItemList]
		LavishSettings[DeleteItem]:Import[${Script.CurrentDirectory}/Save/ItemList.xml]
	}
					
	;; set our settingsetref to ItemList
	variable settingsetref ItemList
	ItemList:Set[${LavishSettings[DeleteItem].FindSet[ItemList]}]

	;; set our iterator to ItemList
	variable iterator Iterator
	ItemList:GetSettingIterator[Iterator]
				
	;; iterate through ItemList
	while ${Iterator.Key(exists)}
	{
		;; we only want to delete items existing in our inventory
		if ${Me.Inventory[exactname,${Iterator.Key}](exists)}
		{
			;; skip diplo papers - that will be handled separately
			if !${Me.Inventory[exactname,${Iterator.Key}].Description.Find[would have an interest in this]}>0
			{
				;; delete only: Unique, No Trade, No Sell, No Rent, and Quest items in list
				if ${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[Unique]}>0 || ${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Trade]}>0 || ${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Rent]}>0 || ${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Sell]}>0 || ${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[Quest]}>0
				{
					EchoIt "Deleting: ${Iterator.Key}"
					while ${Me.Inventory[ExactName,${Iterator.Key}](exists)} && ${doAutoDelete}
					{
						;; some items will not delete if you set the quantity to the reported quantity
						Me.Inventory[exactname,${Iterator.Key}]:Delete[1]
						wait 2
					}						
				}
			}
		}
				
		;; get next iterator
		Iterator:Next
	}
}

;===================================================
;===    FUNCTION - Remove Low Level Diplo       ====
;===================================================

function RemoveLowLevelDiplo()
{
	;CREDIT - to mmoAddict for this idea...
	;DESCRIPTION - this will remove all the low level diplo information you get from diploing
	variable int i
	for (i:Set[1] ; ${i}<=${Me.Inventory} ; i:Inc)
	{
		if ${Me.Inventory[${i}].Type.Equal[Miscellaneous]}
		{
			if !${Me.Inventory[${i}].Description.Find[would have an interest in this unequalled]}>0
			{
				if ${Me.Inventory[${i}].Name.Find[Plots]}>0 || ${Me.Inventory[${i}].Name.Find[Blackmail]}>0 || ${Me.Inventory[${i}].Name.Find[Arcana]}>0 || ${Me.Inventory[${i}].Name.Find[Trends]}>0
				{
					;echo Deleting ${Me.Inventory[${i}].Name} - ${Me.Inventory[${i}].Description}
					Me.Inventory[${i}]:Delete[${Me.Inventory[${i}].Quantity}]
					wait 2
				}
			}
		}
	}
}

