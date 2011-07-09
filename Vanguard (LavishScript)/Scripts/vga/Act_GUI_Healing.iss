function Healcheck()
{
	if ${ClassRole.healer}
	{
		if ${Group.Count} < 2 && ${HealTimer.TimeLeft} == 0
		{
			waitframe

			If ${Me.HealthPct} < ${fhpctgrp[1]} && ${Me.HealthPct} > 0
			{
				healrefresh:Set[FALSE]
				Pawn[Me]:Target
				waitframe
				call checkabilitytocast "${InstantHeal}"
				if ${Return}
				{
					call executeability "${InstantHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${SmallHeal}"
				if ${Return}
				{
					call executeability "${SmallHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${InstantGroupHeal}"
				if ${Return}
				{
					call executeability "${InstantGroupHeal}" "Heal" "Neither"
					return
				}
				return
			}
			If ${Me.HealthPct} < ${hpctgrp[1]} && ${Me.HealthPct} > 0
			{
				healrefresh:Set[FALSE]
				Pawn[Me]:Target
				waitframe
				call checkabilitytocast "${SmallHeal}"
				if ${Return}
				{
					call executeability "${SmallHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${InstantHeal}"
				if ${Return}
				{
					call executeability "${InstantHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${InstantGroupHeal}"
				if ${Return}
				{
					call executeability "${InstantGroupHeal}" "Heal" "Neither"
					return
				}
				return
			}
			If ${Me.HealthPct} < ${bhpctgrp[1]} && ${Me.HealthPct} > 0
			{
				healrefresh:Set[FALSE]
				Pawn[Me]:Target
				call checkabilitytocast "${BigHeal}"
				if ${Return}
				{
					call executeability "${BigHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${SmallHeal}"
				if ${Return}
				{
					call executeability "${SmallHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${HotHeal}"
				if ${Return}
				{
					call executeability "${HotHeal}" "Heal" "Neither"
					return
				}
				return
			}
			If ${Me.HealthPct} < ${hhpctgrp[1]} && ${Me.HealthPct} > 0
			{
				healrefresh:Set[FALSE]
				Pawn[Me]:Target
				waitframe
				call checkabilitytocast "${HotHeal}"
				if ${Return}
				{
					call executeability "${HotHeal}" "Heal" "Neither"
					return
				}
				return
			}
		}
		if ${Group.Count} > 1 && ${HealTimer.TimeLeft} == 0
		{
			waitframe
			variable int icnt

			If ${healneeds.GroupInstantHealNum} > 1 && ${GroupStatus.AOEBuffClose}
			{
				healrefresh:Set[FALSE]
				Group[1].ToPawn:Target
				waitframe
				call checkabilitytocast "${InstantGroupHeal}"
				if ${Return}
				{
					call executeability "${InstantGroupHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${GroupHeal}"
				if ${Return}
				{
					call executeability "${GroupHeal}" "Heal" "Neither"
					return
				}
				return
			}


			icnt:Set[1]
			do
			{
				If ${hgrp[${icnt}]} && ${Group[${icnt}].Health} < ${fhpctgrp[${icnt}]} && ${Group[${icnt}].Health} > 0 && ${Group[${icnt}].Distance} < 25
				{
					healrefresh:Set[FALSE]
					Group[${icnt}].ToPawn:Target
					waitframe
					call checkabilitytocast "${InstantHeal}"
					if ${Return}
					{
						call executeability "${InstantHeal}" "Heal" "Neither"
						return
					}
					call checkabilitytocast "${SmallHeal}"
					if ${Return}
					{
						call executeability "${SmallHeal}" "Heal" "Neither"
						return
					}
					call checkabilitytocast "${InstantGroupHeal}"
					if ${Return}
					{
						call executeability "${InstantGroupHeal}" "Heal" "Neither"
						return
					}
					return
				}
			}
			while ${icnt:Inc} <= ${Group.Count}

			If ${healneeds.GroupHealNum} > 1 && ${healrefresh} && ${GroupStatus.AOEBuffClose}
			{
				healrefresh:Set[FALSE]
				Group[1].ToPawn:Target
				waitframe
				call checkabilitytocast "${GroupHeal}"
				if ${Return}
				{
					call executeability "${GroupHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${InstantGroupHeal}"
				if ${Return}
				{
					call executeability "${InstantGroupHeal}" "Heal" "Neither"
					return
				}
				return
			}

			icnt:Set[1]
			do
			{
				If ${hgrp[${icnt}]} && ${Group[${icnt}].Health} < ${hpctgrp[${icnt}]} && ${Group[${icnt}].Health} > 0 && ${Group[${icnt}].Distance} < 25
				{
					healrefresh:Set[FALSE]
					Group[${icnt}].ToPawn:Target
					waitframe
					call checkabilitytocast "${SmallHeal}"
					if ${Return}
					{
						call executeability "${SmallHeal}" "Heal" "Neither"
						return
					}
					call checkabilitytocast "${InstantHeal}"
					if ${Return}
					{
						call executeability "${InstantHeal}" "Heal" "Neither"
						return
					}
					call checkabilitytocast "${InstantGroupHeal}"
					if ${Return}
					{
						call executeability "${InstantGroupHeal}" "Heal" "Neither"
						return
					}
					return
				}
			}
			while ${icnt:Inc} <= ${Group.Count}

			icnt:Set[1]
			do
			{
				If ${hgrp[${icnt}]} && ${Group[${icnt}].Health} < ${bhpctgrp[${icnt}]} && ${Group[${icnt}].Health} > 0 && ${Group[${icnt}].Distance} < 25
				{
					healrefresh:Set[FALSE]
					Group[${icnt}].ToPawn:Target
					waitframe
					call checkabilitytocast "${BigHeal}"
					if ${Return}
					{
						call executeability "${BigHeal}" "Heal" "Neither"
						return
					}
					call checkabilitytocast "${SmallHeal}"
					if ${Return}
					{
						call executeability "${SmallHeal}" "Heal" "Neither"
						return
					}
					call checkabilitytocast "${HotHeal}"
					if ${Return}
					{
						call executeability "${HotHeal}" "Heal" "Neither"
						return
					}
					return
				}
			}
			while ${icnt:Inc} <= ${Group.Count}

			icnt:Set[1]
			do
			{
				If ${hgrp[${icnt}]} && ${Group[${icnt}].Health} < ${hhpctgrp[${icnt}]} && ${Group[${icnt}].Health} > 0 && ${Group[${icnt}].Distance} < 25
				{
					healrefresh:Set[FALSE]
					Group[${icnt}].ToPawn:Target
					waitframe
					call checkabilitytocast "${HotHeal}"
					if ${Return}
					{
						call executeability "${HotHeal}" "Heal" "Neither"
						return
					}
					return
				}
			}
			while ${icnt:Inc} <= ${Group.Count}
			if ${MyClass.Equal[Shaman]}
			{
				call shamanmana
			}
			return
		}
	}

}
;**********************************************
function checkinstantheal()
{
	if ${ClassRole.healer}
	{
		If ${Me.HealthPct} < ${fhpctgrp[1]} && ${Me.HealthPct} > 0 && ${Group.Count} < 2 && ${HealTimer.TimeLeft} == 0 && ${Group[${icnt}].Distance} < 25
		{
			VGexecute /stopcasting
			Pawn[Me]:Target
			waitframe
			call checkabilitytocast "${InstantHeal}"
			if ${Return}
			{
				call executeability "${InstantHeal}" "Heal" "Neither"
				return
			}
			call checkabilitytocast "${InstantGroupHeal}"
			if ${Return}
			{
				call executeability "${InstantGroupHeal}" "Heal" "Neither"
				return
			}
			return
		}

		if ${Group.Count} > 1 && ${HealTimer.TimeLeft} == 0 && ${Group[${icnt}].Distance} < 25
		{
			waitframe
			variable int icnt

			If ${healneeds.GroupInstantHealNum} > 1 && ${GroupStatus.AOEBuffClose}
			{
				VGexecute /stopcasting
				Group[1].ToPawn:Target
				waitframe
				call checkabilitytocast "${InstantGroupHeal}"
				if ${Return}
				{
					call executeability "${InstantGroupHeal}" "Heal" "Neither"
					return
				}
				call checkabilitytocast "${InstantHeal}"
				if ${Return}
				{
					call executeability "${InstantHeal}" "Heal" "Neither"
					return
				}
				return
			}


			icnt:Set[1]
			do
			{
				If ${hgrp[${icnt}]} && ${Group[${icnt}].Health} < ${fhpctgrp[${icnt}]} && ${Group[${icnt}].Health} > 0 && ${Group[${icnt}].Distance} < 25
				{
					VGexecute /stopcasting
					Group[${icnt}].ToPawn:Target
					waitframe
					call checkabilitytocast "${InstantHeal}"
					if ${Return}
					{
						call executeability "${InstantHeal}" "Heal" "Neither"
						return
					}
					call checkabilitytocast "${InstantGroupHeal}"
					if ${Return}
					{
						call executeability "${InstantGroupHeal}" "Heal" "Neither"
						return
					}
					return
				}
			}
			while ${icnt:Inc} <= ${Group.Count}
		}
	}
}

;******************************HealNeeds***********************
objectdef HealNeeds
{
	member:int GroupInstantHealNum()
	{
		variable int icnt = 1
		variable int needint = 0
		do
		{
			If ${hgrp[${icnt}]} && ${Group[${icnt}].Health} < ${gihpctgrp[${icnt}]}
			{
				needint:Inc
			}
		}
		while ${icnt:Inc} <= ${Group.Count}
		return ${needint}
	}

	member:int GroupHealNum()
	{
		variable int icnt = 1
		variable int needint = 0
		do
		{
			If ${hgrp[${icnt}]} && ${Group[${icnt}].Health} < ${ghpctgrp[${icnt}]}
			{
				needint:Inc
			}
		}
		while ${icnt:Inc} <= ${Group.Count}
		return ${needint}
	}
}
variable HealNeeds healneeds
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
		}
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
;=================================================
function LoadHealers()
{
	return
}
;=================================================
function SaveHealers()
{

}

