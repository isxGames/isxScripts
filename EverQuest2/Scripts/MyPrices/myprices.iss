;
; MyPrices  - EQ2 Broker Buy/Sell script
;
variable string Version="Version 0.15d :  released 22nd May 2010"
;
; Declare Variables
;

variable int brokerslots=8
variable int InventorySlots=6

variable BrokerBot MyPrices

; 
variable bool MatchLowPrice
variable bool IncreasePrice
variable bool TakeCoin=FALSE
variable bool Exitmyprices=FALSE
variable bool Pausemyprices=TRUE
variable bool MerchantMatch
variable bool SetUnlistedPrices
variable bool ItemUnlisted
variable bool ScanSellNonStop
variable bool BuyItems
variable bool MinPriceSet
variable bool IgnoreCopper
variable bool SellItems
variable bool Craft
variable bool Logging
variable bool Natural
variable bool MatchActual
variable bool MaxPriceSet
variable bool runautoscan
variable bool runplace
variable bool ItemNotStack
variable bool BadContainer=FALSE
variable bool BadItem=FALSE
variable bool HighLatency
variable bool NewItemsOnly
variable bool Shinies
variable bool PlaceRaws
variable bool PlaceRares
variable bool PlaceUncommon
variable bool UseOgreCraft

; Bool variables used to integrate with eq2inventory script
variable bool CraftListMade=FALSE
variable bool CraftItemsPlaced=FALSE
variable bool ItemsArePriced=FALSE

; Array stores bool - to scan box or not
variable bool box[8]

; Arrays,  store bool and containerID - to scan inventory container/bag or not
variable bool NoSale[6]
variable int NoSaleID[6]

variable string MyPriceS
variable string MinBasePriceS
variable string SellLoc
variable string SellCon
variable string CurrentChar

variable int i
variable int j
variable int Commission
variable int IntMinBasePrice

variable int numitems
variable int currentpos
variable int currentcount
variable int PauseTimer
variable int WaitTimer
variable int StopWaiting
variable int InventorySlotsFree=${Me.InventorySlotsFree}
variable int ClickID
variable int ShiniesBox=0
variable int RawsBox=0
variable int RaresBox=0
variable int UncommonBox=0

variable float MyBasePrice
variable float MerchPrice
variable float PriceInSilver
variable float MinSalePrice
variable float MaxSalePrice
variable float MinPrice=0
variable float MinBasePrice=0
variable float ItemPrice=0
variable float MyPrice=0

; stats variables

variable float Profit=0
variable float Cost=0
variable float ProfitChange=0

; Index pointers for Lavishsettings
variable settingsetref CraftList
variable settingsetref CraftItemList
variable settingsetref BuyList
variable settingsetref BuyName
variable settingsetref BuyItem
variable settingsetref ItemList
variable settingsetref Item
variable settingsetref General
variable settingsetref Rejected
variable settingsetref Raws
variable settingsetref Rares
variable settingsetref Uncommon


; Global Variables used to save information in all functions/datafiles

variable string Saveset
variable string ItemName
variable float Money
variable float MaxMoney
variable int Number
variable bool Flagged
variable bool NameOnly
variable bool Attunable
variable bool AutoTransmute
variable bool ExamineOpen
variable int StartLevel
variable int EndLevel
variable int Tier
variable string Recipe
variable int Box1
variable int Box2
variable int Box3
variable int Box4
variable int Box5
variable int Box6
variable int Box7
variable int Box8
variable float BoxMaxDefault[8]
variable float BoxMinDefault[8]
variable bool Collectible
variable bool NewCollection
variable bool LowerNumber
variable int LowerItemNumber
variable collection:string BadItems

; Strings holding all the various file paths
variable filepath CraftPath="${LavishScript.HomeDirectory}/Scripts/EQ2Craft/Character Config/"
variable filepath NewCraftPath="${LavishScript.HomeDirectory}/Scripts/EQ2Craft/Queues/"
variable filepath OgreNewCraftPath="${LavishScript.HomeDirectory}/Scripts//eq2ogrecraft/Recipequeues/"
variable filepath XMLPath="${LavishScript.HomeDirectory}/Scripts/MyPrices/XML/"
variable filepath BackupPath="${LavishScript.HomeDirectory}/Scripts/MyPrices/Backup/"
variable filepath MyPricesUIPath="${LavishScript.HomeDirectory}/Scripts/MyPrices/UI/"
variable filepath LogPath="${LavishScript.HomeDirectory}/Scripts/MyPrices/"


; Main Script
;
function main(string goscan, string goscan2)
{
#define WAITEXTPERIOD 120
	call AddLog "Verifying ISXEQ2 is loaded and ready" FF11CCFF
	wait WAITEXTPERIOD ${ISXEQ2.IsReady}
	if !${ISXEQ2.IsReady}
	{
		echo ISXEQ2 could not be loaded. Script aborting.
		Script:End
	}

	variable int loopcount=0

	ISXEQ2:ResetInternalVendingSystem
	CurrentChar:Set[${Me.Name}]

	MyPrices:loadsettings
	; backup the current settings file on script load

	LavishSettings[myprices]:Export[${BackupPath}${EQ2.ServerName}_${Me.Name}_MyPrices.XML]
	
	MyPrices:LoadUI
	MyPrices:InitTriggersAndEvents
	
	Event[EQ2_onInventoryUpdate]:AttachAtom[EQ2_onInventoryUpdate]
	Event[EQ2_onChoiceWindowAppeared]:AttachAtom[EQ2_onChoiceWindowAppeared]
	Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]
	
	call AddLog "${Version}" FF11FFCC
	call echolog "${Version}"
	
	call StartUp	

	if ${goscan.Equal["PLACE"]} || ${goscan2.Equal["PLACE"]}
	{
		Pausemyprices:Set[FALSE]
		runplace:Set[TRUE]
		UIElement[Start Scanning@Sell@GUITabs@MyPrices]:SetText[Stop and Quit]
	}

	if ${goscan.Equal["SCAN"]} || ${goscan2.Equal["SCAN"]}
	{
		Pausemyprices:Set[FALSE]
		runautoscan:Set[TRUE]
		UIElement[Start Scanning@Sell@GUITabs@MyPrices]:SetText[Stop and Quit]
	}

	do
	{
		; wait for the GUI Start Scanning button to be pressed
		
		do
		{
			if !${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[Errortext].Text.Equal["** Waiting **"]}
				UIElement[Errortext@Sell@GUITabs@MyPrices]:SetText["** Waiting **"]

			if !${Me.Name.Equal[${CurrentChar}]}
			{
				
				Echo Character changed , exiting script
				Script:End
			}
			
			if !${QueuedCommands}
				WaitFrame
			else
				ExecuteQueued
				Waitframe
				
			; exit if the Stop and Quit Button is Pressed
			if ${Exitmyprices}
				Script:End
		}
		While ${Pausemyprices}

		ItemsArePriced:Set[FALSE]
		
		UIElement[Errortext@Sell@GUITabs@MyPrices]:SetText[" **Processing**"]
		call echolog "Start Scanning"
		call echolog "**************"
		call LoadList

		PauseTimer:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[PauseTimer].Text}]
		call SaveSetting PauseTimer ${PauseTimer}
		
		; if paramater PLACE used then run place crafted items routine
		if ${runplace} 
		{
			call placeshinies
			
			; if the scan paramater hasn't been set then don't do anything else
			if !${runautoscan}
			{
				exitmyprices:Set[TRUE]
				break
			}
		}
		
		; Start scanning the broker
		if ${SellItems}
		{
			; reset all the main script counters to 1
			currentpos:Set[1]
			currentcount:Set[1]
			call resetscanned
			i:Set[1]
			j:Set[1]

			do
			{
				Call CheckFocus
				ItemName:Set["${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[ItemList].Item[${currentpos}]}"]

				; container number
				i:Set[${itemprice.Element[${currentpos}]}]
				
				; check where the container is being sold from to get the commission %

				SellLoc:Set[${BrokerWindow.VendingContainer[${i}].Market}]
				SellCon:Set[${BrokerWindow.VendingContainer[${i}]}]

				if ${BrokerWindow.VendingContainer[${i}].CurrentCoin} > 0 && ${TakeCoin}
					BrokerWindow.VendingContainer[${i}]:TakeCoin

				if ${SellLoc.Equal["Haven"]}
					Commission:Set[40]
				else
					Commission:Set[20]

				if ${SellCon.Equal["Veteran's Display Case"]} || ${SellCon.Equal["Veteranen-Schaukasten"]}
					Commission:Set[${Math.Calc[${Commission}/2]}]

				; Find where the Item is stored in the container
				call FindItem ${i} "${ItemName}"

				j:Set[${Return}]
				
				; If item was found in the container still
				if ${j} != -1
				{

					ItemUnlisted:Set[TRUE]

					; is the item listed for sale ?
					if ${BrokerWindow.VendingContainer[${i}].Consignment[${j}].IsListed}
						ItemUnlisted:Set[FALSE]
					
					if (${ItemUnlisted} && ${SetUnlistedPrices}) ||  !${SetUnlistedPrices}
					{
						; Calclulate the price someone would pay with commission
						MyBasePrice:Set[${BrokerWindow.VendingContainer[${i}].Consignment[${j}].BasePrice}]
						MerchPrice:Set[${BrokerWindow.VendingContainer[${i}].Consignment[${j}].Value}]
						MyPrice:Set[${Math.Calc[((${MyBasePrice}/100)*${Math.Calc[100+${Commission}]})]}]
						; If increase price is flag set
						if ${IncreasePrice}
						{
							; Unlist the item to make sure it's not included in the check for higher prices
							loopcount:Set[0]
							do
							{
								Call CheckFocus
								BrokerWindow.VendingContainer[${i}].Consignment[${j}]:Unlist
								wait 10
								; check the item hasn't moved in the list because it was unlisted
								call FindItem ${i} "${ItemName}"
								j:Set[${Return}]
							}
							while ${BrokerWindow.VendingContainer[${i}].Consignment[${j}].IsListed} && ${loopcount:Inc} < 10
						}
						call SetColour Sell ${currentpos} FF0B0301
						
						; check to see if the items minimum/maximum price should be used or not
						
						MinPriceSet:Set[${ItemList.FindSet["${ItemName}"].FindSetting[MinSalePrice]}]
						
						MaxPriceSet:Set[${ItemList.FindSet["${ItemName}"].FindSetting[MaxSalePrice]}]

						broker Name "${ItemName}" Sort ByPriceAsc MaxLevel 999

						if ${HighLatency}
							wait 30

						; scan to make sure the item is listed and get lowest price , TRUE means exact name match only
						Call BrokerSearch "${ItemName}" TRUE
						
						; Broker search returns -1 if no items to compare were found
						if ${Return} != -1
						{

							; record the minimum broker price
							MinPrice:Set[${Return}]

							; check if the item has a MaxPrice
							call checkitem MaxPrice "${ItemName}"
							MaxSalePrice:Set[${Return}]

							; check if the item is in the myprices settings file
							call checkitem Sell "${ItemName}"
							MinSalePrice:Set[${Return}]

							; if a stored Sale price was found then carry on
							if ${MinSalePrice}!= -1
							{
								;if my current price is less than my minimum price then increase it
								if (${MyBasePrice} < ${MinSalePrice}) && !${ItemUnlisted} && ${MinPriceSet}
								{
									MinBasePrice:Set[${MinSalePrice}]
									call StringFromPrice ${MinSalePrice}
									call AddLog "${ItemName} : Item price lower than your Minimum Price : ${Return}" FFFF0000
								}
								else
								{
									; If there is a minimum box price and no individual minimum item price set
									If (${MyBasePrice} < ${BoxMinDefault[${i}]}) && ${BoxMinDefault[${i}]} > 0
									{
										MinBasePrice:Set[${BoxMinDefault[${i}]}]
										call StringFromPrice ${BoxMinDefault[${i}]}
										call AddLog "${ItemName} : Item price lower than your Minimum Box Price: ${Return}" FFFF0000
									}
									else
									{
										if ${MatchActual}
										{
											MinBasePrice:Set[${MinPrice}]
										}
										else
										{
											MinBasePrice:Set[${Math.Calc[((${MinPrice}/${Math.Calc[100+${Commission}]})*100)]}]
										}
										
										; if the flag to ignore copper is set and the price is > 1 gold
										if ${IgnoreCopper} && ${MinBasePrice} > 100
										{
											; round the value to remove the coppers
											IntMinBasePrice:Set[${MinBasePrice}]
											MinBasePrice:Set[${IntMinBasePrice}]
										}
									}
								}

								; do conversion from silver value to pp gp sp cp format
								call StringFromPrice ${MyPrice}
								MyPriceS:Set[${Return}]

								; ***** If your price is less than what a merchant would buy for ****
								if ${MerchantMatch} && ${MyPrice} < ${MerchPrice} && !${ItemUnlisted}
								{
									Call echolog "<Main> (Match Mechant Price)"
									call SetItemPrice ${i} ${j} ${MerchPrice}
									MinBasePrice:Set[${MerchPrice}]
									call StringFromPrice ${MerchPrice}
									call AddLog "${ItemName} : Merchant Would buy for : ${Return}" FFFF0000
								}

								; ***** If your price is more than the lowest price on sale ****
								if ${MinPrice}<${MyPrice}
								{
									if ${MerchantMatch} && ${MinBasePrice} < ${MerchPrice}
									{
										MinBasePrice:Set[${MerchPrice}]
										call StringFromPrice ${MerchPrice}
										call AddLog "${ItemName} : Merchant Would buy for  more : ${Return}" FFFF0000
										call SetColour Sell ${currentpos} FFFF0000
									}
									
									; **** if that price is Less than the price you are willing to sell for , don't do anything
									if ${MinBasePrice}<${MinSalePrice} && ${MinPriceSet}
									{
										call StringFromPrice ${MinBasePrice}
										MinBasePriceS:Set[${Return}]
										call StringFromPrice ${MinSalePrice}
										call AddLog "${ItemName} : ${MinBasePriceS} : My Lowest : ${Return}" FFFF0000
										; Set the text in the list box line to red
										call SetColour Sell ${currentpos} FFFF0000
									}
									elseif ${MinBasePrice}<${BoxMinDefault[${i}]} && ${BoxMinDefault[${i}]} > 0 && !${MinPriceSet}
									{
											; OR if no minimum price for this item is set BUT it is Less than the set BOX price , don't do anything
											call StringFromPrice ${MinBasePrice}
											MinBasePriceS:Set[${Return}]
											call StringFromPrice ${BoxMinDefault[${i}]}
											call AddLog "${ItemName} : ${MinBasePriceS} : Box Lowest : ${Return}" FFFF0000
											; Set the text in the list box line to red
											call SetColour Sell ${currentpos} FFFF0000
									}
									else
									{
										; If you have a maximum price set and the sale price is > than that
										; then use the maximum price you will allow.
										if ${MinBasePrice}>${MaxSalePrice} && ${MaxPriceSet}
										{
											MinBasePrice:Set[${MaxSalePrice}]
											call StringFromPrice ${MaxSalePrice}
											call AddLog "${ItemName} : Price higher than you will allow: ${Return}" FFFF0000
										}
									
										; otherwise inform/change value to match
										call StringFromPrice ${MinBasePrice}
										call AddLog "${ItemName} :  Price to match is ${Return}" FF00FF00

										; if you have told the script to match lower prices
										If ${MatchLowPrice}
										{
											; if you've set a minimum item count with lower prices before price matching
											if ${ItemList.FindSet["${ItemName}"].FindSetting[LowerNumber]}
											{
												call checkitemcount "${ItemName}" ${MyBasePrice}
												; if there are MORE than the set number at a lower price then change yours to match.
												if ${Return}
												{
													call SetColour Sell ${currentpos} FF00FF00
													Call echolog "<Main> (Match Price change)"
													call SetItemPrice ${i} ${j} ${MinBasePrice}
													BrokerWindow.VendingContainer[${i}].Consignment[${j}]:SetPrice[${MinBasePrice}]
												}
											}
											else
											{
												call SetColour Sell ${currentpos} FF00FF00
												Call echolog "<Main> (Match Price change)"
												call SetItemPrice ${i} ${j} ${MinBasePrice}
												BrokerWindow.VendingContainer[${i}].Consignment[${j}]:SetPrice[${MinBasePrice}]
											}
										}
									}
								}
								; **** if you are selling an item lower than the next lowest price
								elseif ${MyPrice}<${MinPrice}
								{
									; Set the colour of the listbox line to green initially
									call SetColour Sell ${currentpos} FF00FF00
									; if you have told the script to match higher prices or the item was unlisted
									if ${IncreasePrice} || ${ItemUnlisted}
									{
										If !${ItemUnlisted}
										{
											; If you have a maximum price set and the sale price is > than that
											; then use the maximum price you will allow.
											if ${MinBasePrice}>${MaxSalePrice} && ${MaxPriceSet}
											{
												MinBasePrice:Set[${MaxSalePrice}]
											}
											call StringFromPrice ${MinBasePrice}
											call AddLog "${ItemName} : Price to match is ${Return} :" FF00FF00
											Call echolog "<Main> (Increase Price)"
											call SetItemPrice ${i} ${j} ${MinBasePrice}
										}
										else
										; if the item was unlisted then update your sale price
										{
											; if a minimum price was set previously for this item then use that value
											if ${MinBasePrice}<${MinSalePrice} && ${MinPriceSet}
											{
												call StringFromPrice ${MinSalePrice}
												call AddLog "${ItemName} : Unlisted : Setting to ${Return}" FFFF0000
												Call echolog "<Main> (Unlisted Item - Min Sale price)"
												call SetItemPrice ${i} ${j} ${MinSalePrice}
												
												Money:Set[${MinSalePrice}]
												MaxMoney:Set[${MinSalePrice}]
												Call Saveitem Prices
												
												call SetColour Sell ${currentpos} FFFF0000
											}
											else
											{
												; otherwise use the lowest price on the vendor or your highest price allowed
												if ${MinBasePrice}>${MaxSalePrice} && ${MaxPriceSet} && ${MaxSalePrice} > 0
												{
													MinBasePrice:Set[${MaxSalePrice}]
												}
												
												call StringFromPrice ${MinBasePrice}
												call AddLog "${ItemName} : Unlisted : Setting to ${Return}" FF00FF00
												Call echolog "<Main> (Unlisted Item - Lowest Broker Price)"
												call SetItemPrice ${i} ${j} ${MinBasePrice}
												; if no previous minimum price was saved then save the lowest current price (makes sure a value is there)
												if ${MinSalePrice} == 0
												{
													Money:Set[${MinBasePrice}]
													MaxMoney:Set[${MinBasePrice}]
													Call Saveitem Prices
												}
												call SetColour Sell ${currentpos} FF0000FF
											}
										}
									}
								}
								else
								{
									call SetColour Sell ${currentpos} FF00FF00
								}
							}
							else
							{
								Echo NO Sale Price found in XML
								
								if ${BoxMinDefault[${i}]} > 0
									Money:Set[${BoxMinDefault[${i}]}]
								else
									Money:Set[${MyBasePrice}]

								if ${BoxMaxDefault[${i}]} > 0
									MaxMoney:Set[${BoxMaxDefault[${i}]}]
								else
									MaxMoney:Set[${MyBasePrice}]
									
								call AddLog "Adding ${ItemName} at ${Money}" FF00CCFF

								Call Saveitem Prices
							}

							; Re-List item for sale
							call ReListItem ${i} "${ItemName}"

						}
						else
						{
							; if the item has a maximum price saved then use this
							if ${MaxPriceSet}
							{
								; Find where the Item is stored in the container
								call FindItem ${i} "${ItemName}"
								j:Set[${Return}]
								; Read the maximum price you will allow and set it to that price								
								call checkitem MaxPrice "${ItemName}"
								call SetItemPrice ${i} ${j} ${Return}
							}
							else
							{
								; if if no match or max price was found and the item was STILL listed for sale before
								; then re-list it
								
								if ${BoxMaxDefault[${i}]} > 0
								{
									; Find where the Item is stored in the container
									call FindItem ${i} "${ItemName}"
									j:Set[${Return}]
									; Read the maximum price you will allow and set it to that price								
									call SetItemPrice ${i} ${j} ${BoxMaxDefault[${i}]}
								}

								if !${ItemUnlisted}
									call ReListItem ${i} "${ItemName}"
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
					call SetColour Sell ${currentpos} FFC43012
				}
				; Mark position in list as scanned
				Scanned:Set[${currentpos},TRUE]
				; Choose the next item in the list to be looked at
				if ${Natural} && ${currentcount} < ${numitems}
				{
					call ChooseNextItem ${numitems}
					currentpos:Set[${Return}]
					wait ${Math.Rand[60]}
				}
				else
				{
					currentpos:Inc
				}
			}
			while ${currentcount:Inc} <= ${numitems} && ${Pausemyprices} == FALSE

			UIElement[Errortext@Sell@GUITabs@MyPrices]:SetText[" ** Finished **"]

		
			ItemsArePriced:Set[TRUE]

		}
		
		; Script starts to scan for items to buy if flagged.
		if ${BuyItems} && ${Pausemyprices} == FALSE
			{
			UIElement[Errortext@Sell@GUITabs@MyPrices]:SetText[" ** Buying **"]
			call buy Buy scan
			}

		if !${ScanSellNonStop}
			{
			UIElement[Start Scanning@Sell@GUITabs@MyPrices]:SetText[Start Scanning]
			Pausemyprices:Set[TRUE]
			}
		
		if ${runautoscan} || ${runplace}
			{
			Exitmyprices:Set[TRUE]
			ScanSellNonStop:Set[FALSE]
			}


		if ${ScanSellNonStop} && ${PauseTimer} > 0
		{
			Pausemyprices:Set[FALSE]
			if ${Natural}
			{
				WaitTimer:Set[${Math.Calc[600*${PauseTimer}]}]
				; get 1% of the pause time
				WaitTimer:Set[${Math.Calc[${WaitTimer}/100]}]
				; multiply it with between -20 and +20 to get a +/- 20% varience
				WaitTimer:Set[${Math.Calc[(${Math.Rand[40]}-20)*${WaitTimer}]}]
				; Reduce / Increase time by the random %
				WaitTimer:Set[${Math.Calc[(${PauseTimer}*600)+${WaitTimer}]}]
				call AddLog "Pausing for ${Math.Calc[${WaitTimer}/600]} minutes " FF0033EE
				UIElement[Errortext@Sell@GUITabs@MyPrices]:SetText["Pause ${Math.Calc[${WaitTimer}/600]} Mins"]
			}
			else
			{
				call AddLog "Pausing for ${PauseTimer} minutes " FF0033EE
				WaitTimer:Set[${Math.Calc[600*${PauseTimer}]}]
				UIElement[Errortext@Sell@GUITabs@MyPrices]:SetText["Pause ${PauseTimer} Mins"]
			}
			wait ${WaitTimer} ${StopWaiting}
			StopWaiting:Set[0]
		}
	}
	While ${Exitmyprices} == FALSE
}

function checkitemcount(string ItemName, float MyPrice)
{
	call echolog "-> checkitemcount ${ItemName} ${MyPrice}

	Declare CurrentItem int local=1
	Declare CurrentPage int local=1
	Declare ItemLimit int local
	Declare ItemCount int local=0
	Declare TempMinPrice float local
	
	ItemLimit:Set[${ItemList.FindSet["${ItemName}"].FindSetting[LowerItemNumber]}]
	CurrentPage:Set[1]
	do
	{
		CurrentItem:Set[1]
		do
		{
			; if checkbox set to ignore broker fee when matching prices
			if ${MatchActual}
			{
				TempMinPrice:Set[${BrokerWindow.SearchResult[${CurrentItem}].BasePrice}]
			}
			else
			{
				TempMinPrice:Set[${BrokerWindow.SearchResult[${CurrentItem}].Price}]
			}

			
			if ${TempMinPrice} > ${MyPrice} || ${ItemCount} >= ${ItemLimit}
				break
				
			if ${ItemName.Equal["${MerchantWindow.MerchantInventory[${CurrentItem}].Name}"]}
				ItemCount:Inc[${MerchantWindow.MerchantInventory[${CurrentItem}].Quantity}]
		}
		while ${CurrentItem:Inc}<=${BrokerWindow.NumSearchResults}
	}
	while ${CurrentPage:Inc}<=${BrokerWindow.TotalSearchPages}

	If ${ItemCount} >= ${ItemLimit}
		Return TRUE
	Else
		Return FALSE
		
	call echolog "<- checkitemcount
}

function addtotals(string ItemName, int itemnumber)
{
	call echolog "->  addtotals ${ItemName} ${itemnumber}"
	LavishSettings:AddSet[craft]
	LavishSettings[craft]:AddSet[CraftItem]

	Declare Totals int local

	CraftList:Set[${LavishSettings[craft].FindSet[CraftItem]}]


	if ${CraftList.FindSetting["${ItemName}"](exists)}
	{
		Totals:Set[${CraftList.FindSetting["${ItemName}"]}]
		CraftList:AddSetting["${ItemName}",${Math.Calc[${Totals}+${itemnumber}]}]
	}
	else
	{
		CraftList:AddSetting["${ItemName}",${itemnumber}]
	}
	call echolog "<end> : addtotals"
}

function:int FindItem(int i, string ItemName)
{
	call echolog "-> FindItem ${i} ${ItemName}"
	Call CheckFocus
	Declare j int local
	Declare ConName string local

	j:Set[1]
	do
	{

		ConName:Set["${BrokerWindow.VendingContainer[${i}].Consignment[${j}]}"]
		
		if ${ConName.Equal["${ItemName}"]}
		{
			Return ${j}
		}
	}
	while ${j:Inc} <= ${BrokerWindow.VendingContainer[${i}].NumItems}
	call echolog "<- FindItem -1"
	Return -1
}


function ReListItem(int i, string ItemName)
{
	call echolog "-> ReListItem ${i} ${ItemName}"
	Call CheckFocus
	Declare loopcount int local
	Declare j int local

	Call FindItem ${i} "${ItemName}"
	j:Set[${Return}]
	if ${j} != -1
	{
		if !${BrokerWindow.VendingContainer[${i}].Consignment[${j}].IsListed}
		{
			call echolog "${ItemName} (${i}, ${j}) is not listed for sale : ${BrokerWindow.VendingContainer[${i}].Consignment[${j}].IsListed}"
			call echolog "BrokerWindow.VendingContainer[${i}].Consignment[${j}].BasePrice Returned ${BrokerWindow.VendingContainer[${i}].Consignment[${j}].BasePrice}"

			if ${BrokerWindow.VendingContainer[${i}].Consignment[${j}].BasePrice} >0
			{
				; Re-List the item for sale
				loopcount:Set[0]
				do
				{
					BrokerWindow.VendingContainer[${i}].Consignment[${j}]:List
					wait 15
					Call FindItem ${i} "${ItemName}"
					j:Set[${Return}]
				}
				while !${BrokerWindow.VendingContainer[${i}].Consignment[${j}].IsListed} && ${loopcount:Inc} < 10

				if ${loopcount} == 10
					call AddLog "*** ERROR - unable to mark ${ItemName} as listed for sale" FFFF0000
			}
			else
			{
				call AddLog "*** ERROR - Item was marked as ZERO value - unlisting from sale" FFFF0000
				loopcount:Set[0]
				do
				{
					BrokerWindow.VendingContainer[${i}].Consignment[${j}]:Unlist
					wait 15
					; check the item hasn't moved in the list because it was unlisted
					call FindItem ${i} "${ItemName}"
					j:Set[${Return}]
				}
				while ${BrokerWindow.VendingContainer[${i}].Consignment[${j}].IsListed} && ${loopcount:Inc} < 10

				if ${loopcount} == 10
					call AddLog "*** ERROR - unable to mark ${ItemName} as Unlisted" FFFF0000
			}
		}
	}
	else
	{
		; item was moved or sold
		call SetColour Sell ${currentpos} FFC43012
	}
	call echolog "<end> : ReListItem"
}

function checkstock()
{
	call echolog "<start> : checkstock"

	CraftListMade:Set[FALSE]

	LavishSettings[newcraft]:Clear

	call buy Craft scan

	UIElement[Errortext@Sell@GUITabs@MyPrices]:SetText[" **Making List**"]

	CraftListMade:Set[TRUE]

	call echolog "<end> : checkstock"
}

function buy(string tabname, string action)
{
	
	call echolog "-> buy Tab : ${tabname} Action : ${action}"

	if ${action.Equal["compact"]}
		UIElement[Errortext@Admin@GUITabs@MyPrices]:SetText[" ** Compacting - please wait **"]

	; Read data from the Item Set
	;
	Declare CraftItem bool local
	Declare CraftStack int local
	Declare CraftMinTotal int local
	Declare Harvest bool local

	Declare MinSalePrice bool local
	Declare MaxSalePrice bool local

	Declare BuyAttuneOnly bool local
	Declare BuyNameOnly bool local
	
	Declare i int local
	Declare j int local
	
	if ${tabname.Equal["Buy"]}
		BuyList:Set[${LavishSettings[myprices].FindSet[Buy]}]
	else
		BuyList:Set[${LavishSettings[myprices].FindSet[Item]}]

	if ${action.Equal["init"]}
		UIElement[ItemList@${tabname}@GUITabs@MyPrices]:ClearItems

	variable iterator BuyIterator
	variable iterator NameIterator
	variable iterator BuyNameIterator

	; Index each item under the Set defined by BuyList

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

				; run the various options (Scan / update price etc based on the parameter passed to the routine
				;
				; init = build up the list of items on the buy tab
				; scan = check the broker list one by one - do buy and various workhorse routines
				; clean = remove items from the data if they are not in the vendor boxes,aren't crafted or don't have a min/max price
				; place =  place crafted flagged items on the broker
				; compact = remove excess items from the datafile.

				if ${action.Equal["init"]} && ${tabname.Equal["Buy"]}
					UIElement[ItemList@Buy@GUITabs@MyPrices]:AddItem["${BuyIterator.Key}"]
				else
				{
					; read the Settings in the Sub-Set
					if ${BuyNameIterator:First(exists)}
					{
						Collectible:Set[FALSE]
						CraftItem:Set[FALSE]
						Harvest:Set[FALSE]
						Recipe:Set[NULL]
						AutoTransmute:Set[FALSE]
						BuyAttuneOnly:Set[FALSE]
						BuyNameOnly:Set[FALSE]
						MinSalePrice:Set[FALSE]
						MaxSalePrice:Set[FALSE]
						; Scan the subset to get all the settings
						do
						{
							Switch "${BuyNameIterator.Key}"
							{
								Case BuyNumber
									Number:Set[${BuyNameIterator.Value}]
									break
								Case BuyPrice
									Money:Set[${BuyNameIterator.Value}]
									break
								Case BuyNameOnly
									NameOnly:Set[${BuyNameIterator.Value}]
									break
								Case BuyAttuneOnly
									Attunable:Set[${BuyNameIterator.Value}]
									break
								Case MaxSpend
									MaxMoney:Set[${BuyNameIterator.Value}]
									break
								Case Harvest
									Flagged:Set[${BuyNameIterator.Value}]
									break
								Case AutoTransmute
									AutoTransmute:Set[${BuyNameIterator.Value}]
									break
								Case CraftItem
									CraftItem:Set[${BuyNameIterator.Value}]
									break
								Case Collectible
									Collectible:Set[${BuyNameIterator.Value}]
									break
								Case Stack
									CraftStack:Set[${BuyNameIterator.Value}]
									break
								Case Stock
									CraftMinTotal:Set[${BuyNameIterator.Value}]
									break
								Case Recipe
									Recipe:Set[${BuyNameIterator.Value}]
									break
								Case StartLevel
									StartLevel:Set[${BuyNameIterator.Value}]
									break
								Case EndLevel
									EndLevel:Set[${BuyNameIterator.Value}]
									break
								Case Tier
									Tier:Set[${BuyNameIterator.Value}]
									break
								Case MinSalePrice
									MinSalePrice:Set[${BuyNameIterator.Value}]
									break
								Case MaxSalePrice
									MaxSalePrice:Set[${BuyNameIterator.Value}]
									break
							}
						}
						while ${BuyNameIterator:Next(exists)}

						; run the routine to scan and buy items if we still need more bought
						
						if ${Number} > 0 && ${tabname.Equal["Buy"]}
						{
							Call CheckFocus
							
							ItemName:Set["${BuyIterator.Key}"]
							call BuyItems
						
							; Pause or quit pressed then exit the routine
							
							if !${QueuedCommands}
								WaitFrame
							else
								ExecuteQueued
								Waitframe
								
							if ${Exitmyprices} || ${Pausemyprices}
								Return
						}
						elseif ${action.Equal["init"]} && ${tabname.Equal["Craft"]}
						{
							if ${CraftItem}
							{
								ItemName:Set["${BuyIterator.Key}"]
								if ${UIElement[CraftFilter@Craft@GUITabs@MyPrices].Text.Length} == 0 || ${ItemName.Find[${UIElement[CraftFilter@Craft@GUITabs@MyPrices].Text}]} != NULL
									UIElement[ItemList@Craft@GUITabs@MyPrices]:AddItem["${BuyIterator.Key}"]
							}
						}
						elseif ${action.Equal["scan"]} && ${tabname.Equal["Craft"]}
						{
							UIElement[Errortext@Sell@GUITabs@MyPrices]:SetText[" **Writing List**"]
							; if the item is marked as a craft one then check if the Minimum broker total has been reached
							if ${CraftItem}
							{
								; check for number of items not in NoSale Container
								call numinventoryitems "${BuyIterator.Key}" TRUE FALSE
								call addtotals "${BuyIterator.Key}" ${Return}

								call checktotals "${BuyIterator.Key}" ${CraftStack} ${CraftMinTotal} "${Recipe}"
							}
								
						}
						elseif ${action.Equal["compact"]} && ${tabname.Equal["Sell"]}
						{
							if !${CraftItem} && !${MinSalePrice} && !${MaxSalePrice}
							{
								; check broker boxes for item being read, if not on broker then clear that entry.
								i:Set[1]
								do
								{
									if ${BrokerWindow.VendingContainer[${i}](exists)} 
									{			
										call FindItem ${i} "${BuyIterator.Key}"
										waitframe
										j:Set[${Return}]								
										if ${j} > -1
										{
											break
										}
									}
								}
								while ${i:Inc} <= ${brokerslots}
								if ${j} < 0
									BuyList.FindSet["${BuyIterator.Key}"]:Clear
									waitframe
							}
						}
					}
				}
			}
			; Keep looping till you've read all the Items listed under the ${tabname} Sub-Set
			while ${NameIterator:Next(exists)}
		}
		; Keep looping till you've read all the items in the Top level sets
		While ${BuyIterator:Next(exists)}
	}

	UIElement[Errortext@Sell@GUITabs@MyPrices]:SetText[" ** Finished **"]

	if ${action.Equal["compact"]}
		UIElement[Errortext@Admin@GUITabs@MyPrices]:SetText[" ** Finished **"]
	elseif ${action.Equal["scan"]} && ${tabname.Equal["Craft"]}
		{
			if ${UseOgreCraft}
			{
				LavishSettings[newcraft]:Export[${OgreNewCraftPath}${Me.TSSubClass}-_myprices.xml]
			}
			else
			{
				LavishSettings[newcraft]:Export[${NewCraftPath}${Me.TSSubClass}-_myprices.xml]
			}
		}

	if ${action.Equal["place"]}
		CraftItemsPlaced:Set[TRUE]

	call echolog "<end> : buy"
}


; check to see if we need to make more craftable items to refil our broker stocks
function checktotals(string ItemName, int stacksize, int minlimit, string Recipe)
{
	call echolog "-> checktotals ${ItemName} ${stacksize} ${minlimit} ${Recipe}"
	; totals set (unsaved)
	LavishSettings:AddSet[craft]
	LavishSettings[craft]:AddSet[CraftItem]

	Declare Totals int 0 local
	Declare Makemore int 0 local

	CraftList:Set[${LavishSettings[craft].FindSet[CraftItem]}]

	if ${CraftList.FindSetting["${ItemName}"](exists)}
		Totals:Set[${CraftList.FindSetting["${ItemName}"]}]
	else
		Totals:Set[0]
	
	if ${Totals} < ${minlimit}
		Makemore:Set[${Math.Calc[(${minlimit}-${Totals})/${stacksize}]}]

	if ${Makemore}>0
		{
			call AddLog "you need to make ${Makemore} more stacks of ${ItemName}" FFCCFFCC

			; if an alternative recipe name is there then use that otherwise use the item name
			if ${Recipe.Equal[NULL]} || ${Recipe.Length} == 0
				LavishSettings[newcraft]:AddSetting["${ItemName}",${Makemore}]
			else
				LavishSettings[newcraft]:AddSetting["${Recipe}",${Makemore}]
		}
	call echolog "<end> : checktotals "
}


function BuyItems()
{

	call echolog "-> BuyItems ${ItemName} ${Money} ${Number} ${Flagged} ${NameOnly} ${Attunable} ${AutoTransmute} ${Collectible} ${StartLevel} ${EndLevel} ${Tier}"

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
	Declare CurrentQuantity int local
	Declare InventoryNumber int local
	Declare StackBuySize int local

	Declare namesearch string local
	Declare startsearch string local
	Declare endsearch string local
	Declare tiersearch string local
	Declare costsearch string local
	Declare loopcount int local
	Event[EQ2_ExamineItemWindowAppeared]:AttachAtom[EQ2_ExamineItemWindowAppeared]

	Call CheckFocus
	if ${NameOnly}
	{
		call echolog "searchbrokerlist "${ItemName}" 0 0 0 ${Math.Calc[${Money} * 100]}"
		call searchbrokerlist "${ItemName}" 0 0 0 ${Math.Calc[${Money} * 100]} FALSE ${Collectible}
	}
	else
	{
		call echolog "<BuyItems> call searchbrokerlist "${ItemName}" ${StartLevel} ${EndLevel} ${Tier} ${Math.Calc[${Money} * 100]} ${Attunable}"
		call searchbrokerlist "${ItemName}" ${StartLevel} ${EndLevel} ${Tier} ${Math.Calc[${Money} * 100]} ${Attunable} ${Collectible}
	}

	Call echolog "<BuyItems> Call BrokerSearch ${ItemName}"

	; scan to make sure the item is listed and get lowest price
	Call BrokerSearch "${ItemName}" ${NameOnly}
	
	; if items listed on the broker
	if ${Return} != -1
	{

		; Scan the broker list one by one buying the items until the end of the list is reached or all the Number wanted have been bought
		do
		{
			Call CheckFocus
			if ${InventorySlotsFree}<=0
			{
				UIElement[ErrorText@Buy@GUITabs@MyPrices]:SetText[Out of Inventory Space !]
				Break
			}
			
			BrokerWindow:GotoSearchPage[${CurrentPage}]
			wait 5
			do
			{
				; calculate how much coin this character has on it
				MyCash:Set[${Math.Calc[(${Me.Platinum}*10000)+(${Me.Gold}*100)+(${Me.Silver})+(${Me.Copper}/100)]}]
				; How many items for sale on the current broker entry
				BrokerNumber:Set[${BrokerWindow.SearchResult[${CurrentItem}].Quantity}]
				; How much each single item costs
				BrokerPrice:Set[${BrokerWindow.SearchResult[${CurrentItem}].Price}]

				; if it's more than I want to pay then stop
				if ${BrokerPrice} > ${Money} || ${BrokerPrice} > ${MaxMoney}
				{
					StopSearch:Set[TRUE]
					break
				}
				
				; if there are items available (sometimes broker number shows 0 available when someone beats you to it)
				if ${BrokerNumber} >0
				{
					Call CheckFocus
					do
					{
						BrokerNumber:Set[${BrokerWindow.SearchResult[${CurrentItem}].Quantity}]

						if ${BrokerNumber} == 0
							break

						; if the broker entry being looked at shows more items than we want then buy what we want
						
						if ${Collectible}
						{
							TryBuy:Set[1]
						}
						else
						{
							if ${BrokerNumber} > ${Number}
								TryBuy:Set[${Number}]
							else
								TryBuy:Set[${BrokerNumber}]
						}
						; check you can afford to buy the items
						
						call checkcash ${BrokerPrice} ${MaxMoney} ${TryBuy} ${Flagged}
						
						; buy what you can afford
						if ${Return} > 0
						{
							StackBuySize:Set[${Return}]
							OldCash:Set[${MyCash}]

							Call CheckFocus

							; make sure you don't already have an item and it's lore
							call checklore "${MerchantWindow.MerchantInventory[${CurrentItem}].Name}"

							; if the item is lore or collectible and you already have it then stop and move on
							if ${Return}
							{
								Echo ${MerchantWindow.MerchantInventory[${CurrentItem}].Name} is LORE/collectible and you already have one
								Break
							}
							
							if ${Collectible} 
							{
								call Rejected "${MerchantWindow.MerchantInventory[${CurrentItem}].Name}"
								
								if !${Return}
								{
									Call CheckFocus
									MerchantWindow.MerchantInventory[${CurrentItem}]:Examine

									; Wait till the examine window is open
									do
									{
										waitframe
									}
									while !${ExamineOpen}
									
									wait 5
									
									ExamineOpen:Set[FALSE]
									
									if ${NewCollection}
									{
										Call CheckFocus

										call numinventoryitems "${MerchantWindow.MerchantInventory[${CurrentItem}].Name}" TRUE
										CurrentQuantity:Set[${Return}]
										
										BrokerWindow.SearchResult[${CurrentItem}]:Buy[${StackBuySize}]
										NewCollection:Set[FALSE]

										; make the script wait till the inventory total has changed (item was added)
										; skips to the next item if nothing changes within 10 seconds
					
										loopcount:Set[1]
										do
										{
											call numinventoryitems "${MerchantWindow.MerchantInventory[${CurrentItem}].Name}" TRUE
											
											if ${Return} != ${CurrentQuantity}
											Break

											wait 10
											
											if ${HighLatency}
												wait 20

										}
										while ${loopcount:Inc} <= 10
									}
									else
									{
										break
									}
								}
								else
								{
									break
								}
							}
							else
							{
								Call CheckFocus

								call numinventoryitems "${MerchantWindow.MerchantInventory[${CurrentItem}].Name}" TRUE
								CurrentQuantity:Set[${Return}]
								
								BrokerWindow.SearchResult[${CurrentItem}]:Buy[${StackBuySize}]


								; make the script wait till the inventory total has changed (item was added)
								; skips to the next item if nothing changes within 10 seconds
					
								loopcount:Set[1]
								do
								{
									call numinventoryitems "${MerchantWindow.MerchantInventory[${CurrentItem}].Name}" TRUE
									
									if ${Return} != ${CurrentQuantity}
										Break

									wait 10
											
									if ${HighLatency}
										wait 20

								}
								while ${loopcount:Inc} <= 10

							}
							if ${AutoTransmute}
								Call GoTransmute "${MerchantWindow.MerchantInventory[${CurrentItem}].Name}"
							
							if ${InventorySlotsFree}<=0
							{
								Echo Out of Inventory Space!
								Break
								StopSearch:Set[TRUE]
							}

							; if unable to buy the required stack due to stack limitations then change to buying singles
							
							if ${MerchantWindow.MerchantInventory[${CurrentItem}].Quantity} == ${BrokerNumber} && ${MerchantWindow.MerchantInventory[${CurrentItem}].Quantity} != 0 && !${Collectible}
							{
								; make sure you don't already have an item and it's lore
								call checklore "${MerchantWindow.MerchantInventory[${CurrentItem}].Name}"
								
								; if the item is lore and you already have it then stop and move on
								if ${Return}
								{
									Echo ${MerchantWindow.MerchantInventory[${CurrentItem}].Name} is LORE and you already have one
									Break
								}

								; Number on broker not changed ( Buy Singles )
								do
								{
									Call CheckFocus

									call numinventoryitems "${MerchantWindow.MerchantInventory[${CurrentItem}].Name}" TRUE
									CurrentQuantity:Set[${Return}]

									BrokerWindow.SearchResult[${CurrentItem}]:Buy[1]


									; make the script wait till the inventory total has changed (item was added)
									; skips to the next item if nothing changes within 10 seconds
					
									loopcount:Set[1]
									do
									{
										call numinventoryitems "${MerchantWindow.MerchantInventory[${CurrentItem}].Name}" TRUE
											
										if ${Return} != ${CurrentQuantity}
											Break

										wait 10
											
										if ${HighLatency}
											wait 20

									}
									while ${loopcount:Inc} <= 10
									
									if ${AutoTransmute}
										Call GoTransmute "${MerchantWindow.MerchantInventory[${CurrentItem}].Name}"
									
									if !${QueuedCommands}
										WaitFrame
									else
										ExecuteQueued

									if ${InventorySlotsFree}<=0
									{
										Echo Out of Inventory Space!
										Break
										StopSearch:Set[TRUE]
									}

									if ${Exitmyprices} || ${Pausemyprices}
										break
								}
								while ${StackBuySize:Dec} >= 0 && ${MerchantWindow.MerchantInventory[${CurrentItem}].Quantity} != 0
			
							}
							
							MyCash:Set[${Math.Calc[(${Me.Platinum}*10000)+(${Me.Gold}*100)+(${Me.Silver})+(${Me.Copper}/100)]}]
							; check you have actually bought an item
							call checkbought ${BrokerPrice} ${OldCash} ${MyCash}
							BoughtNumber:Set[${Return}]
							
							; reduce the max coinage you will pay by the cost of the number items you have bought.
							MaxMoney:Dec[${Math.Calc[${BoughtNumber}*${BrokerPrice}]}]
							
							; reduce the number left to buy
							Number:Set[${Math.Calc[${Number}-${BoughtNumber}]}]
							call StringFromPrice ${BrokerPrice}
							call AddLog "Bought (${BoughtNumber}) ${BuyName} at ${Return}" FF00FF00
						}
						else
						{
							; if you can't afford any then stop scanning
							StopSearch:Set[TRUE]
							break
						}
						
						if !${QueuedCommands}
							WaitFrame
						else
							ExecuteQueued
							WaitFrame

						if ${Exitmyprices} || ${Pausemyprices}
							break

					}
					While ${BrokerNumber} > 0 && ${Number} > 0
				}
				if ${StopSearch}
				{
					break
				}

				if !${QueuedCommands}
					WaitFrame
				else
					ExecuteQueued
					WaitFrame

				if ${Exitmyprices} || ${Pausemyprices}
					break
			}
			while ${CurrentItem:Inc}<=${BrokerWindow.NumSearchResults} && ${Number} > 0 && !${Exitmyprices} && !${Pausemyprices} && !${StopSearch}
			CurrentItem:Set[1]
			
			if !${QueuedCommands}
				WaitFrame
			else
				ExecuteQueued
				WaitFrame

			if ${Exitmyprices} || ${Pausemyprices}
				break

			if ${HighLatency}
				wait 30

		}
		; keep going till all items listed have been scanned and bought or you have reached your limit
		while ${CurrentPage:Inc}<=${BrokerWindow.TotalSearchPages} && ${Number} > 0 && !${Exitmyprices} && !${Pausemyprices} && !${StopSearch}

		; now we've bought all that are available , save the number we've still got left to buy
		Call Saveitem BuyUpdate
	}
	call echolog "<end> : BuyItems"
}

; function to check you actually bought an item (stops false positives if someone beats you to it or someone removes an item before you can buy it)

function:int checkbought(float BrokerPrice, float OldCash, float NewCash)
{
	call echolog "-> checkbought Broker Price : ${BrokerPrice} My Old Cash : ${OldCash} My Current cash : ${NewCash}"
	
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
			DiffInt:Inc

		call echolog "<- checkbought ${DiffInt}"
		return ${DiffInt}
	}
	else
	{
		call echolog "<- checkbought 1"
		Return 1
	}

}

; check to see if you have enough coin on your character or if you have enough limit (Max Money you are willing to spend) left 
; to buy the number you want to,
; 
; if not then calculate how many you CAN buy with the coin/limit you have.

function:int checkcash(float Money, float MaxMoney, int Number, bool Harvest)
{
	call echolog  "-> checkcash: BuyPrice : ${Money} MaxMoney : ${MaxMoney}  Buy Number : ${Number} Harvest : ${Harvest}"

	Declare NewNumber int 0 local
	Declare MyCash float local
	Declare MaxNumber int 100 local

	; calculate how much coin this character has on it
	MyCash:Set[${Math.Calc[(${Me.Platinum}*10000)+(${Me.Gold}*100)+(${Me.Silver})+(${Me.Copper}/100)]}]

	; if set limit based on harvest or non-harvest

	if ${Harvest}
		MaxNumber:Set[200]
	else
		MaxNumber:Set[100]

	if ${Number} > ${MaxNumber}
		Number:Set[${MaxNumber}]

	if ${Math.Calc[(${Money}*${Number})]} > ${MaxMoney}
	{
		NewNumber:Set[${Math.Calc[${MaxMoney}/${Money}]}]
		call echolog "<- checkcash ${NewNumber}"
		return ${NewNumber}
	}

	if ${Math.Calc[(${Money}*${Number})]} > ${MyCash}
	{
		NewNumber:Set[${Math.Calc[${MyCash}/${Money}]}]
		call echolog "<- checkcash ${NewNumber}"
		return ${NewNumber}
	}
	else
	{
		call echolog "<- checkcash ${Number}"
		return ${Number}
	}
}

; Scan the broker when an item is clicked on in the BUY item list.

function ClickBrokerSearch(string tabtype, int ItemID)
{
	call echolog "-> ClickBrokerSearch ${tabtype} ${ItemID}"

	Declare cost int local
	Declare pp int local
	Declare gp int local
	Declare sp int local
	Declare cp int local
	
	; scan the broker for the item clicked on in the list
	ItemName:Set["${UIElement[MyPrices].FindChild[GUITabs].FindChild[${tabtype}].FindChild[ItemList].Item[${ItemID}]}"]

	If ${tabtype.Equal["Buy"]}
	{
		StartLevel:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[StartLevel].Text}]
		EndLevel:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[EndLevel].Text}]
		Tier:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[Tier].Selection}]
		pp:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MinPlatPrice].Text}]
		gp:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MinGoldPrice].Text}]
		sp:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MinSilverPrice].Text}]
		cp:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MinCopperPrice].Text}]
		cost:Set[${Math.Calc[(${pp}*1000000)+(${gp}*10000)+(${sp}*100)+${cp}]}]

		if ${UIElement[BuyNameOnly@Buy@GUITabs@MyPrices].Checked}
			call searchbrokerlist "${ItemName}" 0 0 0  ${cost}
		else
			call searchbrokerlist "${ItemName}" ${StartLevel} ${EndLevel} ${Tier} ${cost} ${UIElement[BuyAttuneOnly@Buy@GUITabs@MyPrices].Checked} ${UIElement[Collectible@Buy@GUITabs@MyPrices].Checked}
	}
	else
	{
		broker Name "${ItemName}" Sort ByPriceAsc MaxLevel 999

		if ${HighLatency}
			wait 30

	}
	call echolog "<end> : ClickBrokerSearch"

}


function searchbrokerlist(string ItemName, int StartLevel, int EndLevel, int Tier, float cost, bool BuyAttuneOnly, bool Collectible)
{

	call echolog "-> searchbrokerlist ${ItemName} , ${StartLevel} , ${EndLevel} , ${Tier} , ${cost} ${BuyAttuneOnly}"

	Declare namesearch string local
	Declare startsearch string local
	Declare endsearch string local
	Declare tiersearch string local
	Declare costsearch string local
	Declare typesearch string local

	if !${ItemName.Left[6].Equal[NoName]}
		namesearch:Set[Name "${ItemName}"]
		
	if ${Collectible}
		typesearch:Set["-Type Collectable"]
	else
	{

		if ${BuyAttuneOnly}
			typesearch:Set["-Type Attuneable"]

		if ${StartLevel}>0 
			startsearch:Set["MinLevel ${StartLevel}"]

		if ${EndLevel}>0
			endsearch:Set["MaxLevel ${EndLevel}"]

		if ${Tier}>0
		{
			Switch "${Tier}"
			{
				Case 1
					tiersearch:Set["MinTier Common MaxTier Mythical"]
					break
				Case 2
					tiersearch:Set["MinTier Common MaxTier Common"]
					break
				Case 3
					tiersearch:Set["MinTier Handcrafted MaxTier Handcrafted"]
					break
				Case 4
					tiersearch:Set["MinTier Treasured MaxTier Treasured"]
					break
				Case 5
					tiersearch:Set["MinTier Mastercrafted MaxTier Mastercrafted"]
					break
				Case 6
					tiersearch:Set["MinTier Legendary MaxTier Legendary"]
					break
				Case 7
					tiersearch:Set["MinTier Fabled MaxTier Fabled"]
					break
				Case 8
					tiersearch:Set["MinTier Mythical MaxTier Mythical"]
					break
			}
		}
	}

	costsearch:Set["MaxPrice ${cost}"]

	if ${namesearch.Length}>0
	{
		broker ${namesearch} ${startsearch} ${endsearch} ${tiersearch} ${costsearch} ${typesearch} Sort ByPriceAsc

		if ${HighLatency}
			wait 30

	}
	else
	{
		broker ${startsearch} ${endsearch} ${tiersearch} ${costsearch} ${typesearch} Sort ByPriceAsc

		if ${HighLatency}
			wait 30
			
	}
	
	call echolog "<- searchbrokerlist"
}	

; Search the broker for items , return the cheapest price found

function:float BrokerSearch(string ItemName, bool NameOnly)
{
	call echolog "-> BrokerSearch ${ItemName} ${NameOnly}"

	Declare CurrentPage int 1 local
	Declare CurrentItem int 1 local
	Declare TempMinPrice float -1 local
	Declare stopsearch bool FALSE local
	wait 5
	; check if broker has any listed to compare with your item
	if !${NameOnly}
	{
		if ${BrokerWindow.NumSearchResults} >0
			Return TRUE
		else
			Return FALSE
	}
	
	if ${BrokerWindow.NumSearchResults} >0
	{
		; Work through the brokers list page by page
		do
		{
			BrokerWindow:GotoSearchPage[${CurrentPage}]
			
			do
			{
				waitframe
			}
			while ${BrokerWindow.CurrentSearchPage} != ${CurrentPage}
			
			CurrentItem:Set[1]
			do
			{
				; check that the items name being looked at is an exact match and not just a partial match
				if ${ItemName.Equal["${BrokerWindow.SearchResult[${CurrentItem}]}"]}
				{
					; if checkbox set to ignore broker fee when matching prices
					if ${MatchActual}
					{
						TempMinPrice:Set[${BrokerWindow.SearchResult[${CurrentItem}].BasePrice}]
					}
					else
					{
						TempMinPrice:Set[${BrokerWindow.SearchResult[${CurrentItem}].Price}]
					}
					waitframe
					stopsearch:Set[TRUE]
					break
				}
				waitframe
			}
			while ${CurrentItem:Inc}<=${BrokerWindow.NumSearchResults} && !${stopsearch}
		}
		while ${CurrentPage:Inc}<=${BrokerWindow.TotalSearchPages} && ${TempMinPrice} == -1 && !${stopsearch}
	}
	; Return the Lowest Price Found or -1 if nothing found.
	call echolog "<- BrokerSearch ${TempMinPrice}"
	return ${TempMinPrice}
}


function checkitem(string checktype, string ItemName)
{
	call echolog "-> checkitem : ${checktype} ${name}"
	
	; keep a reference directly to the Item set.
	ItemList:Set[${LavishSettings[myprices].FindSet[Item]}]
	Item:Set[${ItemList.FindSet["${ItemName}"]}]

	if ${Item.FindSetting[${checktype}](exists)}
	{
		call echolog "<- checkitem : ${Item.FindSetting[${checktype}]}"
		return ${Item.FindSetting[${checktype}]}
	}
	else
	{
		call echolog "<- checkitem : -1"
		return -1
	}
}


function LoadList()
{
	call echolog "<start> : Loadlist"

	Declare Min float local
	Declare Max float local
	
	; clear all totals held in the craft set
	LavishSettings[craft]:Clear
	waitframe
	
	wait 5
	
	; keep a reference directly to the Item set.
	ItemList:Set[${LavishSettings[myprices].FindSet[Item]}]

	UIElement[ItemList@Sell@GUITabs@MyPrices]:ClearItems

	i:Set[1]
	j:Set[1]
	
	; open boxes to refresh broker list data
	do
	{
		if ${BrokerWindow.VendingContainer[${i}](exists)}
		{
			ItemName:Set[${BrokerWindow.VendingContainer[${i}].Consignment[1]}]
			waitframe
		}
	}
	while ${i:Inc} <= ${brokerslots}

	i:Set[1]
	
	; scan boxes and add items into the list	
	numitems:Set[0]
	Profit:Set[0]
	Cost:Set[0]
	do
	{
		
		if (${BrokerWindow.VendingContainer[${i}](exists)})  && ${box[${i}]}
		{
			if ${BrokerWindow.VendingContainer[${i}].CurrentCoin} > 0 && ${TakeCoin}
			{
				BrokerWindow.VendingContainer[${i}]:TakeCoin
				wait 10
			}
			ItemName:Set[${BrokerWindow.VendingContainer[${i}].Consignment[1]}]
			wait 5
			if ${BrokerWindow.VendingContainer[${i}].NumItems}>0
			{
				do
				{
					call CheckFocus
					numitems:Inc
					ItemName:Set["${BrokerWindow.VendingContainer[${i}].Consignment[${j}]}"]
					waitframe
					
					; add the item name onto the sell tab list
					UIElement[ItemList@Sell@GUITabs@MyPrices]:AddItem["${ItemName}"]
					
					Cost:Inc[${Math.Calc[${BrokerWindow.VendingContainer[${i}].Consignment[${j}].Value} * ${BrokerWindow.VendingContainer[${i}].Consignment[${j}].Quantity}]}]
					Profit:Inc[${Math.Calc[${BrokerWindow.VendingContainer[${i}].Consignment[${j}].BasePrice} * ${BrokerWindow.VendingContainer[${i}].Consignment[${j}].Quantity}]}]

					; if the item is flagged as a craft item then add the total number on the broker
					if ${ItemList.FindSet["${ItemName}"].FindSetting[CraftItem]}
						call SetColour Sell ${numitems} FFFFFF00

					; keep a total of how many items there are
					call addtotals "${ItemName}" ${BrokerWindow.VendingContainer[${i}].Consignment[${j}].Quantity}
					
					; store the items box number
					itemprice:Set[${numitems},${i}]
					; check to see if it already has a minimum price set
					call checkitem Sell "${ItemName}"
					; If no value is returned then add the price to the settings file
					if ${Return} == -1
					{
						call SetColour Sell ${numitems} FF0000FF
						call AddLog "Item Missing from Settings File,  Adding : ${ItemName}" FF00CCFF
						
						Money:Set[${BrokerWindow.VendingContainer[${i}].Consignment[${j}].BasePrice}]

						if ${BoxMaxDefault[${i}]} > 0
							Money:Set[${BoxMaxDefault[${i}]}]

						; Add the item into the data file with default settings
						call Saveitem Add
					}
					
					; Item sold before but currently unlisted
					if !${BrokerWindow.VendingContainer[${i}].Consignment[${j}].IsListed}
						call SetColour Sell ${numitems} FF990099

				}
				while ${j:Inc} <= ${BrokerWindow.VendingContainer[${i}].NumItems}
				waitframe
			}
			j:Set[1]
		}
	}
	while ${i:Inc} <= ${brokerslots}

	ProfitChange:Set[${Math.Calc[${Profit}-${Cost}]}]
	Call StringFromPrice ${ProfitChange}
	call AddLog "Potential Profit on Broker Items is ${Return}"

	call echolog "<end> : Loadlist"
}

; Convert a float price in silver to pp gp sp cp format
function:string StringFromPrice(float Money)
{
	call echolog "-> StringFromPrice ${Money}"
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
	call echolog "<- StringFromPrice ${Platina}pp ${Gold}gp ${Silver}sp ${Copper}cp"
	return ${Platina}pp ${Gold}gp ${Silver}sp ${Copper}cp
}

; Convert a price in pp gp sp cp format to float price in silver

function SaveSell()
{
	call echolog "<start> SaveSell"
	Declare Platina int local
	Declare Gold int local
	Declare Silver int local
	Declare Copper float local

	ItemName:Set["${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[ItemName].Text}"]
	if ${ItemName.Length} == 0
	{
		call AddLog "Try Selecting something first!!" FFFF0000
	}
	else
	{
		; Read the values held in the GUI boxes
		Platina:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[MinPlatPrice].Text}]
		Gold:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[MinGoldPrice].Text}]
		Silver:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[MinSilverPrice].Text}]
		Copper:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[MinCopperPrice].Text}]

		; calclulate the value in silver
		call calcsilver ${Platina} ${Gold} ${Silver} ${Copper}
		Money:Set[${Return}]
		
		; Read the values held in the GUI boxes
		Platina:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[MaxPlatPrice].Text}]
		Gold:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[MaxGoldPrice].Text}]
		Silver:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[MaxSilverPrice].Text}]
		Copper:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[MaxCopperPrice].Text}]

		; calclulate the value in silver
		call calcsilver ${Platina} ${Gold} ${Silver} ${Copper}
		MaxMoney:Set[${Return}]

		LowerItemNumber:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[LowerItemNumber].Text}]

		; Save the new value in your settings file
		call Saveitem Sell

		; Read the values held in the GUI boxes
		Platina:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[PlatPrice].Text}]
		Gold:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[GoldPrice].Text}]
		Silver:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[SilverPrice].Text}]
		Copper:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[CopperPrice].Text}]

		; calclulate the value in silver
		call calcsilver ${Platina} ${Gold} ${Silver} ${Copper}
		MaxMoney:Set[${Return}]
		
		; Find where the Item is stored in the container
		
		call FindItem ${itemprice.Element[${ClickID}]} "${ItemName}"
		
		j:Set[${Return}]

		; set the current price
		if ${j} > -1
		{
			call SetItemPrice ${itemprice.Element[${ClickID}]} ${j} ${MaxMoney}
			call ClickBrokerSearch Sell ${ClickID}
		}
	}
	call echolog "<end> : pricefromstring"
}

function calcsilver(int plat, int gold, int silver, float copper)
{
	Return ${Math.Calc[${Math.Calc[${plat}*10000]}+${Math.Calc[${gold}*100]}+${silver}+${Math.Calc[${copper}/100]}]}
}

; routine to save/update items and prices

function Saveitem(string Saveset)
{
	Declare xvar int local
	call echolog "-> Saveitem ${Saveset} ${ItemName} ${Money} ${Number} ${Flagged} ${NameOnly} ${Attuneable} ${AutoTransmute} ${StartLevel} ${EndLevel} ${Tier} ${Recipe} ${Box1} ${Box2} ${Box3} ${Box4} ${Box5} ${Box6} ${Box7} ${Box8}"

	if ${Saveset.Equal["Buy"]} || ${Saveset.Equal["BuyUpdate"]}
		ItemList:Set[${LavishSettings[myprices].FindSet[Buy]}]
	else
		ItemList:Set[${LavishSettings[myprices].FindSet[Item]}]


	ItemList:AddSet["${ItemName}"]

	Item:Set[${ItemList.FindSet["${ItemName}"]}]
	
	if ${Saveset.Equal["Prices"]}
	{
		Item:AddSetting[Sell,${Money}]
		Item:AddSetting[MaxPrice,${MaxMoney}]
	}
	elseif ${Saveset.Equal["Sell"]}
	{
		Item:AddSetting[Sell,${Money}]
		if ${UIElement[MinPrice@Sell@GUITabs@MyPrices].Checked}
			Item:AddSetting[MinSalePrice,TRUE]
		else
			Item:AddSetting[MinSalePrice,FALSE]


		if ${UIElement[MaxPrice@Sell@GUITabs@MyPrices].Checked}
		{
			Item:AddSetting[MaxSalePrice,TRUE]
			Item:AddSetting[MaxPrice,${MaxMoney}]
		}
		else
		{
			Item:AddSetting[MaxSalePrice,FALSE]
		}

		if ${UIElement[CraftItem@Sell@GUITabs@MyPrices].Checked}
			Item:AddSetting[CraftItem,TRUE]
		else
			Item:AddSetting[CraftItem,FALSE]
		
		if ${UIElement[LowerNumber@Sell@GUITabs@MyPrices].Checked}
		{
			Item:AddSetting[LowerNumber,TRUE]
			Item:AddSetting[LowerItemNumber,${LowerItemNumber}]
		}
		else
		{
			Item:AddSetting[LowerNumber,FALSE]
		}
	}
	elseif ${Saveset.Equal["Add"]}
	{
		Item:AddSetting[Sell,${Money}]
		Item:AddSetting[MinSalePrice,FALSE]
		Item:AddSetting[MaxSalePrice,FALSE]
		Item:AddSetting[CraftItem,FALSE]
		Item:AddSetting[LowerNumber,FALSE]
	}
	elseif ${Saveset.Equal["Craft"]} || ${Saveset.Equal["Inventory"]}
	{
		
		Item:AddSetting[Stack,${Money}]
		Item:AddSetting[Stock,${Number}]

		if ${Recipe.Length} == 0
		{
			Item:AddSetting[Recipe,"${ItemName}"]
		}
		else
		{
			Item:AddSetting[Recipe,"${Recipe}"]
		}
		
		if ${Saveset.Equal["Inventory"]}
		{
			Item:AddSetting[CraftItem,${UIElement[CraftItem@Inventory@GUITabs@MyPrices].Checked}]
		}
		else
		{
			Item:AddSetting[CraftItem,TRUE]
		}
		
		xvar:Set[1]
		do
		{
			Item:AddSetting[Box${xvar},${UIElement[${xvar}@${Saveset}@GUITabs@MyPrices].Selection}]
		}
		while ${xvar:Inc} <= ${brokerslots}
	}
	elseif ${Saveset.Equal["Buy"]}
	{
		; Clear all previous information
		ItemList["${ItemName}"]:Clear

		Item:AddSetting[BuyNumber,${Number}]
		Item:AddSetting[BuyPrice,${Money}]
		Item:AddSetting[MaxSpend,${MaxMoney}]

		if ${UIElement[Harvest@Buy@GUITabs@MyPrices].Checked}
			Item:AddSetting[Harvest,TRUE]
		else
			Item:AddSetting[Harvest,FALSE]

		if ${UIElement[BuyNameOnly@Buy@GUITabs@MyPrices].Checked}
			Item:AddSetting[Buynameonly,TRUE]
		else
		{
			Item:AddSetting[BuyNameOnly,FALSE]
			Item:AddSetting[StartLevel,${StartLevel}]
			Item:AddSetting[EndLevel,${EndLevel}]
			Item:AddSetting[Tier,${Tier}]
		}

		if ${UIElement[BuyAttuneOnly@Buy@GUITabs@MyPrices].Checked}
			Item:AddSetting[BuyAttuneOnly,TRUE]
		else
			Item:AddSetting[BuyAttuneOnly,FALSE]

		if ${UIElement[Transmute@Buy@GUITabs@MyPrices].Checked}
			Item:AddSetting[AutoTransmute,TRUE]
		else
			Item:AddSetting[AutoTransmute,FALSE]

		if ${UIElement[Collectible@Buy@GUITabs@MyPrices].Checked}
			Item:AddSetting[Collectible,TRUE]

	}
	elseif ${Saveset.Equal["BuyUpdate"]}
	{
		Item:AddSetting[BuyNumber,${Number}]
		Item:AddSetting[MaxSpend,${MaxMoney}]
		
	}

	LavishSettings[myprices]:Export[${EQ2.ServerName}_${XMLPath}${Me.Name}_MyPrices.XML]
	call echolog "<end> : Saveitem"
}

; routine to update the myprices settings

function SaveSetting(string Settingname, string Value)
{
	call echolog "-> SaveSetting ${Settingname} ${Value}"
	General:Set[${LavishSettings[myprices].FindSet[General]}]
	General:AddSetting[${Settingname},${Value}]
	LavishSettings[myprices]:Export[${XMLPath}${EQ2.ServerName}_${CurrentChar}_MyPrices.XML]
	call echolog "<end> : SaveSetting"
}

; changes the color of the items in the listbox

function SetColour(string UITab, int position, string colour)
{
	UIElement[MyPrices].FindChild[GUITabs].FindChild[${UITab}].FindChild[ItemList].Item[${position}]:SetTextColor[${colour}]
	return
}

; update the boxes in the Sell tab with the right values

function FillMinPrice(int ItemID)
{
	call echolog "-> FillMinPrice ${ItemID}"
	Declare Platina int local
	Declare Gold int local
	Declare Silver int local
	Declare Copper int local
	Declare j int local
	Declare CraftItem bool local

	; Put the values in the right boxes.

	; Display the current price
	
	ItemName:Set["${UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[ItemList].Item[${ItemID}]}"]
	
	call FindItem ${itemprice.Element[${ItemID}]} "${ItemName}"

	j:Set[${Return}]

	if ${j} != -1
	{
		ItemName:Set["${BrokerWindow.VendingContainer[${itemprice.Element[${ItemID}]}].Consignment[${j}].Name}"]

		UIElement[ItemName@Sell@GUITabs@MyPrices]:SetText["${ItemName}"]

		; Display your current Price for that Item

		Money:Set[${BrokerWindow.VendingContainer[${itemprice.Element[${ItemID}]}].Consignment[${j}].BasePrice}]

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

		ItemList:Set[${LavishSettings[myprices].FindSet[Item]}]
		ItemList:AddSet["${ItemName}"]

		Item:Set[${ItemList.FindSet["${ItemName}"]}]
		Money:Set[${Item.FindSetting[Sell]}]

		CraftItem:Set[${Item.FindSetting[CraftItem]}]

		if ${CraftItem}
			UIElement[CraftItem@Sell@GUITabs@MyPrices]:SetChecked
		else
			UIElement[CraftItem@Sell@GUITabs@MyPrices]:UnsetChecked

		if !${Item.FindSetting[LowerNumber]}
		{
			UIElement[LowerItemNumber@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[LowerNumber@Sell@GUITabs@MyPrices]:UnsetChecked
		}
		else
		{
			UIElement[LowerItemNumber@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[LowerItemNumber@Sell@GUITabs@MyPrices]:SetText[${Item.FindSetting[LowerItemNumber]}]
			UIElement[LowerNumber@Sell@GUITabs@MyPrices]:SetChecked
		}

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

		Money:Set[${Item.FindSetting[MaxPrice]}]
		
		if !${Item.FindSetting[MaxSalePrice]}
		{
			UIElement[MaxPlatPrice@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MaxPlatPrice@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MaxGoldPrice@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MaxSilverPrice@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MaxCopperPrice@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MaxPlatPriceText@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MaxGoldPriceText@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MaxSilverPriceText@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MaxCopperPriceText@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[label3@Sell@GUITabs@MyPrices]:SetAlpha[0.1]
			UIElement[MaxPrice@Sell@GUITabs@MyPrices]:UnsetChecked
		}
		else
		{
			UIElement[MaxPlatPrice@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MaxPlatPrice@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MaxGoldPrice@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MaxSilverPrice@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MaxCopperPrice@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MaxPlatPriceText@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MaxGoldPriceText@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MaxSilverPriceText@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MaxCopperPriceText@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[label3@Sell@GUITabs@MyPrices]:SetAlpha[1]
			UIElement[MaxPrice@Sell@GUITabs@MyPrices]:SetChecked
		}

		Platina:Set[${Math.Calc[${Money}/10000]}]
		Money:Set[${Math.Calc[${Money}-(${Platina}*10000)]}]
		Gold:Set[${Math.Calc[${Money}/100]}]
		Money:Set[${Math.Calc[${Money}-(${Gold}*100)]}]
		Silver:Set[${Money}]
		Money:Set[${Math.Calc[${Money}-${Silver}]}]
		Copper:Set[${Math.Calc[${Money}*100]}]

		UIElement[MaxPlatPrice@Sell@GUITabs@MyPrices]:SetText[${Platina}]
		UIElement[MaxGoldPrice@Sell@GUITabs@MyPrices]:SetText[${Gold}]
		UIElement[MaxSilverPrice@Sell@GUITabs@MyPrices]:SetText[${Silver}]
		UIElement[MaxCopperPrice@Sell@GUITabs@MyPrices]:SetText[${Copper}]

		; Scan how many items there are and put in this box
		
		if ${CraftList.FindSetting["${ItemName}"](exists)}
		{
			UIElement[ItemNumber@Sell@GUITabs@MyPrices]:SetText[${CraftList.FindSetting["${ItemName}"]} Units]
		}
		else
		{
			UIElement[ItemNumber@Sell@GUITabs@MyPrices]:SetText[ ]
		}
	}

	call echolog "<end> : FillMinPrice"
}

function savebuyinfo()
{
	call echolog "<start> : savebuyinfo"
	Declare Platina int local
	Declare Gold int local
	Declare Silver int local
	Declare Copper float local

	ItemName:Set["${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[BuyName].Text}"]
	Number:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[BuyNumber].Text}]
	Platina:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MinPlatPrice].Text}]
	Gold:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MinGoldPrice].Text}]
	Silver:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MinSilverPrice].Text}]
	Copper:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MinCopperPrice].Text}]
	StartLevel:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[StartLevel].Text}]
	EndLevel:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[EndLevel].Text}]
	Tier:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[Tier].Selection}]
	
	if ${ItemName.Length} == 0 && !${UIElement[BuyNameOnly@Sell@GUITabs@MyPrices].Checked}
		ItemName:Set["NoName S: ${StartLevel} E: ${EndLevel} T : ${Tier}"]

	; calclulate the values in silver
	Platina:Set[${Math.Calc[${Platina}*10000]}]
	Gold:Set[${Math.Calc[${Gold}*100]}]
	Copper:Set[${Math.Calc[${Copper}/100]}]
	Money:Set[${Math.Calc[${Platina}+${Gold}+${Silver}+${Copper}]}]

	Platina:Set[0]
	Gold:Set[0]
	Silver:Set[0]
	Copper:Set[0]
	
	Platina:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MaxPlatPrice].Text}]
	Gold:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MaxGoldPrice].Text}]
	Silver:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MaxSilverPrice].Text}]
	Copper:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[MaxCopperPrice].Text}]

	Platina:Set[${Math.Calc[${Platina}*10000]}]
	Gold:Set[${Math.Calc[${Gold}*100]}]
	Copper:Set[${Math.Calc[${Copper}/100]}]
	MaxMoney:Set[${Math.Calc[${Platina}+${Gold}+${Silver}+${Copper}]}]
	
	if ${MaxMoney} == 0
	{
		MaxMoney:Set[${Math.Calc[${Money}*${Number}]}]
	}

	; check information was entered in all boxes and save
	if ${ItemName.Length} == 0
	{
		UIElement[ErrorText@Buy@GUITabs@MyPrices]:SetText[No item name entered]
	}
	elseif ${Number} < 0
	{
		UIElement[ErrorText@Buy@GUITabs@MyPrices]:SetText[Try setting a valid number of items]
	}
	elseif ${Money} <= 0
	{
		UIElement[ErrorText@Buy@GUITabs@MyPrices]:SetText[You haven't set a price to buy from]
	}
	else
	{
		UIElement[ErrorText@Buy@GUITabs@MyPrices]:SetText[Saved]
		call Saveitem Buy
		call buy Buy init
	}
	call echolog "<end> : savebuyinfo"
}

function savecraftinfo(string UITab)
{
	call echolog "<start> : savecraftinfo"

	ItemName:Set["${UIElement[MyPrices].FindChild[GUITabs].FindChild[${UITab}].FindChild[CraftName].Text}"]
	Recipe:Set["${UIElement[MyPrices].FindChild[GUITabs].FindChild[${UITab}].FindChild[RecipeName].Text}"]
	; Stacksize
	Money:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[${UITab}].FindChild[CraftStack].Text}]
	; Min Stock Number
	Number:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[${UITab}].FindChild[CraftNumber].Text}]

	; check information was entered in all boxes and save

	if ${ItemName.Length} == 0
	{
		UIElement[ErrorText@${UITab}@GUITabs@MyPrices]:SetText[No item selected]
	}
	elseif ${Money} <= 0
	{
		UIElement[ErrorText@${UITab}@GUITabs@MyPrices]:SetText[Try setting a valid Craft Stack size]
	}
	elseif ${Number} < 0
	{
		UIElement[ErrorText@${UITab}GUITabs@MyPrices]:SetText[Try setting a valid Stock Limit]
	}
	else
	{
		call Saveitem ${UITab}
		
		UIElement[ErrorText@${UITab}@GUITabs@MyPrices]:SetText[Saved]
	}
	call echolog "<end> : savecraftinfo"
}


function deletebuyinfo(int ItemID)
{
	call echolog "-> deletebuyinfo ${ItemID}"

	ItemName:Set["${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[Buyname].Text}"]

	; find the item Sub-Set and remove it
	BuyList:Set[${LavishSettings[myprices].FindSet[Buy]}]
	BuyList.FindSet["${ItemName}"]:Remove

	; save the new information
	LavishSettings[myprices]:Export[${XMLPath}${EQ2.ServerName}_${Me.Name}_MyPrices.XML]
	
	UIElement[ErrorText@Buy@GUITabs@MyPrices]:SetText[Deleting "${ItemName}"]

	; re-scan and display the new buy list
	call buy Buy init
	call echolog "<end> : deletebuyinfo"
}

; Delete the current item selected in the buybox
function ShowBuyPrices(int ItemID)
{
	call echolog "-> ShowBuyPrices ${ItemID}"
	Declare Platina int local
	Declare Gold int local
	Declare Silver int local
	Declare Copper int local
	
	; show all elements in tab
	UIElement[BuyNameOnly@Buy@GUITabs@MyPrices]:Show
	UIElement[Harvest@Buy@GUITabs@MyPrices]:Show
	UIElement[Transmute@Buy@GUITabs@MyPrices]:Show
	UIElement[BuyAttuneOnly@Buy@GUITabs@MyPrices]:Show
	UIElement[StartLevelText@Buy@GUITabs@MyPrices]:Show
	UIElement[EndLevelText@Buy@GUITabs@MyPrices]:Show
	UIElement[StartLevel@Buy@GUITabs@MyPrices]:Show
	UIElement[EndLevel@Buy@GUITabs@MyPrices]:Show
	UIElement[Tier@Buy@GUITabs@MyPrices]:Show

	ItemName:Set["${UIElement[MyPrices].FindChild[GUITabs].FindChild[Buy].FindChild[ItemList].Item[${ItemID}]}"]

	BuyList:Set[${LavishSettings[myprices].FindSet[Buy]}]

	BuyItem:Set[${BuyList.FindSet["${ItemName}"]}]

	Number:Set[${BuyItem.FindSetting[BuyNumber]}]
	Money:Set[${BuyItem.FindSetting[BuyPrice]}]
	MaxMoney:Set[${BuyItem.FindSetting[MaxSpend]}]
	
	If ${MaxMoney} == 0
		MaxMoney:Set[${Math.Calc[${Money}*${Number}]}]

	StartLevel:Set[${BuyItem.FindSetting[StartLevel]}]
	EndLevel:Set[${BuyItem.FindSetting[EndLevel]}]
	Tier:Set[${BuyItem.FindSetting[Tier]}]

	; Calculate and Display Max Price willing to spend for this item(s)
	Platina:Set[${Math.Calc[${Money}/10000]}]
	Money:Set[${Math.Calc[${Money}-(${Platina}*10000)]}]
	Gold:Set[${Math.Calc[${Money}/100]}]
	Money:Set[${Math.Calc[${Money}-(${Gold}*100)]}]
	Silver:Set[${Money}]
	Money:Set[${Math.Calc[${Money}-${Silver}]}]
	Copper:Set[${Math.Calc[${Money}*100]}]

	UIElement[BuyName@Buy@GUITabs@MyPrices]:SetText["${ItemName}"]
	UIElement[BuyNumber@Buy@GUITabs@MyPrices]:SetText[${Number}]
	UIElement[MinPlatPrice@Buy@GUITabs@MyPrices]:SetText[${Platina}]
	UIElement[MinGoldPrice@Buy@GUITabs@MyPrices]:SetText[${Gold}]
	UIElement[MinSilverPrice@Buy@GUITabs@MyPrices]:SetText[${Silver}]
	UIElement[MinCopperPrice@Buy@GUITabs@MyPrices]:SetText[${Copper}]

	; Calculate and Display max Spend for this item(s)
	Platina:Set[${Math.Calc[${MaxMoney}/10000]}]
	MaxMoney:Set[${Math.Calc[${MaxMoney}-(${Platina}*10000)]}]
	Gold:Set[${Math.Calc[${MaxMoney}/100]}]
	MaxMoney:Set[${Math.Calc[${MaxMoney}-(${Gold}*100)]}]
	Silver:Set[${MaxMoney}]
	MaxMoney:Set[${Math.Calc[${MaxMoney}-${Silver}]}]
	Copper:Set[${Math.Calc[${MaxMoney}*100]}]

	UIElement[MaxPlatPrice@Buy@GUITabs@MyPrices]:SetText[${Platina}]
	UIElement[MaxGoldPrice@Buy@GUITabs@MyPrices]:SetText[${Gold}]
	UIElement[MaxSilverPrice@Buy@GUITabs@MyPrices]:SetText[${Silver}]
	UIElement[MaxCopperPrice@Buy@GUITabs@MyPrices]:SetText[${Copper}]


	if ${BuyItem.FindSetting[Harvest]}
		UIElement[Harvest@Buy@GUITabs@MyPrices]:SetChecked
	else
		UIElement[Harvest@Buy@GUITabs@MyPrices]:UnsetChecked

	if ${BuyItem.FindSetting[BuyAttuneOnly]}
	{
		UIElement[BuyAttuneOnly@Buy@GUITabs@MyPrices]:SetChecked
	}
	else
	{
		UIElement[BuyAttuneOnly@Buy@GUITabs@MyPrices]:UnsetChecked
	}

	if ${BuyItem.FindSetting[AutoTransmute]}
	{
		UIElement[Transmute@Buy@GUITabs@MyPrices]:SetChecked
	}
	else
		UIElement[Transmute@Buy@GUITabs@MyPrices]:UnsetChecked

	if ${BuyItem.FindSetting[Collectible]}
	{
		UIElement[BuyNameOnly@Buy@GUITabs@MyPrices]:UnsetChecked
		UIElement[BuyAttuneOnly@Buy@GUITabs@MyPrices]:UnsetChecked
		UIElement[Transmute@Buy@GUITabs@MyPrices]:UnsetChecked
		UIElement[BuyNameOnly@Buy@GUITabs@MyPrices]:Hide
		UIElement[Harvest@Buy@GUITabs@MyPrices]:Hide
		UIElement[Transmute@Buy@GUITabs@MyPrices]:Hide
		UIElement[BuyAttuneOnly@Buy@GUITabs@MyPrices]:Hide
		UIElement[StartLevelText@Buy@GUITabs@MyPrices]:Hide
		UIElement[StartLevel@Buy@GUITabs@MyPrices]:Hide
		UIElement[EndLevelText@Buy@GUITabs@MyPrices]:Hide
		UIElement[EndLevel@Buy@GUITabs@MyPrices]:Hide
		UIElement[Tier@Buy@GUITabs@MyPrices]:Hide
	}
	else
	{
		UIElement[Collectible@Buy@GUITabs@MyPrices]:UnsetChecked
	}
	
	if ${BuyItem.FindSetting[BuyNameOnly]}
	{
		UIElement[BuyNameOnly@Buy@GUITabs@MyPrices]:SetChecked
		UIElement[StartLevelText@Buy@GUITabs@MyPrices]:Hide
		UIElement[EndLevelText@Buy@GUITabs@MyPrices]:Hide
		UIElement[StartLevel@Buy@GUITabs@MyPrices]:Hide
		UIElement[EndLevel@Buy@GUITabs@MyPrices]:Hide
		UIElement[Tier@Buy@GUITabs@MyPrices]:Hide
	}
	else
	{
		UIElement[BuyNameOnly@Buy@GUITabs@MyPrices]:UnsetChecked
		UIElement[StartLevel@Buy@GUITabs@MyPrices]:SetText[${StartLevel}]
		UIElement[EndLevel@Buy@GUITabs@MyPrices]:SetText[${EndLevel}]
		UIElement[Tier@Buy@GUITabs@MyPrices]:SetSelection[${Tier}]
	}
	
	call echolog "<end> : ShowBuyPrices"
}

; Display the details of an item marked as crafted
function ShowCraftInfo(string UITab, int ItemID)
{
	call echolog "-> ShowCraftInfo ${ItemID}"
	Declare LBoxString string local
	Declare Stack int local
	Declare Stock int local
	Declare xvar int local 1
	
	LBoxString:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[${UITab}].FindChild[ItemList].Item[${ItemID}]}]
	
	CraftList:Set[${LavishSettings[myprices].FindSet[Item]}]

	CraftItemList:Set[${CraftList.FindSet["${LBoxString}"]}]

	Recipe:Set[${CraftItemList.FindSetting[Recipe]}]
	Stack:Set[${CraftItemList.FindSetting[Stack]}]
	Stock:Set[${CraftItemList.FindSetting[Stock]}]

	UIElement[CraftName@${UITab}@GUITabs@MyPrices]:SetText[${LBoxString}]

	if !${Recipe.Equal[NULL]}
		UIElement[RecipeName@${UITab}@GUITabs@MyPrices]:SetText[${Recipe}]
	else
		UIElement[RecipeName@${UITab}@GUITabs@MyPrices]:SetText[${LBoxString}]

	UIElement[CraftStack@${UITab}@GUITabs@MyPrices]:SetText[${Stack}]
	UIElement[CraftNumber@${UITab}@GUITabs@MyPrices]:SetText[${Stock}]

	if ${UITab.Equal[Inventory]}
	{
		if ${ItemList.FindSet["${LBoxString}"].FindSetting[CraftItem]}
		{
			UIElement[CraftItem@${UITab}@GUITabs@MyPrices]:SetChecked
		}
		else
		{
			UIElement[CraftItem@${UITab}@GUITabs@MyPrices]:UnsetChecked
		}
	}
	
	xvar:Set[1]
	do
	{
		if ${ItemList.FindSet["${LBoxString}"].FindSetting[Box${xvar}]} > 0
		{
			
			UIElement[${xvar}@${UITab}@GUITabs@MyPrices]:SetSelection[${ItemList.FindSet["${LBoxString}"].FindSetting[Box${xvar}]}]

			if ${ItemList.FindSet["${LBoxString}"].FindSetting[Box${xvar}]} == 2
			{
				UIElement[BoxNumber@${UITab}@GUITabs@MyPrices]:SetText[${xvar}]
			}
		}
		else
		{
			UIElement[${xvar}@${UITab}@GUITabs@MyPrices]:SetSelection[1]
		}
	}
	while ${xvar:Inc} <= ${brokerslots}

	call echolog " <end> : ShowCraftInfo"
}

; Toggle an item as 'Non Craftable'
function Unselectcraft(string UITab, int ItemID)
{
	call echolog "-> Unselectcraft ${UITab} ${ItemID}"

	Declare LBoxString string local

	LBoxString:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[${UITab}].FindChild[CraftName].Text}]
	
	if ${LBoxString.Length} == 0
	{
		UIElement[ErrorText@${UITab}@GUITabs@MyPrices]:SetText[No item selected]
	}
	else
	{
		CraftList:Set[${LavishSettings[myprices].FindSet[Item]}]
		CraftItemList:Set[${CraftList.FindSet["${LBoxString}"]}]
		CraftItemList:AddSetting[CraftItem,FALSE]
		
		; save the new information
		LavishSettings[myprices]:Export[${XMLPath}${EQ2.ServerName}_${Me.Name}_MyPrices.XML]
	}
	call echolog " <end> : Unselectcraft"
}


function AddLog(string textline, string colour)
{
	call echolog "** ${textline} **"
	UIElement[ItemList@Log@GUITabs@MyPrices]:AddItem[${textline},1,${colour}]
}

function CheckFocus()
{
	if !${EQ2UIPage[Inventory,Market].IsVisible}
	{
		UIElement[Errortext@Sell@GUITabs@MyPrices]:SetText[" **Paused**"]
		do
		{
			waitframe
		}
		while !${EQ2UIPage[Inventory,Market].IsVisible}
		UIElement[Errortext@Sell@GUITabs@MyPrices]:SetText[" **Processing**"]
	}
	return
}


function SetItemPrice(int i, int j, float price, bool UL)
{
	declare currentitem  string  local
	Call CheckFocus
	currentitem:Set[${BrokerWindow.VendingContainer[${i}].Consignment[${j}]}]
	call echolog "--------- Set Item Price for ${BrokerWindow.VendingContainer[${i}].Consignment[${j}]} using BrokerWindow.VendingContainer[${i}].Consignment[${j}]:SetPrice[${price}]"
	BrokerWindow.VendingContainer[${i}].Consignment[${j}]:SetPrice[${price}]
	if ${UL}
	{
		call FindItem ${i} "${currentitem}"
		j:Set[${Return}]

		if ${j} != -1
			BrokerWindow.VendingContainer[${i}].Consignment[${j}]:Unlist

	}
	wait 10
	if ${Logging}
	{
		; check if the item was moved
		call FindItem ${i} "${currentitem}"
		j:Set[${Return}]
		call echolog	"--------- BrokerWindow.VendingContainer[${i}].Consignment[${j}].BasePrice (${BrokerWindow.VendingContainer[${i}].Consignment[${j}]}) returned ${BrokerWindow.VendingContainer[${i}].Consignment[${j}].BasePrice}"
	}
}

objectdef BrokerBot
{
	method LoadUI()
	{
		call echolog "<start> : LoadUI"
		; Load the UI Parts
		;
		ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/EQ2.xml"
		ui -reload -skin eq2 "${MyPricesUIPath}mypricesUI.xml"
		call echolog "<end> : LoadUI"
		return
	}

	method loadsettings()
	{
		; Set up 'arrays'
		; Bool to check if broker item has been scanned
		DeclareVariable Scanned collection:bool script
		; Array - stores container number for each item in the Listbox
		DeclareVariable itemprice collection:int script
		; Array - stores inventory location number for each item in your inventory
		DeclareVariable InventoryList collection:int script

		; Read settings from The (character name).XML  setting file inside the XML sub-folder
		;
		LavishSettings:AddSet[myprices]
		LavishSettings[myprices]:AddSet[General]
		LavishSettings[myprices]:AddSet[Item]
		LavishSettings[myprices]:AddSet[Buy]

		; set used to integrate craft
		LavishSettings:AddSet[newcraft]
		LavishSettings[newcraft]:AddSet[General Options]
		LavishSettings[newcraft]:AddSet[Recipe Favourites]

		; Non saved set for item totals
		LavishSettings:AddSet[craft]

		; Set for collection items that are already collected
		LavishSettings:AddSet[Rejected]

		; Sets for Raws/Rares and Uncommon Harvests
		LavishSettings:AddSet[Raws]
		LavishSettings:AddSet[Rares]
		LavishSettings:AddSet[Uncommon]

		; Set for Items that are for sale
		ItemList:Set[${LavishSettings[myprices].FindSet[Item]}]

		; Set for items that are to be bought through the buy tab
		BuyList:Set[${LavishSettings[myprices].FindSet[Buy]}]

		; make sure nothing from a previous run is in memory
		myprices[ItemList]:Clear
		myprices[BuyList]:Clear
		LavishSettings[craft]:Clear
		LavishSettings[Rejected]:Clear
		LavishSettings[Raws]:Clear
		LavishSettings[Rares]:Clear
		LavishSettings[Uncommon]:Clear
		
		;Load settings from that characters file
		
		LavishSettings[myprices]:Import[${XMLPath}${EQ2.ServerName}_${Me.Name}_MyPrices.XML]
		LavishSettings[Rejected]:Import[${XMLPath}${EQ2.ServerName}_${Me.Name}_Collections.XML]

		; Load Harvests Datafiles
		
		LavishSettings[Raws]:Import[${XMLPath}raws.XML]
		LavishSettings[Rares]:Import[${XMLPath}rares.XML]
		LavishSettings[Uncommon]:Import[${XMLPath}uncommon.XML]
		
		General:Set[${LavishSettings[myprices].FindSet[General]}]
		Logging:Set[${General.FindSetting[Logging]}]
		MatchLowPrice:Set[${General.FindSetting[MatchLowPrice]}]
		MerchantMatch:Set[${General.FindSetting[MerchantMatch]}]
		IncreasePrice:Set[${General.FindSetting[IncreasePrice]}]
		SetUnlistedPrices:Set[${General.FindSetting[SetUnlistedPrices]}]
		ScanSellNonStop:Set[${General.FindSetting[ScanSellNonStop]}]
		IgnoreCopper:Set[${General.FindSetting[IgnoreCopper]}]
		BuyItems:Set[${General.FindSetting[BuyItems]}]
		SellItems:Set[${General.FindSetting[SellItems]}]
		UseOgreCraft:Set[${General.FindSetting[UseOgreCraft]}]
		PauseTimer:Set[${General.FindSetting[PauseTimer]}]
		Craft:Set[${General.FindSetting[Craft]}]
		MatchActual:Set[${General.FindSetting[ActualPrice]}]
		TakeCoin:Set[${General.FindSetting[TakeCoin]}]
		Shinies:Set[${General.FindSetting[Shinies]}]
		PlaceRaws:Set[${General.FindSetting[PlaceRaws]}]
		PlaceRares:Set[${General.FindSetting[PlaceRares]}]
		PlaceUncommon:Set[${General.FindSetting[PlaceUncommon]}]
		ShiniesBox:Set[${General.FindSetting[ShiniesBox]}]

		if ${ShiniesBox} > ${brokerslots} || !${BrokerWindow.VendingContainer[${ShiniesBox}](exists)}
			ShiniesBox:Set[0]
		
		RawsBox:Set[${General.FindSetting[RawsBox]}]
		
		if ${RawsBox} > ${brokerslots} || !${BrokerWindow.VendingContainer[${RawsBox}](exists)}
			RawsBox:Set[0]
		
		RaresBox:Set[${General.FindSetting[RaresBox]}]
		
		if ${RaresBox} > ${brokerslots} || !${BrokerWindow.VendingContainer[${RaresBox}](exists)}
			RaresBox:Set[0]

		UncommonBox:Set[${General.FindSetting[UncommonBox]}]
		

		if ${UncommonBox} > ${brokerslots} || !${BrokerWindow.VendingContainer[${UncommonBox}](exists)}
			UncommonBox:Set[0]
		
		i:Set[1]
		do
		{
			box[${i}]:Set[${General.FindSetting[box${i}]}]
		}
		while ${i:Inc} <= ${brokerslots}
		
		i:Set[1]
		do
		{
			NoSale[${i}]:Set[${General.FindSetting[NoSale${i}]}]
		}
		while ${i:Inc} <= ${InventorySlots}

		i:Set[1]
		do
		{
			BoxMinDefault[${i}]:Set[${General.FindSetting[BoxMin${i}Default]}]
		}
		while ${i:Inc} <= ${brokerslots}

		i:Set[1]
		do
		{
			BoxMaxDefault[${i}]:Set[${General.FindSetting[BoxMax${i}Default]}]
		}
		while ${i:Inc} <= ${brokerslots}

		Natural:Set[${General.FindSetting[Natural]}]
		HighLatency:Set[${General.FindSetting[HighLatency]}]
		NewItemsOnly:Set[${General.FindSetting[NewItemsOnly]}]

		call echolog "Settings being used"
		call echolog "-------------------"
		call echolog "MatchLowPrice is ${MatchLowPrice}"
		call echolog "IncreasePrice is ${IncreasePrice}"
		call echolog "SetUnlistedPrices is ${SetUnlistedPrices}"
		call echolog "ScanSellNonStop is ${ScanSellNonStop}"
		call echolog "IgnoreCopper is ${IgnoreCopper}"
		call echolog "BuyItems is ${BuyItems}"
		call echolog "SellItems is  ${SellItems}"
		call echolog "PauseTimer is ${PauseTimer}"
		call echolog "Craft is ${Craft}"
		call echolog "MatchActual is ${MatchActual}"
		call echolog "TakeCoin is ${TakeCoin}"
		do
		{
			call echolog "box[${i}] is ${box[1]}"
		}
		while ${i:Inc} <= ${brokerslots}
		call echolog "Natural is ${Natural}"
		return
	}
}

;search your current broker boxes for existing stacks of items and see if theres room for more
function placeitem(string ItemName, int ItemBox)
{
	call echolog "<start> placeitem ${ItemName}"
	variable int xvar
	Declare i int local
	Declare space int local
	Declare numitems int local
	Declare maxspaces int local -1
	Declare currenttotal int local
	Declare nospace bool local
	Declare box int local 0
	CraftItemsPlaced:Set[FALSE]
	nospace:Set[FALSE]
	storebox:Set[0]
	
	UIElement[Errortext@Sell@GUITabs@MyPrices]:SetText["Placing Items"]

	; check for number of items not in a NoSale Container
	call numinventoryitems "${ItemName}" FALSE FALSE
	numitems:Set[${Return}]

	; if there are items to be placed
	if ${numitems} > 0
	{
		If ${ItemBox} > 0 && ${ItemList.FindSet["${ItemName}"].FindSetting[Box${ItemBox}]} != 3
		{
			box:Set[${ItemBox}]
		}
		else
		{
			box:Set[0]
			do
			{
				if ${ItemList.FindSet["${ItemName}"].FindSetting[Box${xvar}]} == 2
				{
					box:Set[${xvar}]
					break
				}
			}
			while ${xvar:Inc} <= ${brokerslots}
		}
			
		if ${box} > 0
			space:Set[${Math.Calc[${BrokerWindow.VendingContainer[${box}].TotalCapacity}-${BrokerWindow.VendingContainer[${box}].UsedCapacity}]}]

		if ${box} > 0 && ${space} > 0
		{
			call placeitems "${ItemName}" ${box} ${numitems}
			numitems:Set[${Return}]
		}
		else
		{
			i:Set[1]
			do
			{
				; check to see if there is are boxes with the same item in already
				; if that box has no been marked as a no-place box for that item
				if ${ItemList.FindSet["${ItemName}"].FindSetting[Box${i}]} != 3
				{
					call FindItem ${i} "${ItemName}"
					if ${Return} != -1
					{
						; check the box has free space
						space:Set[${Math.Calc[${BrokerWindow.VendingContainer[${i}].TotalCapacity}-${BrokerWindow.VendingContainer[${i}].UsedCapacity}]}]
		
						if ${space} > 0
						{
							; place the item into the box
							call placeitems "${ItemName}" ${i} ${numitems}
							numitems:Set[${Return}]
						}
					}
				}
			}
			while ${i:Inc} <= ${brokerslots} && ${numitems} > 0
		}
		;   place the rest of the items (if any) where there are spaces , boxes with most space first
		if ${numitems} >0
		{
			do
			{
				call boxwithmostspace "${ItemName}"
				i:Set[${Return}]
				if ${i} == 0
				{
					nospace:Set[TRUE]
					break
				}
				else
				{
					call placeitems "${ItemName}" ${i} ${numitems}
					numitems:Set[${Return}]
				}
			}
			while ${numitems}>0 && !${nospace}
		}
	}
	call echolog "<end> placeitem"
}


function inventorylist()
{
	call echolog "<start> inventorylist"
	
	variable index:item Items
	variable iterator ItemIterator
	Declare i int local 0
	Declare space int local 0
	
	call refreshbags

	do
	{
		if (${BrokerWindow.VendingContainer[${i}](exists)})
		{
			space:Set[${Math.Calc[${BrokerWindow.VendingContainer[${i}].TotalCapacity}-${BrokerWindow.VendingContainer[${i}].UsedCapacity}]}]
			if ${space} == 0
			{
				UIElement[B${i}@Inventory@GUITabs@MyPrices]:Hide
			}
			else
			{
				UIElement[B${i}@Inventory@GUITabs@MyPrices]:Show
			}
		}
	}
	while ${i:Inc} <= ${brokerslots}
	
	i:Set[0]

	UIElement[ItemList@Inventory@GUITabs@MyPrices]:ClearItems
	Wait 10
	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]
	waitframe

	if ${ItemIterator:First(exists)}
	{
		do
		{
			call InventoryContainer ${ItemIterator.Value.InContainerID}

			if ${ItemIterator.Value.InInventory} && !${NoSale[${Return}]} && !${ItemIterator.Value.IsInventoryContainer}
			{
				if !${ItemIterator.Value.Attuned} && !${ItemIterator.Value.NoTrade} && !${ItemIterator.Value.Heirloom} 
				{
					ItemName:Set["${ItemIterator.Value.Name}"]
					if ${UIElement[InventoryFilter@Inventory@GUITabs@MyPrices].Text.Length} == 0 || ${ItemName.Find[${UIElement[InventoryFilter@Inventory@GUITabs@MyPrices].Text}]} != NULL
					{
						UIElement[ItemList@Inventory@GUITabs@MyPrices]:AddItem["${ItemName}"]

						InventoryList:Set[${i:Inc},${xvar}]

						; Is item a craft item?
						if ${ItemList.FindSet["${ItemName}"].FindSetting[CraftItem]}
							call SetColour Inventory ${i} FFFFFF00

						; is item a collectible ?
						if ${ItemIterator.Value.IsCollectible}
							call SetColour Inventory ${i} CCFF3300

					}
				}
			}
		}
		while ${ItemIterator:Next(exists)}
	}

	call echolog "<end> inventorylist"
}


function placeinventory(int box, int inventorynumber)
{
	Declare xvar int local 1
	Declare space int local
	Declare itemcount int local
	Declare loopcount int local 1

	space:Set[${Math.Calc[${BrokerWindow.VendingContainer[${box}].TotalCapacity}-${BrokerWindow.VendingContainer[${box}].UsedCapacity}]}]


	if ${space} > 0
	{
		if ${InventoryList.Element[${inventorynumber}](exists)}
		{
			; check current used capacity
					
			itemcount:Set[${ItemIterator.Value.Quantity}]
	
			xvar:Set[${InventoryList.Element[${inventorynumber}]}]
	
			; place the item into the consignment system , grouping it with similar items
			ItemIterator.Value:AddToConsignment[${ItemIterator.Value.Quantity},${box},${BrokerWindow.VendingContainer[${box}].Consignment["${ItemIterator.Value.Name}"].SerialNumber}]

			loopcount:Set[1]
			do
			{
				if ${ItemIterator.Value.Quantity} < ${itemcount}
				Break

				wait 10
			}
			while ${loopcount:Inc} <= 10
	
			UIElement[InventoryNumber@Inventory@GUITabs@MyPrices]:SetText[0]
			call SetColour Inventory ${inventorynumber} 00000000
			
			InventoryList:Erase[${inventorynumber}]
	
			space:Set[${Math.Calc[${BrokerWindow.VendingContainer[${box}].TotalCapacity}-${BrokerWindow.VendingContainer[${box}].UsedCapacity}]}]
			
			if ${space} == 0
			{
				UIElement[B${box}@Inventory@GUITabs@MyPrices]:Hide
			}
		}

	}
	else
	{
		UIElement[B${box}@Inventory@GUITabs@MyPrices]:Hide
	}
}

function:int placeitems(string ItemName, int box, int numitems)
{
	call echolog "<start> placeitems ${ItemName} ${box} ${numitems}"
	; attempts to place the items in the defined box
	variable index:item Items
	variable iterator ItemIterator
	Declare lasttotal int local
	Declare space int local
	Declare loopcount int local 1
	Declare itemcount int local
	
	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]

	if ${numitems} >0
	{
		space:Set[${Math.Calc[${BrokerWindow.VendingContainer[${box}].TotalCapacity}-${BrokerWindow.VendingContainer[${box}].UsedCapacity}]}]
		call echolog "placing ${numitems} ${ItemName} in box ${box}"

		if ${ItemIterator:First(exists)}
		{
			do
			{
				; if an item in your inventory matches the crafted item from your crafted item list
				if ${ItemIterator.Value.Name.Equal["${ItemName}"]}
				{
					call InventoryContainer ${ItemIterator.Value.InContainerID}

					if !${ItemIterator.Value.Attuned} && !${NoSale[${Return}]}
					{
						; check current used capacity
						lasttotal:Set[${BrokerWindow.VendingContainer[${box}].UsedCapacity}]
		
						; place the item into the consignment system , grouping it with similar items
						
						itemcount:Set[${ItemIterator.Value.Quantity}]
						
						ItemIterator.Value:AddToConsignment[${ItemIterator.Value.Quantity},${box},${BrokerWindow.VendingContainer[${box}].Consignment["${ItemName}"].SerialNumber}]
		
						; make the script wait till the inventory total has changed (item was added)
						; skips to the next item if nothing changes within 10 seconds (one of the items was unplaceable)
						
						loopcount:Set[1]
						do
						{
							if ${ItemIterator.Value.Quantity} < ${itemcount}
								Break

							if ${BadItem}
								{
									BadItems:Set["${ItemName}"]
									echo BadItems now has ${BadItems.Used} items in it.
									Break
								}
		
							wait 10
							

							if ${HighLatency}
								wait 20

						}
						while ${loopcount:Inc} <= 10
						
						; if a part used item.....skip it
						if ${BadItem}
						{
							Echo Bad Item (Part Used) , Skipping
							BadItem:Set[FALSE]
						}
						else
						{
							; if the system reports that an item will not fit into the container chosen
							if ${BadContainer}
							{
								; change the setting for that item so the container is marked as ignore
								if !${ItemList.FindSet["${ItemName}"]}
									ItemList:AddSet["${ItemName}"]
								
								Item:Set[${ItemList.FindSet["${ItemName}"]}]
								Item:AddSetting[Box${box},3]
							
								; reset the bad Container Flag
								BadContainer:Set[FALSE]
							
								echo Error in container ${box} settings for "${ItemName}" , marking that container as bad
							
								; Get a new container number
								call boxwithmostspace "${ItemName}"
								box:Set[${Return}]
							
								; if no container is available then stop placing that set of items
								if ${box} == 0
								{
									nospace:Set[TRUE]
									break
								}
								else
								{
									; Otherwise try and place item in the new container
								
									itemcount:Set[${ItemIterator.Value.Quantity}]
									
									; place the item into the consignment system , grouping it with similar items
									ItemIterator.Value:AddToConsignment[${ItemIterator.Value.Quantity},${box},${BrokerWindow.VendingContainer[${box}].Consignment["${ItemName}"].SerialNumber}]
									
									; make the script wait till the inventory total has changed (item was added)
									; skips to the next item if nothing changes within 10/30 seconds (one of the items was unplaceable)
		
									loopcount:Set[1]

									do
									{
										if ${ItemIterator.Value.Quantity} < ${itemcount}
											Break

										if ${BadItem}
											Break

										wait 10
										
										if ${HighLatency}
											wait 20

									}
									while ${loopcount:Inc} <= 10

									if ${BadContainer}
									{
										if !${ItemList.FindSet["${ItemName}"]}
											ItemList:AddSet["${ItemName}"]

										; change the setting for that item so the container is marked as ignore
										Item:Set[${ItemList.FindSet["${ItemName}"]}]
										Item:AddSetting[Box${box},3]
							
										; reset the bad Container Flag
										BadContainer:Set[FALSE]
									}					


								}
							}
						}
						space:Set[${Math.Calc[${BrokerWindow.VendingContainer[${box}].TotalCapacity}-${BrokerWindow.VendingContainer[${box}].UsedCapacity}]}]
						numitems:Dec
					}
				}
			}
			while ${ItemIterator:Next(exists)} && ${space} > 0 && ${numitems} > 0
		}
	}
	call echolog "<end> placeitems ${numitems}"
	return ${numitems}
}

function:int numinventoryitems(string ItemName, bool num, bool NoSaleContainer)
{
	
	; returns the number of stacks/number of items in your inventory , num TRUE = total , FALSE = stacks
	; NoSaleContainer = look in inventory slots in a box/bag marked as items not for sale
	
	variable index:item Items
	variable iterator ItemIterator
	Declare numitems int local 0

	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]

	if ${ItemIterator:First(exists)}
	{
		do
		{
			if ${ItemIterator.Value.Name.Equal["${ItemName}"]} && ${ItemIterator.Value.InInventory}
			{
				call InventoryContainer ${ItemIterator.Value.InContainerID}

				if  !${NoSale[${Return}]} || ${NoSaleContainer}
				{
					if ${num}
						numitems:Inc[${ItemIterator.Value.Quantity}]
					else
						numitems:Inc
				}
			}
		}
		while ${ItemIterator:Next(exists)}
	}

	return ${numitems}
}

function:int boxwithmostspace(string ItemName)
{
	; returns the number of the vendor box with the most free space
	Declare i int local 1
	Declare space int local 1
	Declare max int local 0
	do
	{
		; if that box has not been marked as a no-place box for that item
		if ${ItemList.FindSet["${ItemName}"].FindSetting[Box${i}]} != 3
		{
			space:Set[${Math.Calc[${BrokerWindow.VendingContainer[${i}].TotalCapacity}-${BrokerWindow.VendingContainer[${i}].UsedCapacity}]}]

			if ${space} > ${max}
				max:Set[${i}]
		}
	}
	while ${i:Inc} <= ${brokerslots}
	return ${max}
}

function resetscanned()
{
	Declare lcount int local 1
	do
	{
		if ${Scanned.Element[${lcount}](exists)}
			Scanned:Erase[${lcount}]
	}
	While ${Scanned.Element[${lcount:Inc}](exists)}
}

function:int ChooseNextItem(int numitems)
{
	Declare rnumber int local
	do
	{
		rnumber:Set[${Math.Calc[${Math.Rand[${numitems}]}+1]}]
	}
	While ${Scanned.Element[${rnumber}](exists)}
	return ${rnumber}
}

function GoTransmute(string ItemName)
{
	Declare numitems int local
	variable index:item Items
	variable iterator ItemIterator

	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]
	
	; check for number of items not in NoSale Container
	call numinventoryitems "${ItemName}" FALSE FALSE
	numitems:Set[${Return}]
	
	; if the item is in your bags
	if ${numitems} > 0
	{
		if ${ItemIterator:First(exists)}
		{
			do
			{
				; if an item in your inventory matches the name of the item
				if ${ItemIterator.Value.Name.Equal["${ItemName}"]} && !${ItemIterator.Value.Attuned}
				{
						ItemIterator.Value:Transmute
						wait 200 ${RewardWindow(exists)}
						RewardWindow:Receive
					break
				}
			}
			while ${ItemIterator:Next(exists)}
		}
	}
}


function:bool checklore(string ItemName)
{
	
	Declare numitems int local
	variable index:item Items
	variable iterator ItemIterator

	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]
	
	; check for number of items in all Inventory Containers
	call numinventoryitems "${ItemName}" FALSE TRUE
	numitems:Set[${Return}]
	
	; if the item is in your bags
	if ${numitems} > 0
	{
		if ${ItemIterator:First(exists)}
		{
			do
			{
				; if an item in your inventory matches the name of the item
				if ${ItemIterator.Value.Name.Equal["${ItemName}"]}
				{
					
					if ${Collectible} || ${ItemIterator.Value.Lore}
						Return TRUE
				}
			}
			while ${ItemIterator:Next(exists)}
		}
	}
	Return FALSE
}

function CheckPrimary(string UITab, int boxnum, int ID)
{
	Declare xvar int local 1
	
	if ${boxnum} <= ${brokerslots} && ${BrokerWindow.VendingContainer[${boxnum}](exists)}
	{

		if ${UIElement[${boxnum}@${UITab}@GUITabs@MyPrices].Selection} == 0
			UIElement[MyPrices].FindChild[GUITabs].FindChild[${UITab}].FindChild[${boxnum}]:SetSelection[1] 

		if ${ID} == 2
		{	
			UIElement[MyPrices].FindChild[GUITabs].FindChild[${UITab}].FindChild[${boxnum}]:SetSelection[2]
			
			do
			{
				if ${xvar} != ${boxnum}
				{
					if ${UIElement[${xvar}@${UITab}@GUITabs@MyPrices].Selection} == 2
						UIElement[MyPrices].FindChild[GUITabs].FindChild[${UITab}].FindChild[${xvar}]:SetSelection[1] 
				}
	
				if ${UIElement[${xvar}@${UITab}@GUITabs@MyPrices].Selection} == 0
					UIElement[MyPrices].FindChild[GUITabs].FindChild[${UITab}].FindChild[${xvar}]:SetSelection[1] 
			}
			while ${xvar:Inc} <= ${brokerslots}
		}
	}
}

function refreshbags()
{
	variable index:item Items
	variable iterator ItemIterator
	Declare rbxvar int local 1
	Declare bcheck string local
	Declare acheck string local
	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]
	waitframe

	; nothing recognised as in bags so return FALSE
	if (${Items.Used} == 0)
	{
		Echo Unable to read inventory data
		Return FALSE
	}
	
	eq2execute /togglebags
	wait 10
	eq2execute /togglebags
	wait 10

	if ${ItemIterator:First(exists)}
	{
		do
		{
			acheck:Set[${ItemIterator.Value.ToItemInfo.Attuned}]
			bcheck:Set[${ItemIterator.Value.ToItemInfo.IsCollectible}]

			if !${bcheck.Equal[NULL]} && !${acheck.Equal[NULL]}
				Return TRUE
				
			waitframe
		}
		while ${ItemIterator:Next(exists)}
	}

	Echo Unable to read inventory data
	Return FALSE
}

function placeshinies()
{
	call echolog "<start> placeshinies"
	
	variable index:item Items
	variable iterator ItemIterator
	Declare windowopentimer int local
	Event[EQ2_ExamineItemWindowAppeared]:AttachAtom[EQ2_ExamineItemWindowAppeared]

	call refreshbags

	Raws:Set[${LavishSettings.FindSet[Raws]}]
	Rares:Set[${LavishSettings.FindSet[Rares]}]
	Uncommon:Set[${LavishSettings.FindSet[Uncommon]}]
	BadItems:Clear
	
	if ${Return}
	{
		UIElement[Errortext@Sell@GUITabs@MyPrices]:SetText["Placing Items"]
		Me:QueryInventory[Items, Location == "Inventory"]
		Items:GetIterator[ItemIterator]
		waitframe

		if ${ItemIterator:First(exists)}
		{
			do
			{
				call InventoryContainer ${ItemIterator.Value.InContainerID} 
				if ${ItemIterator.Value.InInventory} && !${NoSale[${Return}]} && !${ItemIterator.Value.IsInventoryContainer} && !${BadItems.Element["${ItemIterator.Value.Name}"](exists)}
				{
					if !${ItemIterator.Value.Attuned} && !${ItemIterator.Value.NoTrade} && !${ItemIterator.Value.Heirloom} 
					{
						; is item a collectible ?
						if ${ItemIterator.Value.IsCollectible} && ${Shinies} 
						{
						
							NewCollection:Set[FALSE]
							windowopentimer:Set[1]
							ItemIterator.Value:Examine
							
							
							; Wait till the examine window is open
							do
							{
								waitframe
							}
							while !${ExamineOpen} && ${windowopentimer:Inc} < 100
									
							if ${windowopentimer:Inc} < 100
							{
								wait 5
								ExamineOpen:Set[FALSE]
		
								if !${NewCollection}
								{
									NewCollection:Set[FALSE]
									call placeitem "${ItemIterator.Value.Name}" ${ShiniesBox}
		
									Me:QueryInventory[Items, Location == "Inventory"]
									Items:GetIterator[ItemIterator]
									waitframe
									if ${ItemIterator:First(exists)}
										continue
									else
										break
								}
							}
							else
							{
								BadItems:Set["${ItemIterator.Value.Name}"]
								echo BadItems now has ${BadItems.Used} items in it.
								EQ2Execute /close_top_window
							}
						}
						elseif ${PlaceRaws} && ${Raws.FindSetting["${ItemIterator.Value.Name}"](exists)}
						{
							call placeitem "${ItemIterator.Value.Name}" ${RawsBox}
							Me:QueryInventory[Items, Location == "Inventory"]
							Items:GetIterator[ItemIterator]
							waitframe
							if ${ItemIterator:First(exists)}
								continue
							else
								break
						}
						elseif ${PlaceRares} && ${Rares.FindSetting["${ItemIterator.Value.Name}"](exists)}
						{
							call placeitem "${ItemIterator.Value.Name}" ${RaresBox}
							Me:QueryInventory[Items, Location == "Inventory"]
							Items:GetIterator[ItemIterator]
							waitframe
							if ${ItemIterator:First(exists)}
								continue
							else
								break
						}
						elseif ${PlaceUncommon} && ${Uncommon.FindSetting["${ItemIterator.Value.Name}"](exists)}
						{
							call placeitem "${ItemIterator.Value.Name}" ${UncommonBox}
							Me:QueryInventory[Items, Location == "Inventory"]
							Items:GetIterator[ItemIterator]
							waitframe
							if ${ItemIterator:First(exists)}
								continue
							else
								break
						}
						elseif ${ItemList.FindSet["${ItemIterator.Value.Name}"].FindSetting[CraftItem]} && !${BadItems.Element["${ItemIterator.Value.Name}"](exists)}
						{
							call placeitem "${ItemIterator.Value.Name}"
							Me:QueryInventory[Items, Location == "Inventory"]
							Items:GetIterator[ItemIterator]
							waitframe
							if ${ItemIterator:First(exists)}
								continue
							else
								break
						}
					}
				}
			}
			while ${ItemIterator:Next(exists)}
		}
	}
	else
	{
		Echo Error Reading inventory Contents - Skipping Placing items
	}
	CraftItemsPlaced:Set[TRUE]
	Event[EQ2_ExamineItemWindowAppeared]:DetachAtom[EQ2_ExamineItemWindowAppeared]
	call echolog "<end> placeshinies"
}

function StartUp()
{
	variable index:item Items
	variable iterator ItemIterator
	Declare xvar int local
	Declare space int local

	if ${Actor[guild,Guild World Market Broker](exists)}
	{
		Actor[Guild,Guild World Market Broker]:DoTarget
		wait 10
		Actor[Guild,Guild World Market Broker]:DoubleClick
		wait 20
		call echolog " * Scanning using Guild Hall Broker *"
		echo " * Scanning using Guild Hall Broker *"
	}
	elseif ${Actor[Guild,broker](exists)}
	{
		Actor[Guild,broker]:DoTarget
		wait 10
		Actor[Guild,broker]:DoubleClick
		wait 20
		call echolog " * Scanning using Broker *"
		echo " * Scanning using Broker *"
	}
	elseif ${Actor[name,a market bulletin board](exists)} && ${Actor[name,a market bulletin board].Distance} <= 11
	{
		Actor[name,a market bulletin board]:DoubleClick
		wait 20
		Actor[${Me}]:DoTarget
		wait 20
		call echolog " * Scanning using Room Board *"
		echo " * Scanning using Room Board *"
	}
	else
	{
		Actor[nokillnpc]:DoTarget
		wait 10
		Target:DoubleClick
		wait 20
		call echolog " * Scanning using Nearest Non Agro NPC (Should be broker) *"
		echo " * Scanning using Nearest Non Agro NPC (Should be broker) *"
	}
	
	i:Set[1]
	do
	{
		if (${BrokerWindow.VendingContainer[${i}](exists)})
		{
			space:Set[${Math.Calc[${BrokerWindow.VendingContainer[${i}].TotalCapacity}-${BrokerWindow.VendingContainer[${i}].UsedCapacity}]}]

			if ${space} == 0
				UIElement[B${i}@Inventory@GUITabs@MyPrices]:Hide
		}
		else
		{
			UIElement[${i}@Sell@GUITabs@MyPrices]:Hide
			UIElement[${i}@Craft@GUITabs@MyPrices]:Hide
			UIElement[${i}@Inventory@GUITabs@MyPrices]:Hide
			UIElement[B${i}@Inventory@GUITabs@MyPrices]:Hide
		}

	}
	while ${i:Inc} <= ${brokerslots}
	
	UIElement[InventoryNumber@Inventory@GUITabs@MyPrices]:Hide

	Me:QueryInventory[Items, Location == "Inventory"]
	Items:GetIterator[ItemIterator]

	wait 5

	if ${ItemIterator:First(exists)}
	{
		do
		{
			if ${ItemIterator.Value.IsInventoryContainer}
			{
				UIElement[Bag${ItemIterator.Value.Slot}@Admin@GUITabs@MyPrices]:SetText["${ItemIterator.Value.Name}"]
				xvar:Set[${Math.Calc[${ItemIterator.Value.Slot} + 1]}]
				NoSaleID[${xvar}]:Set[${ItemIterator.Value.ContainerID}]
			}
		}
		while ${ItemIterator:Next(exists)}
	}

	call LoadList

	if ${ScanSellNonStop}
	{
		call AddLog "Pausing ${PauseTimer} minutes between scans" FFCC00FF
	}
	Call LoadDefault
		
}

function:bool Rejected(string ItemName)
{
	Rejected:Set[${LavishSettings.FindSet[Rejected]}]

	if !${Rejected.FindSetting["${ItemName}"](exists)}
	{
		Rejected:AddSetting["${ItemName}",TRUE]
		Return FALSE
	}
	Return TRUE
}

function:int InventoryContainer(int ID)
{
	Declare xvar int local
	xvar:Set[1]
	
	do
	{
		if ${ID} == ${NoSaleID[${xvar}]}
		Return ${xvar}
	}
	while ${xvar:Inc} <= ${InventorySlots}
	Return -1
}

function SaveDefault()
{
	Declare xvar int local
	Declare Platina int local
	Declare Gold int local
	Declare Silver int local
	Declare Copper int local

	xvar:Set[1]
	
	do
	{
		; Read the values held in the GUI boxes
		Platina:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Admin].FindChild[Box${xvar}MinPP].Text}]
		Gold:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Admin].FindChild[Box${xvar}MinGP].Text}]
		Silver:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Admin].FindChild[Box${xvar}MinSP].Text}]
		Copper:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Admin].FindChild[Box${xvar}MinCP].Text}]

		; calclulate the value in silver
		call calcsilver ${Platina} ${Gold} ${Silver} ${Copper}

		BoxMinDefault[${xvar}]:Set[${Return}]

		Call SaveSetting BoxMin${xvar}Default ${Return}

		Platina:Set[0]
		Gold:Set[0]
		Silver:Set[0]
		Copper:Set[0]

		; Read the values held in the GUI boxes
		Platina:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Admin].FindChild[Box${xvar}MaxPP].Text}]
		Gold:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Admin].FindChild[Box${xvar}MaxGP].Text}]
		Silver:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Admin].FindChild[Box${xvar}MaxSP].Text}]
		Copper:Set[${UIElement[MyPrices].FindChild[GUITabs].FindChild[Admin].FindChild[Box${xvar}MaxCP].Text}]

		; calclulate the value in silver
		call calcsilver ${Platina} ${Gold} ${Silver} ${Copper}

		BoxMaxDefault[${xvar}]:Set[${Return}]

		Call SaveSetting BoxMax${xvar}Default ${Return}

		Platina:Set[0]
		Gold:Set[0]
		Silver:Set[0]
		Copper:Set[0]

	}
	while ${xvar:Inc} <= ${InventorySlots}
}

function LoadDefault()
{
	Declare xvar int local
	Declare Platina int local
	Declare Gold int local
	Declare Silver int local
	Declare Copper int local
	xvar:Set[1]
	
	do
	{
	
		Money:Set[${BoxMinDefault[${xvar}]}]
		
		Platina:Set[${Math.Calc[${Money}/10000]}]
		Money:Set[${Math.Calc[${Money}-(${Platina}*10000)]}]
		Gold:Set[${Math.Calc[${Money}/100]}]
		Money:Set[${Math.Calc[${Money}-(${Gold}*100)]}]
		Silver:Set[${Money}]
		Money:Set[${Math.Calc[${Money}-${Silver}]}]
		Copper:Set[${Math.Calc[${Money}*100]}]
	
		UIElement[Box${xvar}MinPP@Admin@GUITabs@MyPrices]:SetText[${Platina}]
		UIElement[Box${xvar}MinGP@Admin@GUITabs@MyPrices]:SetText[${Gold}]
		UIElement[Box${xvar}MinSP@Admin@GUITabs@MyPrices]:SetText[${Silver}]
		UIElement[Box${xvar}MinCP@Admin@GUITabs@MyPrices]:SetText[${Copper}]

		Money:Set[${BoxMaxDefault[${xvar}]}]
		
		Platina:Set[${Math.Calc[${Money}/10000]}]
		Money:Set[${Math.Calc[${Money}-(${Platina}*10000)]}]
		Gold:Set[${Math.Calc[${Money}/100]}]
		Money:Set[${Math.Calc[${Money}-(${Gold}*100)]}]
		Silver:Set[${Money}]
		Money:Set[${Math.Calc[${Money}-${Silver}]}]
		Copper:Set[${Math.Calc[${Money}*100]}]
	
		UIElement[Box${xvar}MaxPP@Admin@GUITabs@MyPrices]:SetText[${Platina}]
		UIElement[Box${xvar}MaxGP@Admin@GUITabs@MyPrices]:SetText[${Gold}]
		UIElement[Box${xvar}MaxSP@Admin@GUITabs@MyPrices]:SetText[${Silver}]
		UIElement[Box${xvar}MaxCP@Admin@GUITabs@MyPrices]:SetText[${Copper}]

	}
	while ${xvar:Inc} <= ${brokerslots}
}

function runcraft()
{
	EQ2Execute /close_top_window
	UIElement[Errortext@Sell@GUITabs@MyPrices]:SetText[" Running Craft "]
	if ${UseOgreCraft}
	{
		if ${Script[${OgreCraftUIScriptName}](exists)}
		{
			OgreCraft:AddRecipeListFromFile[${Me.TSSubClass}-_myprices.xml]
			OgreCraft:Start[]
		}
		else
		{
			ogre craft -q ${Me.TSSubClass}-_myprices.xml -s
		}
	}
	else
	{
		craft ${Me.TSSubClass}-_myprices
	}
	Exitmyprices:Set[TRUE]
}

atom(script) EQ2_onInventoryUpdate()
{
	InventorySlotsFree:Set[${Me.InventorySlotsFree}]
}

function echolog(string logline)
{
	if ${Logging}
		Redirect -append "${LogPath}myprices.log" Echo "${logline}"
}


; when the script exits , save all the settings and do some cleaning up
atom atexit()
{
	if !${ISXEQ2.IsReady}
		return

	LavishSettings[myprices]:Export[${XMLPath}${EQ2.ServerName}_${CurrentChar}_MyPrices.XML]
	LavishSettings[Rejected]:Export[${XMLPath}${EQ2.ServerName}_${CurrentChar}_Collections.XML]

	Event[EQ2_onInventoryUpdate]:DetachAtom[EQ2_onInventoryUpdate]
	Event[EQ2_onChoiceWindowAppeared]:DetachAtom[EQ2_onChoiceWindowAppeared]
	Event[EQ2_onIncomingText]:DetachAtom[EQ2_onIncomingText]
	Event[EQ2_ExamineItemWindowAppeared]:DetachAtom[EQ2_ExamineItemWindowAppeared]

	ui -unload "${MyPricesUIPath}mypricesUI.xml"
	
	LavishSettings[newcraft]:Clear
	LavishSettings[myprices]:Clear
	LavishSettings[craft]:Clear
	LavishSettings[Rejected]:Clear
	LavishSettings[Raws]:Clear
	LavishSettings[Rares]:Clear
	LavishSettings[Uncommon]:Clear
}

atom EQ2_onChoiceWindowAppeared()
{
	if !${ChoiceWindow.Text.Find[Are you sure you want to transmute the]}
		return
	if ${ChoiceWindow.Choice1.Find[Accept]}
		ChoiceWindow:DoChoice1
}

atom(script) EQ2_onIncomingText(string Text)
{
	if ${Text.Find["That container cannot store "]} > 0 
	{
		BadContainer:Set[TRUE]
	}

	if ${Text.Find["You cannot place an expendable with consumed "]} > 0 
	{
		BadItem:Set[TRUE]
	}
	return
}

atom EQ2_ExamineItemWindowAppeared(string ItemName, string WindowID)
{
	if ${ExamineItemWindow[${WindowID}].TextVector} == 2
		NewCollection:Set[TRUE]
	else
		NewCollection:Set[FALSE]

	ExamineOpen:Set[TRUE]
	
	EQ2Execute /close_top_window 
}
