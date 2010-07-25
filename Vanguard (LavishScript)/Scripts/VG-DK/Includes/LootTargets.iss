;===================================================
;===   LOOT & CLEAR TARGET IF TARGET IS DEAD    ====
;===================================================
function LootTargets()
{
	;; Go find a lootable target
	if !${Me.Target(exists)}
	{
		call FindLootableTargets
	}

	;; Try to loot the target
	if ${Me.Target(exists)}
	{
		;; execute only if target is a corpse
		if ${Me.Target.Type.Equal[Corpse]} && ${Me.Target.IsDead}
		{
			;; Return if we are harvesting
			while ${GV[bool,bHarvesting]}
			{
				CurrentAction:Set[Harvesting]
				FURIOUS:Set[FALSE]
				return
			}

			;; Loot everything
			call LootCurrentTarget
			
			;; Return if we are still looting
			while ${Me.IsLooting}
			{
				CurrentAction:Set[Looting]
				FURIOUS:Set[FALSE]
				return
			}

			;; Clear targets
			CurrentAction:Set[Clearing Targets]
			VGExecute "/cleartargets"
			FURIOUS:Set[FALSE]
			call ChangeForm
			EchoIt "---------------------------------"

			;; wait long enough
			wait 1
		}
	}

	;; Clear our collections every 10 seconds
	if ${doClearLoot}
	{
		LootBlackList:Clear
		TimedCommand 100 Script[VG-DK].Variable[doClearLoot]:Set[TRUE]
		doClearLoot:Set[FALSE]
	}
}

;; These are collection variables for looting
variable collection:int64 LootBlackList
variable bool doClearLoot=TRUE

function LootCurrentTarget()
{
	;; return if we do not want to loot
	if !${doLoot}
	{
		return
	}

	;; return if we do not want to loot while in combat
	if !${doLootInCombat} && ${Me.InCombat}
	{
		return
	}

	;; return if we do not want to loot whil in a raid
	if !${doRaidLoot} && ${Group.Count} > 6
	{
		return
	}

	;; Declare our variables
	variable int i

	;; Loot routine if target is a corpse
	if !${Me.Target.IsHarvestable} && ${Me.Target.ContainsLoot} && ${Me.Target.Distance}<5
	{
		wait ${LootDelay}
	
		;; Start Loot Window
		Loot:BeginLooting
		wait 10 ${Loot.NumItems} || !${Me.Target(exists)}

		;; Ready to loot
		if ${Loot.NumItems}
		{
			;; Loot only the item we want
			if ${doLootOnly}
			{
				for ( i:Set[1] ; ${i}<=${Loot.NumItems} ; i:Inc )
				{
					if ${LootOnly.Equal[${Loot.Item[${i}]}]}
					{
						if ${doLootEcho}
						{
							vgecho "*Looted:  ${Loot.Item[${i}]}"
							waitframe
						}
						Loot.Item[${LootOnly}]:Loot
						waitframe
					}
				}
			}
			;; Loot everything
			if !${doLootOnly}
			{
				if ${doLootEcho}
				{
					;; Loot everything 1 at a time!
					for ( i:Set[1] ; ${i}<=${Loot.NumItems} ; i:Inc )
					{
						vgecho "*Looted:  ${Loot.Item[${i}]}"
						waitframe
						if ${i}<${Loot.NumItems}
						{
							Loot.Item[${i}]:Loot
						}
						else
						{
							Loot:LootAll
						}
					}
				}
				else
				{
					;; Loot everything but may miss some items due to Collects
					Loot:LootAll
				}
			}
			wait 1
		}
		
		;; End Looting
		if ${Me.IsLooting}
		{
			;; Unlootable item, try to loot the last item
			Loot.Item[${Loot.NumItems}]:Loot
			wait 1
			Loot:EndLooting
			wait 3
		}

		return
	}
}

function FindLootableTargets()
{
	;; return if we do not want to loot
	if !${doLoot}
	{
		return
	}

	;; return if we do not want to loot whil in a raid
	if !${doRaidLoot} && ${Group.Count} > 6
	{
		return
	}

	;; Don't scan area if we are in combat
	if ${Me.InCombat} || ${Me.Encounter}>0
	{
		return
	}

	;; Return if there are no corpses
	if !${Pawn[Corpse](exists)}
	{
		return
	}
	
	;; declare our variables
	variable int i
	
	;; define our variables
	variable int PawnCount
	PawnCount:Set[${VG.PawnCount}]

	;; Cycle through all the Pawns and find some corpses to Loot and Skin
	for ( i:Set[1] ; ${i}<=${PawnCount} ; i:Inc )
	{
		if ${Pawn[${i}].Type.Equal[Corpse]} && ${Pawn[${i}].Distance}<5 && ${Pawn[${i}].ContainsLoot}
		{
			;-------------------------------------------
			; Exclude things we don't want
			;-------------------------------------------
			if ${LootBlackList.Element[${Pawn[${i}].ID}](exists)}
				continue

			;-------------------------------------------
			; BlackList the target from future scans
			;-------------------------------------------
			if !${LootBlackList.Element[${Pawn[${i}].ID}](exists)}
				LootBlackList:Set[${Pawn[${i}].ID}, ${Pawn[${i}].ID}]
			
			Pawn[${i}]:Target
			wait 10 ${Me.Target(exists)} && ${Me.Target.ContainsLoot}
			return
		}
	}	
}
