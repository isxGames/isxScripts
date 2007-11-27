;
; MyPrices  - EQ2 Broker Buy/Sell script
;
; Version 0.09g : Started 18 Nov 2007 : released 27 Nov 2007
;
; Main Script
;
function main()
{

	; Declare Variables
	;
	variable BrokerBot MyPrices
	Declare MatchLowPrice bool script
	Declare IncreasePrice bool script
	Declare Exitmyprices bool script
	Declare Pausemyprices bool script
	Declare SetUnlistedPrices bool script
	Declare ItemUnlisted bool script
	Declare ScanSellNonStop bool script
	Declare BuyItems bool script
	Declare MinPriceSet bool script
	Declare IgnoreCopper bool script
	Declare SellItems bool script
	Exitmyprices:Set[FALSE]
	Pausemyprices:Set[TRUE]

	Declare labelname string script
	Declare i int script
	Declare j int script
	Declare MyBasePrice float script
	Declare MyPriceS string script
	Declare MinBasePriceS string script
	Declare Commission int script
	Declare SellLoc string script
	Declare SellCon string script
	Declare PriceInSilver float script
	Declare MinSalePrice float script
	Declare MinPrice float 0 script
	Declare MinBasePrice float 0 script
	Declare IntMinBasePrice int script
	Declare ItemPrice float 0 script
	Declare MyPrice float 0 script
	; Array - stores container number for each item in the Listbox
	Declare itemprice[1000] int script
	Declare numitems int script
	Declare currentpos int script
	Declare BuyNumber int script
	Declare BuyPrice float script
	Declare currentitem string script
	Declare PauseTimer int script
	Declare loopcount int 0 local
	Declare StopWaiting int script
	variable settingsetref flabel

	ISXEQ2:ResetInternalVendingSystem

	MyPrices:loadsettings
	MyPrices:LoadUI



#define WAITEXTPERIOD 120

	call AddLog "Verifying ISXEQ2 is loaded and ready" FF11CCFF
	wait WAITEXTPERIOD ${ISXEQ2.IsReady}
	if !${ISXEQ2.IsReady}
	{
		echo ISXEQ2 could not be loaded. Script aborting.
		Script:End
	}
	call AddLog "Running MyPrices version 0.09e - released : 25 Nov 2007" FF11FFCC

	call LoadList

	call buy init

	if ${ScanSellNonStop}
	{
		call AddLog "Pausing ${PauseTimer} minutes between scans" FF0000FF
	}

	do
	{
		; wait for the UI Start Scanning button to be pressed
		do
		{
			Waitframe
			ExecuteQueued
			; exit if the Stop and Quit Button is Pressed
			if ${Exitmyprices} == TRUE
			{
				Script:End
			}
		}
		While ${Pausemyprices}
		PauseTimer:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[PauseTimer].Text}]
		call SaveSetting PauseTimer ${PauseTimer}
		; Start scanning the broker

		if ${SellItems}
		{
			currentpos:Set[1]
			i:Set[1]
			j:Set[1]

			do
			{
				currentitem:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[ItemList].Item[${currentpos}]}]

				; container number
				i:Set[${itemprice[${currentpos}]}]


				; check where the container is being sold from to get the commission

				SellLoc:Set[${Me.Vending[${i}].Market}]
				SellCon:Set[${Me.Vending[${i}]}]

				if ${Me.Vending[${i}].CurrentCoin} > 0
				{
					Me.Vending[${i}]:TakeCoin
				}

				if ${SellLoc.Equal["Haven"]}
				{
					Commission:Set[40]
				}
				else
				{
					Commission:Set[20]
				}
				if ${SellCon.Equal["Veteran's Display Case"]}
				{
					Commission:Set[${Math.Calc[${Commission}/2]}]
				}

				; Find where the Item is stored in the container
				call FindItem ${i} "${currentitem}"
				j:Set[${Return}]

				; If item was found in the container still
				if ${j} != -1
				{
					; is the item listed for sale ?

					if ${Me.Vending[${i}].Consignment[${j}].IsListed}
					{
						ItemUnlisted:Set[FALSE]
					}
					else
					{
						ItemUnlisted:Set[TRUE]
					}
					if !${ItemUnlisted} || ${SetUnlistedPrices}
					{
						; Calclulate the price someone would pay with commission
						MyBasePrice:Set[${Me.Vending[${i}].Consignment[${j}].BasePrice}]
						MyPrice:Set[${Math.Calc[((${MyBasePrice}/100)*${Math.Calc[100+${Commission}]})]}]
						; Unlist the item to make sure it's not included in the check for lower/higher prices
						loopcount:Set[0]
						do
						{
							Me.Vending[${i}].Consignment[${j}]:Unlist
							wait 10

							; check the item hasn't moved in the list because it was unlisted
							call FindItem ${i} "${currentitem}"
							j:Set[${Return}]

						}
						while ${Me.Vending[${i}].Consignment[${j}].IsListed} && ${loopcount:Inc} < 10

						call SetColour ${currentpos} FF0B0301
						; check to see if the items minimum price should be used or not
						Call CheckMinPriceSet "${currentitem}"
						MinPriceSet:Set[${Return}]
						; Call Search routine to find the lowest price
						Call BrokerSearch "${currentitem}"
						; Broker search returns -1 if no items to compare were found
						if ${Return} != -1
						{
							; record the minimum broker price
							MinPrice:Set[${Return}]

							; check if the item is in the myprices settings file
							call checkitem "${currentitem}"
							MinSalePrice:Set[${Return}]

							; if a stored Minimum Sale price was found then carry on
							if ${MinSalePrice}!= -1
							{
								; Calculate the Baseprice + Commission to set the value to match the currently lowest price
								MinBasePrice:Set[${Math.Calc[((${MinPrice}/${Math.Calc[100+${Commission}]})*100)]}]
								; if the flag to ignore copper is set and the price is > 1 gold
								if ${IgnoreCopper} && ${MinBasePrice} > 100
								{
									; round the value to remove the coppers
									IntMinBasePrice:Set[${MinBasePrice}]
									MinBasePrice:Set[${IntMinBasePrice}]
								}

								; do conversion from silver value to pp gp sp cp format
								call StringFromPrice ${MyPrice}
								MyPriceS:Set[${Return}]

								; ***** If your price is more than the lowest price on sale ****
								if ${MinPrice}<${MyPrice}
								{
									; **** if that price is Less than the price you are willing to sell for , don't do anything
									if ${MinBasePrice}<${MinSalePrice} && ${MinPriceSet}
									{
										call StringFromPrice ${MinBasePrice}
										MinBasePriceS:Set[${Return}]
										call StringFromPrice ${MinSalePrice}
										call AddLog "${currentitem} : ${MinBasePriceS} : My Lowest : ${Return}" FFFF0000
										; Set the text in the list box line to red
										call SetColour ${currentpos} FFFF0000
									}
									else
									{
										; otherwise inform/change value to match
										call StringFromPrice ${MinBasePrice}
										call AddLog "${currentitem} :  Price to match is ${Return}" FF00FF00
										If ${MatchLowPrice}
										{
											call SetColour ${currentpos} FF00FF00
											Me.Vending[${i}].Consignment[${j}]:SetPrice[${MinBasePrice}]
										}
									}
								}
								; **** if you are selling an item lower than the next lowest price
								elseif ${MyPrice}<${MinPrice}
								{
									; Set the colour of the listbox line to yellow
									call SetColour ${currentpos} FFFCD116
									; if you have told the script to match higher prices or the item was unlisted
									if ${IncreasePrice} || ${ItemUnlisted}
									{
										If !${ItemUnlisted}
										{
											call StringFromPrice ${MinBasePrice}
											call AddLog "${currentitem} : Price to match is ${Return} :" FF00FF00
											Me.Vending[${i}].Consignment[${j}]:SetPrice[${MinBasePrice}]
										}
										else
										; if the item was unlisted then update your sale price
										{
											; if a minimum price was set previously for this item then use that value
											if ${MinBasePrice}<${MinSalePrice} && ${MinPriceSet}
											{
												call StringFromPrice ${MinSalePrice}
												call AddLog "${currentitem} : Unlisted : Setting to ${Return}" FFFF0000
												Me.Vending[${i}].Consignment[${j}]:SetPrice[${MinSalePrice}]
												Call Saveitem Sell "${currentitem}" ${MinSalePrice}
												call SetColour ${currentpos} FFFF0000
											}
											else
											{
												; otherwise use the lowest price on the vendor
												call StringFromPrice ${MinBasePrice}
												call AddLog "${currentitem} : Unlisted : Setting to ${Return}" FF00FF00
												Me.Vending[${i}].Consignment[${j}]:SetPrice[${MinBasePrice}]
												; if no previous minimum price was saved then save the lowest current price (makes sure a value is there)
												if ${MinSalePrice} == 0
												{
													Call Saveitem Sell "${currentitem}" ${MinBasePrice}
												}
												call SetColour ${currentpos} FF0000FF
											}
										}
									}
								}
								Else
								{
									call SetColour ${currentpos} FF00FF00
								}
							}
							else
							{
								call AddLog "Adding ${currentitem} at ${MyBasePrice}" FF00CCFF
								call Saveitem Sell "${currentitem}" ${MyBasePrice}
							}
							; make sure the item is re-listed for sale
							call ReListItem ${i} "${currentitem}"

						}
						else
						{
							; if if no match was found and the item was STILL listed for sale before
							; then re-list it
							if !${ItemUnlisted}
							{
								call ReListItem ${i} "${currentitem}"
							}
						}
						; if the Quit Button on the UI has been pressed then exit
						if ${Exitmyprices}
						{
							call AddLog "Exit Pressed , closing script."
							Script:End
						}
					}
				}
				else
				{
					; Item not found in the container (sold or removed mid-scan)
					call SetColour ${currentpos} FFC43012
				}
			}
			while ${currentpos:Inc} <= ${numitems} && ${Pausemyprices} == FALSE
			if !${ScanSellNonStop}
			{
				UIElement[Start Scanning@Sell@GUITabs@MyPrices]:SetText[Start Scanning]
				Pausemyprices:Set[TRUE]
			}
		}
		; Script starts to scan for items to buy if flagged.
		if ${BuyItems}
		{
			call buy scan
		}
		if ${ScanSellNonStop} && ${PauseTimer} > 0
		{
			call AddLog "Pausing for ${PauseTimer} minutes " FF0033EE
			wait ${Math.Calc[600*${PauseTimer}]} ${StopWaiting}
			StopWaiting:Set[0]
		}
	}
	While ${Exitmyprices} == FALSE
}

function FindItem(int i, string itemname)
{

	Declare j int local
	Declare Position int -1 local
	Declare ConName string local

	j:Set[1]
	do
	{
		ConName:Set[${Me.Vending[${i}].Consignment[${j}]}]
		if ${ConName.Equal["${itemname}"]}
		{
			Position:Set[${j}]
			Break
		}
	}
	while ${j:Inc} <= ${Me.Vending[${i}].NumItems}
	Return ${Position}
}


function ReListItem(int i, string itemname)
{
	Declare loopcount int local
	Declare j int local

	Call FindItem ${i} "${itemname}"
	j:Set[${Return}]
	if ${j} != -1
	{
		; Re-List the item for sale
		loopcount:Set[0]
		do
		{
			Me.Vending[${i}].Consignment[${j}]:List
			wait 15
			Call FindItem ${i} "${itemname}"
			j:Set[${Return}]

		}
		while !${Me.Vending[${i}].Consignment[${j}].IsListed} && ${loopcount:Inc} < 10
		if ${loopcount} == 10
		{
			call AddLog "*** ERROR - unable to mark ${itemname} as listed for sale" FFFF0000
		}
	}
}


function buy(string action)
{
	; Read data from myprices.xml
	;

	variable settingsetref BuyList
	variable settingsetref BuyName

	BuyList:Set[${LavishSettings[myprices].FindSet[Buy]}]

	; make sure nothing from a previous run is in memory (DEVL)

	BuyList:Clear

	if ${action.Equal["init"]}
	{
		UIElement[ItemList@Buy@GUITabs@MyPrices]:ClearItems
	}

	LavishSettings[myprices]:Import["myprices.xml"]

	variable iterator BuyIterator
	variable iterator NameIterator
	variable iterator BuyNameIterator

	; Index each item under the Set [Item]

	BuyList:GetSetIterator[BuyIterator]

	; if there is anything in the index

	if ${BuyIterator:First(exists)}
	{

		;start going through each Sub-Set under [Item]
		do
		{
			; Get the Sub-Set Location
			NameIterator.Value:GetSetIterator[BuyIterator]
			do
			{
				; Get the reference for the Sub-Set
				BuyName:Set[${BuyList.FindSet[${BuyIterator.Key}]}]
				; Create an Index of all the data in that Sub-set
				BuyName:GetSettingIterator[BuyNameIterator]
				; run the various options (Scan / update price etc based on the paramater passed to the routine
				;
				; init = build up the list of items on the buy tab
				; scan = check the broker list one by one - do buy and various workhorse routines

				if ${action.Equal["init"]}
				{
					UIElement[ItemList@Buy@GUITabs@MyPrices]:AddItem["${BuyIterator.Key}"]
				}
				else
				{
					; read the Settings in the Sub-Set
					if ${BuyNameIterator:First(exists)}
					{
						; Scan the subset to get all the settings
						do
						{
							if ${BuyNameIterator.Key.Equal["BuyNumber"]}
							{
								BuyNumber:Set[${BuyNameIterator.Value}]
							}
							elseif ${BuyNameIterator.Key.Equal["BuyPrice"]}
							{
								BuyPrice:Set[${BuyNameIterator.Value}]
							}

						}
						while ${BuyNameIterator:Next(exists)}
						; run the routine to scan and buy items if we still need more bought
						if ${BuyNumber} > 0
						{
							call BuyItems "${BuyIterator.Key}" ${BuyPrice} ${BuyNumber}
						}
					}
				}
			}

			; Keep looping till you've read all the Items listed under the Buy Sub-Set
			while ${NameIterator:Next(exists)}
		}
		; Keep looping till you've read all the items in the Top level sets
		While ${BuyIterator:Next(exists)}
	}
}


function BuyItems(string BuyName, float BuyPrice, int BuyNumber)
{

	Declare CurrentPage int 1 local
	Declare CurrentItem int 1 local
	Declare FinishBuy bool local
	Declare BrokerNumber int local
	Declare BrokerPrice float local
	Declare TryBuy int local
	Declare StopSearch bool FALSE local
	Declare MyCash float local
	Declare OldCash float local
	Declare BoughtNumber int local
	Declare MaxBuy int local
	Call BrokerSearch "${BuyName}"


	; if items listed on the broker
	if ${Return} != -1
	{
		; Scan the broker list one by one buying the items until the end of the list is reached or all the Number wanted have been bought
		do
		{
			Vendor:GotoSearchPage[${CurrentPage}]
			do
			{
				; calculate how much coin this character has on it
				MyCash:Set[${Math.Calc[(${Me.Platinum}*10000)+(${Me.Gold}*100)+(${Me.Silver})+(${Me.Copper}/100)]}]
				; How many items for sale on the current broker entry
				BrokerNumber:Set[${Vendor.Broker[${CurrentItem}].Quantity}]
				; How much each single item costs
				BrokerPrice:Set[${Vendor.Broker[${CurrentItem}].Price}]

				; if it's more than I want to pay then stop
				if ${BrokerPrice} > ${BuyPrice}
				{
					StopSearch:Set[TRUE]
					break
				}
				; if there are items available (sometimes broker number shows 0 available when someone beats you to it)
				if ${BrokerNumber} >0
				{
					do
					{
						BrokerNumber:Set[${Vendor.Broker[${CurrentItem}].Quantity}]

						; if the broker entry being looked at shows more items than we want then buy what we want
						if ${BrokerNumber} > ${BuyNumber}
						{
							TryBuy:Set[${BuyNumber}]
						}
						else
						{
							; otherwise buy whats there

							TryBuy:Set[${BrokerNumber}]
						}
						; check you can afford to buy the items
						call checkcash ${BrokerPrice} ${TryBuy} ${MyCash}
						; buy what you can afford
						if ${Return} > 0
						{
							OldCash:Set[${MyCash}]
							Vendor.Broker[${CurrentItem}]:Buy[${Return}]
							wait 15
							MyCash:Set[${Math.Calc[(${Me.Platinum}*10000)+(${Me.Gold}*100)+(${Me.Silver})+(${Me.Copper}/100)]}]
							; check you have actually bought an item
							call checkbought ${BrokerPrice} ${OldCash} ${MyCash}
							BoughtNumber:Set[${Return}]
							; reduce the number left to buy
							BuyNumber:Set[${Math.Calc[${BuyNumber}-${BoughtNumber}]}]
							call StringFromPrice ${BrokerPrice}
							call AddLog "Bought (${BoughtNumber}) ${BuyName} at ${Return}" FF00FF00
						}
						else
						{
							; if you can't afford any then stop scanning
							StopSearch:Set[TRUE]
							break
						}
					}
					While ${BrokerNumber} > 0 && ${BuyNumber} > 0
				}
			}
			while ${CurrentItem:Inc}<=${Vendor.NumItemsForSale} && ${BuyNumber} > 0 && !${Exitmyprices} && !${Pausemyprices} && !${StopSearch}
			wait 10
			CurrentItem:Set[1]
		}
		; keep going till all items listed have been scanned and bought or you have reached your limit
		while ${CurrentPage:Inc}<=${Vendor.TotalSearchPages} && ${BuyNumber} > 0 && !${Exitmyprices} && !${Pausemyprices} && !${StopSearch}
		; now we've bought all that are available , save the number we've still got left to buy
		call Saveitem Buy "${BuyName}" ${BuyPrice} ${BuyNumber}
	}

}

; function to check you actually bought an item (stops false positives if someone beats you to it or someone removes an item before you can buy it)

function checkbought(float BrokerPrice, float OldCash, float NewCash)
{
	Declare Diff float local
	Declare DiffInt int local

	; find out how much was spent
	Diff:Set[${Math.Calc[${OldCash}-${NewCash}]}]

	; Find out how many were bought
	Diff:Set[${Math.Calc[${Diff}/${BrokerPrice}]}]


	; Check for partial amounts due to rounding errors in math calculations

	If ${Diff} > 1
	{
		DiffInt:Set[${Diff}]
		If ${Math.Calc[${Diff}-${DiffInt}]} > 0.5
		{
			DiffInt:Inc
		}
		return ${DiffInt}
	}
	else
	{
		Return 1
	}

}

; check to see if you have enough coin on your character to buy the number you want to,
; if not then calculate how many you CAN buy with the coin you have.

function checkcash(float Buyprice, int Buynumber, float MyCash)
{
	Declare NewBuyNumber int 0
	; if trying to buy over 100 then limit to 100 (SoE limit for non harvests)
	if ${Buynumber} > 100
	{
		Buynumber:Set[100]
	}
	if ${Math.Calc[(${Buyprice}*${Buynumber})]} > ${MyCash}
	{
		NewBuyNumber:Set[${Math.Calc[${MyCash}/${Buyprice}]}]
		return ${NewBuyNumber}
	}
	else
	{
		return ${Buynumber}
	}
}

; Scan the broker when an item is clicked on in the BUY item list.

function ClickBrokerSearch(string tabtype, int ItemID)
{
	Declare LBoxString string local
	; scan the broker for the item clicked on in the list
	LBoxString:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[${tabtype}].FindChild[ItemList].Item[${ItemID}]}]
	broker Name "${LBoxString}" Sort ByPriceAsc MaxLevel 999

}


; Search the broker for items , return the cheapest price found

function BrokerSearch(string lookup)
{
	Declare CurrentPage int 1 local
	Declare CurrentItem int 1 local
	Declare TempMinPrice float -1 local
	Declare stopsearch bool FALSE local

	broker Name "${lookup}" Sort ByPriceAsc MaxLevel 999
	Wait 15
	; check if broker has any listed to compare with your item
	if ${Vendor.NumItemsForSale} >0
	{
		; Work through the brokers list page by page
		do
		{
			Vendor:GotoSearchPage[${CurrentPage}]
			CurrentItem:Set[1]
			do
			{
				; check that the items name being looked at is an exact match and not just a partial match
				if "${lookup.Equal["${Vendor.Broker[${CurrentItem}]}"]}"
				{
					TempMinPrice:Set[${Vendor.Broker[${CurrentItem}].Price}]
					stopsearch:Set[TRUE]
					break
				}
			}
			while ${CurrentItem:Inc}<=${Vendor.NumItemsForSale} && !${stopsearch}
			wait 10
		}
		while ${CurrentPage:Inc}<=${Vendor.TotalSearchPages} && ${TempMinPrice} == -1 && !${stopsearch}
	}
	; Return the Lowest Price Found or -1 if nothing found.
	return ${TempMinPrice}
}


function checkitem(string name)
{
	LavishSettings:AddSet[myprices]
	LavishSettings[myprices]:AddSet[General]
	LavishSettings[myprices]:AddSet[Item]
	LavishSettings[myprices]:AddSet[Buy]
	; keep a reference directly to the Item set.

	variable settingsetref ItemList
	ItemList:Set[${LavishSettings[myprices].FindSet[Item]}]
	variable settingsetref Item

	Item:Set[${ItemList.FindSet[${name}]}]

	if ${Item.FindSetting[Sell](exists)}
	{
		return ${Item.FindSetting[Sell]}
	}
	else
	{
		return -1
	}
}

function LoadList()
{
	Declare labelname string local
	Declare Money float local

	UIElement[ItemList@Sell@GUITabs@MyPrices]:ClearItems

	i:Set[1]
	j:Set[1]
	numitems:Set[0]
	do
	{
		if (${Me.Vending[${i}](exists)})
		{
			if ${Me.Vending[${i}].CurrentCoin} > 0
			{
				Me.Vending[${i}]:TakeCoin
				wait 10
			}

			if ${Me.Vending[${i}].NumItems}>0
			{
				do
				{
					numitems:Inc
					labelname:Set[${Me.Vending[${i}].Consignment[${j}]}]
					UIElement[ItemList@Sell@GUITabs@MyPrices]:AddItem[${labelname}]
					Money:Set[${Me.Vending[${i}].Consignment[${j}].BasePrice}]
					; store the item name
					itemprice[${numitems}]:Set[${i}]
					; check to see if it already has a minimum price set
					call checkitem "${labelname}"
					Money:Set[${Return}]
					; If no value is returned then add the price to the settings file
					if ${Money} == -1
					{
						call SetColour ${numitems} FF0000FF
						call AddLog "Item Missing from Settings File,  Adding : ${labelname}" FF00CCFF
						call Saveitem Sell "${labelname}" ${Me.Vending[${i}].Consignment[${j}].BasePrice}
					}
				}
				while ${j:Inc} <= ${Me.Vending[${i}].NumItems}
			}
			j:Set[1]
		}
	}
	while ${i:Inc} <= 6
}

objectdef BrokerBot
{
	method LoadUI()
	{
		; Load the UI Parts
		;
		ui -reload "${LavishScript.HomeDirectory}/Interface/EQ2Skin.xml"
		ui -reload "${LavishScript.HomeDirectory}/Scripts/UI/mypricesUI.xml"
	}

	method loadsettings()
	{
		; Read settings from myprices.xml
		;
		LavishSettings:AddSet[myprices]
		LavishSettings[myprices]:AddSet[General]
		LavishSettings[myprices]:AddSet[Item]
		LavishSettings[myprices]:AddSet[Buy]
		variable settingsetref ItemList
		ItemList:Set[${LavishSettings[myprices].FindSet[Item]}]
		BuyList:Set[${LavishSettings[myprices].FindSet[Buy]}]
		; make sure nothing from a previous run is in memory (DEVL)
		ItemList:Clear
		BuyList:Clear
		LavishSettings[myprices]:Import["myprices.xml"]
		variable settingsetref GeneralSetting
		GeneralSetting:Set[${LavishSettings[myprices].FindSet[General]}]
		MatchLowPrice:Set[${GeneralSetting.FindSetting[MatchLowPrice]}]
		IncreasePrice:Set[${GeneralSetting.FindSetting[IncreasePrice]}]
		SetUnlistedPrices:Set[${GeneralSetting.FindSetting[SetUnlistedPrices]}]
		ScanSellNonStop:Set[${GeneralSetting.FindSetting[ScanSellNonStop]}]
		IgnoreCopper:Set[${GeneralSetting.FindSetting[IgnoreCopper]}]
		BuyItems:Set[${GeneralSetting.FindSetting[BuyItems]}]
		SellItems:Set[${GeneralSetting.FindSetting[SellItems]}]
		PauseTimer:Set[${GeneralSetting.FindSetting[PauseTimer]}]
	}

}



; Convert a float price in silver to pp gp sp cp format

function StringFromPrice(float Money)
{
	Declare Platina int local
	Declare Gold int local
	Declare Silver int local
	Declare Copper int local
	Platina:Set[${Math.Calc[${Money}/10000]}]
	Money:Set[${Math.Calc[${Money}-(${Platina}*10000)]}]
	Gold:Set[${Math.Calc[${Money}/100]}]
	Money:Set[${Math.Calc[${Money}-(${Gold}*100)]}]
	Silver:Set[${Money}]
	Money:Set[${Math.Calc[${Money}-${Silver}]}]
	Copper:Set[${Math.Calc[${Money}* 100]}]
	return ${Platina}pp ${Gold}gp ${Silver}sp ${Copper}cp
}

; Convert a price in pp gp sp cp format to float price in silver

function pricefromstring()
{
	Declare itemname string local
	Declare Platina int local
	Declare Gold int local
	Declare Silver int local
	Declare Copper float local
	Declare Money float local

	itemname:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[Itemname].Text}]
	if ${itemname.Length} == 0
	{
		Echo Try Selecting something first!!
	}
	else
	{
		; Read the values held in the GUI boxes
		Platina:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[MinPlatPrice].Text}]
		Gold:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[MinGoldPrice].Text}]
		Silver:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[MinSilverPrice].Text}]
		Copper:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[MinCopperPrice].Text}]

		; calclulate the value in silver
		Platina:Set[${Math.Calc[${Platina}*10000]}]
		Gold:Set[${Math.Calc[${Gold}*100]}]
		Copper:Set[${Math.Calc[${Copper}/100]}]
		Money:Set[${Math.Calc[${Platina}+${Gold}+${Silver}+${Copper}]}]

		; Save the new value in your settings file
		call Saveitem Sell "${itemname}" ${Money}
	}
}


; routine to save/update items and prices

function Saveitem(string Saveset, string ItemName, float Money, int Number)
{

	LavishSettings:AddSet[myprices]
	LavishSettings[myprices]:AddSet[General]
	LavishSettings[myprices]:AddSet[Item]
	LavishSettings[myprices]:AddSet[Buy]

	variable settingsetref ItemList
	if ${Saveset.Equal["Sell"]}
	{
		ItemList:Set[${LavishSettings[myprices].FindSet[Item]}]
	}
	Else
	{
		ItemList:Set[${LavishSettings[myprices].FindSet[Buy]}]
	}

	ItemList:AddSet[${ItemName}]

	variable settingsetref Item

	Item:Set[${ItemList.FindSet[${ItemName}]}]

	if ${Saveset.Equal["Sell"]}
	{
		Item:AddSetting[${Saveset},${Money}]
		if ${UIElement[MinPrice@Sell@GUITabs@MyPrices].Checked}
		{
			Item:AddSetting[MinSalePrice,TRUE]
		}
		else
		{
			Item:AddSetting[MinSalePrice,FALSE]
		}
	}
	elseif ${Saveset.Equal["Buy"]}
	{
		Item:AddSetting[BuyNumber,${Number}]
		Item:AddSetting[BuyPrice,${Money}]
	}

	LavishSettings[myprices]:Export["myprices.xml"]
}


; routine to update the myprices settings

function SaveSetting(string Settingname, string Value)
{
	LavishSettings:AddSet[myprices]
	LavishSettings[myprices]:AddSet[General]
	LavishSettings[myprices]:AddSet[Item]

	variable settingsetref General

	General:Set[${LavishSettings[myprices].FindSet[General]}]
	General:AddSetting[${Settingname},${Value}]
}

; changes the color of the items in the listbox

function SetColour(int position, string colour)
{
	UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[ItemList].Item[${position}]:SetTextColor[${colour}]
	return
}

; update the boxes in the Sell tab with the right values

function FillMinPrice(int ItemID)
{
	Declare LBoxString string local
	Declare Money float local
	Declare Platina int local
	Declare Gold int local
	Declare Silver int local
	Declare Copper int local
	Declare ItemName string local
	Declare j int local

	; Put the values in the right boxes.

	; Display the current price
	LBoxString:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[ItemList].Item[${ItemID}]}]

	call FindItem ${itemprice[${ItemID}]} "${LBoxString}"
	j:Set[${Return}]

	if ${j} != -1
	{
		ItemName:Set[${Me.Vending[${itemprice[${ItemID}]}].Consignment[${j}].Name}]

		UIElement[Itemname@Sell@GUITabs@MyPrices]:SetText[${LBoxString}]

		; Display your current Price for that Item

		Money:Set[${Me.Vending[${itemprice[${ItemID}]}].Consignment[${j}].BasePrice}]

		Platina:Set[${Math.Calc[${Money}/10000]}]
		Money:Set[${Math.Calc[${Money}-(${Platina}*10000)]}]
		Gold:Set[${Math.Calc[${Money}/100]}]
		Money:Set[${Math.Calc[${Money}-(${Gold}*100)]}]
		Silver:Set[${Money}]
		Money:Set[${Math.Calc[${Money}-${Silver}]}]
		Copper:Set[${Math.Calc[${Money}* 100]}]

		UIElement[PlatPrice@Sell@GUITabs@MyPrices]:SetText[${Platina}]
		UIElement[GoldPrice@Sell@GUITabs@MyPrices]:SetText[${Gold}]
		UIElement[SilverPrice@Sell@GUITabs@MyPrices]:SetText[${Silver}]
		UIElement[CopperPrice@Sell@GUITabs@MyPrices]:SetText[${Copper}]

		; Display your minimum price for the item

		LavishSettings:AddSet[myprices]
		LavishSettings[myprices]:AddSet[General]
		LavishSettings[myprices]:AddSet[Item]

		variable settingsetref ItemList
		ItemList:Set[${LavishSettings[myprices].FindSet[Item]}]
		ItemList:AddSet[${ItemName}]

		variable settingsetref Item
		Item:Set[${ItemList.FindSet[${LBoxString}]}]
		Money:Set[${Item.FindSetting[Sell]}]

		if !${Item.FindSetting[MinSalePrice]}
		{
			UIElement[MinPlatPrice@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MinPlatPrice@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MinGoldPrice@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MinSilverPrice@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MinCopperPrice@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MinPlatPriceText@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MinGoldPriceText@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MinSilverPriceText@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MinCopperPriceText@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[label2@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MinPrice@Sell@GUITabs@MyPrices]:UnsetChecked
		}
		else
		{
			UIElement[MinPlatPrice@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MinPlatPrice@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MinGoldPrice@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MinSilverPrice@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MinCopperPrice@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MinPlatPriceText@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MinGoldPriceText@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MinSilverPriceText@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MinCopperPriceText@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[label2@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MinPrice@Sell@GUITabs@MyPrices]:SetChecked
		}

		Platina:Set[${Math.Calc[${Money}/10000]}]
		Money:Set[${Math.Calc[${Money}-(${Platina}*10000)]}]
		Gold:Set[${Math.Calc[${Money}/100]}]
		Money:Set[${Math.Calc[${Money}-(${Gold}*100)]}]
		Silver:Set[${Money}]
		Money:Set[${Math.Calc[${Money}-${Silver}]}]
		Copper:Set[${Math.Calc[${Money}*100]}]

		UIElement[MinPlatPrice@Sell@GUITabs@MyPrices]:SetText[${Platina}]
		UIElement[MinGoldPrice@Sell@GUITabs@MyPrices]:SetText[${Gold}]
		UIElement[MinSilverPrice@Sell@GUITabs@MyPrices]:SetText[${Silver}]
		UIElement[MinCopperPrice@Sell@GUITabs@MyPrices]:SetText[${Copper}]
	}
}

function CheckMinPriceSet(string itemname)
{
	LavishSettings:AddSet[myprices]
	LavishSettings[myprices]:AddSet[General]
	LavishSettings[myprices]:AddSet[Item]

	variable settingsetref ItemList
	ItemList:Set[${LavishSettings[myprices].FindSet[Item]}]
	ItemList:AddSet[${itemName}]

	variable settingsetref Item
	Item:Set[${ItemList.FindSet[${itemname}]}]
	return ${Item.FindSetting[MinSalePrice]}
}

function savebuyinfo()
{
	Declare itemname string local
	Declare itemnumber int local
	Declare Platina int local
	Declare Gold int local
	Declare Silver int local
	Declare Copper float local
	Declare Money float local

	itemname:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[Buyname].Text}]
	itemnumber:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[BuyNumber].Text}]
	Platina:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MinPlatPrice].Text}]
	Gold:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MinGoldPrice].Text}]
	Silver:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MinSilverPrice].Text}]
	Copper:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MinCopperPrice].Text}]


	; calclulate the value in silver
	Platina:Set[${Math.Calc[${Platina}*10000]}]
	Gold:Set[${Math.Calc[${Gold}*100]}]
	Copper:Set[${Math.Calc[${Copper}/100]}]
	Money:Set[${Math.Calc[${Platina}+${Gold}+${Silver}+${Copper}]}]

	; check information was entered in all boxes and save
	if ${itemname.Length} == 0
	{
		UIElement[ErrorText@Buy@GUITabs@MyPrices]:SetText[No item name entered]
	}
	elseIf ${itemnumber} <= 0
	{
		UIElement[ErrorText@Buy@GUITabs@MyPrices]:SetText[Try setting a valid number of items]
	}
	elseif ${Money} <= 0
	{
		UIElement[ErrorText@Buy@GUITabs@MyPrices]:SetText[You haven't set a price to buy from]
	}
	else
	{
		UIElement[ErrorText@Buy@GUITabs@MyPrices]:SetText[Saving Information]
		call Saveitem Buy "${itemname}" ${Money} ${itemnumber}
		call buy init
	}
}

function deletebuyinfo(int ItemID)
{
	Declare itemname string local

	itemname:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[Buyname].Text}]

	LavishSettings:AddSet[myprices]
	LavishSettings[myprices]:AddSet[General]
	LavishSettings[myprices]:AddSet[Item]
	LavishSettings[myprices]:AddSet[Buy]

	variable settingsetref BuyList

	; find the item Sub-Set and remove it
	BuyList:Set[${LavishSettings[myprices].FindSet[Buy]}]
	BuyList.FindSet["${itemname}"]:Remove

	; save the new information
	LavishSettings[myprices]:Export["myprices.xml"]

	UIElement[ErrorText@Buy@GUITabs@MyPrices]:SetText[Deleting ${itemname}]

	; re-scan and display the new buy list
	call buy init
}

; Delete tyhe current item selected in the buybox

function ShowBuyPrices(int ItemID)
{
	Declare Money float local
	Declare number int local
	Declare LBoxString string local
	Declare Platina int local
	Declare Gold int local
	Declare Silver int local
	Declare Copper int local

	LBoxString:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[ItemList].Item[${ItemID}]}]

	LavishSettings:AddSet[myprices]
	LavishSettings[myprices]:AddSet[General]
	LavishSettings[myprices]:AddSet[Item]
	LavishSettings[myprices]:AddSet[Buy]

	variable settingsetref BuyList
	BuyList:Set[${LavishSettings[myprices].FindSet[Buy]}]

	variable settingsetref BuyItem
	BuyItem:Set[${BuyList.FindSet["${LBoxString}"]}]

	number:Set[${BuyItem.FindSetting[BuyNumber]}]
	Money:Set[${BuyItem.FindSetting[BuyPrice]}]

	Platina:Set[${Math.Calc[${Money}/10000]}]
	Money:Set[${Math.Calc[${Money}-(${Platina}*10000)]}]
	Gold:Set[${Math.Calc[${Money}/100]}]
	Money:Set[${Math.Calc[${Money}-(${Gold}*100)]}]
	Silver:Set[${Money}]
	Money:Set[${Math.Calc[${Money}-${Silver}]}]
	Copper:Set[${Math.Calc[${Money}*100]}]

	UIElement[MinPlatPrice@Buy@GUITabs@MyPrices]:SetText[${Platina}]
	UIElement[MinGoldPrice@Buy@GUITabs@MyPrices]:SetText[${Gold}]
	UIElement[MinSilverPrice@Buy@GUITabs@MyPrices]:SetText[${Silver}]
	UIElement[MinCopperPrice@Buy@GUITabs@MyPrices]:SetText[${Copper}]
	UIElement[BuyNumber@Buy@GUITabs@MyPrices]:SetText[${number}]
	UIElement[BuyName@Buy@GUITabs@MyPrices]:SetText[${LBoxString}]

}


function AddLog(string textline, string colour)
{
	UIElement[ItemList@Log@GUITabs@MyPrices]:AddItem[${textline},1,${colour}]
}

; when the script exits , save all the settings and do some cleaning up
atom atexit()
{
	LavishSettings[myprices]:Export[myprices.xml]
	ui -unload "${LavishScript.HomeDirectory}/Interface/EQ2Skin.xml"
	ui -unload "${LavishScript.HomeDirectory}/scripts/UI/mypricesUI.xml"
}


