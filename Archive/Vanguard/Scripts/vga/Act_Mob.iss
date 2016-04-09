function:bool mobresist(string x_ability)
{
	variable iterator Iterator
	If ${MobResists.Fire}
	{
		FireA:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if ${x_ability.Equal[${Iterator.Key}]}
			{
				debuglog "NO FIRE!!!"
				return FALSE
			}
			Iterator:Next
		}
	}

	If ${MobResists.Ice}
	{
		IceA:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if ${x_ability.Equal[${Iterator.Key}]}
			{
				debuglog "No ICE!!!"
				return FALSE
			}
			Iterator:Next
		}
	}
	If ${MobResists.Spiritual}
	{
		SpiritualA:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if ${x_ability.Equal[${Iterator.Key}]}
			{
				debuglog "No Spiritual!!!"
				return FALSE
			}
			Iterator:Next
		}
	}
	If ${MobResists.Physical}
	{
		PhysicalA:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if ${x_ability.Equal[${Iterator.Key}]}
			{
				debuglog "No PHYSICAL!!!"
				return FALSE
			}
			Iterator:Next
		}
	}
	If ${MobResists.Arcane}
	{
		ArcaneA:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if ${x_ability.Equal[${Iterator.Key}]}
			{
				debuglog "NO ARCANE!!!"
				return FALSE
			}
			Iterator:Next
		}
	}
	return TRUE
}


