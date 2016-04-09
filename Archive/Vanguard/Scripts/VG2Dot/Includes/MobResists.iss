;********************************************
/*     Add item to the Arcane list         */
;********************************************
atom(global) AddArcane(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[MobResists].FindSet[Arcane]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		echo ${aName}
	}
}
atom(global) RemoveArcane(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Arcane.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildArcane()
{
	variable iterator Iterator
	Arcane:GetSettingIterator[Iterator]
	UIElement[ArcaneList@MobsCFrm@Mobs@VGT@VG2Dot]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ArcaneList@MobsCFrm@Mobs@VGT@VG2Dot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}


;********************************************
/*        Add item to the Physical list    */
;********************************************
atom(global) AddPhysical(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[MobResists].FindSet[Physical]:AddSetting[${aName}, ${aName}]
	}
	else
	{
	}
}
atom(global) RemovePhysical(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Physical.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildPhysical()
{
	variable iterator Iterator
	Physical:GetSettingIterator[Iterator]
	UIElement[PhysicalList@MobsCFrm@Mobs@VGT@VG2Dot]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[PhysicalList@MobsCFrm@Mobs@VGT@VG2Dot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}


;********************************************
/*        Add item to the Fire list         */
;********************************************
atom(global) AddFire(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[MobResists].FindSet[Fire]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveFire(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Fire.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildFire()
{
	variable iterator Iterator
	Fire:GetSettingIterator[Iterator]
	UIElement[FireList@MobsCFrm@Mobs@VGT@VG2Dot]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[FireList@MobsCFrm@Mobs@VGT@VG2Dot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}


;********************************************
/*      Add item to the ColdIce list      */
;********************************************
atom(global) AddColdIce(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[MobResists].FindSet[ColdIce]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveColdIce(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		ColdIce.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildColdIce()
{
	variable iterator Iterator
	ColdIce:GetSettingIterator[Iterator]
	UIElement[ColdIceList@MobsCFrm@Mobs@VGT@VG2Dot]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[ColdIceList@MobsCFrm@Mobs@VGT@VG2Dot]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}

objectdef MobResists
{
	member:string Type()
	{
		variable iterator Iterator

		;; ARCANE
		Arcane:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if ${Me.Target.Name.Equal[${Iterator.Value}]}
			{
				return Arcane
			}
			Iterator:Next
		}

		;; FIRE
		Fire:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if ${Me.Target.Name.Equal[${Iterator.Value}]}
			{
				return Fire
			}
			Iterator:Next
		}

		;; COLD/ICE
		ColdIce:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if ${Me.Target.Name.Equal[${Iterator.Value}]}
			{
				return ColdIce
			}
			Iterator:Next
		}

		;; PHYSICAL
		Physical:GetSettingIterator[Iterator]
		Iterator:First
		while ( ${Iterator.Key(exists)} )
		{
			if ${Me.Target.Name.Equal[${Iterator.Value}]}
			{
				return Physical
			}
			Iterator:Next
		}

		return None
	}
}

variable MobResists MobResists




