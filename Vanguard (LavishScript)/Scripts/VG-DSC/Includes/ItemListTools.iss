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
		PlaySound ALARM
		EchoIt "NO MORE SPACE... Total space remaining is ${Me.InventorySlotsOpen}"
		
		if !${Pawn[Merchant](exists)} && ${Pawn[Merchant].Distance}<=5
		{
			if ${Me.Inventory[Merchant Contract](exists)}
			{
				EchoIt "Popping a Merchant"
				Me.Inventory[Merchant Contract]:Use
				wait 20
			}
		}

		if ${Pawn[Merchant](exists)} && ${Pawn[Merchant].Distance}<=5
		{
			EchoIt "Targeting Merchant"
			Pawn[Merchant]:Target
			wait 5
			call RepairItemList
			Pawn[Merchant]:Target
			wait 5
		}
	}

	;; Sell items only if Merchant is in BuySell dialog
	if ${Me.Target.Type.Equal[Merchant]}
	{
		;; create a temp variable
		variable string temp

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

		variable int finishplat
		variable int finishgold
		variable int finishsilver
		variable int finishcopper
		variable int startmoney = ${Me.Copper}
		startmoney:Inc[${Math.Calc[${Me.Silver}*100]}]
		startmoney:Inc[${Math.Calc[${Me.Gold}*100*100]}]
		startmoney:Inc[${Math.Calc[${Me.Platinum}*100*100*100]}]
		
		;; iterate through ItemList
		while ${Iterator.Key(exists)} && ${Me.Target(exists)} && !${Me.InCombat} && !${isPaused}
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

						temp:Set[${Iterator.Key}]
						while ${Me.Inventory[exactname,${temp}](exists)} && ${Me.Target(exists)} && ${doAutoSell} && !${Me.InCombat}
						{
							;; some items will not sell if you set the quantity to the reported quantity
							Me.Inventory[exactname,${temp}]:Sell[1]
							wait 2
						}
					}
				}
			}
			;; get next iterator
			Iterator:Next
		}
		variable int finishmoney
		finishmoney:Inc[${Me.Copper}]
		finishmoney:Inc[${Math.Calc[${Me.Silver}*100]}]
		finishmoney:Inc[${Math.Calc[${Me.Gold}*100*100]}]
		finishmoney:Inc[${Math.Calc[${Me.Platinum}*100*100*100]}]
		variable int diff
		diff:Set[${startmoney} - ${finishmoney}]
		finishplat:Set[${Math.Abs[${Math.Calc[${diff}/100/100/100]}].Int}]
		diff:Dec[${Math.Abs[${Math.Calc[${finishplat}*100*100*100]}].Int}]
		finishgold:Set[${Math.Abs[${Math.Calc[${diff}/100/100]}].Int}]
		diff:Dec[${Math.Abs[${Math.Calc[${finishgold}*100*100]}].Int}]
		finishsilver:Set[${Math.Abs[${Math.Calc[${diff}/100]}].Int}]
		diff:Dec[${Math.Abs[${Math.Calc[${finishsilver}*100]}].Int}]
		finishcopper:Set[${diff}]
		if ${finishplat}>0 && ${finishgold}>0 && ${finishcopper}>0
		{
			EchoIt "Selling earned ${finishplat}p ${finishgold}g ${finishsilver}s ${finishcopper}c"
			vgecho "Selling earned ${finishplat}p ${finishgold}g ${finishsilver}s ${finishcopper}c"	
		}
		if ${doHunt}
		{
			Merchant:End
			VGExecute "/cleartargets"
			waitframe
		}
	}
}

;===================================================
;===   FUNCTION - Delete No Sell listed items   ====
;===================================================
function DeleteItemList()
{
	;; create a temp variable
	variable string temp

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
							Me.Inventory[exactname,${Iterator.Key}]:Delete[all]
							wait 2
						}
					}
				}
				;; delete only: sellable items in list
				if ${doDeleteSell}
				{
					if !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[Unique]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Trade]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Rent]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[No Sell]}>0 && !${Me.Inventory[exactname,${Iterator.Key}].Flags.Find[Quest]}>0
					{
						temp:Set[${Iterator.Key}]
						while ${Me.Inventory[ExactName,${temp}](exists)} && ${doDeleteSell} && !${Me.InCombat}
						{
							;; some items will not delete if you set the quantity to the reported quantity
							Me.Inventory[exactname,${temp}]:Delete[all]
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
atom(script) InventoryChatEvent(string Text, string ChannelNumber, string ChannelName)
{
	variable filepath EventFilePath = "${Script.CurrentDirectory}/Saves"
	mkdir "${EventFilePath}"
	redirect -append "${EventFilePath}/Event-Inventory.txt" echo "[${Time}][InventoryChatEvent][Channel=${ChannelNumber}] ${Text}"
	
	if ${doAutoSell}
	{
		if ${ChannelNumber.Equal[0]}
		{
			if ${Text.Find[You sell]}
			{
				variable string FindSell
				FindSell:Set[${Text.Mid[9,${Math.Calc[${Text.Length}-9]}]}]
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

function RepairItemList(bool ForceRepairs=FALSE)
{
	EchoIt "Checking for Repairs"

	;; find the lowest durable item
	variable int LowestDurability = 100

	;; total items in inventory
	variable int TotalItems = 0
	
	;; define our index
	variable index:item CurentItems
	
	variable int temp2
	variable string temp
		
	;; populate our index and update total items in inventory
	TotalItems:Set[${Me.GetInventory[CurentItems]}]

	for (i:Set[1] ; ${CurentItems.Get[${i}].Name(exists)} ; i:Inc)
	{
		;; We want to ignore the following
		temp:Set[${CurentItems.Get[${i}].CurrentEquipSlot}]
		if ${temp.Find[None]} || ${temp.Find[Crafting]} || ${temp.Find[Harvesting]} || ${temp.Find[Diplomacy]} || ${temp.Find[Appearance]}
		{
			continue
		}
		temp2:Set[${CurentItems.Get[${i}].Durability}]
		if ${temp2}<0
		{
			continue
		}
		
		;; Set durability to the lowest
		if ${temp2}<${LowestDurability}
		{
			LowestDurability:Set[${temp2}]
		}
	}
	

	;; return if no equipment needs repairing
	if ${LowestDurability}>=99
	return
	
	;; return if we are not forcing repairs
	if !${ForceRepairs} && ${LowestDurability}>=50
	return

	variable int finishplat
	variable int finishgold
	variable int finishsilver
	variable int finishcopper
	variable int startmoney = ${Me.Copper}
	startmoney:Inc[${Math.Calc[${Me.Silver}*100]}]
	startmoney:Inc[${Math.Calc[${Me.Gold}*100*100]}]
	startmoney:Inc[${Math.Calc[${Me.Platinum}*100*100*100]}]

	if !${Pawn[Merchant](exists)} && ${Pawn[Merchant].Distance}<=5
	{
		if ${Me.Inventory[Merchant Contract](exists)}
		{
			EchoIt "*Popping a Merchant"
			Me.Inventory[Merchant Contract]:Use
			wait 20
		}
	}

	if ${Pawn[Merchant](exists)} && ${Pawn[Merchant].Distance}<=5
	{
		EchoIt "*Targeting Merchant"
		Pawn[Merchant]:Target
		wait 5
	}
	
	if !${Me.Target.Type.Equal[Merchant]}
	{
		return
	}
	
	Merchant:Begin[Repair]
	wait 3
	Merchant:RepairAll
	wait 3
	Merchant:End

	variable int finishmoney
	finishmoney:Inc[${Me.Copper}]
	finishmoney:Inc[${Math.Calc[${Me.Silver}*100]}]
	finishmoney:Inc[${Math.Calc[${Me.Gold}*100*100]}]
	finishmoney:Inc[${Math.Calc[${Me.Platinum}*100*100*100]}]
	variable int diff
	diff:Set[${startmoney} - ${finishmoney}]
	finishplat:Set[${Math.Abs[${Math.Calc[${diff}/100/100/100]}].Int}]
	diff:Dec[${Math.Abs[${Math.Calc[${finishplat}*100*100*100]}].Int}]
	finishgold:Set[${Math.Abs[${Math.Calc[${diff}/100/100]}].Int}]
	diff:Dec[${Math.Abs[${Math.Calc[${finishgold}*100*100]}].Int}]
	finishsilver:Set[${Math.Abs[${Math.Calc[${diff}/100]}].Int}]
	diff:Dec[${Math.Abs[${Math.Calc[${finishsilver}*100]}].Int}]
	finishcopper:Set[${diff}]
	if ${finishplat}>0 && ${finishgold}>0 && ${finishcopper}>0
	{
		EchoIt "Repairs costed ${finishplat}p ${finishgold}g ${finishsilver}s ${finishcopper}c"
		vgecho "Repairs costed ${finishplat}p ${finishgold}g ${finishsilver}s ${finishcopper}c"
	}
}

