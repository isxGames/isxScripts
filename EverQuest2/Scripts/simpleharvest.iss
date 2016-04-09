function main()
{
	While 1
	{
		if !${Me.InCombat}
		{
			if ${Actor[resource].Distance} < 7
			{
				Actor[resource]:DoTarget
				while ${Target(exists)} && ${Target.Type.Equal[Resource]} && ${Target.Distance} < 7
				{
					waitframe
					Target:DoubleClick
					waitframe
					while ${Me.CastingSpell}
						waitframe
				}
			}
		}
	}
}