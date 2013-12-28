/* Movement related code for VGCraft */


/* Target and Start a convo with the Supply NPC */
function:bool TargetSupplyNPC()
{
	; We should already be targeting the NPC
	
	;; Go ahead and attempt to retarget the Supply NPC
	Pawn[exactname,npc,${cSupplyNPC}]:Target
	wait 5

	if ( ${Me.Target(exists)} && (${Me.Target.Distance} < 7) )
	{

		if !${Me.Target.HaveLineOfSightTo}
			call faceloc ${Me.Target.X} ${Me.Target.Y} 15 2

		Merchant:Begin[BuySell]

		wait 5

		return TRUE
	}
	else
	{
		call ErrorOut "VGCraft:: Can not target Supply NPC: ${cSupplyNPC}"
	}

	return FALSE
}


/* Target and Start a convo with Work Order NPC */
function:bool TargetOrderNPC()
{
	; We should already be targeting the NPC

	;; Go ahead and retarget Work Order NPC
	Pawn[exactname,npc,${cWorkNPC}]:Target
	wait 5

	VG:ExecBinding[moveforward,release]
	while ( ${Me.Target(exists)} && (${Me.Target.Distance} == 0) )
	{
		VG:ExecBinding[movebackward]
		face ${X} ${Y}
	}
	VG:ExecBinding[movebackward,release]
	
	if ( ${Me.Target(exists)} && (${Me.Target.Distance} < 7) )
	{
		call DebugOut "VG:TargetOrderNPC called"

		Me.Target:DoubleClick

		if !${Me.Target.HaveLineOfSightTo}
			call faceloc ${Me.Target.X} ${Me.Target.Y} 15 2

		TaskMaster[Crafting]:Begin

		;; wait up to 3 seconds for work orders to appear in list
		wait 30 ${TaskMaster[Crafting].AvailWorkOrderCount} >= 1
		

		return TRUE
	}
	else
	{
		call ErrorOut "VGCraft:: Can not Target Work Order NPC: ${cWorkNPC}"
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
			call ErrorOut "VGCraft:: ERROR: No Recipe Crafting Station Set"
			return FALSE
		}
	}
	elseif ( !${cStation(exists)} || ${cStation.Equal[NONE]} )
	{
		; They did not set the station with the UI button
		call ErrorOut "VGCraft:: ERROR: No Crafting Station Set"
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
	
	wait 5

	if ( !${Me.Target(exists)} || (${Me.Target.Distance} > 5) )
	{
		call DebugOut "VG:TargetStation to far away"
		return FALSE
	}

	if ${Math.Abs[${Me.Heading} - ${Me.Target.HeadingTo}]} > 40
		call faceloc ${Me.Target.X} ${Me.Target.Y} 45 2

	if ${Me.Target.Distance} > ${objPrecision}
	{
		; Nope, no good
		call ErrorOut "VGCraft:: Too far from station: ${cStation} :: ${Me.Target.Distance}"
		farAwayError:Set[TRUE]
		return FALSE
	}

	while ( ${Me.Target(exists)} && (${Me.Target.Distance} == 0) )
	{
		VG:ExecBinding[movebackward]
		face ${X} ${Y}
	}
	VG:ExecBinding[movebackward,release]	
	
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
		call DebugOut "VGCraft:: No TARGET set in TargetLOS"
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
	variable float xDist
	variable float SavDist = ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}
	variable int xTimer
	variable int FullTimer	

	; Start Moving!

	if ( ${cTargetID} == 0 )
	{
		call ErrorOut "VGCraft:: Missing move target ID"
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

/* AWSOME ROUTINE... WE NEED TO USE THIS IF WE BUMPED INTO A OBSTACLE BECAUSE RIGHT NOW THE COLLISION CAN BE ANYWHERE
	if ${VG.CheckCollision[${Me.Target.X},${Me.Target.Y},${Me.Z}](exists)}
	{
		; Collision detected, so start over from the top
		if ${cTarget.Equal[${cWorkNPC}]}
		{
			call DebugOut "VG:MoveToTarget: cWorkNPC CheckCollision returned TRUE"
			cState:Set[CS_MOVE_TARGWAIT]
			return
		}
		else
		{
			call ErrorOut "VG:MoveToTarget: CheckCollision to Target returned true!"
			call ErrorOut "VG:MoveToTarget: Trying to move around it...."
			face
			VG:ExecBinding[movebackward]
			wait 5
			VG:ExecBinding[movebackward,release]
			wait 2
			VG:ExecBinding[strafeLeft]
			wait 5
			VG:ExecBinding[strafeLeft,release]
			
			if ${VG.CheckCollision[${Me.Target.X},${Me.Target.Y},${Me.Z}](exists)}
			{
				VG:ExecBinding[movebackward]
				wait 5
				VG:ExecBinding[movebackward,release]
				wait 2
				VG:ExecBinding[strafeRight]
				wait 5
				VG:ExecBinding[strafeRight,release]
			}
			
			if ${VG.CheckCollision[${Me.Target.X},${Me.Target.Y},${Me.Z}](exists)}
			{
				call ErrorOut "VG:MoveToTarget: There is still a collision... let's see if we've targeted the wrong thing..."
				variable index:pawn Pawns
				variable int i = 1
				variable int PawnsCount = 0
				PawnsCount:Set[${VG.GetPawns[Pawns,${Me.Target.Name}]}]
				;echo Populating Pawns List:: ${PawnsCount} pawns total
				do
				{
					if !${VG.CheckCollision[${Pawns.Get[${i}].X},${Pawns.Get[${i}].Y},${Me.Z}](exists)}
					{
						press esc
						wait 2
						;echo "*** ${Pawns.Get[${i}]} -- ${Pawns.Get[${i}].Distance}"
						Pawns.Get[${i}]:Target
						wait 10
						cState:Set[CS_MOVE_TOTARGET]
						return
					}
					;echo "${i}. ${Pawns.Get[${i}].Name} - ${Pawns.Get[${i}].CheckCollision(exists)}"
				}
				while ${i:Inc} <= ${PawnsCount}
				GlobalPanicAttack:Inc
				
				if ${GlobalPanicAttack} > 4
				{
					;; Otherwise, we have a major problem ...and should shut down...
					call ErrorOut "VG:MoveToTarget:  Couldn't find any thing within range that is collision free -- the path file for this area should probably be redone more carefully."
					call DebugOut "VG:MoveToTarget:  Couldn't find any thing within range that is collision free -- the path file for this area should probably be redone more carefully."
					endscript VGCraft
					return
				}
			}	
		}
	}
*/

	call DebugOut "VGCraft:: Moving to Found Target: ${cTargetID}"

	; Set wait STATE
	cState:Set[CS_MOVE_WAIT]


	; Path got us close, let's finish off the move
	if ${farAwayError}
	{
		call DebugOut "VGCraft:: Too far away, get closer!"
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

	call DebugOut "VGCraft:: State to CS_MOVE_DONE"
}

/* *************************************************************************** */

/* Get back onto a mapped square that also has connections to somewhere else */
function:bool MoveToMap()
{
	call ErrorOut "VGCraft:: Error: Not on MAP, MoveToMap called"
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
			call DebugOut "VGCraft:: FindMoveTarget: Pawn:Target(exists): ${Pawn[${cTarget}].Name}"

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
function:string MoveTargetPath(string aTarget, int64 aTargetID)
{
	variable string sTest = "NO"

	if ${cTarget.Equal[${cWorkNPC}]}
		call DebugOut "VG:MoveTargetPath called: ${aTarget} :: ${aTargetID}"
	else
		call DebugOut "VG:MoveTargetPath called: ${aTarget} :: ${aTargetID}"

	if !${Pawn[id,${aTargetID}](exists)}
	{
		return "NO TARGET"
	}

	if ${Pawn[id,${aTargetID}](exists)} && (${Pawn[id,${aTargetID}].Distance} <= ${objPrecision}) && (${Pawn[id,${aTargetID}].Distance} > 0)
	{
		call DebugOut "VG:MoveTargetPath: already close! :: ${Pawn[id,${aTargetID}].Distance}"
		return "END"
	}

	isMoving:Set[TRUE]

	while !${sTest.Equal[END]}
	{
		if ${aTarget.Equal[${cWorkNPC}]}
			call navi.MovetoTargetID "${aTargetID}" TRUE
		else
			call navi.MovetoTargetID "${aTargetID}" FALSE

		sTest:Set[${Return}]
		
		if ${sTest.Equal[NO MAP]}
		{
			call ErrorOut "VG:ERROR: MTP: navi returned NO MAP"
			isMoving:Set[FALSE]
			VG:ExecBinding[moveforward,release]
			VG:ExecBinding[movebackward,release]
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

	;; Retarget our pawn now that we should be at location
	Pawn[exactname,${cTarget}]:Target
	wait 5
	VG:ExecBinding[moveforward,release]
	while ${Math.Distance[${Me.X},${Me.Y},${Me.Target.X},${Me.Target.Y}]}<100
	{
		VG:ExecBinding[movebackward]
		face ${Me.Target.X} ${Me.Target.Y}
	}
	VG:ExecBinding[movebackward,release]	
	
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

	call DebugOut "VGCraft:: MoveAlongPath called"

	wait 5

	; Where are we going?
	if ${nextDest.Equal[${destStation}]}
	{
		call DebugOut "VGCraft:: Move to Crafting Station: ${cStation} "
		cTarget:Set[${cStation}]
		cTargetLoc:Set[${stationLoc}]
	}
	elseif ${nextDest.Equal[${destWorkSearch}]}
	{
		call DebugOut "VGCraft:: Move to WO NPC Search spot: ${woNPCSearch} "
		cTarget:Set[${woNPCSearch}]
		cTargetLoc:Set[${workLoc}]
	}
	elseif ${nextDest.Equal[${destWork}]}
	{
		call DebugOut "VGCraft:: Move to WO NPC: ${cWorkNPC} "
		cTarget:Set[${cWorkNPC}]
		cTargetLoc:Set[${workLoc}]
	}
	elseif ${nextDest.Equal[${destSupply}]}
	{
		call DebugOut "VGCraft:: Move to Supply NPC: ${cSupplyNPC} "
		cTarget:Set[${cSupplyNPC}]
		cTargetLoc:Set[${supplyLoc}]
	}
	elseif ${nextDest.Equal[${destRepair}]}
	{
		call DebugOut "VGCraft:: Move to Repair NPC: ${cRepairNPC} "
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
	VG:ExecBinding[moveforward,release]
	VG:ExecBinding[movebackward,release]
	
	;; Retarget our pawn now that we should be at location
	Pawn[exactname,${cTarget}]:Target
	wait 5
	
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

	;; Retarget our pawn now that we are at location
	Pawn[exactname,${cTarget}]:Target
	wait 5

	call DebugOut "VGCraft:: MoveDone called :: Distance: ${Me.Target.Distance}"

	isMoving:Set[FALSE]

	if ( ${Me.Target.Distance} > 5 )
	{
		call DebugOut "VGCraft:: Not close enough to target (${Me.Target.Distance}), move again"
		; Hmmm, we are not close enough to our target -- Try again!
		cState:Set[CS_MOVE]
		return
	}

	VG:ExecBinding[moveforward,release]
	while ${Math.Distance[${Me.X},${Me.Y},${Me.Target.X},${Me.Target.Y}]}<100
	{
		VG:ExecBinding[movebackward]
		face ${${Me.Target.X} ${Me.Target.Y}
	}
	VG:ExecBinding[movebackward,release]	

	if ${nextDest.Equal[${destStation}]}
	{
		call DebugOut "VGCraft:: at Station, start working" 1
		cTarget:Set[${cStation}]

		; Start Working at the Crafting Station
		cState:Set[CS_STATION]
	}
	elseif ${nextDest.Equal[${destWorkSearch}]}
	{
		call DebugOut "VGCraft:: at WO NPC Search Spot, look for NPC"

		; Set our new Target
		cTarget:Set[${cWorkNPC}]
		nextDest:Set[${destWork}]

		; Keep moving
		cState:Set[CS_MOVE_FIND]
	}
	elseif ${nextDest.Equal[${destWork}]}
	{
		call DebugOut "VGCraft:: at WO NPC, get some"
		cTarget:Set[${cWorkNPC}]

		; Work Orders, Turn in Old and get New
		cState:Set[CS_ORDER]
	}
	elseif ${nextDest.Equal[${destSupply}]}
	{
		call DebugOut "VGCraft:: at Supply NPC, buy/sell"
		cTarget:Set[${cSupplyNPC}]

		; Stock UP!
		cState:Set[CS_SUPPLY]
	}
	elseif ${nextDest.Equal[${destRepair}]}
	{
		Call DebugOut "VGCraft:: at Repair NPC, repairing items"
		cTarget:Set[${cRepairNPC}]

		; Repairitems
		cState:Set[CS_REPAIR]
	}
}
