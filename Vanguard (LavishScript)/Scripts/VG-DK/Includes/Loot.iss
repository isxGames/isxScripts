variable collection:int64 LootBlackList
variable bool doClearLoot=TRUE


function Loot()
{
	;; return if we do not want to loot
	if !${doLoot}
	{
		return
	}
	
	if ${Me.InCombat} && !${doLootInCombat}
	{
		return
	}

	;; Safety - no looting while in Raid
	if !${doRaidLoot} && ${Group.Count} > 6
	{
		return
	}
	
	;; Setup our variables
	variable int a
	variable int iCount

	;; Loot routine if target is a corpse
	if ${Me.Target.Type.Equal[Corpse]} && !${Me.Target.IsHarvestable} && ${Me.Target.ContainsLoot} && ${Me.Target.Distance}<5 && ${doLootInCombat}
	{
		;; Start Loot Window
		Loot:BeginLooting
		wait 10 ${Loot.NumItems} || !${Me.Target(exists)}

		;; Ready to loot
		if ${Loot.NumItems}
		{
			;; Loot only the item we want
			if ${doLootOnly}
			{
				for ( a:Set[1] ; ${a}<=${Loot.NumItems} ; a:Inc )
				{
					if ${LootOnly.Equal[${Loot.Item[${a}]}]}
					{
						if ${doLootEcho}
						{
							vgecho "*Looted:  ${Loot.Item[${a}]}"
							waitframe
						}
						Loot.Item[${LootOnly}]:Loot
						waitframe
					}
				}
			}
			;; Loot everything 1 at a time!
			if !${doLootOnly}
			{
				for ( a:Set[1] ; ${a}<=${Loot.NumItems} ; a:Inc )
				{
					if ${doLootEcho}
					{
						vgecho "*Looted:  ${Loot.Item[${a}]}"
						waitframe
					}
					if ${a}<${Loot.NumItems}
					{
						Loot.Item[${a}]:Loot
					}
					else
					{
						Loot:LootAll
					}
				}
			}
			wait 3
		}
		
		;; End Looting
		;if ${Me.IsLooting}
		;{
		;	wait 3
		;	Loot:EndLooting
		;}

		;; Clear Target - this is a MUST if you are tanking and other's are assisting!
		CurrentAction:Set[Clearing Targets]
		VGExecute "/cleartargets"
		wait 5
		call ChangeForm
		EchoIt "---------------------------------"

		if ${Me.IsLooting}
		{
			Loot:EndLooting
			wait 3
		}

		;; update stats
		FURIOUS:Set[FALSE]
		return
	}

	;;  === Scan area to loot ===
	
	;; Return if there are no corpses
	if !${Pawn[Corpse](exists)}
	{
		return
	}
	
	;; Don't scan area if we are in combat
	if ${Me.InCombat} || ${Me.Encounter}>0
	{
		return
	}
	
	iCount:Set[1]
		
	; Cycle through all the Pawns and find some corpses to Loot and Skin
	do
	{
		if ${Pawn[${iCount}].Type.Equal[Corpse]} && ${Pawn[${iCount}].Distance}<5 && ${Pawn[${iCount}].ContainsLoot}
		{
			;-------------------------------------------
			; Exclude things we don't want
			;-------------------------------------------
			if ${LootBlackList.Element[${Pawn[${iCount}].ID}](exists)}
				continue
			;-------------------------------------------
			; BlackList the target from future scans
			;-------------------------------------------
			if !${LootBlackList.Element[${Pawn[${iCount}].ID}](exists)}
				LootBlackList:Set[${Pawn[${iCount}].ID}, ${Pawn[${iCount}].ID}]
		
			CurrentAction:Set[Looting]
			Pawn[${iCount}]:Target
			wait ${LootDelay}
			;; Start Loot Window
			Loot:BeginLooting
			wait 10 ${Loot.NumItems}

			;; Ready to loot
			if ${Loot.NumItems}
			{
				;; Loot only the item we want
				if ${doLootOnly}
				{
					for ( a:Set[1] ; ${a}<=${Loot.NumItems} ; a:Inc )
					{
						if ${LootOnly.Equal[${Loot.Item[${a}]}]}
						{
							if ${doLootEcho}
							{
								vgecho "**Looted:  ${Loot.Item[${a}]}"
								waitframe
							}
							Loot.Item[${LootOnly}]:Loot
							waitframe
						}
					}
					Loot.Item[${LootOnly}]:Loot
				}
				;; Loot everything 1 at a time!
				if !${doLootOnly}
				{
					for ( a:Set[1] ; ${a}<=${Loot.NumItems} ; a:Inc )
					{
						if ${doLootEcho}
						{
							vgecho "*Looted:  ${Loot.Item[${a}]}"
							waitframe
						}
						if ${a}<${Loot.NumItems}
						{
							Loot.Item[${a}]:Loot
						}
						else
						{
							Loot:LootAll
						}
					}
				}
				wait 3
			}
					

			;; Clear Target - this is a MUST if you are tanking and other's are assisting!
			CurrentAction:Set[Clearing Targets]
			VGExecute "/cleartargets"
			wait 5
			call ChangeForm
			EchoIt "---------------------------------"

			if ${Me.IsLooting}
			{
				Loot:EndLooting
				wait 3
			}
		
			;; update stats
			FURIOUS:Set[FALSE]
		}
	}	
	while ${iCount:Inc} <= ${VG.PawnCount}

	;; Clear our collections every 10 seconds
	if ${doClearLoot}
	{
		LootBlackList:Clear
		TimedCommand 10 Script[VG-DK].Variable[doClearLoot]:Set[TRUE]
		doClearLoot:Set[FALSE]
	}
	
}
