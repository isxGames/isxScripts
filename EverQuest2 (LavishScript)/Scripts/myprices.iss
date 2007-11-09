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
    echo ISXEQ2 could not be loaded.  Script aborting.
    Script:End	
  }

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
	Exitmyprices:Set[FALSE]
	Pausemyprices:Set[TRUE]
	ScanSellNonStop:Set[FALSE]

	Declare labelname string script
	Declare i int script
	Declare j int script
	Declare ItemsForSale float script
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
	Declare itemlist[500] string script
	Declare itemprice[500,8] int script
	Declare numitems int script
	variable settingsetref flabel

	ISXEQ2:ResetInternalVendingSystem

	MyPrices:loadsettings
	MyPrices:LoadUI

	echo Running MyPrices version 0.08

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
							Me.Vending[${i}].Consignment[${j}]:Unlist
							wait 15
							; Call Search routine to find the lowest price
							Call BrokerSearch "${Me.Vending[${i}].Consignment[${j}]}"			
							ItemsForSale:Set[${Return}]
							; Broker search returns -1 if no items to compare were found	
							if ${ItemsForSale} != -1
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
										if ${MinBasePrice}<${MinSalePrice}
										{
											call StringFromPrice ${MinBasePrice}
											MinBasePriceS:Set[${Return}]
											call StringFromPrice ${MinSalePrice}
											Echo ${Me.Vending[${i}].Consignment[${j}].Name} : Low Price Found !! Match Price is ${MinBasePriceS} My Lowest Price is ${Return}
											; Set the text in the list box line to red
											call SetColour "${Me.Vending[${i}].Consignment[${j}].Name}" FFFF0000
										}
										else
										{
										; otherwise inform/change value to match
											call StringFromPrice ${MinBasePrice}
											Echo "${Me.Vending[${i}].Consignment[${j}].Name} : My Price : ${MyPriceS} : Cheaper Price Found !! Price to match is ${Return}"
											If ${MatchLowPrice}
											{
												call SetColour "${Me.Vending[${i}].Consignment[${j}].Name}" FF00FF00
												Me.Vending[${i}].Consignment[${j}]:SetPrice[${MinBasePrice}]
											}
										}
									}
									; **** if you are selling an item lower than the next lowest price
									elseif ${MyPrice}<${MinPrice}
									{
										; Set the colour of the listbox line to yellow
										call SetColour "${Me.Vending[${i}].Consignment[${j}].Name}" FFFCD116
										; if you have told the script to match higher prices or the item was unlisted
										if ${IncreasePrice} || ${ItemUnlisted}
										{
											call StringFromPrice ${MinBasePrice}
											Echo "${Me.Vending[${i}].Consignment[${j}].Name} : Your Price is lower that the next Lowest Price : Price to match is ${Return}"
											Me.Vending[${i}].Consignment[${j}]:SetPrice[${MinBasePrice}]
											; if the item was unlisted then update your sale price
											If ${ItemUnlisted}
											{
												if ${MinBasePrice}<${MinSalePrice}
												{
												Me.Vending[${i}].Consignment[${j}]:SetPrice[${MinSalePrice}]
												Call Saveitem Sell "${Me.Vending[${i}].Consignment[${j}].Name}" ${MinSalePrice}
												call SetColour "${Me.Vending[${i}].Consignment[${j}].Name}" FF00FF00
												}
												else
												{
												Call Saveitem Sell "${Me.Vending[${i}].Consignment[${j}].Name}" ${MinBasePrice}
												call SetColour "${Me.Vending[${i}].Consignment[${j}].Name}" FF00FF00
												Call SetArrayValues "${Me.Vending[${i}].Consignment[${j}].Name}" ${MinBasePrice}
												}
											}
										}
									}
									Else
									{
									call SetColour "${Me.Vending[${i}].Consignment[${j}].Name}" FF00FF00
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
								Me.Vending[${i}].Consignment[${j}]:List
								Wait 25
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
	Declare Platina int local
	Declare Gold int local
	Declare Silver int local
	Declare Copper int local

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
					itemlist[${numitems}]:Set[${Me.Vending[${i}].Consignment[${j}]}]
					; store the current price in PP,GP,SP,CP

					Platina:Set[${Math.Calc[${Money}/10000]}]
					itemprice[${numitems},1]:Set[${Platina}]

					Money:Set[${Math.Calc[${Money}-(${Platina}*10000)]}]
					Gold:Set[${Math.Calc[${Money}/100]}]
					itemprice[${numitems},2]:Set[${Gold}]

					Money:Set[${Math.Calc[${Money}-(${Gold}*100)]}]
					Silver:Set[${Money}]
					itemprice[${numitems},3]:Set[${Silver}]

					Money:Set[${Math.Calc[${Money}-${Silver}]}]
					Copper:Set[${Math.Calc[${Money}* 100]}]
					itemprice[${numitems},4]:Set[${Copper}]

					; store the minimum price in PP,GP,SP,CP

					call checkitem "${labelname}"
					Money:Set[${Return}]
					; If the a saved value is returned use those otherwise it will use the same values for both
					if ${Money} != -1
					{				
						Platina:Set[${Math.Calc[${Money}/10000]}]
						Money:Set[${Math.Calc[${Money}-(${Platina}*10000)]}]
						Gold:Set[${Math.Calc[${Money}/100]}]
						Money:Set[${Math.Calc[${Money}-(${Gold}*100)]}]
						Silver:Set[${Money}]
						Money:Set[${Math.Calc[${Money}-${Silver}]}]
						Copper:Set[${Math.Calc[${Money}* 100]}]
					}
					else
					{
						Echo Item Missing from Settings File,  Adding : ${labelname}
						call Saveitem Sell "${labelname}" ${Me.Vending[${i}].Consignment[${j}].BasePrice}
						call SetArrayValues "${labelname}" ${Me.Vending[${i}].Consignment[${j}].BasePrice}
					}
					itemprice[${numitems},5]:Set[${Platina}]
					itemprice[${numitems},6]:Set[${Gold}]
					itemprice[${numitems},7]:Set[${Silver}]
					itemprice[${numitems},8]:Set[${Copper}]
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
	}

}

; Convert a price in pp gp sp cp format to float price in silver 

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


function pricefromstring()
	{
		Declare itemname string local
		Declare Platina int local
		Declare Gold int local
		Declare Silver int local
		Declare Copper float local
		Declare Money float local

		itemname:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[Itemname].Text}]
		if ${itemname.Equal[*]}
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
function Saveitem(string Saveset, string Name, float Money)
	{
 	     	LavishSettings:AddSet[myprices]
		LavishSettings[myprices]:AddSet[General]
		LavishSettings[myprices]:AddSet[Item]

		variable settingsetref ItemList
     		variable settingsetref Item

	      ItemList:Set[${LavishSettings[myprices].FindSet[Item]}]
		ItemList:AddSet[${Name}]
		Item:Set[${ItemList.FindSet[${Name}]}]
		Item:AddSetting[${Saveset},${Money}]
		LavishSettings[myprices]:Export["myprices.xml"]
	}

function SetColour(string text, string colour)
	{
		Declare LocalLoop int 1 local
		Declare LBoxString string local
		Declare MaxElements int local
		MaxElements:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[ItemList].Items}]
		do
		{
			LBoxString:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[ItemList].Item[${LocalLoop}]}] 
			if ${text.Equal["${LBoxString}"]}
			{
			UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[ItemList]:RemoveItem[${LocalLoop}]
			UIElement[ItemList@Sell@GUITabs@MyPrices]:AddItem[${text},${LocalLoop},${colour}]
			}
		}
		While ${LocalLoop:Inc} <= ${MaxElements} 
	}

function SetArrayValues(string text, float Money)
	{
		Declare LocalLoop int 1 local
		Declare LBoxString string local
		Declare MaxElements int local
		Declare Platina int local
		Declare Gold int local
		Declare Silver int local
		Declare Copper float local

		MaxElements:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[ItemList].Items}]
		Platina:Set[${Math.Calc[${Money}/10000]}]
		Money:Set[${Math.Calc[${Money}-(${Platina}*10000)]}]
		Gold:Set[${Math.Calc[${Money}/100]}]
		Money:Set[${Math.Calc[${Money}-(${Gold}*100)]}]
		Silver:Set[${Money}]
		Money:Set[${Math.Calc[${Money}-${Silver}]}]
		Copper:Set[${Math.Calc[${Money}* 100]}]

		do
		{
			LBoxString:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[ItemList].Item[${LocalLoop}]}] 
			if ${text.Equal["${LBoxString}"]}
			{
			itemprice[${LocalLoop},1]:Set[${Platina}]
			itemprice[${LocalLoop},2]:Set[${Gold}]
			itemprice[${LocalLoop},3]:Set[${Silver}]
			itemprice[${LocalLoop},4]:Set[${Copper}]
			itemprice[${LocalLoop},5]:Set[${Platina}]
			itemprice[${LocalLoop},6]:Set[${Gold}]
			itemprice[${LocalLoop},7]:Set[${Silver}]
			itemprice[${LocalLoop},8]:Set[${Copper}]
			}
		}
		While ${LocalLoop:Inc} <= ${MaxElements} 
	}

; when the script exits , do some cleaning up
atom atexit()
{
	LavishSettings[myprices]:Export[myprices.xml]
	ui -unload "${LavishScript.HomeDirectory}/Interface/EQ2Skin.xml"
	ui -unload "${LavishScript.HomeDirectory}/scripts/UI/mypricesUI.xml"
}
