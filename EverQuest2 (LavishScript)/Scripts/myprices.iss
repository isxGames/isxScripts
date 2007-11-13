;
; MyPrices  - EQ2 Broker script
;
; Version 0.08d : Coded 13 Nov 2007
;
; Main Script
;
function main()
{

#define WAITEXTPERIOD 120

	echo "Verifying ISXEQ2 is loaded and ready "
	wait WAITEXTPERIOD ${ISXEQ2.IsReady}
	if !${ISXEQ2.IsReady}
	{
		echo ISXEQ2 could not be loaded. Script aborting.
		Script:End
	}
	echo Running MyPrices version 0.08d - coded : 12 Nov 2007

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
	Declare ItemPrice float 0 script
	Declare MyPrice float 0 script
	; Array - stores name (Listbox ID)
	Declare itemlist[600] string script
	; Array - stores current price (Container,Position in container)
 	Declare itemprice[600,2] int script
	Declare numitems int script

	Declare loopcount int 0 local

	variable settingsetref flabel

	ISXEQ2:ResetInternalVendingSystem

	MyPrices:loadsettings
	MyPrices:LoadUI

	call LoadList

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
		While ${Pausemyprices} == TRUE

		; Start scanning the broker


		i:Set[1]
		j:Set[1]

		do
		{
			if (${Me.Vending[${i}](exists)})
			{
				SellLoc:Set[${Me.Vending[${i}].Market}]
				SellCon:Set[${Me.Vending[${i}]}]
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
				if "${Me.Vending[${i}].NumItems}>0"
				{
					do
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
							}
							while ${Me.Vending[${i}].Consignment[${j}].IsListed} && ${loopcount:Inc} < 10
							; check to see if the items minimum price should be used or not
							Call CheckMinPriceSet "${Me.Vending[${i}].Consignment[${j}]}"
							MinPriceSet:Set[${Return}]
							; Call Search routine to find the lowest price
							Call BrokerSearch "${Me.Vending[${i}].Consignment[${j}]}"
							; Broker search returns -1 if no items to compare were found
							if ${Return} != -1
							{
								; record the minimum broker price
								MinPrice:Set[${Return}]

								; check if the item is in the myprices settings file
								call checkitem "${Me.Vending[${i}].Consignment[${j}]}"
								MinSalePrice:Set[${Return}]

								; if a stored Minimum Sale price was found then carry on
								if ${MinSalePrice}!= -1
								{
									; Calculate the Baseprice + Commission to set the value to match the currently lowest price
									MinBasePrice:Set[${Math.Calc[((${MinPrice}/${Math.Calc[100+${Commission}]})*100)]}]
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
											Echo ${Me.Vending[${i}].Consignment[${j}].Name} : Match Price is ${MinBasePriceS} : My Lowest Price is ${Return}
											; Set the text in the list box line to red
											call SetColour ${i} ${j} FFFF0000
										}
										else
										{
											; otherwise inform/change value to match
											call StringFromPrice ${MinBasePrice}
											Echo "${Me.Vending[${i}].Consignment[${j}].Name} : My Price : ${MyPriceS} : Cheaper Price Found !! Price to match is ${Return}"
											If ${MatchLowPrice}
											{
												call SetColour ${i} ${j} FF00FF00
												Me.Vending[${i}].Consignment[${j}]:SetPrice[${MinBasePrice}]
											}
										}
									}
									; **** if you are selling an item lower than the next lowest price
									elseif ${MyPrice}<${MinPrice}
									{
										; Set the colour of the listbox line to yellow
										call SetColour ${i} ${j} FFFCD116
										; if you have told the script to match higher prices or the item was unlisted
										if ${IncreasePrice} || ${ItemUnlisted}
										{
											If !${ItemUnlisted}
											{
												call StringFromPrice ${MinBasePrice}
												Echo "${Me.Vending[${i}].Consignment[${j}].Name} : Price < Lowest Price : Price to match is ${Return}"
												Me.Vending[${i}].Consignment[${j}]:SetPrice[${MinBasePrice}]
											}
											else
											; if the item was unlisted then update your sale price
											{
												; if a minimum price was set previously for this item then use that value
												if ${MinBasePrice}<${MinSalePrice} && ${MinPriceSet}
												{
													call StringFromPrice ${MinSalePrice}
													Echo "${Me.Vending[${i}].Consignment[${j}].Name} : Unlisted : Setting to ${Return}"
													Me.Vending[${i}].Consignment[${j}]:SetPrice[${MinSalePrice}]
													Call Saveitem Sell "${Me.Vending[${i}].Consignment[${j}].Name}" ${MinSalePrice}
													call SetColour ${i} ${j} FFFF0000
												}
												else
												{
													; otherwise use the lowest price on the vendor
													call StringFromPrice ${MinBasePrice}
													Echo "${Me.Vending[${i}].Consignment[${j}].Name} : Unlisted : Setting to ${Return}"
													Me.Vending[${i}].Consignment[${j}]:SetPrice[${MinBasePrice}]
													; if no previous minimum price was saved then save the lowest current price (makes sure a value is there)
													if ${MinSalePrice} == 0
													{
														Call Saveitem Sell "${Me.Vending[${i}].Consignment[${j}].Name}" ${MinBasePrice}
													}
													call SetColour ${i} ${j} FF0000FF
												}
											}
										}
									}
									Else
									{
										call SetColour ${i} ${j} FF00FF00
									}
								}
								else
								{
									echo Adding ${Me.Vending[${i}].Consignment[${j}]} at ${MyBasePrice}
									call Saveitem Sell "${Me.Vending[${i}].Consignment[${j}]}" ${MyBasePrice}
								}
							}

							; Re-List the item for sale if the item was already for sale
							if !${ItemUnlisted}
							{
								loopcount:Set[0]
								do
								{
									Me.Vending[${i}].Consignment[${j}]:List
									wait 10
								}
								while !${Me.Vending[${i}].Consignment[${j}].IsListed} && ${loopcount:Inc} < 10
								if ${loopcount} == 10
								{
									echo *** ERROR - unable to mark ${Me.Vending[${i}].Consignment[${j}]} as listed for sale
								}
							}
							; if the Quit Button on the UI has been pressed then exit
							if ${Exitmyprices}
							{
								Echo Exit Pressed , closing script.
								Script:End
							}
						}
					}
					while ${j:Inc} <= ${Me.Vending[${i}].NumItems} && ${Pausemyprices} == FALSE
				}
				j:Set[1]
			}
		}
		while ${i:Inc} <= 6 && ${Pausemyprices} == FALSE
		if !${ScanSellNonStop}
		{
			UIElement[Start Scanning@Sell@GUITabs@MyPrices]:SetText[Start Scanning]
			Pausemyprices:Set[TRUE]
		}
	}
	While ${Exitmyprices} == FALSE
}

function BrokerSearch(string lookup)
{
	Declare CurrentPage int 1 local
	Declare CurrentItem int 1 local
	Declare TempMinPrice float -1 local
	broker Name "${lookup}"
	Wait 15
	; if broker has any listed to compare with your item
	if "${Vendor.NumItemsForSale} >0"
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
					; if the price of the item is less than the current lowest price then make that the new lowest price
					if ${Vendor.Broker[${CurrentItem}].Price}<${TempMinPrice} || ${TempMinPrice} == -1
					{
						TempMinPrice:Set[${Vendor.Broker[${CurrentItem}].Price}]
					}
				}
			}
			while "${CurrentItem:Inc}<=${Vendor.NumItemsForSale}"
			wait 10
		}
		while ${CurrentPage:Inc}<=${Vendor.TotalSearchPages}
		wait 5
	}
	; Return the Lowest Price Found or -1 if nothing found.
	return ${TempMinPrice}
}


function checkitem(string name)
{
	LavishSettings:AddSet[myprices]
	LavishSettings[myprices]:AddSet[General]
	LavishSettings[myprices]:AddSet[Item]

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
			if ${Me.Vending[${i}].NumItems}>0
			{
				do
				{
					numitems:Set[${Math.Calc[${numitems}+1]}]
					labelname:Set[${Me.Vending[${i}].Consignment[${j}]}]
					UIElement[ItemList@Sell@GUITabs@MyPrices]:AddItem[${labelname}]
					Money:Set[${Me.Vending[${i}].Consignment[${j}].BasePrice}]
					; store the item name
					call SetArrayValues ${numitems} ${i} ${j} "${labelname}"
					; check to see if it already has a minimum price set
					call checkitem "${labelname}"
					Money:Set[${Return}]
					; If no value is returned then add the price to the settings file
					if ${Money} == -1
					{
						call SetColour ${i} ${j} FF0000FF
						Echo Item Missing from Settings File,  Adding : ${labelname}
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
		variable settingsetref ItemList
		ItemList:Set[${LavishSettings[myprices].FindSet[Item]}]
		; make sure nothing from a previous run is in memory (DEVL)
		ItemList:Clear
		LavishSettings[myprices]:Import["myprices.xml"]
		variable settingsetref GeneralSetting
		GeneralSetting:Set[${LavishSettings[myprices].FindSet[General]}]
		MatchLowPrice:Set[${GeneralSetting.FindSetting[MatchLowPrice]}]
		IncreasePrice:Set[${GeneralSetting.FindSetting[IncreasePrice]}]
		SetUnlistedPrices:Set[${GeneralSetting.FindSetting[SetUnlistedPrices]}]
		ScanSellNonStop:Set[${GeneralSetting.FindSetting[ScanSellNonStop]}]
		BuyItems:Set[${GeneralSetting.FindSetting[BuyItems]}]
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
		Echo Try Selecting someting first!!
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

function Saveitem(string Saveset, string ItemName, float Money, int Number, float Buyprice)
{
	LavishSettings:AddSet[myprices]
	LavishSettings[myprices]:AddSet[General]
	LavishSettings[myprices]:AddSet[Item]

	variable settingsetref ItemList
	ItemList:Set[${LavishSettings[myprices].FindSet[Item]}]
	ItemList:AddSet[${ItemName}]

	variable settingsetref Item
	Item:Set[${ItemList.FindSet[${ItemName}]}]

	Item:AddSetting[${Saveset},${Money}]
	if ${Saveset.Equal["Sell"]}
	{
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
		Item:AddSetting[BuyPrice,${Buyprice}]
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

function SetColour(int i, int j, string colour)
{
	Declare MaxElements int local
	Declare LocalLoop int 1 local
	Declare ItemName string local
	MaxElements:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[ItemList].Items}]

	; Scan the array till a match is found

	do
	{
		if ${itemprice[${LocalLoop},1]} == ${i} && ${itemprice[${LocalLoop},2]} == ${j}
		{
			ItemName:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[ItemList].Item[${LocalLoop}]}]

			; if the item in the listbox is still in the same spot in your broker slots change the color
			if ${ItemName.Equal[${Me.Vending[${i}].Consignment[${j}]}]}
			{
				UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[ItemList].Item[${LocalLoop}]:SetTextColor[${colour}]
			}
			else
			{
			; otherwise , the item(s) were removed or sold , re-scan your broker slots to update the GUI list again
				Call LoadList
			}
			break
		}

	}
	while ${LocalLoop:Inc} <= ${MaxElements}
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

	; Put the values in the right boxes.

	; Display the current price

	ItemName:Set[${Me.Vending[${itemprice[${ItemID},1]}].Consignment[${itemprice[${ItemID},2]}].Name}]

	if !${ItemName.Equal["${itemlist[${ItemID}]}"]}
	{
		; Item List name doesn't match your consignment items name , re-scan the list
		call LoadList
	}
	else
	{
		UIElement[Itemname@Sell@GUITabs@MyPrices]:SetText[${itemlist[${ItemID}]}]

		; Display your current Price for that Item

		Money:Set[${Me.Vending[${itemprice[${ItemID},1]}].Consignment[${itemprice[${ItemID},2]}].BasePrice}]

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

		LBoxString:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[ItemList].Item[${ItemID}]}]

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
		Copper:Set[${Math.Calc[${Money}* 100]}]

		UIElement[MinPlatPrice@Sell@GUITabs@MyPrices]:SetText[${Platina}]
		UIElement[MinGoldPrice@Sell@GUITabs@MyPrices]:SetText[${Gold}]
		UIElement[MinSilverPrice@Sell@GUITabs@MyPrices]:SetText[${Silver}]
		UIElement[MinCopperPrice@Sell@GUITabs@MyPrices]:SetText[${Copper}]
	}
}


; change the values in the arrays holding item name and placement in your broker system
function SetArrayValues(int ListID, int i, int j, string text)
{
	itemlist[${ListID}]:Set["${text}"]
	itemprice[${ListID},1]:Set[${i}]
	itemprice[${ListID},2]:Set[${j}]
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

	if ${itemname.Length} == 0
	{
		UIElement[ErrorText@Buy@GUITabs@MyPrices]:SetText[No item name entered]
	}
	elseIf ${itemnumber} <= 0
	{
		UIElement[ErrorText@Buy@GUITabs@MyPrices]:SetText[Try setting a valid ammount]
	}
	elseif ${Money} <= 0
	{
		UIElement[ErrorText@Buy@GUITabs@MyPrices]:SetText[You haven't set a price to buy from]
	}
	else
	{
		UIElement[ErrorText@Buy@GUITabs@MyPrices]:SetText[Saving Information]
		call Saveitem Buy "${itemname}" ${Money} {itemnumber}

	}
}


; when the script exits , save all the settings and do some cleaning up
atom atexit()
{
	LavishSettings[myprices]:Export[myprices.xml]
	ui -unload "${LavishScript.HomeDirectory}/Interface/EQ2Skin.xml"
	ui -unload "${LavishScript.HomeDirectory}/scripts/UI/mypricesUI.xml"
}
