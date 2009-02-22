;******************************CombatLists***********************
function PopulateHealLists()
{
	variable int i

	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
	
		if ${Me.Ability[${i}].Type.Equal[Spell]}
			{
			UIElement[BuffCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[CombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[NonCombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[LazyBuffCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[ResStoneCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[hotsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[instantsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[smallsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[bigsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[instantgrouphealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[grouphealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			UIElement[RestoreSpecialCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
			}
	}
	for (i:Set[1] ; ${i} <= ${Me.Form} ; i:Inc)
	{
		UIElement[CombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Form[${i}].Name}]
		UIElement[NonCombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Form[${i}].Name}]
	}

	variable int rCount
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[LazyBuffCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[LazyBuffCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${lazybuff}]}
			UIElement[LazyBuffCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[CombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[CombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${CombatRes}]}
			UIElement[CombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[NonCombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[NonCombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${NonCombatRes}]}
			UIElement[NonCombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[ResStoneCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[ResStoneCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${ResStone}]}
			UIElement[ResStoneCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[instantsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[hotsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${HotHeal}]}
			UIElement[hotsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[instantsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[instantsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${InstantHeal}]}
			UIElement[instantsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[smallsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[smallsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${SmallHeal}]}
			UIElement[smallsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[bigsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[bigsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${BigHeal}]}
			UIElement[bigsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[instantgrouphealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[instantgrouphealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${InstantGroupHeal}]}
			UIElement[instantgrouphealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[grouphealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[grouphealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${GroupHeal}]} 
			UIElement[grouphealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[CombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[CombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${CombatStance}]}
			UIElement[CombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[NonCombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[NonCombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${NonCombatStance}]} 
			UIElement[NonCombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
		rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[RestoreSpecialCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[RestoreSpecialCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${NonCombatStance}]}
			UIElement[RestoreSpecialCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}


}
;********************************************
/* Add item to the Buff list */
;********************************************
atom(global) AddBuff(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		LavishSettings[VGA].FindSet[Buff]:AddSetting[${aName}, ${aName}]

	}
	else
	{
		return
	}
}
atom(global) RemoveBuff(string aName)
{
	if ( ${aName.Length} > 1 )
	{
		Buff.FindSetting[${aName}]:Remove
	}
	else
	{
	}
}

atom(global) BuildBuff()
{
	variable iterator Iterator
	Buff:GetSettingIterator[Iterator]
	UIElement[BuffList@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:ClearItems
	while ( ${Iterator.Key(exists)} )
	{
		UIElement[BuffList@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Iterator.Key}]
		Iterator:Next
	}
} 
