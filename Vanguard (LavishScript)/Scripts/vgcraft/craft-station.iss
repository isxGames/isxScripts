/* Crafting Station code */


/* Find a Recipe to use */
function:bool StationRecipeSelect()
{
	variable int rCount
	variable string RecipeName
	variable int Count

	if ${doRecipeOnly}
	{
		call DebugOut "VGCraft:: RecipeOnly: StationRecipeSelect called: ${recipeName} :: ${Refining.RecipeCount} "

		if ${Refining.Recipe[${recipeName}](exists)}
		{
			; Set the recipe... we should have already checked ingredients
			Refining.Recipe[${recipeName}]:Select
			return TRUE
		}
		else
		{
			; Recipe does not exist. VG sometimes doesn't register you have these for some wierd reason
			call ErrorOut "VGCraft:: ERROR: Recipe does not exist! BAD VG! :: ${recipeName}"
			call ErrorOut "VGCraft:: ERROR: Try Selecting table first to force a refresh"
			return FALSE
		}
	}

	call DebugOut "VGCraft:: StationRecipeSelect called: ${TaskMaster[Crafting].CurrentWorkOrder} :: ${Refining.RecipeCount} "

	wait 10

	rCount:Set[0]

	while ( ${rCount:Inc} <= ${TaskMaster[Crafting].CurrentWorkOrder} )
	{
		; Select a Recipe

		if !${Refining.Recipe["${TaskMaster[Crafting].CurrentWorkOrder[${rCount}]}"](exists)}
		{
			if (${TaskMaster[Crafting].CurrentWorkOrder[${rCount}].RequestedItems.Length} < 2)
			{
				TaskMaster[Crafting].CurrentWorkOrder[${rCount}]:GetRequestedItems
				wait 5
				Count:Set[0]
				do
				{
					waitframe
					Count:Inc
					if ${Count} > 5000
					{
						call MyOutput "VGCraft:: SRS: Waited too long for work order 'requested items' to populate ... giving up..."
						break
					}
				}
				while ${TaskMaster[Crafting].CurrentWorkOrder[${rCount}].RequestedItems.Length} < 2
			}
			
			if ${TaskMaster[Crafting].CurrentWorkOrder[${rCount}].RequestedItems.Right[1].Equal[" "]}
			{
				if !${Refining.Recipe["${TaskMaster[Crafting].CurrentWorkOrder[${rCount}].RequestedItems.Left[-1].Right[-2]}"](exists)}
				{
					call DebugOut "VGCraft:: SRS: There is no refining recipe for '${TaskMaster[Crafting].CurrentWorkOrder[${rCount}]}' OR '${TaskMaster[Crafting].CurrentWorkOrder[${rCount}].RequestedItems.Left[-1].Right[-2]}'"
					BadRecipes:Add["${TaskMaster[Crafting].CurrentWorkOrder[${rCount}]}"]
					continue
				}
				else
					RecipeName:Set["${TaskMaster[Crafting].CurrentWorkOrder[${rCount}].RequestedItems.Left[-1].Right[-2]}"]
			}
			else
			{
				if !${Refining.Recipe["${TaskMaster[Crafting].CurrentWorkOrder[${rCount}].RequestedItems.Right[-2]}"](exists)}
				{
					call DebugOut "VGCraft:: SRS: There is no refining recipe for '${TaskMaster[Crafting].CurrentWorkOrder[${rCount}]}' OR '${TaskMaster[Crafting].CurrentWorkOrder[${rCount}].RequestedItems.Right[-2]}'"
					BadRecipes:Add["${TaskMaster[Crafting].CurrentWorkOrder[${rCount}]}"]
					continue
				}
				else
					RecipeName:Set["${TaskMaster[Crafting].CurrentWorkOrder[${rCount}].RequestedItems.Right[-2]}"]
			}
		}
		else
			RecipeName:Set["${TaskMaster[Crafting].CurrentWorkOrder[${rCount}]}"]


		if !${Refining.Recipe["${RecipeName}"].IsWorkOrder}
		{
			; We only do Work Orders!
			call DebugOut "VGCraft:: SRS: not a work order: ${Refining.Recipe[${RecipeName}].Name}"
			continue
		}

		if ${doFactionGrind}
		{
			if ${woGrindCount.Contains[${Refining.Recipe["${RecipeName}"].Name}]}
				continue
		}

		if ${BadRecipes.Contains[${Refining.Recipe["${RecipeName}"].Name}]}
		{
			; Work Around for bad SOE code in recipes
			continue
		}

		if ${Refining.Recipe["${RecipeName}"].NumUses} < 1
		{
			; We only do Work Orders!
			call DebugOut "VGCraft:: SRS: We have finished doing: ${Refining.Recipe[${RecipeName}].Name}"
			continue
		}
		
		call DebugOut "VG:SRS:Set ${Refining.Recipe[${RecipeName}].Name} ::  ${Refining.Recipe[${RecipeName}].NumUses} :: ${Refining.Recipe[${RecipeName}].IsWorkOrder} [for Work Order: '${TaskMaster[Crafting].CurrentWorkOrder[${rCount}]}']"
		call DebugOut "VG:Difficulty: ${TaskMaster[Crafting].CurrentWorkOrder[${rCount}].Difficulty}"

		; Set the recipe... we should have already checked ingredients
		CurrentWorkOrderName:Set[${TaskMaster[Crafting].CurrentWorkOrder[${rCount}]}]
		Refining.Recipe["${RecipeName}"]:Select
		BadRecipeName:Set[${Refining.Recipe["${RecipeName}"].Name}]

		woGrindCount:Add[${Refining.Recipe["${RecipeName}"].Name}]

		return TRUE
	}

	; No good recipies found, abort!
	call DebugOut "VG:SRS: No Work Order recipes found"

	return FALSE
}

/* Add must have ingredients */
function TableAddRecipeIngredients()
{
	variable int itemIndex = 0
	variable string fuel
	variable int tableIndex
	variable bool doAddIngredient
	
	variable int supplyLineCount = 0
	while ${Refining.CurrentRecipe.Description.Token[${supplyLineCount:Inc},"\n"](exists)}
	{
		;; look through each line of recipe for the word "Ingredients:"
		if ${Refining.CurrentRecipe.Description.Token[${supplyLineCount},"\n"].Find[Ingredients:]}
		{
			;; next line is the ingredient we want
			supplyLineCount:Inc
			fuel:Set[${Refining.CurrentRecipe.Description.Token[${supplyLineCount},"\n"]}]

			;; does it exist? 
			while !${fuel.Equal[NULL]} && ${fuel.Length} > 1
			{
				fuel:Set[${fuel.Right[${Math.Calc[${fuel.Length}-4]}]}]
				fuel:Set[${fuel.Token[1,"\r"]}]

				;; cycle through our table (we don't want to add twice)
				doAddIngredient:Set[TRUE]
				tableIndex:Set[0]
				while (${Refining.Table[${tableIndex:Inc}].Name(exists)})
				{
					if ${Refining.Table[${tableIndex}].Name.Find[${fuel}]}
						doAddIngredient:Set[FALSE]
				}

				;; adding the ingredient
				if ${doAddIngredient}
				{
					;; cycle thru inventory 
					itemIndex:Set[0]
					while ( ${Me.Inventory[${itemIndex:Inc}].Name(exists)} && ${Refining.Table}<${Refining.TotalTableSpace} )
					{
						;; add ingredient 
						if ( ${Me.Inventory[${itemIndex}].Name.Find[${fuel}]} )
						{
							call MyOutput "VGCraft:: AddRecipieIngredients adding: ${Me.Inventory[${itemIndex}].Name}, Quantity=${Me.Inventory[${itemIndex}].Quantity}"
							Me.Inventory[${itemIndex}]:AddToCraftingTable
							wait 2
							break
						}
					}
				}
				supplyLineCount:Inc
				fuel:Set[${Refining.CurrentRecipe.Description.Token[${supplyLineCount},"\n"]}]
			}
		}
	
	
		;; look through each line of recipe for the word "Utilities:"
		if ${Refining.CurrentRecipe.Description.Token[${supplyLineCount},"\n"].Find[Utilities:]}
		{
			;; next line is the ingredient we want
			supplyLineCount:Inc
			fuel:Set[${Refining.CurrentRecipe.Description.Token[${supplyLineCount},"\n"]}]
			
			;; does it exist? 
			while !${fuel.Equal[NULL]} && ${fuel.Length} > 1
			{
				fuel:Set[${fuel.Token[1,"\r"]}]

				;; cycle through our table (we don't want to add twice)
				doAddIngredient:Set[TRUE]
				tableIndex:Set[0]
				while (${Refining.Table[${tableIndex:Inc}].Name(exists)})
				{
					if ${Refining.Table[${tableIndex}].Name.Find[${fuel}]}
						doAddIngredient:Set[FALSE]
				}

				;; adding the ingredient
				if ${doAddIngredient}
				{
					;; cycle thru inventory 
					itemIndex:Set[0]
					while ( ${Me.Inventory[${itemIndex:Inc}].Name(exists)} && ${Refining.Table}<${Refining.TotalTableSpace} )
					{
						;; add ingredient if quantity is 15 or more
						if ( ${Me.Inventory[${itemIndex}].Name.Find[${fuel}]} && (${Me.Inventory[${itemIndex}].Quantity} >= 15) )
						{
							call MyOutput "VGCraft:: AddRecipieIngredients adding: ${Me.Inventory[${itemIndex}].Name}, Quantity=${Me.Inventory[${itemIndex}].Quantity}"
							Me.Inventory[${itemIndex}]:AddToCraftingTable
							wait 2
							break
						}
					}
				}
				supplyLineCount:Inc
				fuel:Set[${Refining.CurrentRecipe.Description.Token[${supplyLineCount},"\n"]}]
			}
		}
	}
}

/* Removes non-fuel / extra ingredients */
function TableRemovePersonals()
{
	variable int tableIndex
	variable bool isFound
	
	tableIndex:Set[${Refining.TotalTableSpace}]
	
	;; remove the first supplied ingedient from the table
	if ( ${Refining.Stage.Index} == 1 && ${tableIndex} > 0 && ${Refining.Stage.Step[1].AvailAction[1].Name.Find[Supplied]} )
	{
		Refining.Table[1]:RemoveFromTable
		tableIndex:Set[${Refining.TotalTableSpace}]
	}
	
	while (${tableIndex} > 0)
	{
		;call DebugOut "VGCraft:: item: ${Refining.Table[${tableIndex}].Name}"

		isFound:Set[FALSE]

		if ${woRecipeFuel.FirstKey(exists)}
		{
			do
			{
				;call DebugOut "VGCraft:: CurrentKey: ${woRecipeFuel.CurrentKey}"

				if ( ${Refining.Table[${tableIndex}].Name.Find[${woRecipeFuel.CurrentKey}]} && ${Refining.Table[${tableIndex}].Name(exists)} )
				{
					;call DebugOut "VGCraft:: found: ${Refining.Table[${tableIndex}].Name}"
					isFound:Set[TRUE]
					break
				}
			}
			while ${woRecipeFuel.NextKey(exists)}

			call DebugOut "VGCraft:: ${Me.Inventory[${Refining.Table[${tableIndex}].Name}].MiscDescription}"
			if !${isFound} && ${Refining.Table[${tableIndex}].Name(exists)}
			{
				if ${Me.Inventory[${Refining.Table[${tableIndex}].Name}].MiscDescription.Find[Small crafting utilities]}
				{
					;Small crafting utilities
					call DebugOut "VGCraft:: Not found but OK: ${Me.Inventory[${Refining.Table[${tableIndex}].Name}].Type} :: ${Refining.Table[${tableIndex}].Name}"
				}
				elseif
				{
					; We found an Item that is not on the list, remove it!
					call DebugOut "VGCraft:: Removing from table: ${Refining.Table[${tableIndex}].Name}"
					Refining.Table[${tableIndex}]:RemoveFromTable
					wait 5
				}
			}
		}
		tableIndex:Dec
	}
}

/* Adds optional items to Table setup */
/* Mostly used for Complication Corrections */
function TableAddExtra()
{
	variable int itemIndex = 0
	variable iterator extraIter

	setExtraItems:GetSettingIterator[extraIter]
	if ${extraIter:First(exists)}
	{
		do
		{
			call MyOutput "VGCraft:: AddExtra testing: ${extraIter.Key}"

			call IsItemOnTable "${extraIter.Key}"
			if ${Return}
			{
				call MyOutput "VGCraft:: AddExtra already on table: ${extraIter.Key}"
				continue
			}

			itemIndex:Set[0]
			while ( ${Me.Inventory[${itemIndex:Inc}].Name(exists)} )
			{
				if ( ${Me.Inventory[${itemIndex}].Name.Find[${extraIter.Key}]} && (${Me.Inventory[${itemIndex}].Quantity} >= 10) )
				{
					if ${Refining.Table}<${Refining.TotalTableSpace}
					{
						call MyOutput "VGCraft:: AddExtra adding: ${Me.Inventory[${itemIndex}].Name}"
						Me.Inventory[${itemIndex}]:AddToCraftingTable
						wait 2
					}
					break
				}
			}
		}
		while ${extraIter:Next(exists)}
	}
}

/* Adds Extra Fuel to Table setup */
function TableAddExtraFuel()
{
	if ( ${Me.Inventory[${Refining.Table[1].Name}](exists)} && ${Me.Inventory[${Refining.Table[1].Name}].Type.Equal[Crafting Component]} )
		Me.Inventory[${Refining.Table[1].Name}]:AddToCraftingTable
	wait 3
}

/* This function exists because ${Refining.Table[NonMatchingText]} is returning ${Refining.Table[1]} */
function:bool IsItemOnTable(string anItem)
{
	variable int tableIndex

	tableIndex:Set[0]
	while ${tableIndex:Inc} <= ${Refining.TotalTableSpace}
	{
		if ${Refining.Table[${tableIndex}].Name.Find[${anItem}]}
			return TRUE
	}

	return FALSE
}

/* Check to see if we are getting low on Table loaded Fuel */
function:bool TableFuelLow()
{

	variable int count = 1
	variable int fuelCount = 0
	variable string fuel
	variable iterator anIter

	woRecipeNeeds:GetIterator[anIter]

	if ( !${anIter:First(exists)} )
	{
		return FALSE
	}

	anIter:First
	do
	{
		count:Set[1]
		fuelCount:Set[0]
		fuel:Set[${anIter.Key}]

		do
		{
			if ( ${fuel.Equal[${Refining.Table[${count}].Name}]} )
			{
				;call MyOutput "VGCraft:: Fuel on Table :: ${fuel} :: ${Refining.Table[${count}].Quantity}"
				fuelCount:Inc[${Refining.Table[${count}].Quantity}]
			}
		}
		while ( ${count:Inc} <= ${Refining.TotalTableSpace} )

		if ( (${fuelCount} < 11)  && (${fuelCount} > 0) )
			return TRUE

	}
	while ${anIter:Next(exists)}


	return FALSE
}
