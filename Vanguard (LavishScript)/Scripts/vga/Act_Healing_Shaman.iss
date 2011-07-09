function EmergencyHeal_Shaman(int64 XGN, int64 XEN, int64 XIN)
{
	echo "Emergency ${Group[${XGN}].Name} ${XEN}"
	if ${XEN} > 1
	{
		Pawn[ID,${Group[${XGN}].ID}]:Target
		call checkabilitytocast "${HealCrit1}"
		if ${Return}
		{
			call executeability "${HealCrit1}" "Heal" "Neither"
			call CheckGroupDamage
		}
		call checkabilitytocast "${HealCrit2}"
		if ${Return}
		{
			call executeability "${HealCrit2}" "Heal" "Neither"
			return
		}
		return
	}
	if ${XEN} == 1
	{
		Pawn[ID,${Group[${XGN}].ID}]:Target
		call checkabilitytocast "${InstantHeal}"
		if ${Return}
		{
			call executeability "${InstantHeal}" "Heal" "Neither"
			call CheckGroupDamage
		}
		call checkabilitytocast "${HealCrit2}"
		if ${Return}
		{
			call executeability "${HealCrit2}" "Heal" "Neither"
			call CheckGroupDamage
		}
		call checkabilitytocast "${HealCrit1}"
		if ${Return}
		{
			call executeability "${HealCrit1}" "Heal" "Neither"
			return
		}
		call checkabilitytocast "${SmallHeal}"
		if ${Return}
		{
			call executeability "${SmallHeal}" "Heal" "Neither"
			return
		}
		return
	}
}
function InjuryHeal_Shaman(int64 XGN, int64 XEN, int64 XIN)
{
	echo "Injury ${Group[${XGN}].Name} ${XIN}"
	if ${XIN} > 2
	{
		call checkabilitytocast "${HealCrit1}"
		if ${Return}
		{
			call executeability "${HealCrit1}" "Heal" "Neither"
			return
		}
		call checkabilitytocast "${HealCrit2}"
		if ${Return}
		{
			call executeability "${HealCrit2}" "Heal" "Neither"
			return
		}
		call checkabilitytocast "${GroupHeal}"
		if ${Return}
		{
			call executeability "${GroupHeal}" "Heal" "Neither"
			return
		}
	}
	if ${XIN} == 1
	{
		Pawn[ID,${Group[${XGN}].ID}]:Target
		if ${GrpMemberClassType[${XGN}].Equal[Squishy]}
		{
			call checkabilitytocast "${HealCrit1}"
			if ${Return}
			{
				call executeability "${HealCrit1}" "Heal" "Neither"
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
			call checkabilitytocast "${HealCrit1}"
			if ${Return}
			{
				call executeability "${HealCrit1}" "Heal" "Neither"
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


