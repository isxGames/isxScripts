;; Defines
#define ALARM "${Script.CurrentDirectory}/level.wav"

variable bool doAutoSell = FALSE
variable bool doDeleteSell = FALSE
variable bool doDeleteNoSell = FALSE
variable bool doAutoDecon = FALSE

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
			LavishSettings[AddItem]:Import[${Script.CurrentDirectory}/Saves/ItemList.xml]
		}

		;; do only if item does not exist in our item list
		if !${LavishSettings[AddItem].FindSet[ItemList].FindSetting[${AddItem}](exists)}
		{
			;; add item to settings
			LavishSettings[AddItem].FindSet[ItemList]:AddSetting[${AddItem}, ${AddItem}]
				
			;; save and clear settings
			LavishSettings[AddItem]:Export[${Script.CurrentDirectory}/Saves/ItemList.xml]
			LavishSettings[AddItem]:Clear
		
			;; don't forget to clear these
			LavishSettings[SellItem]:Clear
			LavishSettings[DeleteItem]:Clear
			
			;; repopulate our window
			PopulateItemList "ItemList@Items@Tabs@VG-DSC"
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
			LavishSettings[RemoveItem]:Import[${Script.CurrentDirectory}/Saves/ItemList.xml]
		}

		;; do only if item exists in our item list
		if ${LavishSettings[RemoveItem].FindSet[ItemList].FindSetting[${RemoveItem}](exists)}
		{
			;; remove item to settings
			LavishSettings[RemoveItem].FindSet[ItemList].FindSetting[${RemoveItem}]:Remove
					
			;; save and clear settings
			LavishSettings[RemoveItem]:Export[${Script.CurrentDirectory}/Saves/ItemList.xml]
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
	;; Import ItemList into PopulateItem
	LavishSettings[PopulateItem]:Clear
	LavishSettings:AddSet[PopulateItem]
	LavishSettings[PopulateItem]:AddSet[ItemList]
	LavishSettings[PopulateItem]:Import[${Script.CurrentDirectory}/Saves/ItemList.xml]

	;; Import ItemList into AddItem
	LavishSettings[AddItem]:Clear
	LavishSettings:AddSet[AddItem]
	LavishSettings[AddItem]:AddSet[ItemList]
	LavishSettings[AddItem]:Import[${Script.CurrentDirectory}/Saves/ItemList.xml]	
					
	;; Import ItemList into RemoveItem
	LavishSettings[RemoveItem]:Clear
	LavishSettings:AddSet[RemoveItem]
	LavishSettings[RemoveItem]:AddSet[ItemList]
	LavishSettings[RemoveItem]:Import[${Script.CurrentDirectory}/Saves/ItemList.xml]

	;; Import ItemList into SellItem
	LavishSettings[SellItem]:Clear
	LavishSettings:AddSet[SellItem]
	LavishSettings[SellItem]:AddSet[ItemList]
	LavishSettings[SellItem]:Import[${Script.CurrentDirectory}/Saves/ItemList.xml]

	;; Import ItemList into DeleteItem
	LavishSettings[DeleteItem]:Clear
	LavishSettings:AddSet[DeleteItem]
	LavishSettings[DeleteItem]:AddSet[ItemList]
	LavishSettings[DeleteItem]:Import[${Script.CurrentDirectory}/Saves/ItemList.xml]

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
	;; make sure we are out of bag space
	if ${Me.InventorySlotsOpen}<=2
	{
		if !${Me.Target.Type.Equal[Merchant]}
		{
			PlaySound ALARM
			wait 50
			vgecho NO MORE SPACE TO LOOT, GO SELL SOMETHING
			isRunning:Set[FALSE]
			return
		}
	}
	
	;; Sell items only if Merchant is in BuySell dialog
	if ${Me.Target.Type.Equal[Merchant]}
	{
		;; cut down on the loading times
		if !${LavishSettings[SellItem].FindSet[ItemList](exists)}
		{
			;; build and import ItemList
			LavishSettings[SellItem]:Clear
			LavishSettings:AddSet[SellItem]
			LavishSettings[SellItem]:AddSet[ItemList]
			LavishSettings[SellItem]:Import[${Script.CurrentDirectory}/Saves/ItemList.xml]
		}
							
		;; set our settingsetref to ItemList
		variable settingsetref ItemList
		ItemList:Set[${LavishSettings[SellItem].FindSet[ItemList]}]

		;; set our iterator to ItemList
		variable iterator Iterator
		ItemList:GetSettingIterator[Iterator]
						
		;; iterate through ItemList
		while ${Iterator.Key(exists)} && ${Me.Target(exists)} && !${Me.InCombat}
		{
			;; we only want to sell items existing in our inventory
			if ${Me.Inventory[exactname,${Iterator.Key}](exists)} && ${doAutoSell}
			{
				;; skip diplo papers - that will be handled separately
				if !${Me.Inventory[exactname,${Iterator.Key}].Description.Find[would have an interest in this]}>0
				{
					;; sell anything that is not Unique, No Trade, No Sell, No Rent, and Quest items in the list
					if !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[Unique]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Trade]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Rent]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Sell]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[Quest]}>0
					{
						echo "Selling: ${Iterator.Key}"
						vgecho "Selling: ${Iterator.Key}"

						;; if not in BuySell dialog then...
						if !${Merchant.NumItemsForSale}>0
						{
							if ${Me.Target.Distance}>4
							{
								vgecho MOVING
								waitframe
								;; get closer
								call MoveCloser 4
							}
							
							;; open BuySell dialog with merchant
							Pawn[${Me.Target.Name}]:DoubleClick
							wait 3
							Merchant:Begin[BuySell]
							wait 5
						}

						while ${Me.Inventory[exactname,${Iterator.Key}](exists)} && ${Me.Target(exists)} && ${doAutoSell} && !${Me.InCombat}
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
		LavishSettings[DeleteItem]:Import[${Script.CurrentDirectory}/Saves/ItemList.xml]
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
		if ${Me.Inventory[exactname,${Iterator.Key}](exists)} && !${Me.InCombat}
		{
			;; skip diplo papers - that will be handled separately
			if !${Me.Inventory[exactname,${Iterator.Key}].Description.Find[would have an interest in this]}>0
			{
				;; delete only: Unique, No Trade, No Sell, No Rent, and Quest items in list
				if ${doDeleteNoSell}
				{
					if ${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[Unique]}>0 || ${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Trade]}>0 || ${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Rent]}>0 || ${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Sell]}>0 || ${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[Quest]}>0
					{
						echo "Deleting NoSell: ${Iterator.Key}"
						while ${Me.Inventory[ExactName,${Iterator.Key}](exists)} && ${doDeleteNoSell} && !${Me.InCombat}
						{
							;; some items will not delete if you set the quantity to the reported quantity
							Me.Inventory[exactname,${Iterator.Key}]:Delete[1]
							wait 2
						}
					}
				}
				;; delete only: sellable items in list
				if ${doDeleteSell}
				{
					if !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[Unique]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Trade]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Rent]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Sell]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[Quest]}>0
					{
						echo "Deleting Sellable: ${Iterator.Key}"
						while ${Me.Inventory[ExactName,${Iterator.Key}](exists)} && ${doDeleteSell} && !${Me.InCombat}
						{
							;; some items will not delete if you set the quantity to the reported quantity
							Me.Inventory[exactname,${Iterator.Key}]:Delete[1]
							wait 2
						}
					}
				}
			}
		}
		;; get next iterator
		Iterator:Next
	}
}

;===================================================
;===   FUNCTION - Decon all Shandrel's Items    ====
;===================================================
function AutoDecon()
{
	;; DECON SHANDREL JUNK
	if ${doAutoDecon}
	{
		if ${Me.Inventory[Deconstruction Kit](exists)}
		{
			if ${Me.Inventory[Shandrel's](exists)} && ${Me.Inventory[Shandrel's].Description.Find[This relic]}
			{
				echo "Deconstructing: ${Me.Inventory[Shandrel's].Name}"
				vgecho "Deconstructing: ${Me.Inventory[Shandrel's].Name}"
				Me.Inventory[Deconstruction Kit]:Use
				wait 5
				Me.Inventory[Shandrel's]:DeconstructToResource
				wait 25
			}
		}
	}
	return
}


;===================================================
;===       ATOM - Monitor Chat Event            ====
;===================================================
atom(script) InventoryChatEvent(string aText, string ChannelNumber, string ChannelName)
{
	;echo [${ChannelNumber}][${doAutoSell}] ${aText}
	if ${doAutoSell}
	{
		if ${ChannelNumber.Equal[0]}
		{
			if ${aText.Find[You sell]}
			{
				variable string FindSell
				FindSell:Set[${aText.Mid[9,${Math.Calc[${aText.Length}-9]}]}]
				if ( ${FindSell.Length} > 1 )
				{
					AddItemList "${FindSell}"
					PopulateItemList "ItemList@Items@Tabs@VG-DSC"
				}
			}
		}
	}
}

;===================================================
;===          ATOM - PLAY A SOUND               ====
;===================================================
atom(script) PlaySound(string Filename)
{
	echo "PlaySound: ${Filename}"
	System:APICall[${System.GetProcAddress[WinMM.dll,PlaySound].Hex},Filename.String,0,"Math.Dec[22001]"]
}