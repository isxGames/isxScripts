function EmergencyHeal_Cleric(int64 XGN, int64 XEN, int64 XIN)
{
	if ${XEN} > 1
	{
		Pawn[ID,${Group[${XGN}].ID}]:Target
		if !${Me.Target.Name.Equal[${Me}]}
		{
			call checkabilitytocast "${InstantHeal2}"
			if ${Return}
			{
				call executeability "${InstantHeal2}" "Heal" "Neither"
				call CheckGroupDamage
			}
		}
		call checkabilitytocast "${InstantHeal}"
		if ${Return}
		{
			call executeability "${InstantHeal}" "Heal" "Neither"
			call CheckGroupDamage
		}
		call checkabilitytocast "${SmallHeal}"
		if ${Return}
		{
			call executeability "${SmallHeal}" "Heal" "Neither"
			call CheckGroupDamage
		}
	}
	if ${XEN} == 1
	{
		Pawn[ID,${Group[${XGN}].ID}]:Target
		if !${Me.Target.Name.Equal[${Me}]}
		{
			call checkabilitytocast "${InstantHeal2}"
			if ${Return}
			{
				call executeability "${InstantHeal2}" "Heal" "Neither"
				return
			}
		}
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
	}

}
function InjuryHeal_Cleric(int64 XGN, int64 XEN, int64 XIN)
{
	if ${XIN} > 2
	{
		call checkabilitytocast "${GroupHeal}"
		if ${Return}
		{
			call executeability "${GroupHeal}" "Heal" "Neither"
			return
		}
		Pawn[ID,${Group[${XGN}].ID}]:Target
		if ${GrpMemberClassType[${XGN}].Equal[Squishy]}
		{
			call checkabilitytocast "${InstantHeal}"
			if ${Return}
			{
				call executeability "${InstantHeal}" "Heal" "Neither"
				call CheckGroupDamage
			}
			call checkabilitytocast "${InstantHeal2}"
			if ${Return}
			{
				call executeability "${InstantHeal2}" "Heal" "Neither"
				call CheckGroupDamage
			}
			call checkabilitytocast "${SmallHeal}"
			if ${Return}
			{
				call executeability "${SmallHeal}" "Heal" "Neither"
				call CheckGroupDamage
			}
		}
		if ${GrpMemberClassType[${XGN}].Equal[Medium]}
		{
			call checkabilitytocast "${HotHeal}"
			if ${Return}
			{
				call CanApplyHOT "${HotHeal}" ${XGN}
				if ${Return}
				{
					usedAbility:Set[FALSE]
					call executeability "${HotHeal}" "Heal" "Neither"
					if ${usedAbility}
					call SaveHOTTime "${HotHeal}" ${XGN}
					call CheckGroupDamage
				}
			}
			call checkabilitytocast "${SmallHeal}"
			if ${Return}
			{
				call executeability "${SmallHeal}" "Heal" "Neither"
				call CheckGroupDamage
			}
		}
		if ${GrpMemberClassType[${XGN}].Equal[Tank]}
		{
			call checkabilitytocast "${HotHeal}"
			if ${Return}
			{
				call CanApplyHOT "${HotHeal}" ${XGN}
				if ${Return}
				{
					usedAbility:Set[FALSE]
					call executeability "${HotHeal}" "Heal" "Neither"
					if ${usedAbility}
					call SaveHOTTime "${HotHeal}" ${XGN}
					call CheckGroupDamage
				}
			}
			call checkabilitytocast "${SmallHeal}"
			if ${Return}
			{
				call executeability "${SmallHeal}" "Heal" "Neither"
				call CheckGroupDamage
			}
		}
		return
	}

	if ${XIN} == 2
	{
		Pawn[ID,${Group[${XGN}].ID}]:Target
		if ${GrpMemberClassType[${XGN}].Equal[Squishy]}
		{
			call checkabilitytocast "${InstantHeal}"
			if ${Return}
			{
				call executeability "${InstantHeal}" "Heal" "Neither"
				call CheckGroupDamage
			}
			call checkabilitytocast "${InstantHeal2}"
			if ${Return}
			{
				call executeability "${InstantHeal2}" "Heal" "Neither"
				call CheckGroupDamage
			}
			call checkabilitytocast "${SmallHeal}"
			if ${Return}
			{
				call executeability "${SmallHeal}" "Heal" "Neither"
				call CheckGroupDamage
			}
		}
		if ${GrpMemberClassType[${XGN}].Equal[Medium]}
		{
			call checkabilitytocast "${HotHeal}"
			if ${Return}
			{
				call CanApplyHOT "${HotHeal}" ${XGN}
				if ${Return}
				{
					usedAbility:Set[FALSE]
					call executeability "${HotHeal}" "Heal" "Neither"
					if ${usedAbility}
					call SaveHOTTime "${HotHeal}" ${XGN}
					call CheckGroupDamage
				}
			}
			call checkabilitytocast "${SmallHeal}"
			if ${Return}
			{
				call executeability "${SmallHeal}" "Heal" "Neither"
				call CheckGroupDamage
			}
		}
		if ${GrpMemberClassType[${XGN}].Equal[Tank]}
		{
			call checkabilitytocast "${HotHeal}"
			if ${Return}
			{
				call CanApplyHOT "${HotHeal}" ${XGN}
				if ${Return}
				{
					usedAbility:Set[FALSE]
					call executeability "${HotHeal}" "Heal" "Neither"
					if ${usedAbility}
					call SaveHOTTime "${HotHeal}" ${XGN}
					call CheckGroupDamage
				}
			}
			call checkabilitytocast "${SmallHeal}"
			if ${Return}
			{
				call executeability "${SmallHeal}" "Heal" "Neither"
				call CheckGroupDamage
			}
		}
		return
	}

	if ${XIN} == 1
	{
		Pawn[ID,${Group[${XGN}].ID}]:Target
		if ${GrpMemberClassType[${XGN}].Equal[Squishy]}
		{
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
		}
		if ${GrpMemberClassType[${XGN}].Equal[Medium]}
		{
			call checkabilitytocast "${HotHeal}"
			if ${Return}
			{
				call CanApplyHOT "${HotHeal}" ${XGN}
				if ${Return}
				{
					usedAbility:Set[FALSE]
					call executeability "${HotHeal}" "Heal" "Neither"
					if ${usedAbility}
					call SaveHOTTime "${HotHeal}" ${XGN}
					return
				}
			}
			call checkabilitytocast "${SmallHeal}"
			if ${Return}
			{
				call executeability "${SmallHeal}" "Heal" "Neither"
				return
			}
		}
		if ${GrpMemberClassType[${XGN}].Equal[Tank]}
		{
			call checkabilitytocast "${HotHeal}"
			if ${Return}
			{
				call CanApplyHOT "${HotHeal}" ${XGN}
				if ${Return}
				{
					usedAbility:Set[FALSE]
					call executeability "${HotHeal}" "Heal" "Neither"
					if ${usedAbility}
					call SaveHOTTime "${HotHeal}" ${XGN}
					return
				}
			}
			call checkabilitytocast "${BigHeal}"
			if ${Return}
			{
				call executeability "${BigHeal}" "Heal" "Neither"
				return
			}
		}
		return
	}
}

