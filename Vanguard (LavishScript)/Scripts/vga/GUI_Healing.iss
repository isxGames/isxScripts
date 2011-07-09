;******************************CombatLists***********************
function PopulateHealLists()
{
	variable int i

	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{

		UIElement[BuffCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[CombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[NonCombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[LazyBuffCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[ResStoneCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[InstantHotHeal1Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[InstantHotHeal2Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[instantsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[instant2solohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[TapSoloHealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[smallsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[bigsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[grouphealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[HealCrit1Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[HealCrit2Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]
		UIElement[RestoreSpecialCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Ability[${i}].Name}]

	}
	for (i:Set[1] ; ${i} <= ${Me.Form} ; i:Inc)
	{
		UIElement[CombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Form[${i}].Name}]
		UIElement[NonCombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Form[${i}].Name}]
	}

	UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[Gooey Syndrome]
	UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[Ankle Biter]
	UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[Worse Than Fleas]
	UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[Yetibacca]
	UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[Dry Irritating Bones]
	UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[Overgrown Rodent]
	UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[Man's Best Friend]
	UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[Rocky Machine]
	UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[False Knowledge]
	UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[Roach]
	UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[Feline Ferocity]
	UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[Angry Outcomes]

	variable int rCount
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${ShiftingImage}]}
		UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
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
	while ${rCount:Inc} <= ${UIElement[instant2solohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[instant2solohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${InstantHeal2}]}
		UIElement[instant2solohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[InstantHotHeal1Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[InstantHotHeal1Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${InstantHotHeal1}]}
		UIElement[InstantHotHeal1Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[InstantHotHeal2Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[InstantHotHeal2Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${InstantHotHeal2}]}
		UIElement[InstantHotHeal2Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[TapSoloHealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[TapSoloHealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${TapSoloHeal}]}
		UIElement[TapSoloHealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
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
	while ${rCount:Inc} <= ${UIElement[HealCrit1Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[HealCrit1Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${HealCrit1}]}
		UIElement[HealCrit1Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
	}
	rCount:Set[0]
	while ${rCount:Inc} <= ${UIElement[HealCrit2Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Items}
	{
		if ${UIElement[HealCrit2Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${rCount}].Text.Equal[${HealCrit2}]}
		UIElement[HealCrit2Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${rCount}]
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


