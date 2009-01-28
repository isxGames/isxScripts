/* Movement related code for VGCraft */


/* Target and Start a convo with the Supply NPC */
function:bool TargetSupplyNPC()
{
	; We should already be targeting the NPC
	;Pawn[exactname,npc,${cSupplyNPC}]:Target
	;wait 5

	if ( ${Me.Target(exists)} && (${Me.Target.Distance} < 5) )
	{

		if !${Me.Target.HaveLineOfSightTo}
			call faceloc ${Me.Target.X} ${Me.Target.Y} 15 2

		Merchant:Begin[BuySell]

		wait 5

		return TRUE
	}
	else
	{
		call ErrorOut "VG: Can not target Supply NPC: ${cSupplyNPC}"
	}

	return FALSE
}


/* Target and Start a convo with Work Order NPC */
function:bool TargetOrderNPC()
{
	; We should already be targeting the NPC
	;Pawn[exactname,npc,${cWorkNPC}]:Target
	;wait 5

	if ( ${Me.Target(exists)} && (${Me.Target.Distance} < 6) )
	{
		call DebugOut "VG:TargetOrderNPC called"

		Me.Target:DoubleClick

		if !${Me.Target.HaveLineOfSightTo}
			call faceloc ${Me.Target.X} ${Me.Target.Y} 15 2

		TaskMaster[Crafting]:Begin

		wait 5

		return TRUE
	}
	else
	{
		call ErrorOut "VG: Can not Target Work Order NPC: ${cWorkNPC}"
	}

	return FALSE
}

/* See if we can Target the crafting station */
function:bool TargetStation()
{
	if ${doRecipeOnly}
	{
		if ( !${recipeStation(exists)} || ${recipeStation.Equal[NONE]} )
		{
			; They did not set the station with the UI button
			call ErrorOut "VG: ERROR: No Recipe Crafting Station Set"
			return FALSE
		}
	}
	elseif ( !${cStation(exists)} || ${cStation.Equal[NONE]} )
	{
		; They did not set the station with the UI button
		call ErrorOut "VG: ERROR: No Crafting Station Set"
		return FALSE
	}

	;echo ${Me.Target.Name}
	;echo ${Me.Target.Type}
	;echo ${Me.Target.Title}

	if ${doRecipeOnly}
	{
		call DebugOut "Targeting: ${recipeStation}"
		Pawn[exactname,${recipeStation}]:Target
	}
	else
	{
		call DebugOut "Targeting: ${cStation}"
		Pawn[exactname,${cStation}]:Target
	}

	if ( !${Me.Target(exists)} || (${Me.Target.Distance} > 5) )
	{
		call DebugOut "VG:TargetStation to far away"
		return FALSE
	}

	wait 5

	if ${Math.Abs[${Me.Heading} - ${Me.Target.HeadingTo}]} > 40
		call faceloc ${Me.Target.X} ${Me.Target.Y} 45 2

	if ${Me.Target.Distance} > ${objPrecision}
	{
		; Nope, no good
		call ErrorOut "VG: Too far from station: ${cStation} :: ${Me.Target.Distance}"
		farAwayError:Set[TRUE]
		return FALSE
	}

	return TRUE
}

/* Check to see if we have Line Of Sight to current target */
/* Is used to check if WO NPC has wandered off */
function:bool TargetLOS()
{

	Pawn[exactname,${cTarget}]:Target

	wait 5

	if !${Me.Target(exists)}
	{
		call DebugOut "VG: No TARGET set in TargetLOS"
		isMoving:Set[FALSE]
		return FALSE
	}

	if ${VG.CheckCollision[${Me.Target.X},${Me.Target.Y},${Me.Z}](exists)}
	{
		call DebugOut "VG:TargetLOS: CheckCollision returned true!"
		isMoving:Set[FALSE]
		return FALSE
	}

	if ${Me.Target(exists)}
	{
		call DebugOut "VG:TargetLOS: we have LoS to Target: ${cTarget}"
		call faceloc ${Me.Target.X} ${Me.Target.Y} 15 2
		return TRUE
	}
	else
	{
		call ErrorOut "VG:TargetLOS: no LoS to Target: ${cTarget}"
	}

	isMoving:Set[FALSE]
	return FALSE
}

/* *************************************************************************** */

/* Target a Close Object */
function:bool TargetCloseObject()
{
	VGExecute "/cleartargets"

	wait 5

	cTargetID:Set[0]

	call DebugOut "TargetCloseObject: ${cTarget}"

	if ( !${cTarget.Equal[NONE]} )
	{
		if ${cTarget.Equal[${cStation}]}
			Pawn[exactname,${cTarget}]:Target
		else
			Pawn[exactname,npc,${cTarget}]:Target

		wait 3

		if ( ${Me.Target(exists)} )
		{
			call DebugOut "VG:TargetCloseObject: Target(exists): ${Me.Target.Name}"

			cTargetID:Set[${Me.Target.ID}]

			return TRUE
		}
		else
		{
			; Hmm, maybe we didn't wait long enough
			call DebugOut "VG:TargetCloseObject: Me.Target(exists): FALSE!"

			return FALSE
		}
	}
	else
	{
		call ErrorOut "TargetCloseObject: cTarget is not set! :: ${cTarget}"
	}

	return FALSE
}

/* Use the move.iss functions to move to the target */
function MoveToTarget()
{
	; Start Moving!

	if ( ${cTargetID} == 0 )
	{
		call ErrorOut "VG: Missing move target ID"
		call FindMoveTarget
		if !${Return}
			return
	}

	if !${Me.Target(exists)}
	{
		call ErrorOut "VG:ERROR: MoveToTarget: No Me.Target!"
		call FindMoveTarget
		if !${Return}
			return
	}

	if (${Me.Target.Distance} <= ${objPrecision})
	{
		; We are already within range, so just continue
		call DebugOut "VG:MoveToTarget: Already nice and close. All done."
		cState:Set[CS_MOVE_DONE]
		return
	}

	; If we are moving to Work Order Taskmaster, there are some extra checks
	if ${cTarget.Equal[${cWorkNPC}]} && ${Me.Target.Distance} > ${maxWorkDist}
	{
		; Check against user supplied max distance
		call DebugOut "VG:MoveToTarget: cWorkNPC is too far away: ${Me.Target.Distance}"
		cState:Set[CS_MOVE_TARGWAIT]
		return
	}

	if ${VG.CheckCollision[${Me.Target.X},${Me.Target.Y},${Me.Z}](exists)}
	{
		; Collision detected, so start over from the top
		if ${cTarget.Equal[${cWorkNPC}]}
		{
			call DebugOut "VG:MoveToTarget: cWorkNPC CheckCollision returned TRUE"
			cState:Set[CS_MOVE_TARGWAIT]
		}
		else
		{
			call ErrorOut "VG:MoveToTarget: CheckCollision to Target returned true!"
			cState:Set[CS_MOVE]
		}
		return
	}


	call DebugOut "VG: Moving to Found Target: ${cTargetID}"

	; Set wait STATE
	cState:Set[CS_MOVE_WAIT]


	; Path got us close, let's finish off the move
	if ${farAwayError}
	{
		call DebugOut "VG: Too far away, get closer!"
		isMoving:Set[TRUE]
		call moveToTargetedObject ${cTargetID} 1 0 FALSE
	}
	else
	{
		isMoving:Set[TRUE]
		call moveToTargetedObject ${cTargetID} ${objPrecision} 0 FALSE
		if !${Return} && ${cTarget.Equal[${cWorkNPC}]}
		{
			cState:Set[CS_MOVE_TARGWAIT]
			isMoving:Set[FALSE]
			return
		}
	}

	farAwayError:Set[FALSE]

	; Set STATE
	cState:Set[CS_MOVE_DONE]
	isMoving:Set[FALSE]

	call DebugOut "VG: State to CS.MOVE_DONE"
}

/* *************************************************************************** */

/* Get back onto a mapped square that also has connections to somewhere else */
function:bool MoveToMap()
{
	call ErrorOut "VG: Error: Not on MAP, MoveToMap called"
	if !${isMapping}
		isMapping:Set[TRUE]

	isMoving:Set[TRUE]
	call navi.MoveToMappedArea
	isMoving:Set[FALSE]

	return "${Return}"
}

/* *************************************************************************** */

/* Find the Target we want to move to */
function:bool FindMoveTarget()
{
	call DebugOut "FindMoveTarget: ${cTarget}"

	if ( !${cTarget.Equal[NONE]} )
	{
		if ( ${Pawn[exactname,${cTarget}](exists)} )
		{
			call DebugOut "VG: FindMoveTarget: Pawn:Target(exists): ${Pawn[${cTarget}].Name}"

			if ${cTarget.Equal[${cStation}]}
				cTargetID:Set[${Pawn[exactname,${cTarget}].ID}]
			else
				cTargetID:Set[${Pawn[exactname,npc,${cTarget}].ID}]

			return TRUE
		}
		else
		{
			; Hmm, maybe we didn't wait long enough
			call DebugOut "VG:FindMoveTarget: Pawn:Target(exists): FALSE!"

			return FALSE
		}
	}
	else
	{
		call ErrorOut "FindMoveTarget: cTarget is not set! :: ${cTarget}"
	}

	return FALSE
}

/* Use LavishNav path to get to a Target */
function:string MoveTargetPath(string aTarget)
{
	variable string sTest = "NO"

	if ${cTarget.Equal[${cWorkNPC}]}
		call DebugOut "VG:MoveTargetPath called: ${aTarget} :: ${Pawn[exactname,npc,${aTarget}].ID}"
	else
		call DebugOut "VG:MoveTargetPath called: ${aTarget} :: ${Pawn[exactname,${aTarget}].ID}"

	if !${Pawn[exactname,${aTarget}](exists)}
	{
		return "NO TARGET"
	}

	if ${Pawn[exactname,${aTarget}](exists)} && (${Pawn[exactname,${aTarget}].Distance} <= ${objPrecision}) && (${Pawn[exactname,${aTarget}].Distance} > 0)
	{
		call DebugOut "VG:MoveTargetPath: already close! :: ${Pawn[${Target}].Distance}"
		return "END"
	}

	isMoving:Set[TRUE]

	while !${sTest.Equal[END]}
	{
		if ${aTarget.Equal[${cWorkNPC}]}
			call navi.MovetoTargetName "${aTarget}" TRUE
		else
			call navi.MovetoTargetName "${aTarget}" FALSE

		sTest:Set[${Return}]

		if ${sTest.Equal[NO MAP]}
		{
			call ErrorOut "VG:ERROR: MTP: navi returned NO MAP"
			VG:ExecBinding[moveforward,release]
			VG:ExecBinding[movebackward,release]
			isMoving:Set[FALSE]
			return "${sTest}"
		}
		if ${sTest.Equal[NO PATH]}
		{
			call ErrorOut "VG:ERROR: MTP: navi returned NO PATH to ${aTarget}"
			VG:ExecBinding[moveforward,release]
			VG:ExecBinding[movebackward,release]
			isMoving:Set[FALSE]
			return "${sTest}"
		}
		if ${sTest.Equal[STUCK]}
		{
			call ErrorOut "VG:ERROR: MTP: navi returned STUCK!"
			VG:ExecBinding[moveforward,release]
			VG:ExecBinding[movebackward,release]
			isMoving:Set[FALSE]
			return "${sTest}"
		}
	
	}

	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward,release]
	isMoving:Set[FALSE]

	call DebugOut "VG:MoveTargetPath: END"

	return "END"
}

/* *************************************************************************** */

/* Move along a Path between user defined points */
function:string MoveAlongPath()
{
	variable string aStart = "NONE"
	variable string aEnd = "NONE"

	; Figure out what path to take based on what our ${cTarget} is
	; ${cStation}
	; ${cWorkNPC}
	; ${cSupplyNPC}

	call DebugOut "VG: MoveAlongPath called"

	wait 5

	; Where are we going?
	if ${nextDest.Equal[${destStation}]}
	{
		call DebugOut "VG: Move to Crafting Station: ${cStation} "
		cTarget:Set[${cStation}]
		cTargetLoc:Set[${stationLoc}]
	}
	elseif ${nextDest.Equal[${destWorkSearch}]}
	{
		call DebugOut "VG: Move to WO NPC Search spot: ${woNPCSearch} "
		cTarget:Set[${woNPCSearch}]
		cTargetLoc:Set[${workLoc}]
	}
	elseif ${nextDest.Equal[${destWork}]}
	{
		call DebugOut "VG: Move to WO NPC: ${cWorkNPC} "
		cTarget:Set[${cWorkNPC}]
		cTargetLoc:Set[${workLoc}]
	}
	elseif ${nextDest.Equal[${destSupply}]}
	{
		call DebugOut "VG: Move to Supply NPC: ${cSupplyNPC} "
		cTarget:Set[${cSupplyNPC}]
		cTargetLoc:Set[${supplyLoc}]
	}
	elseif ${nextDest.Equal[${destRepair}]}
	{
		call DebugOut "VG: Move to Repair NPC: ${cRepairNPC} "
		cTarget:Set[${cRepairNPC}]
		cTargetLoc:Set[${repairLoc}]
	}

	call MovePath "${cTarget}"

	return ${Return}
}

/* Move along a path */
function:string MovePath(string end)
{
	call DebugOut "VG:MovePath called: ${end}"
	isMoving:Set[TRUE]

	;call navi.MovetoWP "${end}"

	call navi.MovetoXYZ ${cTargetLoc.X} ${cTargetLoc.Y} ${cTargetLoc.Z}

	isMoving:Set[FALSE]

	if ${Return.Equal[NO PATH]}
	{
		call DebugOut "VG:ERROR: MovePath Could not find a Path to ${end}"
		VG:ExecBinding[moveforward,release]
		return "NO PATH"
	}
	if ${Return.Equal[STUCK]}
	{
		call ErrorOut "VG:ERROR: We got STUCK!"
		VG:ExecBinding[moveforward,release]
		return "STUCK"
	}

	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward,release]

	return "END"

}

/* *************************************************************************** */


/* We have reached our target */
function MoveDone()
{
	; Figure out what path to take based on what our ${cTarget} is
	; ${cStation}
	; ${cWorkNPC}
	; ${cSupplyNPC}

	call DebugOut "VG: MoveDone called :: Distance: ${Me.Target.Distance}"

	isMoving:Set[FALSE]

	wait 2

	if ( ${Me.Target.Distance} > 5 )
	{
		call DebugOut "VG: Not close enough to target (${Me.Target.Distance}), move again"
		; Hmmm, we are not close enough to our target -- Try again!
		cState:Set[CS_MOVE]
		return
	}

	if ${nextDest.Equal[${destStation}]}
	{
		call DebugOut "VG: at Station, start working"
		cTarget:Set[${cStation}]

		; Start Working at the Crafting Station
		cState:Set[CS_STATION]
	}
	elseif ${nextDest.Equal[${destWorkSearch}]}
	{
		call DebugOut "VG: at WO NPC Search Spot, look for NPC"

		; Set our new Target
		cTarget:Set[${cWorkNPC}]
		nextDest:Set[${destWork}]

		; Keep moving
		cState:Set[CS_MOVE_FIND]
	}
	elseif ${nextDest.Equal[${destWork}]}
	{
		call DebugOut "VG: at WO NPC, get some"
		cTarget:Set[${cWorkNPC}]

		; Work Orders, Turn in Old and get New
		cState:Set[CS_ORDER]
	}
	elseif ${nextDest.Equal[${destSupply}]}
	{
		call DebugOut "VG: at Supply NPC, buy/sell"
		cTarget:Set[${cSupplyNPC}]

		; Stock UP!
		cState:Set[CS_SUPPLY]
	}
	elseif ${nextDest.Equal[${destRepair}]}
	{
		Call DebugOut "VG: at Repair NPC, repairing items"
		cTarget:Set[${cRepairNPC}]

		; Repairitems
		cState:Set[CS_REPAIR]
	}
}
