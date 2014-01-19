/* Craft supplies, Inventory management, Fuel Calculations, etc */

/* Open up all the loot packs in preparation to selling */
function openLootPacks()
{
	variable int iCount = 1

	call DebugOut "VGCraft:: openLootPacks called"

	do
	{
		if ( ${Me.Inventory[${iCount}].Name.Equal[Supply Pack]} || ${Me.Inventory[${iCount}].Name.Equal[Supply Pouch]} || ${Me.Inventory[${iCount}].Name.Equal[Supply Kit]} )
		{
			call DebugOut "VGCraft:: Opening: ${Me.Inventory[${iCount}].Name}"
			Me.Inventory[${iCount}]:Use
			wait 10
			call DoLoot
			wait 10
			iCount:Set[0]
		}
	}
	while ${iCount:Inc} <= ${Me.Inventory}

}

/* Sell all the items added to list from the UI */
function SellLoot()
{
	variable int iCount = 0
	variable iterator Iterator

	call DebugOut "VGCraft:: SellLoot called"

	;; All item types of Miscellaneous without a description are added to Selling List and sold
	iCount:Set[1]
	do
	{
		if ${Me.Inventory[${iCount}].Type.Equal[Miscellaneous]} && ${Me.Inventory[${iCount}].Description.Equal[""]}
		{
			if ${Me.Inventory[${iCount}].Flags.Find[Unique]}
				continue
			if ${Me.Inventory[${iCount}].Flags.Find[No Trade]}
				continue
			if ${Me.Inventory[${iCount}].Flags.Find[No Rent]}
				continue
			if ${Me.Inventory[${iCount}].Flags.Find[No Sell]}
				continue
			if ${Me.Inventory[${iCount}].Flags.Find[Quest]}
				continue
			
			AddSellItem "${Me.Inventory[${iCount}].Name}"
			BuildSellList
			UIElement[${Me.Inventory[${iCount}].Name}]:SetText[]
			call DebugOut "VG:Selling: ${Me.Inventory[${iCount}].Name}"
			Me.Inventory[${iCount}]:Sell[${Me.Inventory[${iCount}].Quantity}]
			wait 1
			iCount:Set[0]
		}
	}
	while (${iCount:Inc} <= ${Me.Inventory})
	
	setSaleItems:GetSettingIterator[Iterator]

	if ( !${Iterator:First(exists)} )
	{
		call DebugOut "VGCraft:: Nothing to sell"
		return
	}

	Iterator:First
	do
	{
		;call DebugOut "SellLoot: Testing ${Iterator.Value}"

		if ( ${woRecipeNeeds.Contains[${Iterator.Value}]} )
			continue

		while ( ${Me.Inventory[ExactName,${Iterator.Value}](exists)} )
		{
			iCount:Set[1]
			do
			{
				if ${Me.Inventory[${iCount}].Name.Equal[${Iterator.Value}]}
				{
					if ${Me.Inventory[${iCount}].Flags.Find[Unique]}
						continue
					if ${Me.Inventory[${iCount}].Flags.Find[No Trade]}
						continue
					if ${Me.Inventory[${iCount}].Flags.Find[No Rent]}
						continue
					if ${Me.Inventory[${iCount}].Flags.Find[No Sell]}
						continue
					if ${Me.Inventory[${iCount}].Flags.Find[Quest]}
						continue
						
					call DebugOut "VG:Selling: ${Iterator.Value}"
					Me.Inventory[${iCount}]:Sell[${Me.Inventory[${iCount}].Quantity}]
					wait 5
					iCount:Set[0]
				}
			}
			while (${iCount:Inc} <= ${Me.Inventory})
		}
	}
	while ${Iterator:Next(exists)}
	
	
}

/* Buy needed Supplies */
function BuySupplies()
{
	variable int lCount
	call DebugOut "VGCraft:: BuySupplies called"

	call AddExtraIngredients

	if ${woRecipeFuel.FirstKey(exists)}
	{
		do
		{
			call DebugOut "VG:Testing: ${woRecipeFuel.CurrentKey} :: ${woRecipeFuel.CurrentValue}"

			if ${woRecipeFuel.CurrentValue} > 0
			{
				lCount:Set[0]
				while ${lCount:Inc} <= ${Math.Calc[(${woRecipeFuel.CurrentValue}+50)/100].Round}
				{
					call DebugOut "VG:Buying: ${woRecipeFuel.CurrentKey}"
					Merchant.ForSaleItem[${woRecipeFuel.CurrentKey}]:Buy
					wait 5
					call MoveCraftSupplies
					wait 5

					; Just ran out of space!
					if ( ${Me.InventorySlotsOpen} < 2 )
					{
						call ErrorOut "VGCraft:: NOTICE: Out of pack space (${Me.InventorySlotsOpen})"
						call DebugOut "VGCraft:: NOTICE: Out of pack space (${Me.InventorySlotsOpen})"
						return
					}

				}
			}
		}
		while ${woRecipeFuel.NextKey(exists)}
	}
	wait 5

	; Move any extra stuff we may have into the Supply Pouch
	call CleanUpInventory

}

/* Add Extra Ingredients to the fuel requirements ... used to fix Complications */
function AddExtraIngredients()
{
	call DebugOut "VGCraft:: AddExtraIngredients called"

	variable int lCount=0
	variable int CurrentFuel
	variable iterator extraIter

	setExtraItems:GetSettingIterator[extraIter]

	extraIter:First
	while ${extraIter.IsValid}
	{
		; SupplyNeeded should add any required items to the list (after clearing the list)
		; So the list should not contain any Extra items when this is first called
		; If it's not on the list, then make sure we add it and have at least 100

		if !${woRecipeFuel.Element[${extraIter.Key}](exists)}
		{
			CurrentFuel:Set[0]
			lCount:Set[0]
			while ${Me.Inventory[${lCount:Inc}].Name(exists)}
			{
				if ${Me.Inventory[${lCount}].Name.Find[${extraIter.Key}]} && ${Me.Inventory[${lCount}].MiscDescription.Find[Small crafting utilities]}
				{
					; call DebugOut "VG:AE: ${Me.Inventory[${lCount}].Name} :: ${woRecipeFuel.Element[${extraIter.Key}]} :: ${Me.Inventory[${lCount}].Quantity}]}"
					CurrentFuel:Inc[${Math.Calc[${Me.Inventory[${lCount}].Quantity}]}]
				}
			}
		
			if ${CurrentFuel} < 100
			{
				woRecipeFuel:Set[${extraIter.Key},${Math.Calc[100 - ${CurrentFuel}]}]
				call DebugOut "VG:Fuel list adding: ${extraIter.Key} @ ${woRecipeFuel.Element[${extraIter.Key}]}"
			}
		}

		extraIter:Next	
	}
}

/* How much more do we need? */
function:bool SupplyNeeded(bool atStation)
{
	variable bool supplyNeeded=FALSE
	variable int supplyLineCount=7
	variable int amountNeeded
	variable bool fuelNeeded=TRUE
	variable string RecipeName
	
	woRecipeNeeds:Clear
	woRecipeFuel:Clear

	call DebugOut "VGCraft:: Called SupplyNeeded"

	; Check each unfinished Work Order -- find the Fuel requirements and increment
	; the recipe fuel that we need by one stack per uncompleted work order
	variable int woCount=0
	while (${woCount:Inc} <= ${TaskMaster[Crafting].CurrentWorkOrder})
	{
		;;;;;;;;;;;;
		;; Get True Recipe Name
		;;;;;;;;;;;;
		if !${Refining.Recipe["${TaskMaster[Crafting].CurrentWorkOrder[${woCount}]}"](exists)}
		{
			if (${TaskMaster[Crafting].CurrentWorkOrder[${woCount}].RequestedItems.Length} < 2)
			{
				TaskMaster[Crafting].CurrentWorkOrder[${woCount}]:GetRequestedItems
				wait 5
				Count:Set[0]
				do
				{
					waitframe
					Count:Inc
					if ${Count} > 5000
					{
						call MyOutput "VGCraft:: SN: Waited too long for work order 'requested items' to populate ... giving up..."
						break
					}
				}
				while ${TaskMaster[Crafting].CurrentWorkOrder[${woCount}].RequestedItems.Length} < 2
			}
			
			if ${TaskMaster[Crafting].CurrentWorkOrder[${woCount}].RequestedItems.Right[1].Equal[" "]}
			{
				if !${Refining.Recipe["${TaskMaster[Crafting].CurrentWorkOrder[${woCount}].RequestedItems.Left[-1].Right[-2]}"](exists)}
				{
					call DebugOut "VGCraft:: SN: There is no refining recipe for '${TaskMaster[Crafting].CurrentWorkOrder[${woCount}]}' OR '${TaskMaster[Crafting].CurrentWorkOrder[${woCount}].RequestedItems.Left[-1].Right[-2]}'"
					BadRecipes:Add["${TaskMaster[Crafting].CurrentWorkOrder[${woCount}]}"]
					continue
				}
				else
					RecipeName:Set["${TaskMaster[Crafting].CurrentWorkOrder[${woCount}].RequestedItems.Left[-1].Right[-2]}"]
			}
			else
			{
				if !${Refining.Recipe["${TaskMaster[Crafting].CurrentWorkOrder[${woCount}].RequestedItems.Right[-2]}"](exists)}
				{
					call DebugOut "VGCraft:: SN: There is no refining recipe for '${TaskMaster[Crafting].CurrentWorkOrder[${woCount}]}' OR '${TaskMaster[Crafting].CurrentWorkOrder[${woCount}].RequestedItems.Right[-2]}'"
					BadRecipes:Add["${TaskMaster[Crafting].CurrentWorkOrder[${woCount}]}"]
					continue
				}
				else
					RecipeName:Set["${TaskMaster[Crafting].CurrentWorkOrder[${woCount}].RequestedItems.Right[-2]}"]
			}
		}
		else
			RecipeName:Set["${TaskMaster[Crafting].CurrentWorkOrder[${woCount}]}"]
		;;;;;;;;;;;;
		;;;
		
		
		
		if ${Refining.Recipe["${RecipeName}"].NumUses} < 1
			continue

		; Magic Number -- line 7 is the start of fuel information in the recipe
		supplyLineCount:Set[7]
		fuelNeeded:Set[TRUE]
		while ${fuelNeeded}
		{
			variable string fuel

			fuel:Set[${Refining.Recipe["${RecipeName}"].Description.Token[${supplyLineCount},"\n"]}]
			if !${fuel.Equal[NULL]} && ${fuel.Length} > 1
			{
				fuel:Set[${fuel.Token[1,"\r"]}]

				if !${woRecipeNeeds.Contains[${fuel}]}
					woRecipeNeeds:Add[${fuel}]

				amountNeeded:Set[${Math.Calc[8 * ${Refining.Recipe["${RecipeName}"].NumUses}]}]

				if ${woRecipeFuel.Element[${fuel}](exists)}
					woRecipeFuel.Element[${fuel}]:Inc[${amountNeeded}]
				else
					woRecipeFuel:Set[${fuel},${amountNeeded}]

				call DebugOut "VG:recipe requires: ${fuel} :: ${amountNeeded} :: ${woRecipeFuel.Element[${fuel}]}"
			}
			else
			{
				fuelNeeded:Set[FALSE]
			}


			supplyLineCount:Inc
		}
	}

	; ...and then subtract any fuel that we already have on hand
	if ${woRecipeFuel.FirstKey(exists)}
	{
		variable int invIndex
		variable int minCount
		do
		{
			invIndex:Set[1]
			minCount:Set[0]
			;call DebugOut "Checking through inventory for '${woRecipeFuel.CurrentKey}'"
			do
			{
				;call DebugOut "${invIndex} - ${Me.Inventory[${invIndex:Inc}].Name}..."
				if ${Me.Inventory[${invIndex}].Name.Find[${woRecipeFuel.CurrentKey}]} && ${Me.Inventory[${invIndex}].MiscDescription.Find[Small crafting utilities]}
				{
					woRecipeFuel.CurrentValue:Dec[${Me.Inventory[${invIndex}].Quantity}]
					minCount:Inc[${Me.Inventory[${invIndex}].Quantity}]
					;call DebugOut "-- MATCH(${invIndex}):  woRecipeFuel.CurrentValue now ${woRecipeFuel.CurrentValue} (decreased it by ${Me.Inventory[${invIndex}].Quantity}"
					;call DebugOut "-- MATCH(${invIndex}): minCount now ${minCount}"  
				}
			}
			while ${invIndex:Inc} <= ${Me.Inventory}

			; If we are at the Station and have more than 100, don't worry, be happy now!
			if ${atStation} && (${minCount} > 100)
				continue

			; If, after subtracting fuel in our inventory, we still need fuel -- we'll return TRUE
			if ${woRecipeFuel.CurrentValue} > 0
			{
				supplyNeeded:Set[TRUE]
				; ...if we need to buy, then buy 200 Extra... less time running back and forth
				woRecipeFuel.CurrentValue:Inc[${Math.Calc[${woRecipeFuel.CurrentValue} + 200]}]
				call DebugOut "VGCraft:: SupplyNeeded should buy : ${woRecipeFuel.CurrentKey} @ ${woRecipeFuel.CurrentValue}"
			}
		}
		while ${woRecipeFuel.NextKey(exists)}
	}

	return ${supplyNeeded}
}

/* How much more do we need? */
function:bool RecipeSupplyNeeded()
{
	variable bool fuelNeeded = TRUE
	variable bool isFound = FALSE
	variable bool supplyNeeded = FALSE
	variable int supplyLineCount = 1
	variable int amountNeeded
	
	woRecipeNeeds:Clear
	woRecipeFuel:Clear

	call DebugOut "VGCraft:: Called RecipeSupplyNeeded"

	; Check the Recipe -- find the Fuel requirements and increment fuel that we need by one stack
	supplyLineCount:Set[1]
	fuelNeeded:Set[TRUE]
	isFound:Set[FALSE]

	call DebugOut "VGCraft:: Desc: ${Refining.Recipe[${recipeName}].Description}"

	; Don't care how many we have, so return FALSE
	if !${doRecipeMatCheck}
		return FALSE

	do
	{
		supplyLineCount:Inc
		call DebugOut "VGCraft:: Desc: ${supplyLineCount} :: ${Refining.Recipe[${recipeName}].Description.Token[${supplyLineCount},"\n"]}"

		if !${Refining.Recipe[${recipeName}].Description.Token[${supplyLineCount},"\n"](exists)}
			return FALSE

		if ${Refining.Recipe[${recipeName}].Description.Token[${supplyLineCount},"\n"].Find[Utilities:]}
		{
			isFound:Set[TRUE]
			supplyLineCount:Inc
		}

	}
	while !${isFound}

	call DebugOut "VGCraft:: Desc: ${Refining.Recipe[${recipeName}].Description.Token[${supplyLineCount},"\n"]}"

	while ${fuelNeeded}
	{
		variable string fuel

		fuel:Set[${Refining.Recipe[${recipeName}].Description.Token[${supplyLineCount},"\n"]}]
		if ! ${fuel.Equal[NULL]} && ${fuel.Length} > 1
		{
			fuel:Set[${fuel.Token[1,"\r"]}]

			if ! ${woRecipeNeeds.Contains[${fuel}]}
				woRecipeNeeds:Add[${fuel}]

			amountNeeded:Set[${Math.Calc[5 * (${recipeRepeatNum} - ${recipeRepeatNumDone})]}]
			if ${woRecipeFuel.Element[${fuel}](exists)}
				woRecipeFuel.Element[${fuel}]:Inc[${amountNeeded}]
			else
				woRecipeFuel:Set[${fuel},${amountNeeded}]

			call DebugOut "VG:recipe requires: ${fuel} :: ${amountNeeded} :: ${woRecipeFuel.Element[${fuel}]}"
		}
		else
		{
			fuelNeeded:Set[FALSE]
		}

		supplyLineCount:Inc
	}

	; ...and then subtract any fuel that we already have on hand
	if ${woRecipeFuel.FirstKey(exists)}
	{
		variable int invIndex
		variable int minCount

		do
		{
			invIndex:Set[1]
			minCount:Set[0]
			do
			{
				if ${Me.Inventory[${invIndex}].Name.Find[${woRecipeFuel.CurrentKey}]} && ${Me.Inventory[${invIndex}].MiscDescription.Find[Small crafting utilities]}
				{
					woRecipeFuel.CurrentValue:Dec[${Me.Inventory[${invIndex}].Quantity}]
					minCount:Inc[${Me.Inventory[${invIndex}].Quantity}]
				}
			}
			while ${invIndex:Inc} <= ${Me.Inventory}

			; If we are at the Station and have more than 100, don't worry, be happy now!
			if (${minCount} > 100)
				continue

			; If, after subtracting fuel in our inventory, we still need fuel -- we'll return TRUE
			if ${woRecipeFuel.CurrentValue} > 0
			{
				supplyNeeded:Set[TRUE]
				; ...buying two extra Fuel items -- just because
				woRecipeFuel.CurrentValue:Inc[200]
				call ScreenOut "VGCraft:: SupplyNeeded: ${woRecipeFuel.CurrentKey} @ ${woRecipeFuel.CurrentValue}"
			}
		}
		while ${woRecipeFuel.NextKey(exists)}
	}

	return ${supplyNeeded}
}

/* This code snippet was written by Amadeus */
/* Used to move Crafting Sipplies into the Crafting Pouch automagicaly */
function MoveCraftSupplies()
{
	variable int i = 1
	variable int UtilityPouchIndex = 0
	variable int ContainerCurrentlyInIndex = 0

	; The name of the "Utility Pouch" is set in main script
	UtilityPouchIndex:Set[${Me.Inventory[${sUtilPouch}].Index}]

	; This will take the last item added to your inventory and move it to the Pouch

	call DebugOut "VGCraft:: Move: ${Me.Inventory[${Me.Inventory}].Name}"
	;call DebugOut "VGCraft:: Move: ${Me.Inventory[${Me.Inventory}].MiscDescription}"

	if ( ${Me.Inventory[${Me.Inventory}].MiscDescription.Find[Small crafting utilities]} )
	{
		Me.Inventory[${Me.Inventory}]:PutInContainer[${UtilityPouchIndex}]
		call DebugOut "VGCraft:: MOVING ${Me.Inventory[${Me.Inventory}].Name} to Container Index: ${UtilityPouchIndex}"
		wait 5
	}
}

/* Moves extra Ingredients into the Utility Pouch */
function CleanUpInventory()
{
	variable int i = 1
	variable int UtilityPouchIndex = 0
	variable int ContainerCurrentlyInIndex = 0

	; The name of the "Utility Pouch" is set in main script
	UtilityPouchIndex:Set[${Me.Inventory[${sUtilPouch}].Index}]

	; This will take the last item added to your inventory and move it to the Pouch

	call DebugOut "VGCraft:: CleanUpInventory Called"

	do
	{
		if ${Me.Inventory[${i}].MiscDescription.Find[Small crafting utilities]}
		{
			if !${Me.Inventory[${i}].InContainer(exists)} && ${woRecipeFuel.FirstKey(exists)}
			{
				do
				{
					if ${Me.Inventory[${i}].Name.Find[${woRecipeFuel.CurrentKey}]}
					{
						call DebugOut "VGCraft::  Move Utility: ${Me.Inventory[${i}].Name}"
						Me.Inventory[${i}]:PutInContainer[${UtilityPouchIndex}]
						wait 5
					}
				}
				while ${woRecipeFuel.NextKey(exists)}
			}
		}
	}
	while (${i:Inc} <= ${Me.Inventory})
}


/* Repair Items */
function RepairItems()
{
	variable int i = 1

	call DebugOut "VGCraft:: RepairItems Called"

	Merchant:Begin[Repair]
	wait 5
	Merchant:RepairAll
	wait 5
   	Merchant:End		
}


function:bool RepairNeeded()
{
	variable int iCount = 1
	variable int iDamaged = 90

	Call DebugOut "VGCraft:: Determining if items need repairing"

	do
	{
		if ${Me.Inventory[${iCount}].CurrentEquipSlot.Find[Craft]} && ${Me.Inventory[${iCount}].Durability} < ${iDamaged}
			return TRUE
	}
	while (${iCount:Inc} <= ${Me.Inventory})

	return FALSE
}
