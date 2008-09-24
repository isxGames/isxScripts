;EQ2Broker v2  
;By Syliac

function main()
{
	declare FP filepath "${LavishScript.HomeDirectory}/Scripts/EQ2Inventory/CharConfig/"
   
  if ${FP.FileExists[${Me.Name}.xml]}
  {
		ui -reload "${LavishScript.HomeDirectory}/Interface/eq2skin.xml"
		ui -reload -skin eq2skin "${LavishScript.HomeDirectory}/Scripts/EQ2Inventory/UI/EQ2InventoryUI.xml"	
	}
	else
	{
		call makefile
		wait 5
		ui -reload "${LavishScript.HomeDirectory}/Interface/eq2skin.xml"
		ui -reload -skin eq2skin "${LavishScript.HomeDirectory}/Scripts/EQ2Inventory/UI/EQ2InventoryUI.xml"
	}


  while 1
  {
    while ${QueuedCommands}
      ExecuteQueued
      
    waitframe 
  }
} 

function placeitems()
{
	variable int tempvar=1
	wait 5
	UIElement[ItemList@EQ2Broker@GUITabs@EQ2Inventory]:ClearItems
	call AddLog "**Starting EQ2Broker v2 By Syliac**" FF00FF00
	Actor[nokillnpc]:DoTarget
	wait 5
	Target:DoFace
	wait 5
	Target:DoubleClick
	wait 5
	press b
	wait 5
	press b
		
	call CheckFocus	
	
	if ${UIElement[ScanRares@EQ2Broker@GUITabs@EQ2Inventory].Checked}
		call placerare
			
	if ${UIElement[ScanHarvests@EQ2Broker@GUITabs@EQ2Inventory].Checked}	
		call placeharvest
		
	if ${UIElement[ScanCollections@EQ2Broker@GUITabs@EQ2Inventory].Checked}	
		{
			call AddLog "**Checking Collections List 1000+ Items**"	FFFF00FF
			call placecollection
		}	
		
	if ${UIElement[ScanCollections@EQ2Broker@GUITabs@EQ2Inventory].Checked}	
		call placecollection	
		
	if ${UIElement[ScanTradeskills@EQ2Broker@GUITabs@EQ2Inventory].Checked}
		{
			call AddLog "**Checking Tradeskill Books List 510 Items**" FFFF00FF	
			call placecraftbooks
		}	
	
	if ${UIElement[ScanTradeskills@EQ2Broker@GUITabs@EQ2Inventory].Checked}
		call placecraftbooks	
		
	if ${UIElement[ScanSpellBooks@EQ2Broker@GUITabs@EQ2Inventory].Checked}
		{
			call AddLog "**Checking Spell Books List 3500+ Items**" FFFF00FF
			call placespellbooks
		}	
	
	if ${UIElement[ScanSpellBooks@EQ2Broker@GUITabs@EQ2Inventory].Checked}
		call placespellbooks	
		
	if ${UIElement[ScanStatus@EQ2Broker@GUITabs@EQ2Inventory].Checked}
		call placestatusitems
		
	if ${UIElement[ScanFertilizer@EQ2Broker@GUITabs@EQ2Inventory].Checked}	
		call placefertilizer
		
	if ${UIElement[ScanCustom@EQ2Broker@GUITabs@EQ2Inventory].Checked}	
		call placecustom
		
		call ShutDown
}


function placerare()
{
	call AddLog "**Checking Rares List**" FFFF00FF
	
	call placeraret1
	call placeraret2
	call placeraret3
	call placeraret4
	call placeraret5
	call placeraret6
	call placeraret7
	call placeraret8
	
}

function placeraret1()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[RHarvestT1@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[2].Keys}
	}
}	
function placeraret2()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[RHarvestT2@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[4].Keys}
	}
}
function placeraret3()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[RHarvestT3@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[6].Keys}
	}
}	
function placeraret4()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[RHarvestT4@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[8].Keys}
	}
}	
function placeraret5()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[RHarvestT5@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[10].Keys}
	}
}	
function placeraret6()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[RHarvestT6@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[12].Keys}
	}
}	
function placeraret7()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[RHarvestT7@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[14].Keys}
	}
}	
function placeraret8()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[RHarvestT8@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[RHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[16].Keys}
	}
}
function placeharvest()
{
	call CheckFocus
 	call AddLog "**Checking Harvests List**" FFFF00FF
	
	if ${UIElement[DeleteMeat@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
		call deletemeat
	
	call placeharvestt1
	call placeharvestt2
	call placeharvestt3
	call placeharvestt4
	call placeharvestt5
	call placeharvestt6
	call placeharvestt7
	call placeharvestt8	
}

function placeharvestt1()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[CHarvestT1@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[1].Keys}
	}
}	
function placeharvestt2()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[CHarvestT2@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[3].Keys}
	}
}
function placeharvestt3()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[CHarvestT3@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[5].Keys}
	}
}	
function placeharvestt4()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[CHarvestT4@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[7].Keys}
	}
}	
function placeharvestt5()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[CHarvestT5@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[9].Keys}
	}
}	
function placeharvestt6()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[CHarvestT6@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[11].Keys}
	}
}	
function placeharvestt7()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[CHarvestT7@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[13].Keys}
	}
}	
function placeharvestt8()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[CHarvestT8@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CHarvestBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Harvests.xml].Set[15].Keys}
	}
}	


function placecollection()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
	wait 25
  
	if ${UIElement[Collections@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		if ${Math.Calc[${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CollectionsBox]}].TotalCapacity}-${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CollectionsBox]}].UsedCapacity}]} > 0	
		{
			Do
			{	
				Do
				{	 
					if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Collections.xml].Set[Collection].Key[${tempvar}]}].Quantity} > 0
	  			{	
	  				call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Collections.xml].Set[Collection].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Collections.xml].Set[Collection].Key[${tempvar}]} to Broker" FF11CCFF
	  				Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Collections.xml].Set[Collection].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Collections.xml].Set[Collection].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CollectionsBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CollectionsBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Collections.xml].Set[Collection].Key[${tempvar}]}].SerialNumber}]
	  				wait ${Math.Rand[30]:Inc[20]}		
					}
	  		}		
				while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Collections.xml].Set[Collection].Key[${tempvar}]}](exists)}
				call CheckFocus
			}
			while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Collections.xml].Set[Collection].Keys}
		}
	}
}

function placecraftbooks()
{
  call CheckFocus
   
  call placealchemist
  call placearmorer
  call placecarpenter
  call placejeweler
  call placesage
  call placetailor
  call placeweaponsmith
  call placewoodworker
  call placecraftsman
  call placeoutfitter
  call placescholar
}
function placealchemist()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	  
	if ${UIElement[Alchemist@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 			
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Alchemist].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Alchemist].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Alchemist].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Alchemist].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Alchemist].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Alchemist].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Alchemist].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Alchemist].Keys}
	}	
}
function placearmorer()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]		
	if ${UIElement[Armorer@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 			
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Armorer].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Armorer].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Armorer].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Armorer].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Armorer].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Armorer].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Armorer].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Armorer].Keys}
	}	
}
function placecarpenter()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]		
	if ${UIElement[Carpenter@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 			
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Carpenter].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Carpenter].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Carpenter].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Carpenter].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Carpenter].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Carpenter].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Carpenter].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Carpenter].Keys}
	}	
}
function placejeweler()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]		
	if ${UIElement[Jeweler@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 			
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Jeweler].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Jeweler].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Jeweler].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Jeweler].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Jeweler].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Jeweler].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Jeweler].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Jeweler].Keys}
	}	
}
function placesage()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Sage@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 			
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Sage].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Sage].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Sage].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Sage].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Sage].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Sage].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Sage].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Sage].Keys}
	}	
}
function placetailor()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Tailor@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 			
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Tailor].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Tailor].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Tailor].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Tailor].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Tailor].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Tailor].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Tailor].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Tailor].Keys}
	}	
}
function placeweaponsmith()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
  if ${UIElement[Weaponsmith@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 			
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Weaponsmith].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Weaponsmith].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Weaponsmith].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Weaponsmith].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Weaponsmith].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Weaponsmith].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Weaponsmith].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Weaponsmith].Keys}
	}	
}	
function placewoodworker()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Woodworker@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 			
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Woodworker].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Woodworker].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Woodworker].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Woodworker].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Woodworker].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Woodworker].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Woodworker].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Woodworker].Keys}
	}	
}	
function placecraftsman()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Craftsman@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Craftsman].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Craftsman].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Craftsman].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Craftsman].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Craftsman].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Craftsman].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Craftsman].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Craftsman].Keys}
	}
}		
function placeoutfitter()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Outfitter@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 			
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Outfitter].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Outfitter].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Outfitter].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Outfitter].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Outfitter].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Outfitter].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Outfitter].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Outfitter].Keys}
	}	
}
function placescholar()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Scholar@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 			
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Scholar].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Scholar].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Scholar].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Scholar].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Scholar].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CraftBoxNumber]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Scholar].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Scholar].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Tradeskills.xml].Set[Scholar].Keys}
	}
}


function placespellbooks()
{
  call CheckFocus
	call placeassassin
	call placeberserker
	call placebrigand
	call placebruiser
	call placecoercer
	call placeconjuror
	call placedefiler
	call placedirge
	call placefury
	call placeguardian
	call placeillusionist
	call placeinquisitor
	call placemonk
	call placemystic
	call placenecromancer
	call placepaladin
	call placeranger
	call placeshadowknight
	call placeswashbuckler
	call placetemplar
	call placetroubador
	call placewarden
	call placewarlock
	call placewizard

}
function placeassassin()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Assassin@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 			
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Assassin].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Assassin].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Assassin].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Assassin].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Assassin].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Assassin].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Assassin].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Assassin].Keys}
	}
}		
function placeberserker()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
	if ${UIElement[Berserker@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 			
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Berserker].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Berserker].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Berserker].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Berserker].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Berserker].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Berserker].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Berserker].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Berserker].Keys}
	}	
}

function placebrigand()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
	if ${UIElement[Brigand@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Brigand].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Brigand].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Brigand].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Brigand].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Brigand].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Brigand].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Brigand].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Brigand].Keys}
	}	
}

function placebruiser()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Bruiser@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Bruiser].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Bruiser].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Bruiser].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Bruiser].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Bruiser].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Bruiser].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Bruiser].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Bruiser].Keys}
	}	
}

function placecoercer()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Coercer@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Coercer].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Coercer].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Coercer].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Coercer].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Coercer].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Coercer].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Coercer].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Coercer].Keys}
	}	
}

function placeconjuror()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Conjuror@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Conjuror].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Conjuror].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Conjuror].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Conjuror].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Conjuror].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Conjuror].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Conjuror].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Conjuror].Keys}
	}	
}

function placedefiler()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Defiler@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Defiler].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Defiler].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Defiler].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Defiler].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Defiler].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Defiler].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Defiler].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Defiler].Keys}
	}	
}

function placedirge()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Dirge@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Dirge].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Dirge].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Dirge].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Dirge].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Dirge].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Dirge].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Dirge].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Dirge].Keys}
	}	
}

function placefury()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Fury@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 			
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Fury].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Fury].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Fury].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Fury].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Fury].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Fury].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Fury].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Fury].Keys}
	}	
}

function placeguardian()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
	if ${UIElement[Guardian@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Guardian].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Guardian].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Guardian].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Guardian].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Guardian].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Guardian].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Guardian].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Guardian].Keys}
	}	
}

function placeillusionist()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Illusionist@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Illusionist].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Illusionist].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Illusionist].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Illusionist].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Illusionist].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Illusionist].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Illusionist].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Illusionist].Keys}
	}	
}

function placeinquisitor()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Inquisitor@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Inquisitor].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Inquisitor].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Inquisitor].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Inquisitor].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Inquisitor].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Inquisitor].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Inquisitor].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Inquisitor].Keys}
	}	
}

function placemonk()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
	if ${UIElement[Monk@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Monk].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Monk].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Monk].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Monk].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Monk].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Monk].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Monk].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Monk].Keys}
	}	
}

function placemystic()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]

	if ${UIElement[Mystic@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Mystic].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Mystic].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Mystic].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Mystic].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Mystic].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Mystic].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Mystic].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Mystic].Keys}
	}	
}

function placenecromancer()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]		
	if ${UIElement[Necromancer@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Me:CreateCustomInventoryArray[nonbankonly]
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Necromancer].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Necromancer].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Necromancer].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Necromancer].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Necromancer].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Necromancer].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Necromancer].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Necromancer].Keys}
	}	
}

function placepaladin()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Paladin@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 			
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Paladin].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Paladin].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Paladin].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Paladin].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Paladin].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Paladin].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Paladin].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Paladin].Keys}
	}	
}

function placeranger()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Ranger@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Ranger].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Ranger].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Ranger].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Ranger].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Ranger].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Ranger].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Ranger].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Ranger].Keys}
	}	
}

function placeshadowknight()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
	if ${UIElement[Shadowknight@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Shadowknight].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Shadowknight].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Shadowknight].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Shadowknight].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Shadowknight].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Shadowknight].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Shadowknight].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Shadowknight].Keys}
	}	
}

function placeswashbuckler()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Swashbuckler@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Swashbuckler].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Swashbuckler].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Swashbuckler].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Swashbuckler].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Swashbuckler].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Swashbuckler].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Swashbuckler].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Swashbuckler].Keys}
	}	
}

function placetemplar()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Templar@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Templar].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Templar].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Templar].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Templar].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Templar].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Templar].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Templar].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Templar].Keys}
	}	
}

function placetroubador()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Troubador@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Troubador].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Troubador].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Troubador].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Troubador].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Troubador].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Troubador].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Troubador].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Troubador].Keys}
	}	
}

function placewarden()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Warden@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warden].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warden].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warden].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warden].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warden].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warden].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warden].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warden].Keys}
	}	
}

function placewarlock()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Warlock@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 				
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warlock].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warlock].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warlock].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warlock].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warlock].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warlock].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warlock].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Warlock].Keys}
	}	
}

function placewizard()
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]	
	if ${UIElement[Wizard@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 
				if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Wizard].Key[${tempvar}]}].Quantity} > 0
	  		{	
	  			call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Wizard].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Wizard].Key[${tempvar}]} to Broker" FF11CCFF
	  			Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Wizard].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Wizard].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[ClassSpellBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Wizard].Key[${tempvar}]}].SerialNumber}]
	  			wait ${Math.Rand[30]:Inc[20]}		
	  		}	
			}
			while ${Me.Vending[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Wizard].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/SpellList.xml].Set[Wizard].Keys}
	}
}

function placestatusitems()
{
	call CheckFocus
	call AddLog "**Checking Status Items List**" FFFF00FF
	call placestatust1
	call placestatust2
	call placestatust3
	call placestatust4
	call placestatust5
	call placestatust6
	call placestatust7
	call placestatust8
}


function placestatust1()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[StatusItemT1@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT1].Keys}
	}
}	
function placestatust2()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[StatusItemT2@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT2].Keys}
	}
}
function placestatust3()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[StatusItemT3@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT3].Keys}
	}
}	
function placestatust4()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[StatusItemT4@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT4].Keys}
	}
}	
function placestatust5()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[StatusItemT5@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT5].Keys}
	}
}	
function placestatust6()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[StatusItemT6@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT6].Keys}
	}
}	
function placestatust7()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[StatusItemT7@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT7].Keys}
	}
}	
function placestatust8()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[StatusItemT8@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[StatusItemBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.XML].Set[StatusT8].Keys}
	}
}
function placefertilizer()
{
	call CheckFocus
	call AddLog "**Checking Fertilizers List**" FFFF00FF
	call placefertilizert1
	call placefertilizert2
	call placefertilizert3
	call placefertilizert4
	call placefertilizert5
	call placefertilizert7
	
}


function placefertilizert1()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[FertT1@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[FertilizerItemBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[FertilizerItemBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT1].Keys}
	}
}	
function placefertilizert2()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[FertT2@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[FertilizerItemBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[FertilizerItemBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT2].Keys}
	}
}
function placefertilizert3()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[FertT3@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[FertilizerItemBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[FertilizerItemBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT3].Keys}
	}
}	
function placefertilizert4()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[FertT4@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[FertilizerItemBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[FertilizerItemBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT4].Keys}
	}
}	
function placefertilizert5()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[FertT5@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[FertilizerItemBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[FertilizerItemBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT5].Keys}
	}
}	
function placefertilizert7()	
{
	variable int tempvar=1
  call CheckFocus
  Me:CreateCustomInventoryArray[nonbankonly]
  
	if ${UIElement[FertT7@EQ2Broker Setup@GUITabs@EQ2Inventory].Checked}
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[FertilizerItemBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[FertilizerItemBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Fertilizer.xml].Set[FertT7].Keys}
	}
}	

function placecustom()	
{
	variable int tempvar=1
  call CheckFocus
  call AddLog "**Checking Custom Items List**" FFFF00FF
  Me:CreateCustomInventoryArray[nonbankonly]
  
	{
		Do
		{	
			Do
			{	 	
		  	if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${tempvar}]}].Quantity} > 0
		  	{
		 	  	call AddLog "Adding ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${tempvar}]}].Quantity} ${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${tempvar}]} to Broker" FF11CCFF
		 	  	Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${tempvar}]}]:AddToConsignment[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${tempvar}]}].Quantity},${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CustomItemsBox]},${Me.Vending[${SettingXML[Scripts/EQ2Inventory/CharConfig/${Me.Name}.xml].Set[General Settings].GetString[CustomItemsBox]}].Consignment[${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${tempvar}]}].SerialNumber}]
  		  	wait ${Math.Rand[30]:Inc[20]}	
	  		}
			}
			while ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${tempvar}]}](exists)}
			call CheckFocus
		}
		while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Keys}
	}
}
	
function destroyitems()
{
	variable int tempvar=1
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
			if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Key[${tempvar}]}].Quantity} > 0 
	  	{
	  		call AddSellLog "Destroying  ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Key[${tempvar}]}].Quantity}  ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Key[${tempvar}]}]}" FFFF0000
	  		Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Key[${tempvar}]}]:Destroy[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Key[${tempvar}]}].Quantity}]
				wait ${Math.Rand[30]:Inc[20]}
			}
		}	
		while ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Key[${tempvar}]}](exists)}
	}
	while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Keys}
	call AddSellLog "**Items Destroyed**" FFFF00FF
	announce "\You have Destroyed Items" 1 2
	
}

function vendortype()
{
	if ${UIElement[StatusMerchant@EQ2Junk@GUITabs@EQ2Inventory].Checked}
	{
		call sellstatus
	}	
	else
	{
		call selljunk
	}		
	
}

function selljunk()
{
	variable int tempvar=1
	UIElement[SellItemList@EQ2Junk@GUITabs@EQ2Inventory]:ClearItems
	call AddSellLog "**Starting EQ2Junk v2 By Syliac**" FF00FF00		
	Actor[nokillnpc]:DoTarget
	wait 5
	Target:DoFace
	wait 5
	Target:DoubleClick
	wait 5
	press b
	wait 5
	press b	
	Me:CreateCustomInventoryArray[nonbankonly]
	wait 10
	call AddSellLog "**Selling Junk Items**" FFFF00FF
	Do
	{	
		Do
		{	
			if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Key[${tempvar}]}].Quantity} > 0
	  	{
	  		call AddSellLog "Selling ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Key[${tempvar}]}].Quantity}  ${Me.Merchandise[${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Key[${tempvar}]}]}" FF11CCFF
	  		Me.Merchandise[${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Key[${tempvar}]}]:Sell[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Key[${tempvar}]}].Quantity}]
				wait ${Math.Rand[30]:Inc[20]}
			}
		}	
		while ${Me.Merchandise[${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Key[${tempvar}]}](exists)}
	}
	while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Keys}
	call AddSellLog "**Junk Items Sold**" FFFF00FF
	press ESC
	press ESC
	press ESC
}

function sellstatus()
{
	variable int tempvar=1
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
	call AddSellLog "**Selling Status Items**" FFFF00FF
	Do
	{	
		Do
		{	
			if ${Me.CustomInventory[ExactName,${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.xml].Set[StatusMerchant].Key[${tempvar}]}].Quantity} > 0
	  	{
	  		call AddSellLog "Selling ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.xml].Set[StatusMerchant].Key[${tempvar}]}].Quantity}  ${Me.Merchandise[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.xml].Set[StatusMerchant].Key[${tempvar}]}]}" FF11CCFF
	  		Me.Merchandise[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.xml].Set[StatusMerchant].Key[${tempvar}]}]:Sell[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.xml].Set[StatusMerchant].Key[${tempvar}]}].Quantity}]
				wait ${Math.Rand[30]:Inc[20]}
			}
		}	
		while ${Me.Merchandise[${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.xml].Set[StatusMerchant].Key[${tempvar}]}](exists)}
	}
	while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/StatusItems.xml].Set[StatusMerchant].Keys}
	
	call AddSellLog "**Status Items Sold**" FFFF00FF
	
	press ESC
	press ESC
	press ESC
}
		
function junklist()
{
	variable int tempvar=1
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory]:ClearItems
	wait 5
	call AddRemoveList "*******Vendor Junk List*******" FFFF00FF
	Do
	{	
	  	call AddRemoveList "${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Key[${tempvar}]}"					
	}
	while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk].Keys}
}

function destroylist()
{
	variable int tempvar=1
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory]:ClearItems
	wait 5
	call AddRemoveList "*******Destroy Item List*******" FFFF00FF
	Do
	{	
	  	call AddRemoveList "${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Key[${tempvar}]}"			
	}
	while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy].Keys}
}

function customlist()
{
	variable int tempvar=1
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory]:ClearItems
	wait 5
	call AddRemoveList "*******Custom Item List*******" FFFF00FF
	Do
	{	
	  	call AddRemoveList "${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Key[${tempvar}]}"			
	}
	while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems].Keys}
}

function deletemeat()
{
	variable int tempvar=1
	call AddLog "**Deleting Meats**" FFFF0000	
	
	Me:CreateCustomInventoryArray[nonbankonly]

	Do
	{	
		Do
		{	
			if ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/DeleteMeats.xml].Set[Meats].Key[${tempvar}]}].Quantity} > 0 
	  	{
	  		call AddLog "Deleting  ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/DeleteMeats.xml].Set[Meats].Key[${tempvar}]}].Quantity}  ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/DeleteMeats.xml].Set[Meats].Key[${tempvar}]}]}" FFFF0000
	  		Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/DeleteMeats.xml].Set[Meats].Key[${tempvar}]}]:Destroy[${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/DeleteMeats.xml].Set[Meats].Key[${tempvar}]}].Quantity}]
				wait 15
			}
		}	
		while ${Me.CustomInventory[${SettingXML[./EQ2Inventory/ScriptConfig/DeleteMeats.xml].Set[Meats].Key[${tempvar}]}](exists)}
	}
	while ${tempvar:Inc} <= ${SettingXML[./EQ2Inventory/ScriptConfig/DeleteMeats.xml].Set[Meats].Keys}	
}

function addcollection(string brokeritem)
{
	SettingXML[./EQ2Inventory/ScriptConfig/Collections.xml].Set[Collection]:Set[${UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem},Sell]
	wait 5
	SettingXML[./EQ2Inventory/ScriptConfig/Collections.xml]:Save
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FF00FF00]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function addjunk()
{
	SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk]:Set[${UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem},Sell]
	wait 5
	SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml]:Save
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FF00FF00]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function adddestroy()
{
	SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy]:Set[${UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem},Sell]
	wait 5
	SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml]:Save
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FF00FF00]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function addcustom()
{
	SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems]:Set[${UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem},Sell]
	wait 5
	SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml]:Save
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FF00FF00]
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function removejunk()
{
	SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml].Set[Junk]:UnSet[${UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem}]
	wait 5
	SettingXML[./EQ2Inventory/ScriptConfig/Junk.xml]:Save
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FFFF0000]
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}
function removedestroy()
{
	SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml].Set[Destroy]:UnSet[${UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem}]
	wait 5
	SettingXML[./EQ2Inventory/ScriptConfig/Destroy.xml]:Save
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FFFF0000]
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function removecustom()
{
	SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml].Set[CustomItems]:UnSet[${UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem}]
	wait 5
	SettingXML[./EQ2Inventory/ScriptConfig/CustomItems.xml]:Save
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:SetTextColor[FFFF0000]
	UIElement[RemoveItemList@Remove Items@GUITabs@EQ2Inventory].SelectedItem:Deselect
}

function invlist()
{
	call createinventorylist
	call createinventorylist
	call createinventorylist
	call createinventorylist
	call createinventorylist
	call createinventorylist
}

function createinventorylist()
{
	variable int ArrayPosition=1
	UIElement[AddItemList@Add Items@GUITabs@EQ2Inventory]:ClearItems
	Me:CreateCustomInventoryArray[nonbankonly]
	call AddInvList "**Creating Inventory List ${Me.CustomInventoryArraySize} Items**" FFFF00FF
	
	
	
	Do
	{		
	  	call AddInvList "${Me.CustomInventory[${ArrayPosition}].Name}"
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

function echolog(string logline)
{
		Redirect -append "${LavishScript.HomeDirectory}/Scripts/EQ2Inventory/EQ2Inventory.log" Echo "${logline}"
}

function makefile()
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
		run myprices.iss
		Wait 125
		
		UIElement[MyPrices].FindChild[GUITabs].FindChild[Sell].FindChild[Start Scanning]:LeftClick
	}
	call savesettings
		 
}

function savesettings()
{
	SettingXML["./EQ2Inventory/ScriptConfig/Collections.xml"]:Save
	SettingXML["./EQ2Inventory/ScriptConfig/Collections.xml"]:Unload
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
	SettingXML["./EQ2Inventory/ScriptConfig/SpellList.xml"]:Save
	SettingXML["./EQ2Inventory/ScriptConfig/SpellList.xml"]:Unload
	SettingXML["./EQ2Inventory/ScriptConfig/StatusItems.XML"]:Save
	SettingXML["./EQ2Inventory/ScriptConfig/StatusItems.XML"]:Unload
	SettingXML["./EQ2Inventory/ScriptConfig/Tradeskills.xml"]:Save
	SettingXML["./EQ2Inventory/ScriptConfig/Tradeskills.xml"]:Unload
	SettingXML["./EQ2Inventory/ScriptConfig/DeleteMeats.xml"]:Save
	SettingXML["./EQ2Inventory/ScriptConfig/DeleteMeats.xml"]:Unload
	SettingXML["./EQ2Inventory/CharConfig/${Me.Name}.xml"]:Save
	SettingXML["./EQ2Inventory/CharConfig/${Me.Name}.xml"]:Unload
}

function atexit()
{
	ui -unload "${LavishScript.HomeDirectory}/Scripts/EQ2Inventory/UI/EQ2InventoryUI.xml"
}