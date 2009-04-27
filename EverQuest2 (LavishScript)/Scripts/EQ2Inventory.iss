;EQ2Broker v2
;By Syliac
;=================================
;Consignment Box Variables
;=================================
variable int TSBox
variable int SBBox
variable int CLBox
variable int CHBox
variable int RHBox
variable int LLBox
variable int FertBox
variable int StatBox
variable int CustBox
variable int UseBox
;=================================
;Item Variables
;=================================
variable string ClassName
variable string TradeClass
variable string BookTradeClass
variable string ItemType
variable string NameFilter1
variable string NameFilter2
variable string NameFilter3
;=================================
;Run Variables
;=================================

variable int RunBroker
variable int RunDepot
variable int SlotFull
variable int SkipItem
variable int RunHirelings
variable int RunJunk
variable int RunDestroy
variable int CloseScript
;=================================
function main()
{
	declare FP filepath "${LavishScript.HomeDirectory}/Scripts/EQ2Inventory/CharConfig/"

  if ${FP.FileExists[${Me.Name}.xml]}
  {
		ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"
		ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/EQ2Inventory/UI/EQ2InventoryUI.xml"
	}
	else
	{
		call MakeFile
		wait 5
		ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"
		ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/EQ2Inventory/UI/EQ2InventoryUI.xml"
	}
	RunBroker:Set[1]
	RunDepot:Set[1]
	RunJunk:Set[1]
	RunDestroy:Set[1]
	RunHirelings:Set[1]
	CloseScript:Set[0]
	wait 1
	
	UIElement[StatusText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[EQ2Hirelings Inactive.]
	wait 5

	while 1
  {
    while ${QueuedCommands}
      ExecuteQueued

    waitframe
  }
}

function PlaceItems()
{
	TSBox:Set[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]}]
 	SBBox:Set[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}]
	CLBox:Set[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CollectionsBox]}]
	CHBox:Set[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]}]
	RHBox:Set[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]}]
	LLBox:Set[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[LoreAndLegendBox]}]
	FertBox:Set[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[FertilizerItemBox]}]
	StatBox:Set[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]}]
	CustBox:Set[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CustomItemsBox]}]
	RunBroker:Set[1]
	wait 5
	UIElement[ItemList@EQ2Broker@GUITabs@EQ2Inventory]:ClearItems
	call AddLog "**Starting EQ2Broker v2 By Syliac**" FF00FF00
	EQ2:CreateCustomActorArray[byDist,15]
	if ${Actor[guild,Guild World Market Broker](exists)}
	{
		Actor[guild,Guild World Market Broker]:DoTarget
		wait 5
		Target:DoFace
		wait 5
		Target:DoubleClick
		wait 5
	}
	else
	{
		Actor[guild, Broker]:DoTarget
		wait 5
		Target:DoFace
		wait 5
		Target:DoubleClick
		wait 5
	}	
	EQ2Execute /togglebags
	wait 5
	EQ2Execute /togglebags
	wait 5
	EQ2Execute /togglebags
	wait 5
	EQ2Execute /togglebags

	call CheckFocus

	if ${UIElement[ScanRares@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker} == 1
		call PlaceRare

	if ${UIElement[ScanHarvests@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker} == 1
		call PlaceHarvest

	if ${UIElement[ScanCollections@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker} == 1
		call PlaceCollection
		
	if ${UIElement[ScanCollections@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker} == 1
		call PlaceCollection	

	if ${UIElement[ScanTradeskills@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker} == 1
		call PlaceTradeskillBooks

	if ${UIElement[ScanSpellBooks@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker} == 1
		call PlaceSpellBooks

	if ${UIElement[ScanLoreAndLegend@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker} == 1
		call PlaceLoreAndLegend
	
	if ${UIElement[ScanStatus@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker} == 1
		call PlaceStatusItems

	if ${UIElement[ScanFertilizer@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker} == 1
		call PlaceFertilizer

	if ${UIElement[ScanCustom@EQ2Broker@GUITabs@EQ2Inventory].Checked} && ${RunBroker} == 1
		call PlaceCustom	

	if ${RunBroker} == 1
	{
		call ShutDown
	}
	else
	{
		call AddLog "**EQ2Broker Canceled!**" FF00FF00
	}		
}

function PlaceRare()
{
	call AddLog "**Checking Rares List**" FFFF00FF

	call PlaceRaret1
	call PlaceRaret2
	call PlaceRaret3
	call PlaceRaret4
	call PlaceRaret5
	call PlaceRaret6
	call PlaceRaret7
	call PlaceRaret8
}

function PlaceRaret1()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[RHarvestT1@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Key[${KeyNum}]}].Quantity},${RHBox},${Me.Vending[${RHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Keys}
	}
}
function PlaceRaret2()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[RHarvestT2@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Key[${KeyNum}]}].Quantity},${RHBox},${Me.Vending[${RHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Keys}
	}
}
function PlaceRaret3()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[RHarvestT3@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Key[${KeyNum}]}].Quantity},${RHBox},${Me.Vending[${RHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Keys}
	}
}
function PlaceRaret4()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[RHarvestT4@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Key[${KeyNum}]}].Quantity},${RHBox},${Me.Vending[${RHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Keys}
	}
}
function PlaceRaret5()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[RHarvestT5@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Key[${KeyNum}]}].Quantity},${RHBox},${Me.Vending[${RHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Keys}
	}
}
function PlaceRaret6()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[RHarvestT6@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Key[${KeyNum}]}].Quantity},${RHBox},${Me.Vending[${RHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Keys}
	}
}
function PlaceRaret7()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[RHarvestT7@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Key[${KeyNum}]}].Quantity},${RHBox},${Me.Vending[${RHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Keys}
	}
}
function PlaceRaret8()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[RHarvestT8@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Key[${KeyNum}]}].Quantity},${RHBox},${Me.Vending[${RHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Keys}
	}
}
function PlaceHarvest()
{
	call CheckFocus
 	call AddLog "**Checking Harvests List**" FFFF00FF

	if ${UIElement[DeleteMeat@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
		call DeleteMeat

	call PlaceHarvestT1
	call PlaceHarvestT2
	call PlaceHarvestT3
	call PlaceHarvestT4
	call PlaceHarvestT5
	call PlaceHarvestT6
	call PlaceHarvestT7
	call PlaceHarvestT8
}

function PlaceHarvestT1()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[CHarvestT1@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Key[${KeyNum}]}].Quantity},${CHBox},${Me.Vending[${CHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Keys}
	}
}
function PlaceHarvestT2()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[CHarvestT2@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Key[${KeyNum}]}].Quantity},${CHBox},${Me.Vending[${CHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Keys}
	}
}
function PlaceHarvestT3()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[CHarvestT3@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Key[${KeyNum}]}].Quantity},${CHBox},${Me.Vending[${CHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Keys}
	}
}
function PlaceHarvestT4()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[CHarvestT4@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Key[${KeyNum}]}].Quantity},${CHBox},${Me.Vending[${CHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Keys}
	}
}
function PlaceHarvestT5()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[CHarvestT5@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Key[${KeyNum}]}].Quantity},${CHBox},${Me.Vending[${CHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Keys}
	}
}
function PlaceHarvestT6()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[CHarvestT6@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Key[${KeyNum}]}].Quantity},${CHBox},${Me.Vending[${CHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Keys}
	}
}
function PlaceHarvestT7()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[CHarvestT7@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Key[${KeyNum}]}].Quantity},${CHBox},${Me.Vending[${CHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Keys}
	}
}
function PlaceHarvestT8()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[CHarvestT8@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Key[${KeyNum}]}].Quantity},${CHBox},${Me.Vending[${CHBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Keys}
	}
}

function PlaceCollection()
{
	variable int ArrayPosition=1
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5
	call AddLog "**Checking Previously Collected Collections**"	FFFF00FF
	Do
	{
	  	if ${UIElement[Collections@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked} && ${Me.CustomInventory[${ArrayPosition}].IsCollectible} && ${Me.CustomInventory[${ArrayPosition}].AlreadyCollected}
			{
				Do
				{
					call AddLog "Adding ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name} to Broker" FF11CCFF
					Me.CustomInventory[${Me.CustomInventory[${ArrayPosition}].Name}]:AddToConsignment[${Me.CustomInventory[${Me.CustomInventory[${ArrayPosition}].Name}].Quantity},${CLBox},${Me.Vending[${CLBox}].Consignment[${Me.CustomInventory[${ArrayPosition}].Name}].SerialNumber}]
					wait ${Math.Rand[30]:Inc[20]}
				}
				while ${Me.CustomInventory[${ArrayPosition}].Name(exists)} && ${Me.CustomInventory[${ArrayPosition}].Name.Length}>4	
			}
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize}
}

function PlaceTradeskillBooks()
{
	ItemType:Set[Item]
	NameFilter1:Set[Advanced]
	NameFilter2:Set[Enigma]
	NameFilter3:Set[Ancient]
	UseBox:Set[${TSBox}]
		call AddLog "**Checking Tradeskill Books**"	FFFF00FF

		if ${UIElement[Alchemist@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Alchemist]
				call PlaceBooks
			}
		if ${UIElement[Armorer@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Armorer]
				call PlaceBooks
			}
		if ${UIElement[Carpenter@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Carpenter]
				call PlaceBooks
			}
		if ${UIElement[Jeweler@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Jeweler]
				call PlaceBooks
			}
		if ${UIElement[Sage@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Sage]
				call PlaceBooks
			}
		if ${UIElement[Tailor@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Tailor]
				call PlaceBooks
			}
		if ${UIElement[Weaponsmith@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Weaponsmith]
				call PlaceBooks
			}
		if ${UIElement[Woodworker@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Woodworker]
				call PlaceBooks
			}
		if ${UIElement[Craftsman@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Craftsman]
				call PlaceBooks
			}
		if ${UIElement[Outfitter@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Outfitter]
				call PlaceBooks
			}
		if ${UIElement[Scholar@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Scholar]
				call PlaceBooks
			}
}

function PlaceSpellBooks()
{
	ItemType:Set[Item]
	NameFilter1:Set[Adept I)]
	NameFilter2:Set[Master I)]
	NameFilter3:Set[Adept I)]
	UseBox:Set[${SBBox}]
		call AddLog "**Checking Spell Books**" FFFF00FF

		if ${UIElement[Assassin@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Assassin]
				call PlaceBooks
			}
		if ${UIElement[Berserker@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Berserker]
				call PlaceBooks
			}
		if ${UIElement[Brigand@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Brigand]
				call PlaceBooks
			}
		if ${UIElement[Bruiser@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Bruiser]
				call PlaceBooks
			}
		if ${UIElement[Coercer@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Coercer]
				call PlaceBooks
			}
		if ${UIElement[Conjuror@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Conjuror]
				call PlaceBooks
			}
		if ${UIElement[Defiler@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Defiler]
				call PlaceBooks
			}
		if ${UIElement[Dirge@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Dirge]
				call PlaceBooks
			}
		if ${UIElement[Fury@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Fury]
				call PlaceBooks
			}
		if ${UIElement[Guardian@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Guardian]
				call PlaceBooks
			}
		if ${UIElement[Illusionist@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Illusionist]
				call PlaceBooks
			}
		if ${UIElement[Inquisitor@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Inquisitor]
				call PlaceBooks
			}
		if ${UIElement[Monk@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Monk]
				call PlaceBooks
			}
		if ${UIElement[Mystic@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Mystic]
				call PlaceBooks
			}
		if ${UIElement[Necromancer@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Necromancer]
				call PlaceBooks
			}
		if ${UIElement[Paladin@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Paladin]
				call PlaceBooks
			}
		if ${UIElement[Ranger@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Ranger]
				call PlaceBooks
			}
		if ${UIElement[Shadowknight@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Shadowknight]
				call PlaceBooks
			}
		if ${UIElement[Swashbuckler@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Swashbuckler]
				call PlaceBooks
			}
		if ${UIElement[Templar@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Templar]
				call PlaceBooks
			}
		if ${UIElement[Troubador@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Troubador]
				call PlaceBooks
			}
		if ${UIElement[Warden@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Warden]
				call PlaceBooks
			}
		if ${UIElement[Warlock@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Warlock]
				call PlaceBooks
			}
		if ${UIElement[Wizard@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
			{
				ClassName:Set[Wizard]
				call PlaceBooks
			}
}

function PlaceBooks()
{
	variable int ArrayPosition=1
	Me:CreateCustomInventoryArray[nonbankonly]
	call CheckFocus
	wait 5
	Do
	{
		
			if ${Me.CustomInventory[${ArrayPosition}].Type.Equal[${ItemType}]} && ${Me.CustomInventory[${ArrayPosition}].Class[1].Name.Equal[${ClassName}]} && ${Me.CustomInventory[${ArrayPosition}].Name.Find[${NameFilter1}]}
	  	{
	  		call AddLog "Adding ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name} to broker" FF11CCFF
	  		Me.CustomInventory[ExactName,${Me.CustomInventory[${ArrayPosition}].Name}]:AddToConsignment[${Me.CustomInventory[${ArrayPosition}].Quantity},${UseBox},${Me.Vending[${UseBox}].Consignment[${Me.CustomInventory[${ArrayPosition}].Name}].SerialNumber}]
	  		wait ${Math.Rand[30]:Inc[20]}
			}
			if ${Me.CustomInventory[${ArrayPosition}].Type.Equal[${ItemType}]} && ${Me.CustomInventory[${ArrayPosition}].Class[1].Name.Equal[${ClassName}]} && ${Me.CustomInventory[${ArrayPosition}].Name.Find[${NameFilter2}]}
	 	 {
	  		call AddLog "Adding ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name} to broker" FF11CCFF
	  		Me.CustomInventory[ExactName,${Me.CustomInventory[${ArrayPosition}].Name}]:AddToConsignment[${Me.CustomInventory[${ArrayPosition}].Quantity},${UseBox},${Me.Vending[${UseBox}].Consignment[${Me.CustomInventory[${ArrayPosition}].Name}].SerialNumber}]
	  		wait ${Math.Rand[30]:Inc[20]}
			}
			if ${Me.CustomInventory[${ArrayPosition}].Type.Equal[${ItemType}]} && ${Me.CustomInventory[${ArrayPosition}].Class[1].Name.Equal[${ClassName}]} && ${Me.CustomInventory[${ArrayPosition}].Name.Find[${NameFilter3}]}
		  {
	  		call AddLog "Adding ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name} to broker" FF11CCFF
	  		Me.CustomInventory[ExactName,${Me.CustomInventory[${ArrayPosition}].Name}]:AddToConsignment[${Me.CustomInventory[${ArrayPosition}].Quantity},${UseBox},${Me.Vending[${UseBox}].Consignment[${Me.CustomInventory[${ArrayPosition}].Name}].SerialNumber}]
	  		wait ${Math.Rand[30]:Inc[20]}
			}		
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize} && ${RunBroker} == 1
}

function PlaceStatusItems()
{
	call CheckFocus
	call AddLog "**Checking Status Items List**" FFFF00FF
	call PlaceStatusT1
	call PlaceStatusT2
	call PlaceStatusT3
	call PlaceStatusT4
	call PlaceStatusT5
	call PlaceStatusT6
	call PlaceStatusT7
	call PlaceStatusT8
}

function PlaceStatusT1()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[StatusItemT1@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Key[${KeyNum}]}].Quantity},${StatBox},${Me.Vending[${StatBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Keys}
	}
}
function PlaceStatusT2()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[StatusItemT2@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Key[${KeyNum}]}].Quantity},${StatBox},${Me.Vending[${StatBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Keys}
	}
}
function PlaceStatusT3()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[StatusItemT3@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Key[${KeyNum}]}].Quantity},${StatBox},${Me.Vending[${StatBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Keys}
	}
}
function PlaceStatusT4()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[StatusItemT4@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Key[${KeyNum}]}].Quantity},${StatBox},${Me.Vending[${StatBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Keys}
	}
}
function PlaceStatusT5()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[StatusItemT5@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Key[${KeyNum}]}].Quantity},${StatBox},${Me.Vending[${StatBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Keys}
	}
}
function PlaceStatusT6()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[StatusItemT6@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Key[${KeyNum}]}].Quantity},${StatBox},${Me.Vending[${StatBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Keys}
	}
}
function PlaceStatusT7()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[StatusItemT7@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Key[${KeyNum}]}].Quantity},${StatBox},${Me.Vending[${StatBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Keys}
	}
}
function PlaceStatusT8()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[StatusItemT8@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Key[${KeyNum}]}].Quantity},${StatBox},${Me.Vending[${StatBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Keys}
	}
}
function PlaceFertilizer()
{
	call CheckFocus
	call AddLog "**Checking Fertilizers List**" FFFF00FF
	call PlaceFertilizerT1
	call PlaceFertilizerT2
	call PlaceFertilizerT3
	call PlaceFertilizerT4
	call PlaceFertilizerT5
	call PlaceFertilizerT7
}

function PlaceFertilizerT1()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[FertT1@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Key[${KeyNum}]}].Quantity},${FertBox},${Me.Vending[${FertBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Keys}
	}
}
function PlaceFertilizerT2()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[FertT2@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Key[${KeyNum}]}].Quantity},${FertBox},${Me.Vending[${FertBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Keys}
	}
}
function PlaceFertilizerT3()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[FertT3@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Key[${KeyNum}]}].Quantity},${FertBox},${Me.Vending[${FertBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Keys}
	}
}
function PlaceFertilizerT4()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[FertT4@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Key[${KeyNum}]}].Quantity},${FertBox},${Me.Vending[${FertBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Keys}
	}
}
function PlaceFertilizerT5()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[FertT5@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Key[${KeyNum}]}].Quantity},${FertBox},${Me.Vending[${FertBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Keys}
	}
}
function PlaceFertilizerT7()
{
	variable int KeyNum=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[FertT7@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Key[${KeyNum}]}].Quantity},${FertBox},${Me.Vending[${FertBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Keys}
	}
}

function PlaceLoreAndLegend()
{
	variable int ArrayPosition=1
	NameFilter1:Set[could be studied to learn]
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5
	call CheckFocus
	call AddLog "**Checking Lore & Legend Items**" FFFF00FF	
	if ${UIElement[LoreAndLegend@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
		{
			Do
			{	
				if ${Me.CustomInventory[${ArrayPosition}].Description.Find[${NameFilter1}]} 
				{
						call AddLog "Adding ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name} to Broker" FF11CCFF
						Me.CustomInventory[${Me.CustomInventory[${ArrayPosition}].Name}]:AddToConsignment[${Me.CustomInventory[${Me.CustomInventory[${ArrayPosition}].Name}].Quantity},${LLBox},${Me.Vending[${LLBox}].Consignment[${Me.CustomInventory[${ArrayPosition}].Name}].SerialNumber}]
						wait ${Math.Rand[30]:Inc[20]}
				}			
			}
			while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize} && ${RunBroker} == 1	
		}
}

function PlaceCustom()
{
	variable int KeyNum=1
  call CheckFocus
  call AddLog "**Checking Custom Items List**" FFFF00FF
  Me:CreateCustomInventoryArray[nonbankonly]

	{
		Do
		{
			Do
			{
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${KeyNum}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${KeyNum}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${KeyNum}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${KeyNum}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${KeyNum}]}].Quantity},${CustBox},${Me.Vending[${CustBox}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${KeyNum}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${KeyNum}]}](exists)} && ${RunBroker} == 1
			call CheckFocus
		}
		while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Keys}
	}
}

function DestroyItems()
{
	variable int KeyNum=1
	RunDestroy:Set[1]
	wait 5
	UIElement[SellItemList@EQ2Junk@GUITabs@EQ2Inventory]:ClearItems
	call AddSellLog "**Starting EQ2Destroy v2 By Syliac**" FF00FF00
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5
	call AddSellLog "**Destroying Items**" FFFF00FF
	wait 5
	Do
	{
		Do
		{
			if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Key[${KeyNum}]}].Quantity} > 0
	  	{
	  		call AddSellLog "Destroying  ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Key[${KeyNum}]}].Quantity}  ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Key[${KeyNum}]}]}" FFFF0000
	  		Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Key[${KeyNum}]}]:Destroy[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Key[${KeyNum}]}].Quantity}]
				wait ${Math.Rand[30]:Inc[20]}
			}
		}
		while ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Key[${KeyNum}]}](exists)} && ${RunDestroy} == 1
	}
	while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Keys}
	
	if ${RunDestroy} == 1
	{
		call AddSellLog "**Items Destroyed**" FFFF00FF
	}
	else
	{
		call AddSellLog "**EQ2Destroy Canceled!**" FFFF00FF
	}	
}

function VendorType()
{
	if ${UIElement[StatusMerchant@EQ2Junk@GUITabs@EQ2Inventory].Checked}
	{
		call SellStatus
	}
	else
	{
		call SellJunk
	}
}

function SellJunk()
{
	variable int KeyNum=1
	RunJunk:Set[1]
	
	UIElement[SellItemList@EQ2Junk@GUITabs@EQ2Inventory]:ClearItems
	call AddSellLog "**Starting EQ2Junk v2 By Syliac**" FF00FF00
	EQ2:CreateCustomActorArray[byDist,15]
	if ${Actor[guild,Guild Commodities Exporter](exists)}
	{
		Actor[guild,Guild Commodities Exporter]:DoTarget
		wait 5
		Target:DoFace
		wait 5
		Target:DoubleClick
		wait 5
	}
	else
	{
		Actor[nokillnpc]:DoTarget
		wait 5
		Target:DoFace
		wait 5
		Target:DoubleClick
		wait 5
	}	
	wait 5
	EQ2Execute /togglebags
	wait 5
	EQ2Execute /togglebags
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 10
	call AddSellLog "**Selling Junk Items**" FFFF00FF
	Do
	{
		Do
		{
			if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Key[${KeyNum}]}].Quantity} > 0
	  	{
	  		call AddSellLog "Selling ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Key[${KeyNum}]}].Quantity}  ${Me.Merchandise[${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Key[${KeyNum}]}]}" FF11CCFF
	  		Me.Merchandise[${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Key[${KeyNum}]}]:Sell[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Key[${KeyNum}]}].Quantity}]
				wait 15
			}
		}
		while ${Me.Merchandise[${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Key[${KeyNum}]}](exists)} && ${RunJunk} == 1
	}
	while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Keys}

	if ${UIElement[SellTreasured@EQ2Junk@GUITabs@EQ2Inventory].Checked} && ${RunJunk} == 1
	{
		call SellTreasured
	}

	if ${UIElement[SellAdeptI@EQ2Junk@GUITabs@EQ2Inventory].Checked} && ${RunJunk} == 1
	{
		call SellAdeptI
	}
	
	if ${UIElement[SellHandcrafted@EQ2Junk@GUITabs@EQ2Inventory].Checked} && ${RunJunk} == 1
	{
		call SellHandcrafted
	}
	
	if ${UIElement[SellUncommon@EQ2Junk@GUITabs@EQ2Inventory].Checked} && ${RunJunk} == 1
	{
		call SellUncommon
	}
	
	if ${RunJunk} == 1
	{
		call AddSellLog "**Junk Items Sold**" FFFF00FF
	}
	else	
	{
		call AddSellLog "**EQ2Junk Canceled!**" FFFF00FF
	}	
	press ESC
	press ESC
	press ESC
}

function SellStatus()
{
	variable int ArrayPosition=1
	NameFilter1:Set[awarded a great amount of status]
	UIElement[SellItemList@EQ2junk@GUITabs@EQ2Inventory]:ClearItems
	wait 5
	call AddSellLog "**Starting EQ2Junk v2 By Syliac**" FF00FF00
	Actor[nokillnpc]:DoTarget
	wait 5
	Target:DoFace
	wait 5
	Target:DoubleClick
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 20
	call AddSellLog "**Selling Status Items to Status Vendor**" FFFF00FF

	Do
	{
			if ${Me.CustomInventory[${ArrayPosition}].Description.Find[${NameFilter1}]} 
	  	{
	  		call AddSellLog "Selling ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name}"
	  		Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}]:Sell[${Me.CustomInventory[${ArrayPosition}].Quantity}]
			}
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize} && ${RunJunk} == 1
	call AddSellLog "**Status Items Sold to Status Vendor**" FFFF00FF

	press ESC
	press ESC
	press ESC
}

function SellTreasured()
{
	variable int ArrayPosition=1
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5
	Do
	{
	  	if ${Me.CustomInventory[${ArrayPosition}].Tier.Equal[TREASURED]} && ${Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}].IsForSale}
			{
				if !${Me.CustomInventory[${ArrayPosition}].InNoSaleContainer}
				{
					if !${Me.CustomInventory[${ArrayPosition}].IsContainer}
					{
						call AddSellLog "Selling ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name}"
						Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}]:Sell[${Me.CustomInventory[${ArrayPosition}].Quantity}]
						wait 15
					}
				}	
			}
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize} && ${RunJunk} == 1
}

function SellHandcrafted()
{
	variable int ArrayPosition=1
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5
	Do
	{
	  	if ${Me.CustomInventory[${ArrayPosition}].Tier.Equal[HANDCRAFTED]} && ${Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}].IsForSale}
			{
				if !${Me.CustomInventory[${ArrayPosition}].InNoSaleContainer}
				{
					if !${Me.CustomInventory[${ArrayPosition}].IsContainer}
					{
						call AddSellLog "Selling ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name}"
						Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}]:Sell[${Me.CustomInventory[${ArrayPosition}].Quantity}]
						wait 15
					}	
				}	
			}
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize} && ${RunJunk} == 1
}

function SellUncommon()
{
	variable int ArrayPosition=1
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5
	Do
	{
	  	if ${Me.CustomInventory[${ArrayPosition}].Tier.Equal[UNCOMMON]} && ${Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}].IsForSale}
			{
				if !${Me.CustomInventory[${ArrayPosition}].InNoSaleContainer}
				{
					if !${Me.CustomInventory[${ArrayPosition}].IsContainer}
					{
						call AddSellLog "Selling ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name}"
						Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}]:Sell[${Me.CustomInventory[${ArrayPosition}].Quantity}]
						wait 15
					}
				}		
			}
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize} && ${RunJunk} == 1
}
function SellAdeptI()
{
	variable int ArrayPosition=1
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5

	Do
	{
		if ${Me.CustomInventory[${ArrayPosition}].Name.Find[Adept I)]} && ${Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}].IsForSale} && ${RunJunk} == 1
			{
				if !${Me.CustomInventory[${ArrayPosition}].InNoSaleContainer}
				{
					if !${Me.CustomInventory[${ArrayPosition}].IsContainer}
					{
						call AddSellLog "Selling ${Me.CustomInventory[${ArrayPosition}].Quantity} ${Me.CustomInventory[${ArrayPosition}].Name}"
						Me.Merchandise[${Me.CustomInventory[${ArrayPosition}].Name}]:Sell
						wait ${Math.Rand[30]:Inc[20]}
					}	
				}	
			}
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize} && ${RunJunk} == 1
}

function AddToDepot()
{
	variable int KeyNum=1
	Event[EQ2_onIncomingText]:AttachAtom[GetText]
	RunDepot:Set[1]
	SkipItem:Set[0]
	SlotFull:Set[0]
	wait 5
	UIElement[DepotItemList@EQ2Depot@GUITabs@EQ2Inventory]:ClearItems
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 5
	call AddDepotLog "**Adding Items to Supply Depot**" FFFF00FF
	wait 5
	Do
	{
		Do
		{
			if ${SkipItem} == 1
				{
					call AddDepotLog "---Skipping item will not add to depot properly!!---" FFFF0000
					KeyNum:Inc	
					SkipItem:Set[0]
				}
			
			if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SupplyDepotList.xml].Set[Supplys].Key[${KeyNum}]}].Quantity} > 0
			{
				call AddDepotLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SupplyDepotList.xml].Set[Supplys].Key[${KeyNum}]}].Quantity}  ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SupplyDepotList.xml].Set[Supplys].Key[${KeyNum}]}]}"
				Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SupplyDepotList.xml].Set[Supplys].Key[${KeyNum}]}]:AddToDepot[${Actor[depot].ID}]
				wait ${Math.Rand[30]:Inc[20]}
				
				if ${SlotFull} == 1
					{		
						call AddDepotLog "---Slot ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SupplyDepotList.xml].Set[Supplys].Key[${KeyNum}]}]} Max QTY!!---" FFFF0000
						KeyNum:Inc	
						SlotFull:Set[0]
					}
				if ${SkipItem} == 1
				{
					call AddDepotLog "---Skipping item will not add to depot properly!!---" FFFF0000
					KeyNum:Inc	
					SkipItem:Set[0]
				}
			}
		}
		while ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SupplyDepotList.xml].Set[Supplys].Key[${KeyNum}]}](exists)} && ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SupplyDepotList.xml].Set[Supplys].Key[${KeyNum}]}].Name.Length}>4 && ${RunDepot} == 1
		
	}
	while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SupplyDepotList.xml].Set[Supplys].Keys} && ${RunDepot} == 1
	
	if ${RunDepot} == 1
	{
		call AddDepotLog "**Items Added to Supply Depot**" FFFF00FF
	}
	else
	{
		call AddDepotLog "**EQ2Depot Canceled!**" FFFF00FF
	}	
	
	if ${CloseScript} == 1
	{
		Script[EQ2Inventory]:End
	}
}

atom GetText(string DepotItemFull)
{
	if ${DepotItemFull.Find["This container cannot hold any more of this item."]}
		{
				SlotFull:Set[1]
		}
}				


function JunkList()
{
	variable int KeyNum=1
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory]:ClearItems
	wait 5
	call AddRemoveList "*******Vendor Junk List*******" FFFF00FF
	Do
	{
	  	call AddRemoveList "${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Key[${KeyNum}]}"
	}
	while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Keys}
}

function DestroyList()
{
	variable int KeyNum=1
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory]:ClearItems
	wait 5
	call AddRemoveList "*******Destroy Item List*******" FFFF00FF
	Do
	{
	  	call AddRemoveList "${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Key[${KeyNum}]}"
	}
	while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Keys}
}

function CustomList()
{
	variable int KeyNum=1
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory]:ClearItems
	wait 5
	call AddRemoveList "*******Custom Item List*******" FFFF00FF
	Do
	{
	  	call AddRemoveList "${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${KeyNum}]}"
	}
	while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Keys}
}

function DepotList()
{
	variable int KeyNum=1
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory]:ClearItems
	wait 5
	call AddRemoveList "*******Depot Item List*******" FFFF00FF
	Do
	{
	  	call AddRemoveList "${SettingXML[./EQ2Inventory/ScriptConfig/SupplyDepotList.xml].Set[Supplys].Key[${KeyNum}]}"
	}
	while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SupplyDepotList.xml].Set[Supplys].Keys}
}

function DeleteMeat()
{
	variable int KeyNum=1
	call AddLog "**Deleting Meats**" FFFF0000

	Me:CreateCustomInventoryArray[nonbankonly]

	Do
	{
		Do
		{
			if ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/DeleteMeats.xml].Set[Meats].Key[${KeyNum}]}].Quantity} > 0
	  	{
	  		call AddLog "Deleting  ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/DeleteMeats.xml].Set[Meats].Key[${KeyNum}]}].Quantity}  ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/DeleteMeats.xml].Set[Meats].Key[${KeyNum}]}]}" FFFF0000
	  		Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/DeleteMeats.xml].Set[Meats].Key[${KeyNum}]}]:Destroy[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/DeleteMeats.xml].Set[Meats].Key[${KeyNum}]}].Quantity}]
				wait 15
			}
		}
		while ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/DeleteMeats.xml].Set[Meats].Key[${KeyNum}]}](exists)}
	}
	while ${KeyNum:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/DeleteMeats.xml].Set[Meats].Keys}
}

function EQ2Hirelings()
{
	variable int GathererTier
	variable int HunterTier
	variable int MinerTier
	variable int StartTime
	variable int StopTime
	variable int RunTime
	variable int TripCount
	
	RunTime:Set[${Time.Timestamp}]
	wait 5
	RunHirelings:Set[1]
	TripCount:Set[0]
	wait 5
	UIElement[StatusText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[Sending Hirelings to Harvest.]
	wait 5
	do
	{
		GathererTier:Set[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[EQ2Hirelings].GetString[GathererTierNumber]}]
		HunterTier:Set[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[EQ2Hirelings].GetString[HunterTierNumber]}]
		MinerTier:Set[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[EQ2Hirelings].GetString[MinerTierNumber]}]
	
		if ${UIElement[GathererHireling@EQ2Hirelings@GUITabs@EQ2Inventory].Checked}
		{
			Actor[guild,"Guild Gatherer"]:DoTarget
			wait 10
			Actor[guild,"Guild Gatherer"]:DoubleClick
			wait 25
			EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${GathererTier}]:LeftClick
			wait 10
		}
		if ${UIElement[HunterHireling@EQ2Hirelings@GUITabs@EQ2Inventory].Checked}
		{
			Actor[guild,"Guild Hunter"]:DoTarget
			wait 10
			Actor[guild,"Guild Hunter"]:DoubleClick
			wait 25
			EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${HunterTier}]:LeftClick
			wait 10
		}
		if ${UIElement[MinerHireling@EQ2Hirelings@GUITabs@EQ2Inventory].Checked}
		{
			Actor[guild,"Guild Miner"]:DoTarget
			wait 10
			Actor[guild,"Guild Miner"]:DoubleClick
			wait 25
			EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${MinerTier}]:LeftClick
			wait 10
		}
		StartTime:Set[${Time.Timestamp}]
		wait 10
		StopTime:Set[${Math.Calc64[${StartTime}+7260]}]
		wait 5
		UIElement[StatusText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[Waiting for Hirelings to Return.]
		wait 5
		do
		{
			UIElement[RuntimeText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[${Math.Calc[(${Time.Timestamp}-${RunTime})/60].Precision[2]} min.]
		 	UIElement[WaittimeText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[${Math.Calc[(${StopTime}-${Time.Timestamp})/60].Precision[2]} min.]
		}
		while ${Math.Calc64[(${StopTime}-${Time.Timestamp}]} > 0 && ${RunHirelings} == 1
		
		if ${RunHirelings} == 0
		{
			UIElement[StatusText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[EQ2Hirelings Inactive.]
			wait 5
			Return
		}
		
		if ${UIElement[GathererHireling@EQ2Hirelings@GUITabs@EQ2Inventory].Checked}
		{
			Actor[guild,"Guild Gatherer"]:DoTarget
			wait 10
			Actor[guild,"Guild Gatherer"]:DoubleClick
			wait 25
			EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
			wait 10
		}
		if ${UIElement[HunterHireling@EQ2Hirelings@GUITabs@EQ2Inventory].Checked}
		{
			Actor[guild,"Guild Hunter"]:DoTarget
			wait 10
			Actor[guild,"Guild Hunter"]:DoubleClick
			wait 25
			EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
			wait 10
		}
		if ${UIElement[MinerHireling@EQ2Hirelings@GUITabs@EQ2Inventory].Checked}
		{
			Actor[guild,"Guild Miner"]:DoTarget
			wait 10
			Actor[guild,"Guild Miner"]:DoubleClick
			wait 25
			EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
			wait 10
		}
		TripCount:Inc
		wait 5
		UIElement[TripText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[${TripCount}]
		
		if ${UIElement[UseHarvestDepot@EQ2Hirelings@GUITabs@EQ2Inventory].Checked}
		{
			UIElement[StatusText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[Adding Items to Supply Depot.]
			wait 5
			call AddToDepot
		}
		UIElement[StatusText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[Sending Hirelings to Harvest.]
		wait 5
	}
	while ${RunHirelings} == 1
	wait 5
	UIElement[StatusText@EQ2Hirelings@GUITabs@EQ2Inventory]:SetText[EQ2Hirelings Inactive.]
}

function AddJunk()
{
	SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk]:Set[${UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem},Sell]
	wait 5
	SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml]:Save
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FF00FF00]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function AddDestroy()
{
	SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy]:Set[${UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem},Sell]
	wait 5
	SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml]:Save
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FF00FF00]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function AddCustom()
{
	SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems]:Set[${UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem},Sell]
	wait 5
	SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml]:Save
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FF00FF00]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function AddDepot()
{
	SettingXML[./EQ2Inventory/ScriptConfig/SupplyDepotList.xml].Set[Supplys]:Set[${UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem},Save]
	wait 5
	SettingXML[./EQ2Inventory/ScriptConfig/SupplyDepotList.xml]:Save
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FF00FF00]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function RemoveJunk()
{
	SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk]:UnSet[${UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem}]
	wait 5
	SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml]:Save
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FFFF0000]
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}
function RemoveDestroy()
{
	SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy]:UnSet[${UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem}]
	wait 5
	SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml]:Save
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FFFF0000]
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function RemoveCustom()
{
	SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems]:UnSet[${UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem}]
	wait 5
	SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml]:Save
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FFFF0000]
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function RemoveDepot()
{
	SettingXML[./EQ2Inventory/ScriptConfig/SupplyDepotList.xml].Set[Supplys]:UnSet[${UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem}]
	wait 5
	SettingXML[./EQ2Inventory/ScriptConfig/SupplyDepotList.xml]:Save
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FFFF0000]
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function InvList()
{
	call CreateInventorylist
	wait 5
	call CreateInventorylist
	wait 5
	call CreateInventorylist
}

function CreateInventorylist()
{
	variable int ArrayPosition=1
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory]:ClearItems
	Me:CreateCustomInventoryArray[nonbankonly]
	call AddInvList "**Creating Inventory List ${Me.CustomInventoryArraySize} Items**" FFFF00FF

	Do
	{
		if !${Me.CustomInventory[${ArrayPosition}].InNoSaleContainer}
		{
			if !${Me.CustomInventory[${ArrayPosition}].IsContainer} 
			{
				if ${Me.CustomInventory[${ArrayPosition}].InInventory}
					call AddInvList "${Me.CustomInventory[${ArrayPosition}].Name}"
			}  
	  }	
	}
	while ${ArrayPosition:Inc} <= ${Me.CustomInventoryArraySize}
}

function AddLog(string textline, string colour)
{
	UIElement[ItemList@EQ2Broker@GUITabs@EQ2Inventory]:AddItem[${textline},1,${colour}]
	UIElement[ItemList@EQ2Broker@GUITabs@EQ2Inventory].FindUsableChild[Vertical,Scrollbar]:LowerValue[1]
}

function AddSellLog(string textline, string colour)
{
	UIElement[SellItemList@EQ2Junk@GUITabs@EQ2Inventory]:AddItem[${textline},1,${colour}]
	UIElement[SellItemList@EQ2Junk@GUITabs@EQ2Inventory].FindUsableChild[Vertical,Scrollbar]:LowerValue[1]
}

function AddDepotLog(string textline, string colour)
{
	UIElement[DepotItemList@EQ2Depot@GUITabs@EQ2Inventory]:AddItem[${textline},1,${colour}]
	UIElement[DepotItemList@EQ2Depot@GUITabs@EQ2Inventory].FindUsableChild[Vertical,Scrollbar]:LowerValue[1]
}
function AddOverDepotLog(string textline, string colour)
{
	UIElement[DepotItemList@EQ2Depot@GUITabs@EQ2Inventory]:AddItem[${textline},1,${colour}]
	UIElement[DepotItemList@EQ2Depot@GUITabs@EQ2Inventory].FindUsableChild[Vertical,Scrollbar]:LowerValue[1]
}
function AddInvList(string textline, string colour)
{
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory]:AddItem[${textline},1,${colour}]
}

function AddRemoveList(string textline, string colour)
{
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory]:AddItem[${textline},1,${colour}]
}

function CheckFocus()
{
	if !${EQ2UIPage[Inventory,Market].IsVisible}
	{
		call AddLog "EQ2Broker **Paused** Place Cursor over Broker" FFEECC00
		do
		{
			waitframe
		}
		while !${EQ2UIPage[Inventory,Market].IsVisible}
	}
	return
}

function MakeFile()
{
	echo **Creating Settings File**
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[RunMyPrices,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[ScanRares,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[ScanHarvests,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[ScanCollections,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[ScanTradeskills,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[ScanSpellBooks,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[ScanStatus,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[ScanFertilizer,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[ScanCustom,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Alchemist,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Armorer,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Carpenter,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Jeweler,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Sage,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Tailor,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Weaponsmith,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Woodworker,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Craftsman,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Outfitter,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Scholar,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Assassin,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Berserker,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Brigand,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Bruiser,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Coercer,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Conjuror,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Defiler,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Dirge,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Fury,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Guardian,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Illusionist,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Inquisitor,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Monk,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Mystic,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Necromancer,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Paladin,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Ranger,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Shadowknight,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Swashbuckler,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Templar,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Troubador,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Warden,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Warlock,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[Wizard,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[AddCollections,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[AddCustomItems,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[CustomItemsBox,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[CHarvestBox,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[DeleteMeat,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[CHarvestT1,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[CHarvestT2,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[CHarvestT3,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[CHarvestT4,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[CHarvestT5,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[CHarvestT6,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[CHarvestT7,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[CHarvestT8,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[CustomItemsBox,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[RHarvestBox,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[RHarvestT1,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[RHarvestT2,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[RHarvestT3,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[RHarvestT4,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[RHarvestT5,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[RHarvestT6,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[RHarvestT7,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[RHarvestT8,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[StatusItemBox,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[StatusItemT1,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[StatusItemT2,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[StatusItemT3,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[StatusItemT4,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[StatusItemT5,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[StatusItemT6,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[StatusItemT7,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[StatusItemT8,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[FertilizerItemBox,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[FertT1,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[FertT2,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[FertT3,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[FertT4,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[FertT5,1]
	SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings]:Set[FertT7,1]
}

function ShutDown()
{
	press ESC
	press ESC
	press ESC
	call AddLog "**Ending EQ2Broker**" FF00FF00
	announce "\Broker Items Placed" 1 2

	if ${UIElement[RunMyPrices@EQ2Broker@GUITabs@EQ2Inventory].Checked}
	{
		call AddLog "*****Starting MyPrices*****" FFEECC00
		wait 5
		run myprices/myprices.iss
		Wait 125

		UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[Start Scanning]:LeftClick
	}
	call SaveSettings

}

function SaveSettings()
{
	SettingXML["./EQ2Inventory/ScriptConfig/CustomItems.xml"]:Save
	SettingXML["./EQ2Inventory/ScriptConfig/CustomItems.xml"]:Unload
	SettingXML["./EQ2Inventory/ScriptConfig/Destroy.xml"]:Save
	SettingXML["./EQ2Inventory/ScriptConfig/Destroy.xml"]:Unload
	SettingXML["./EQ2Inventory/ScriptConfig/Fertilizer.xml"]:Save
	SettingXML["./EQ2Inventory/ScriptConfig/Fertilizer.xml"]:Unload
	SettingXML["./EQ2Inventory/ScriptConfig/Harvests.xml"]:Save
	SettingXML["./EQ2Inventory/ScriptConfig/Harvests.xml"]:Unload
	SettingXML["./EQ2Inventory/ScriptConfig/Junk.xml"]:Save
	SettingXML["./EQ2Inventory/ScriptConfig/Junk.xml"]:Unload
	SettingXML["./EQ2Inventory/ScriptConfig/StatusItems.XML"]:Save
	SettingXML["./EQ2Inventory/ScriptConfig/StatusItems.XML"]:Unload
	SettingXML["./EQ2Inventory/ScriptConfig/DeleteMeats.xml"]:Save
	SettingXML["./EQ2Inventory/ScriptConfig/DeleteMeats.xml"]:Unload
	SettingXML["./EQ2Inventory/CharConfig/${Me.Name}.xml"]:Save
	SettingXML["./EQ2Inventory/CharConfig/${Me.Name}.xml"]:Unload
}

function atexit()
{
	ui -unload "${LavishScript.HomeDirectory}/Scripts/EQ2Inventory/UI/EQ2InventoryUI.xml"
}