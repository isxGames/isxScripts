/* Work Order related code */

/* Fill up on some new work orders! */
function:bool GetWorkOrder(bool getAny, int countType)
{
	call DebugOut "VGCraft:: GetWorkOrder called :: ${getAny}"

	if ( ${TaskMaster[Crafting].InTransaction} && (${TaskMaster[Crafting].AvailWorkOrderCount} >= 1) )
	{
		call DebugOut "VGCraft:: GetWorkOrder called :: ${TaskMaster[Crafting].AvailWorkOrderCount}"
		call IRCSpew "Getting Work Orders ... ${TaskMaster[Crafting].AvailWorkOrderCount} available."

		variable int iCount = 0
		variable bool allDone = FALSE
		variable string sDiff 
		variable string sReqSkill

		if ( ${doHardFirst} )
			iCount:Set[0]
		else
			iCount:Set[${Math.Calc[${TaskMaster[Crafting].AvailWorkOrderCount} + 1]}]

		do
		{
			if ( ${doHardFirst} )
				iCount:Inc
			else
				iCount:Dec

			if ( (${iCount} < 1) || (${iCount} > ${TaskMaster[Crafting].AvailWorkOrderCount}) )
			{
				call MyOutput "VGCraft:: All done checking for Work Orders :: ${iCount}"
				return FALSE
			}

			call ChooseWorkOrder ${iCount} ${getAny} ${countType}

			if ( ${Return} )
				return TRUE

		}
		while ( !${allDone} )

	}

	return FALSE
}

/* Select the correct Work Order */
function:bool ChooseWorkOrder(int iCount, bool findAny, int woCount)
{

	variable string sDiff 
	variable string sReqSkill
	variable string WorkOrderSelected
	variable int Count

	if ${iCount} <= 0
		return FALSE

	sDiff:Set[${TaskMaster[Crafting].AvailWorkOrder[${iCount}].Difficulty}]
	sReqSkill:Set[${TaskMaster[Crafting].AvailWorkOrder[${iCount}].RequiredSkill}]

	call MyOutput "VGCraft:: GetWorkOrder: diff: ${sDiff}  :: Skill: ${sReqSkill} :: ${TaskMaster[Crafting].AvailWorkOrder[${iCount}].Name}"

	if ( ${doAnyWO} )
		call MyOutput "VGCraft:: ChooseWorkOrder: doAnyWO TRUE"
	elseif ( ${sDiff.Equal[Very Difficult]} )
		return FALSE
	elseif ( ${sDiff.Equal[Difficult]} && !${doDiffWO} )
		return FALSE
	elseif ( ${sDiff.Equal[Moderate]} && !${doModWO} )
		return FALSE
	elseif ( ${sDiff.Equal[Easy]} && !${doEasyWO} )
		return FALSE
	elseif ( ${sDiff.Equal[Very Easy]} && !${doVeryEasyWO} )
		return FALSE
	elseif ( ${sDiff.Equal[Trivial]} && !${doTrivWO} )
		return FALSE

	; Check to see if we have the required skill
	call SkillCheck "${sReqSkill}"
	if ( ${Return} )
	{
		call MyOutput "VGCraft::WO:name: ${TaskMaster[Crafting].AvailWorkOrder[${iCount}].Name}"
		;call MyOutput "VGCraft:::WO:desc: ${TaskMaster[Crafting].AvailWorkOrder[${iCount}].Description}"
		;call MyOutput "VGCraft::WO:issue: ${TaskMaster[Crafting].AvailWorkOrder[${iCount}].IssuedBy}"
		call MyOutput "VGCraft::WO:Diff: ${TaskMaster[Crafting].AvailWorkOrder[${iCount}].Difficulty}"
		call MyOutput "VGCraft::WO:skill: ${TaskMaster[Crafting].AvailWorkOrder[${iCount}].RequiredSkill}"
		call MyOutput "VGCraft::WO:ReqItems: ${TaskMaster[Crafting].AvailWorkOrder[${iCount}].RequestedItems.Left[1]}"

		if ${BadRecipes.Contains["${TaskMaster[Crafting].AvailWorkOrder[${iCount}].Name}"]}
		{
			; Don't Pick bad recipes
			return FALSE
		}

		if ${TaskMaster[Crafting].AvailWorkOrder[${iCount}].RequestedItems(exists)} && (${TaskMaster[Crafting].AvailWorkOrder[${iCount}].RequestedItems.Left[1]} == ${woCount})
		{
			call DebugOut "VGCraft::Selected: ${TaskMaster[Crafting].AvailWorkOrder[${iCount}].Name}"
			call IRCSpew "Seleting Work Order: '${TaskMaster[Crafting].AvailWorkOrder[${iCount}].Name}'"
			WorkOrderSelected:Set[${TaskMaster[Crafting].AvailWorkOrder[${iCount}]}]
			TaskMaster[Crafting].AvailWorkOrder[${iCount}]:Select
			wait 5
			wait 5
			if !${TaskMaster[Crafting].CurrentWorkOrder[${WorkOrderSelected}](exists)}
			{
				do
				{
					waitframe
				}
				while !${TaskMaster[Crafting].CurrentWorkOrder[${WorkOrderSelected}](exists)}
			}
			TaskMaster[Crafting].CurrentWorkOrder[${WorkOrderSelected}]:GetRequestedItems
			wait 5
			Count:Set[0]
			do
			{
				waitframe
				Count:Inc
				if ${Count} > 5000
				{
					call MyOutput "Waited too long for work order 'requested items' to populate ... giving up..."
					break
				}
			}
			while ${TaskMaster[Crafting].CurrentWorkOrder[${WorkOrderSelected}].RequestedItems.Length} < 2
			return TRUE
		}

		if ${findAny}
		{
			call MyOutput "VGCraft:: ChooseWorkOrder: findAny TRUE"
			call DebugOut "VGCraft::Selected: ${TaskMaster[Crafting].AvailWorkOrder[${iCount}].Name}"
			call IRCSpew "Seleting Work Order: '${TaskMaster[Crafting].AvailWorkOrder[${iCount}].Name}'"
			WorkOrderSelected:Set[${TaskMaster[Crafting].AvailWorkOrder[${iCount}]}]
			TaskMaster[Crafting].AvailWorkOrder[${iCount}]:Select
			wait 5
			if !${TaskMaster[Crafting].CurrentWorkOrder[${WorkOrderSelected}](exists)}
			{
				do
				{
					waitframe
				}
				while !${TaskMaster[Crafting].CurrentWorkOrder[${WorkOrderSelected}](exists)}
			}
			TaskMaster[Crafting].CurrentWorkOrder[${WorkOrderSelected}]:GetRequestedItems
			wait 5
			Count:Set[0]
			do
			{
				waitframe
				Count:Inc
				if ${Count} > 5000
				{
					call MyOutput "Waited too long for work order 'requested items' to populate ... giving up..."
					break
				}
			}
			while ${TaskMaster[Crafting].CurrentWorkOrder[${WorkOrderSelected}].RequestedItems.Length} < 2
			return TRUE
		}
	}
	else
	{
		call MyOutput "VGCraft:: Not high enough skill for that work order"
	}

	return FALSE
}

/* Try to finish a work order */
function:bool FinishWorkOrder()
{
	; Check to see if we have any work orders to turn in
	; If we can, do so

	; a text Event will determin if we Loot or Abandon

	call DebugOut "VG:FinishWorkOrder called :: WO Count: ${TaskMaster[Crafting].CurrentWorkOrderCount}"

	if ( ${TaskMaster[Crafting].CurrentWorkOrderCount} >= 1 )
	{
		call DebugOut "VG:Complete WO[1]: ${TaskMaster[Crafting].CurrentWorkOrder[1].Name} "
		call StatsOut "VGCraft::   Trying to Complete WO: ${TaskMaster[Crafting].CurrentWorkOrder[1].Name} "
		call IRCSpew "Work Order (${TaskMaster[Crafting].CurrentWorkOrder[1].Name}) Complete!"

		; Just Select and Complete the first one in the list
		TaskMaster[Crafting].CurrentWorkOrder[1]:Complete

		return TRUE
	}

	return FALSE
}

/* Abandon a work order */
function AbandonWorkOrder()
{
	call DebugOut "VG:AbandonWorkOrder called:: ${TaskMaster[Crafting].CurrentWorkOrder[1].Name}"
	call IRCSpew "Abandoning Work Order: ${TaskMaster[Crafting].CurrentWorkOrder[1].Name}"

	if ( ${TaskMaster[Crafting].CurrentWorkOrderCount} >= 1 )
	{
		call StatsOut "VGCraft::   Abandoned WO: ${TaskMaster[Crafting].CurrentWorkOrder[1].Name} "

		; Just Select and Abandon the first one in the list
		TaskMaster[Crafting].CurrentWorkOrder[1]:Abandon
	}

}

/* Make sure we have enough skill for this */
function:bool SkillCheck(string sReqSkill)
{
	call MyOutput "VG:SkillCheck: ${sReqSkill} :: ${Me.Stat[Crafting, ${sReqSkill}]} "
	if ( ${Me.Stat[Crafting,${sReqSkill}]} >= 1 )
		return TRUE

	return FALSE
}