
;********************************************
/* Add item to the OpeningSeqMelee list */
;********************************************
atom(global) AddOpeningMeleeSequence(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		If ${LavishSettings[VGA].FindSet[OpeningMeleeSequence].FindSetting[${aName} (3)](exists)}
		LavishSettings[VGA].FindSet[OpeningMeleeSequence]:AddSetting[${aName} (4), ${aName}]
		If ${LavishSettings[VGA].FindSet[OpeningMeleeSequence].FindSetting[${aName} (2)](exists)}
		LavishSettings[VGA].FindSet[OpeningMeleeSequence]:AddSetting[${aName} (3), ${aName}]
		If ${LavishSettings[VGA].FindSet[OpeningMeleeSequence].FindSetting[${aName}](exists)}
		LavishSettings[VGA].FindSet[OpeningMeleeSequence]:AddSetting[${aName} (2), ${aName}]
		LavishSettings[VGA].FindSet[OpeningMeleeSequence]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveOpeningMeleeSequence(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		OpeningMeleeSequence.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildOpeningMeleeSequence()
{
	variable iterator Iterator
	OpeningMeleeSequence:GetSettingIterator[Iterator]
	UIElement[OpeningMeleeSequenceList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[OpeningMeleeSequenceList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the CombatSeqMelee list */
;********************************************
atom(global) AddCombatMeleeSequence(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		If ${LavishSettings[VGA].FindSet[CombatMeleeSequence].FindSetting[${aName} (3)](exists)}
		LavishSettings[VGA].FindSet[CombatMeleeSequence]:AddSetting[${aName} (4), ${aName}]
		If ${LavishSettings[VGA].FindSet[CombatMeleeSequence].FindSetting[${aName} (2)](exists)}
		LavishSettings[VGA].FindSet[CombatMeleeSequence]:AddSetting[${aName} (3), ${aName}]
		If ${LavishSettings[VGA].FindSet[CombatMeleeSequence].FindSetting[${aName}](exists)}
		LavishSettings[VGA].FindSet[CombatMeleeSequence]:AddSetting[${aName} (2), ${aName}]
		LavishSettings[VGA].FindSet[CombatMeleeSequence]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveCombatMeleeSequence(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		CombatMeleeSequence.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildCombatMeleeSequence()
{
	variable iterator Iterator
	CombatMeleeSequence:GetSettingIterator[Iterator]
	UIElement[CombatMeleeSequenceList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[CombatMeleeSequenceList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the AOEMelee list */
;********************************************
atom(global) AddAOEMelee(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[AOEMelee]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveAOEMelee(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		AOEMelee.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildAOEMelee()
{
	variable iterator Iterator
	AOEMelee:GetSettingIterator[Iterator]
	UIElement[AOEMeleeList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[AOEMeleeList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the DotMelee list */
;********************************************
atom(global) AddDotMelee(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[DotMelee]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		echo ${aName}
	}
}
atom(global) RemoveDotMelee(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		DotMelee.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildDotMelee()
{
	variable iterator Iterator
	DotMelee:GetSettingIterator[Iterator]
	UIElement[DotMeleeList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DotMeleeList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the DebuffMelee list */
;********************************************
atom(global) AddDebuffMelee(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[DebuffMelee]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveDebuffMelee(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		DebuffMelee.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildDebuffMelee()
{
	variable iterator Iterator
	DebuffMelee:GetSettingIterator[Iterator]
	UIElement[DebuffMeleeList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DebuffMeleeList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;******************************CombatLists***********************
function PopulateMeleeLists()
{
	variable int i

	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		UIElement[OpeningMeleeSequenceCombo@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[CombatMeleeSequenceCombo@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[AOEMeleeCombo@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[DotMeleeCombo@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[DebuffMeleeCombo@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[cmbKillingBlow@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
	}
	variable iterator Iterator
	OpeningMeleeSequence:GetSettingIterator[Iterator]
	UIElement[OpeningMeleeSequenceList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[OpeningMeleeSequenceList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	DebuffMelee:GetSettingIterator[Iterator]
	UIElement[DebuffMeleeList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DebuffMeleeList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	DotMelee:GetSettingIterator[Iterator]
	UIElement[DotMeleeList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DotMeleeList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	AOEMelee:GetSettingIterator[Iterator]
	UIElement[AOEMeleeList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[AOEMeleeList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	CombatMeleeSequence:GetSettingIterator[Iterator]
	UIElement[CombatMeleeSequenceList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[CombatMeleeSequenceList@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	variable int rCount
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[cmbKillingBlow@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Items}
	{
		if ${UIElement[cmbKillingBlow@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui].Item[${rCount}].Text.Equal[${KillingBlow}]}
		UIElement[cmbKillingBlow@MeleeCFrm@Melee@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:SelectItem[${rCount}]
	}
}



