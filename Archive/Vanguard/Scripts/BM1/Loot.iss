;===================================================
;===            MAIN SCRIPT                     ====
;===================================================
function main()
{
	;-------------------------------------------
	; LOOP THIS INDEFINITELY
	;-------------------------------------------
	while ${Script[BM1].Variable[isRunning]}
	{
		;; wait 10 seconds until our target is dead
		wait 100 ${Me.Target.IsDead} && ${Me.Target.Type.Equal[Corpse]} && !${GV[bool,bHarvesting]} && !${Me.IsLooting}
		
		;; wait 1/2 second for target to contain loot or we are looting
		wait 5 ${Me.Target.ContainsLoot} || ${Me.IsLooting}
		
		;; let's loot the target!
		if ${Me.Target.IsDead} && ${Me.Target.Type.Equal[Corpse]} && !${GV[bool,bHarvesting]}
		{
			;; only loot if we want to loot
			if ${Script[BM1].Variable[doLootAll]} && ${Me.Target.Distance}<5
			{
				;; if we are not looting then start looting
				if !${Me.IsLooting}
				{
					Loot:BeginLooting
					wait 10 ${Me.IsLooting} && ${Loot.NumItems}
				}
				
				;; start looting 1 item at a time, gaurantee to get all items
				if ${Me.IsLooting}
				{
					if ${Loot.NumItems}
					{
						variable int i
						;; start highest to lowest, last item will close loot
						for ( i:Set[${Loot.NumItems}] ; ${i}>0 ; i:Dec )
						{
							vgecho Looting: ${Loot.Item[${i}]}
							waitframe
							Loot.Item[${i}]:Loot
						}
					}
					else
					{
						;; sometimes, we just have to loot everything if we can't determine how many items to loot
						Loot:LootAll
					}
				}
				
				;; this will actually stop everything until you deal with the loot, need a timer of some form to break out
				wait 10 !${Me.IsLooting}
			}
		}
	}
}
