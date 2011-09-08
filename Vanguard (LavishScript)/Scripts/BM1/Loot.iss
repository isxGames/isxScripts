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
		wait 100 ${Me.Target.ContainsLoot} || ${Me.IsLooting}
		if ${Me.Target.ContainsLoot} || ${Me.IsLooting}
		{
			if ${Script[BM1].Variable[doLootAll]}
			{
				;; if we are not looting then start looting
				if !${Me.IsLooting}
				{
					Loot:BeginLooting
					wait 10 ${Loot.NumItems}
				}
				
				;; start looting 1 item at a time, gaurantee to get all items
				if ${Me.IsLooting}
				{
					if ${Loot.NumItems}
					{
						variable int i
						for ( i:Set[${Loot.NumItems}] ; ${i}>0 ; i:Dec )
						{
							vgecho Looting: ${Loot.Item[${i}]}
							waitframe
							Loot.Item[${i}]:Loot
						}
					}
					else
					{
						Loot:LootAll
					}
				}
				
				;; this will actually stop everything until you deal with the loot, need a timer of some form to break out
				do
				{
					waitframe
				}
				while ${Me.IsLooting}
			}
		}
	}
}
