

;********************************************
/* Add item to the OpeningSeqSpell list */
;********************************************
atom(global) AddOpeningSpellSequence(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		If ${LavishSettings[VGA].FindSet[OpeningSpellSequence].FindSetting[${aName} (3)](exists)}
		LavishSettings[VGA].FindSet[OpeningSpellSequence]:AddSetting[${aName} (4), ${aName}]
		If ${LavishSettings[VGA].FindSet[OpeningSpellSequence].FindSetting[${aName} (2)](exists)}
		LavishSettings[VGA].FindSet[OpeningSpellSequence]:AddSetting[${aName} (3), ${aName}]
		If ${LavishSettings[VGA].FindSet[OpeningSpellSequence].FindSetting[${aName}](exists)}
		LavishSettings[VGA].FindSet[OpeningSpellSequence]:AddSetting[${aName} (2), ${aName}]
		LavishSettings[VGA].FindSet[OpeningSpellSequence]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveOpeningSpellSequence(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		OpeningSpellSequence.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildOpeningSpellSequence()
{
	variable iterator Iterator
	OpeningSpellSequence:GetSettingIterator[Iterator]
	UIElement[OpeningSpellSequenceList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[OpeningSpellSequenceList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the CombatSeqSpell list */
;********************************************
atom(global) AddCombatSpellSequence(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		If ${LavishSettings[VGA].FindSet[CombatSpellSequence].FindSetting[${aName} (3)](exists)}
		LavishSettings[VGA].FindSet[CombatSpellSequence]:AddSetting[${aName} (4), ${aName}]
		If ${LavishSettings[VGA].FindSet[CombatSpellSequence].FindSetting[${aName} (2)](exists)}
		LavishSettings[VGA].FindSet[CombatSpellSequence]:AddSetting[${aName} (3), ${aName}]
		If ${LavishSettings[VGA].FindSet[CombatSpellSequence].FindSetting[${aName}](exists)}
		LavishSettings[VGA].FindSet[CombatSpellSequence]:AddSetting[${aName} (2), ${aName}]
		LavishSettings[VGA].FindSet[CombatSpellSequence]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveCombatSpellSequence(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		CombatSpellSequence.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildCombatSpellSequence()
{
	variable iterator Iterator
	CombatSpellSequence:GetSettingIterator[Iterator]
	UIElement[CombatSpellSequenceList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[CombatSpellSequenceList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the AOESpell list */
;********************************************
atom(global) AddAOESpell(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[AOESpell]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveAOESpell(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		AOESpell.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildAOESpell()
{
	variable iterator Iterator
	AOESpell:GetSettingIterator[Iterator]
	UIElement[AOESpellList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[AOESpellList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the DotSpell list */
;********************************************
atom(global) AddDotSpell(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[DotSpell]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		echo ${aName}
	}
}
atom(global) RemoveDotSpell(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		DotSpell.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildDotSpell()
{
	variable iterator Iterator
	DotSpell:GetSettingIterator[Iterator]
	UIElement[DotSpellList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DotSpellList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;********************************************
/* Add item to the DebuffSpell list */
;********************************************
atom(global) AddDebuffSpell(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[DebuffSpell]:AddSetting[${aName}, ${aName}]
	}
	else
	{
		return
	}
}
atom(global) RemoveDebuffSpell(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		DebuffSpell.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildDebuffSpell()
{
	variable iterator Iterator
	DebuffSpell:GetSettingIterator[Iterator]
	UIElement[DebuffSpellList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DebuffSpellList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}
;******************************CombatLists***********************
function PopulateSpellLists()
{
	variable int i

	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${Me.Ability[${i}].Type.Equal[Spell]}
		{
			UIElement[OpeningSpellSequenceCombo@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[CombatSpellSequenceCombo@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[AOESpellCombo@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[DotSpellCombo@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[DebuffSpellCombo@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		}
	}
	variable iterator Iterator
	OpeningSpellSequence:GetSettingIterator[Iterator]
	UIElement[OpeningSpellSequenceList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[OpeningSpellSequenceList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	DebuffSpell:GetSettingIterator[Iterator]
	UIElement[DebuffSpellList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DebuffSpellList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	DotSpell:GetSettingIterator[Iterator]
	UIElement[DotSpellList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[DotSpellList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	AOESpell:GetSettingIterator[Iterator]
	UIElement[AOESpellList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[AOESpellList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
	CombatSpellSequence:GetSettingIterator[Iterator]
	UIElement[CombatSpellSequenceList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[CombatSpellSequenceList@SpellsCFrm@Spells@CombatSubTab@CombatFrm@Combat@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
}



