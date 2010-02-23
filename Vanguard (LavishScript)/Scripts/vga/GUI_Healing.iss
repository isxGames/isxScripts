;******************************CombatLists***********************
function PopulateHealLists()
{
	variable int i

	;; dump all abilities into each of these
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

	;; do the same for forms
	for (i:Set[1] ; ${i} <= ${Me.Form} ; i:Inc)
	{
		UIElement[CombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Form[${i}].Name}]
		UIElement[NonCombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${Me.Form[${i}].Name}]
	}

	;; let's create a listing for these
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
	
	;; Hey... I think I shaved off 2 seconds by looping this once instead of 21 times!	
	for (i:Set[1] ; ${i}<=${Me.Ability} ; i:Inc)
	{
		if ${UIElement[LazyBuffCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${lazybuff}]}
			UIElement[LazyBuffCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[LazyBuffCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${lazybuff}]}
			UIElement[LazyBuffCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[CombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${CombatRes}]}
			UIElement[CombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[NonCombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${NonCombatRes}]}
			UIElement[NonCombatResCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[ResStoneCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${ResStone}]}
			UIElement[ResStoneCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[hotsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${HotHeal}]}
			UIElement[hotsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[instantsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${InstantHeal}]}
			UIElement[instantsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[instant2solohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${InstantHeal2}]}
			UIElement[instant2solohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[InstantHotHeal1Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${InstantHotHeal1}]}
			UIElement[InstantHotHeal1Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[InstantHotHeal2Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${InstantHotHeal2}]}
			UIElement[InstantHotHeal2Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[TapSoloHealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${TapSoloHeal}]}
			UIElement[TapSoloHealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[smallsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${SmallHeal}]}
			UIElement[smallsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[bigsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${BigHeal}]}
			UIElement[bigsolohealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[HealCrit1Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${HealCrit1}]} 
			UIElement[HealCrit1Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[HealCrit2Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${HealCrit2}]} 
			UIElement[HealCrit2Combo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[grouphealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${GroupHeal}]} 
			UIElement[grouphealCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[RestoreSpecialCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${NonCombatStance}]}
			UIElement[RestoreSpecialCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[CombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${CombatStance}]}
			UIElement[CombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[NonCombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${NonCombatStance}]} 
			UIElement[NonCombatStanceCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
		if ${UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui].Item[${i}].Text.Equal[${ShiftingImage}]}
			UIElement[ShiftingImageCombo@HealCFrm@Heal_Buff@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:SelectItem[${i}]
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
