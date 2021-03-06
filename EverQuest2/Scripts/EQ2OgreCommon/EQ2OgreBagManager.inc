#ifndef _OBJECT_EQ2OGREBAGMANAGER_
#define _OBJECT_EQ2OGREBAGMANAGER_

/**
OgreBags Version 1.01 - Kannkor

Usage:
#include ../EQ2ogrecommon/OgreBags.inc
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
	variable string BagInformation[7,3]
	;First number is the bag #
	;Second number (1), is the ContainerID
	;Second number (2), is the ID
	;Second number (3), is the Name.
	variable int BagContents[7,100]
	variable int BagSize[7]
	variable int BagInfoCounter2
	variable index:item Items
	variable iterator ItemIterator

	method Initialize()
	{
		This:UpdateInfo
	}
	method UpdateInfo()
	{
		This:ClearInformation
		Me:QueryInventory[Items, Location == "Inventory"]
		Items:GetIterator[ItemIterator]

		;Create the bag listing

		if ${ItemIterator:First(exists)}
		{
			do
			{
				if ${ItemIterator.Value.IsInventoryContainer}
				{
					;// echo Slot: ${Math.Calc64[${ItemIterator.Value.Slot}+1]}: ${ItemIterator.Value.Name} ${ItemIterator.Value.ID} ${ItemIterator.Value.EmptySlots}
					BagInformation[${Math.Calc[${ItemIterator.Value.Slot}+1]},1]:Set[${ItemIterator.Value.ContainerID}]
					BagInformation[${Math.Calc[${ItemIterator.Value.Slot}+1]},2]:Set[${ItemIterator.Value.ID}]
					BagInformation[${Math.Calc[${ItemIterator.Value.Slot}+1]},3]:Set[${ItemIterator.Value.Name}]
				}
				else
				{
					continue
					;// This previously was used to determine your ammo slot type. Instead, just using Equipment[ammo]
					;// Finding the quiver
					if ${ItemIterator.Value.Type.NotEqual[container]}
						continue
					if ${ItemIterator.Value.NumSlots} <= 0
						continue
					if ${ItemIterator.Value.IsSharedBankContainer}
						continue
					if !${ItemIterator.Value.IsContainer}
						continue
					if ${ItemIterator.Value.InInventory}
						continue
					if ${ItemIterator.Value.InInventorySlot}
						continue
					if ${ItemIterator.Value.InBank}
						continue
					if ${ItemIterator.Value.InContainer}
						continue
					;// echo Ranged slot iteM? ${ItemIterator.Value.Name} - ID: ${ItemIterator.Value.ID}
					BagInformation[7,1]:Set[${ItemIterator.Value.ContainerID}]
					BagInformation[7,2]:Set[${ItemIterator.Value.ID}]
					BagInformation[7,3]:Set[${ItemIterator.Value.Name}]
				}
			}
			while ${ItemIterator:Next(exists)}
		}
		BagInformation[7,1]:Set[${Me.Equipment[ammo].ContainerID}]
		BagInformation[7,2]:Set[${Me.Equipment[ammo].ID}]
		BagInformation[7,3]:Set[${Me.Equipment[ammo].Name}]
		
		;// Now that we have the bag listing, create a list of each box contents
		if ${ItemIterator:First(exists)}
		{
			do
			{
				BagInfoCounter2:Set[0]
				while ${BagInfoCounter2:Inc}<=7
				{
					if ${BagInformation[${BagInfoCounter2},1]}==${ItemIterator.Value.InContainerID}
					{
						;echo ${ItemIterator.Value} ID: ${ItemIterator.Value.ID}
						BagContents[${BagInfoCounter2},${BagSize[${BagInfoCounter2}]:Inc}]:Set[${ItemIterator.Value.ID}]
						;echo BagSize: ${BagSize[${BagInfoCounter2}]}					
						break
					}
				}
			}
			while ${ItemIterator:Next(exists)}
		}
	}
	member:string GetIDOfItemIn(int _Bag=1, int _Slot=0)
	{
		_Slot:Dec
		Me:QueryInventory[Items, Location == "Inventory"]
		Items:GetIterator[ItemIterator]

		if ${ItemIterator:First(exists)}
		{
			do
			{
				if ${ItemIterator.Value.InContainerID} != ${This.BagInformation[${_Bag},1]}
					continue
				if ${ItemIterator.Value.Slot} != ${_Slot}
					continue
				return ${ItemIterator.Value.ID}
			}
			while ${ItemIterator:Next(exists)}
		}
		return 0
	}
	method ClearInformation()
	{
		BagInfoCounter:Set[0]
		while ${BagInfoCounter:Inc}<=7
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
			echo WhichBag: ${WhichBag} BagInfoCounter: ${BagInfoCounter} ID: ${BagContents[${WhichBag},${BagInfoCounter}]} -- Name: ${Me.Inventory[id,${BagContents[${WhichBag},${BagInfoCounter}]}]}
		}
	}
	method ListBags()
	{
		BagInfoCounter:Set[0]
		while ${BagInfoCounter:Inc}<=7
		{
			echo Bag #${BagInfoCounter}: ContainerID: ${BagInformation[${BagInfoCounter},1]} || Inventory ID: ${BagInformation[${BagInfoCounter},2]} ( ${Me.Inventory[id,${BagInformation[${BagInfoCounter},2]}]} )
		}
	}
	;// member:string 
}


/*
atom atexit()
{
	echo Ogre Bag Information session completed.
}
*/

#endif