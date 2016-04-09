function main()
{
		if (!${Me.Target.ContainsLoot})
		{
			return
		}
	
		Me.Target:Loot

		do 
		{
			wait 1
		}
		while !${Me.IsLooting}
		
		
		
		if (${Loot.NumItems} > 0)
		{
			  wait 1
			  Loot:LootAll
			  return
		}
		
		Loot:EndLooting
		return
}