
; *********************************
; **    Find and Target a Mob    **
; *********************************
function:bool FindTarget(int checkDistance)
{
	variable int iCount

	if ${Me.InCombat} || ${Me.Encounter} > 0
	{
		; If we are already in combat, just keep the current Target (unless it's dead)
		if ${Me.Target.IsDead} || ${Me.Target.Type.Equal[CORPSE]} || ${Me.TargetHealth} <= 0
		{
			call DebugIt ".  FindTarget Called -- target IsDead"
			VGExecute /cleartargets
			wait 5
		}
		else
		{
			call DebugIt ".  FindTarget Called, but we already have a good target inCombat"
			return TRUE
		}
		if ${Me.Encounter} > 0
		{
			; Find the next mob in the Encounter that is a valid target
			for (iCount:Set[1] ; ${iCount}<=${Me.Encounter} ; iCount:Inc)
			{
				if ${Me.Encounter[${iCount}].ToPawn.IsDead} || ${Me.Encounter[${iCount}].ToPawn.Type.Equal[CORPSE]}
				{
					continue
				}
				
				;if ${Me.Encounter[${iCount}].Distance} > ${maxPullRange}
				;	continue

				; Ok, Target this one
				Me.Encounter[${iCount}].ToPawn:Target
				call DebugIt ".  FindTarget: target ${Me.Target.Name}"
				wait 5
				return TRUE
			}
			call DebugIt ".  FindTarget Encouter but not able to Target any mobs"
			return FALSE
		}
	}

	; If we are in combat, find Targets that are owned by us
	if ${Me.InCombat}
	{
		for (iCount:Set[1] ; ${iCount} <= ${VG.PawnCount} ; iCount:Inc)
		{
			if ${Pawn[${iCount}].ID} == ${Me.ToPawn.ID}
			{
				continue
			}
			
			if ${Pawn[${iCount}].Owner.Equal[${Me.Name}]}
			{
				Pawn[${iCount}]:Target
				cTargetID:Set[${Pawn[${iCount}].ID}]
				wait 5
				return TRUE
			}
		}
	}

	; We are not in Combat, so find a good Target
	if ${checkDistance} == 0
	{
		checkDistance:Set[${maxRoamingDistance}]
	}

	MinLevel:Set[${Math.Calc[${Me.Level} - ${modMinLevel}].Int}]
	MaxLevel:Set[${Math.Calc[${Me.Level} + ${modMaxLevel}].Int}]

	call DebugIt ".  FindTarget: ${MinLevel} :: ${MaxLevel} :: ${checkDistance}"

	for (iCount:Set[1] ; ${iCount} <= ${VG.PawnCount} ; iCount:Inc)
	{
		if ${Pawn[${iCount}].ID} == ${Me.ToPawn.ID}
		{
			continue
		}

		; First check to see if this ID has been blacklisted
		if ${MobBlackList.Element[${Pawn[${iCount}].ID}](exists)}
		{
			call DebugIt ".  FindTarget: BlackListed: ${Pawn[${iCount}].Name} :: ${Pawn[${iCount}].ID}"
			continue
		}

		call DebugIt ".    Pawn ${iCount}: ${Pawn[${iCount}].Name}  Dist: ${Pawn[${iCount}].Distance}  Con: ${ConCheck}  LOS: ${Pawn[${iCount}].HaveLineOfSightTo}"

		if ${doNonAgroMobs}
		{
			if (${Pawn[${iCount}].Type.Equal[NPC]} || ${Pawn[${iCount}].Type.Equal[AggroNPC]}) && ${Pawn[${iCount}].Distance} < ${checkDistance} && ${Pawn[${iCount}].Level} >= ${MinLevel} && ${Pawn[${iCount}].Level} <= ${MaxLevel} && ${Pawn[${iCount}].HaveLineOfSightTo} && !${Pawn[${iCount}].IsDead}
			{
				Pawn[${iCount}]:Target
				wait 3

				; If we are already in combat, just keep the current Target (unless it's dead)
				if ${Me.Target.IsDead} || ${Me.Target.Type.Equal[CORPSE]} || ${Me.TargetHealth} <= 99
				{
					if ${Me.TargetHealth} <= 99
					{
						call DebugIt ".  FindTarget Called -- target health is below 100"
					}
					else
					{
						call DebugIt ".  FindTarget Called -- target IsDead"
					}
					call BlackListMobID ${Me.Target.ID}
					VGExecute /cleartargets
					wait 5
				}

				; If we are already in combat, just keep the current Target (unless it's dead)
				if ${Me.Target.IsDead} || ${Me.Target.Type.Equal[CORPSE]} || ${Me.TargetHealth} <= 99
				{
					call DebugIt ".  FindTarget Called -- target IsDead"
					call BlackListMobID ${Me.Target.ID}
					VGExecute /cleartargets
					wait 5
				}

				if ${Me.TargetAsEncounter.Difficulty} > ${ConCheck}
				{
					call DebugIt ".  T_Next: too Difficult: ${Me.TargetAsEncounter.Difficulty} > ${ConCheck}"
					call BlackListMobID ${Me.Target.ID}
					echo ".   T_Next: ConCheck overLimit: clearTargets"
					VGExecute /cleartargets
					return FALSE
				}
				else
				{
					call DebugIt ". T_Next: NonAgro Found Target:  ${Pawn[${iCount}].Name}  ID:  ${Pawn[${iCount}].ID}"
					cTargetID:Set[${Pawn[${iCount}].ID}]
					wait 5
					return TRUE
				}
			}
		}
		else
		{
			call TargetOnList "${Pawn[${iCount}].Name}"
			if ${Return} && ${Pawn[${iCount}].Distance} < ${checkDistance} && ${Pawn[${iCount}].Level} >= ${MinLevel} && ${Pawn[${iCount}].Level} <= ${MaxLevel} && ${Pawn[${iCount}].HaveLineOfSightTo} && !${Pawn[${iCount}].IsDead}
			{
				Pawn[${iCount}]:Target
				wait 3

				; If we are already in combat, just keep the current Target (unless it's dead)
				if ${Me.Target.IsDead} || ${Me.Target.Type.Equal[CORPSE]} || ${Me.TargetHealth} <= 99
				{
					call DebugIt ".  FindTarget Called -- target IsDead"
					call BlackListMobID ${Me.Target.ID}
					VGExecute /cleartargets
					wait 5
					return FALSE
				}

				if ${Me.TargetAsEncounter.Difficulty} > ${ConCheck}
				{
					call DebugIt ".  T_Next: too Difficult: ${Me.TargetAsEncounter.Difficulty} > ${ConCheck}"
					call BlackListMobID ${Me.Target.ID}
					echo ".   T_Next ConCheck overLimit: clearTargets"
					VGExecute /cleartargets
					wait 5
					return FALSE
				}
				else
				{
					call DebugIt ".  T_Next: On List:  ${Pawn[${iCount}].Name}  ID:  ${Pawn[${iCount}].ID}"
					cTargetID:Set[${Pawn[${iCount}].ID}]
					wait 5
					Face
					return TRUE
				}
			}
		}
	}

	return FALSE

}

; ***************************************
; **     Add ID to Mob blacklisted     **
; ***************************************
function BlackListMobID(int64 anID)
{
	if !${MobBlackList.Element[${anID}](exists)}
	{
		MobBlackList:Set[${anID},${anID}]
	}
}


; **********************************************************
; **     Check to see if this ID has been blacklisted     **
; **********************************************************
function:bool MobIDBlackListed(int64 anID)
{
	if ${MobBlackList.Element[${anID}](exists)}
	{
		return TRUE
	}
	return FALSE
}

; **********************************************************
; ** Check to see if this Pawn is on the list to attack   **
; **********************************************************
function:bool TargetOnList(string aName)
{
	variable iterator anIter

	; Check to see if aName is on the list
	setPath.FindSet[${Me.Chunk}].FindSet[Mobs]:GetSettingIterator[anIter]
	anIter:First

	while ${anIter.Key(exists)}
	{
		if ${aName.Equal[${anIter.Key}]}
		{
			return TRUE
		}
		anIter:Next
	}
	return FALSE
}


; ************************************************
; **    See if there are any Targets in Range   **
; **
; ** Possible targets include:
; **  Mobs, Corpses or Resources
; ************************************************
function:string TargetInRange(float inX, float inY, float inZ, int checkDistance)
{
	variable int iCount
	variable int iTotal
	variable iterator anIter
	variable index:pawn pIndex

	;call DebugIt ". Starting TargetInRange Routine"

	call DoEvents

	if ${Test_Path}
	{
		return "NONE"
	}

	if ${Me.InCombat} || ${Me.Encounter} > 0
	{
		; If we are already in combat, just keep the current Target (unless it's dead)
		if ${Me.Target(exists)} && ( ${Me.Target.IsDead} || ${Me.Target.Type.Equal[CORPSE]} || ${Me.TargetHealth} <= 0 )
		{
			call DebugIt ".  TargetinRange Called with inCombat TRUE --  but target IsDead"
		}
		else
		{
			call DebugIt ".  TargetinRange Called, but we already have a target inCombat"
			return "MOB"
		}
	}

	if ${checkDistance} == 0
	{
		checkDistance:Set[${maxRoamingDistance}]
	}

	MinLevel:Set[${Math.Calc[${Me.Level} - ${modMinLevel}].Int}]
	MaxLevel:Set[${Math.Calc[${Me.Level} + ${modMaxLevel}].Int}]

	pIndex:Clear

	;iTotal:Set[${VG.GetPawns[pIndex,npc,levels,${MinLevel},${MaxLevel},from,${inX},${inY},${inZ},radius,${checkDistance}]}]
	iTotal:Set[${VG.GetPawns[pIndex,radius,${checkDistance}]}]

	;call DebugIt ".  Pawns List: ${iTotal}"

	for (iCount:Set[1] ; ${iCount} <= ${iTotal} ; iCount:Inc)
	{
		if ${pIndex.Get[${iCount}].ID} == ${Me.ToPawn.ID}
		{
			continue
		}

		; First check to see if this ID has been blacklisted
		if ${MobBlackList.Element[${pIndex.Get[${iCount}].ID}](exists)}
		{
			;call DebugIt ".  FindTarget: BlackListed: ${pIndex.Get[${iCount}].Name} :: ${pIndex.Get[${iCount}].ID}"
			continue
		}

		;call DebugIt ".    Pawn ${iCount}: ${pIndex.Get[${iCount}].Name}  Dist: ${pIndex.Get[${iCount}].Distance}  Con: ${ConCheck}  LOS: ${pIndex.Get[${iCount}].HaveLineOfSightTo}"
		if ${doNonAgroMobs}
		{
			if (${pIndex.Get[${iCount}].Type.Equal[NPC]} || ${pIndex.Get[${iCount}].Type.Equal[AggroNPC]}) && ${pIndex.Get[${iCount}].Distance} < ${checkDistance} && ${pIndex.Get[${iCount}].Level} >= ${MinLevel} && ${pIndex.Get[${iCount}].Level} <= ${MaxLevel} && ${pIndex.Get[${iCount}].HaveLineOfSightTo}
			{
				return "MOB"
			}
		}
		else
		{
			call TargetOnList "${pIndex.Get[${iCount}].Name}"
			if ${Return} && ${pIndex.Get[${iCount}].Distance} < ${checkDistance} && ${pIndex.Get[${iCount}].Level} >= ${MinLevel} && ${pIndex.Get[${iCount}].Level} <= ${MaxLevel} && ${pIndex.Get[${iCount}].HaveLineOfSightTo}
			{
				return "MOB"
			}
		}
	}

/*
	if ${doNonAgroMobs}
	{
		if ${Pawn[npc,AgroNPC,levels,${MinLevel},${MaxLevel},from,${inX},${inY},${inZ},radius,${checkDistance}](exists)}
		{
			return "MOB"
		}
	}
	else
	{
		setPath.FindSet[${Me.Chunk}].FindSet[Mobs]:GetSettingIterator[anIter]
		anIter:First
		
		while ${anIter.Key(exists)}
		{
			if ${Pawn[exactname,${anIter.Key},levels,${MinLevel},${MaxLevel},from,${inX},${inY},${inZ},radius,${checkDistance}](exists)}
			{
				return "MOB"
			}
			anIter:Next
		}
	}
*/

/*
	if ${doLootCorpses}
	{
		pIndex:Clear
		
		; Now look for corpses we can loot
		iTotal:Set[${VG.GetPawns[pIndex,corpse,from,${inX},${inY},${inZ},radius,${checkDistance}]}]
		
		call DebugIt ".  Corpse List: ${iTotal}"
		
		for (iCount:Set[1] ; ${iCount} <= ${iTotal} ; iCount:Inc)
		{
			if ${pIndex.Get[${iCount}].ID} == ${Me.ToPawn.ID}
			{
				continue
			}
			if ${CorpseBlackList.Element[${pIndex.Get[${iCount}].ID}](exists)}
			{
				continue
			}
			
			if ${pIndex.Get[${iCount}].ContainsLoot}
			{
				return "CORPSE"
			}
		}
	}
*/

	; If we want to Harvest, check for that also
	if ${doHarvest}
	{
		setConfig.FindSet[Harvest]:GetSettingIterator[anIter]

		if !${anIter:First(exists)}
		{
			return "NONE"
		}

		while ${anIter.Key(exists)}
		{
			pIndex:Clear
			; Now look for corpses we can loot
			iTotal:Set[${VG.GetPawns[pIndex,resource,radius,${checkDistance},${anIter.Key}]}]

			;call DebugIt ".  Resource (${anIter.Key}) List: ${iTotal}"

			for (iCount:Set[1] ; ${iCount} <= ${iTotal} ; iCount:Inc)
			{
				if ${pIndex.Get[${iCount}].ID} == ${Me.ToPawn.ID}
				{
					continue
				}
				if ${pIndex.Get[${iCount}].Name.Find[remains]}
				{
					;call DebugIt ".  Resource (${anIter.Key}) remains ${pIndex.Get[${iCount}].Name}"
					continue
				}
				if ${HarvestBlackList.Element[${pIndex.Get[${iCount}].ID}](exists)}
				{
					;call DebugIt ".  Resource (${anIter.Key}) BlackListed: ${pIndex.Get[${iCount}].ID}"
					continue
				}
				if ${pIndex.Get[${iCount}].Name.Equal[${anIter.Key}]}
				{
					;HarvestBlackList:Set[${Me.Target.ID},${Me.Target.ID}]
					call DebugIt ".  Resource (${anIter.Key}) FOUND: ${pIndex.Get[${iCount}].Name} at distance of ${pIndex.Get[${iCount}].Distance}"
					return "HARVEST"
				}
			}
			anIter:Next
		}
	}
	return "NONE"
}