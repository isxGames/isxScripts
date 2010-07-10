function Loot()
{
	;; return if we do not want to loot
	if !${doLoot}
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
	if ${Me.Target.Type.Equal[Corpse]} && !${Me.Target.IsHarvestable} && ${Me.Target.ContainsLoot} && ${Me.Target.Distance}<5
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
						echo "*Looted ${Loot.Item[${a}]}"
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
					echo "*Looting ${Loot.Item[${a}]}"
					Loot.Item[${a}]:Loot
					waitframe
				}
			}
		}
		
		;; End Looting
		if ${Me.IsLooting}
		{
			wait 1
			Loot:EndLooting
		}

		;; Clear Target - this is a MUST if you are tanking and other's are assisting!
		VGExecute "/cleartargets"
		wait 3
	}

	;;  === Scan area to loot ===
	
	;; Return if there are no corpses
	if !${Pawn[Corpse](exists)}
	{
		return
	}
	
	;; 
	if (!${Me.InCombat} || ${Me.Encounter} == 0)
	{
		iCount:Set[1]

		; Cycle through all the Pawns and find some corpses to Loot and Skin
		do
		{
			if ${Pawn[${iCount}].Type.Equal[Corpse]} && ${Pawn[${iCount}].Distance}<5 && ${Pawn[${iCount}].ContainsLoot}
			{
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
								echo "*Looted ${Loot.Item[${a}]}"
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
							echo "*Looted ${Loot.Item[${a}]}"
							Loot.Item[${a}]:Loot
							waitframe
						}
					}
				}
					
				;; End Looting, the wait is so that loot will appear in the chat logs
				if ${Me.IsLooting}
				{
					wait 2
					Loot:EndLooting
				}

				;; Clear Target - this is a MUST if you are tanking and other's are assisting!
				VGExecute "/cleartargets"
				wait 3
			}
		}	
		while ${iCount:Inc} <= ${VG.PawnCount}
	}
}
