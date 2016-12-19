/**
OgreBags Version 1.00 - Kannkor

Usage:
#include ../EQ2OgreFree/OgreBags.inc
Bag information is created when the script is initially run. To update the array, you need to use:
OgreBagInfoOb:UpdateInfo
Following methods are also available:
OgreBagInfoOb:UpdateInfo - Updates the array with current bag information
OgreBagInfoOb:ListBags - lists the bags in the console
OgreBagInfoOb:ListBagContents[#] - # is the bag # (1-6) and lists the contents in the console

Bag information available:
${OgreBagInfoOb.BagContents[a,b]} - a is the bag # (1-6), b is the # of the content (1-items)
${OgreBagInfoOb.BagSize[#]} - # is the bag # (1-6). This returns how many items in the bag, not the size of the container. For example, if you have a 20 slot container, but only 2 items in it, this would return 2


Special thanks to Nuprecon for the initial code and logic.
**/


variable OgreBagInfoObject OgreBagInfoOb

objectdef OgreBagInfoObject
{
	variable string BagInformation[6,2]
	;First number is the bag #
	;Second number (1), is the ContainerID
	;Second number (2), is the ID

	variable int BagContents[6,100]
	variable int BagSize[6]
	variable int BagInfoCounter
	variable int BagInfoCounter2

	method Initialize()
	{
		;Me:CreateCustomInventoryArray[nonbankonly]
		This:UpdateInfo
	}
	method UpdateInfo()
	{
		This:ClearInformation
		Me:CreateCustomInventoryArray[nonbankonly]

		;Create the bag listing
		BagInfoCounter:Set[0]
		while ${BagInfoCounter:Inc}<=${Me.CustomInventoryArraySize}
		{
			if ${Me.CustomInventory[${BagInfoCounter}].IsInventoryContainer}
			{
				BagInformation[${Math.Calc[${Me.CustomInventory[${BagInfoCounter}].Slot}+1]},1]:Set[${Me.CustomInventory[${BagInfoCounter}].ContainerID}]
				BagInformation[${Math.Calc[${Me.CustomInventory[${BagInfoCounter}].Slot}+1]},2]:Set[${Me.CustomInventory[${BagInfoCounter}].ID}]
			}
		}
		
		;Now that we have the bag listing, create a list of each box contents
		BagInfoCounter:Set[0]
		while ${BagInfoCounter:Inc}<=${Me.CustomInventoryArraySize}
		{
			BagInfoCounter2:Set[0]
			while ${BagInfoCounter2:Inc}<=6
			{
				if ${BagInformation[${BagInfoCounter2},1]}==${Me.CustomInventory[${BagInfoCounter}].InContainerID}
				{
					;echo ${Me.CustomInventory[${BagInfoCounter}]} ID: ${Me.CustomInventory[${BagInfoCounter}].ID}
					BagContents[${BagInfoCounter2},${BagSize[${BagInfoCounter2}]:Inc}]:Set[${Me.CustomInventory[${BagInfoCounter}].ID}]
					;echo BagSize: ${BagSize[${BagInfoCounter2}]}					
					break
				}
			}
		}
	}
	method ClearInformation()
	{
		BagInfoCounter:Set[0]
		while ${BagInfoCounter:Inc}<=6
		{
			BagInformation[${BagInfoCounter},1]:Set[0]
			BagSize[${BagInfoCounter}]:Set[0]
		}
	}
	method ListBagContents(int WhichBag=1)
	{
		BagInfoCounter:Set[0]
		while ${BagInfoCounter:Inc}<=${BagSize[${WhichBag}]}
		{
			echo ID: ${BagContents[${WhichBag},${BagInfoCounter}]} -- Name: ${Me.Inventory[id,${BagContents[${WhichBag},${BagInfoCounter}]}]}
		}
	}
	method ListBags()
	{
		BagInfoCounter:Set[0]
		while ${BagInfoCounter:Inc}<=6
		{
			echo Bag #${BagInfoCounter}: ContainerID: ${BagInformation[${BagInfoCounter},1]} || Inventory ID: ${BagInformation[${BagInfoCounter},2]} ( ${Me.Inventory[id,${BagInformation[${BagInfoCounter},2]}]} )
		}
	}
	;member:string 
}


atom atexit()
{
	echo Ogre Bag Information session completed.
}