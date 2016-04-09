function EmergencyHeal_BloodMage(int GN, int EN, int IN)
{
	echo "1-GN=${GN}, EN=${EN}, IN=${IN}"
	;-------------------------------------------
	; Fastest heal we got - Drains your mana
	;-------------------------------------------
	if ${EN} > 1
	{
		Pawn[ID,${Group[${GN}].ID}]:Target
		call checkabilitytocast "${SmallHeal}"
		if ${Return}
		{
			call executeability "${SmallHeal}" "Heal" "Neither"
			return
		}
		return
	}

	;-------------------------------------------
	; No need to panic - Drains your mana
	;-------------------------------------------
	if ${EN} == 1
	{
		Pawn[ID,${Group[${GN}].ID}]:Target
		if ${GrpMemberClassType[${GN}].Equal[Squishy]}
		{
			call checkabilitytocast "${SmallHeal}"
			if ${Return}
			{
				call executeability "${SmallHeal}" "Heal" "Neither"
				return
			}
		}
		call checkabilitytocast "${BigHeal}"
		if ${Return}
		{
			call executeability "${BigHeal}" "Heal" "Neither"
			return
		}
		return
	}

}

function InjuryHeal_BloodMage(int GN, int EN, int IN)
{
	echo "2-GN=${GN}, EN=${EN}, IN=${IN}"
	;-------------------------------------------
	; Big slow heals - conserve mana
	;-------------------------------------------
	if ${IN} < 3
	{
		Pawn[ID,${Group[${GN}].ID}]:Target
		if ${GrpMemberClassType[${GN}].Equal[Squishy]}
		{
			call checkabilitytocast "${SmallHeal}"
			if ${Return}
			{
				call executeability "${SmallHeal}" "Heal" "Neither"
				return
			}
		}
		call checkabilitytocast "${BigHeal}"
		if ${Return}
		{
			call executeability "${BigHeal}" "Heal" "Neither"
			return
		}
		return
	}

	;-------------------------------------------
	; Small Fast Heals - Drains your mana
	;-------------------------------------------
	if ${IN} > 2
	{
		Pawn[ID,${Group[${GN}].ID}]:Target
		call checkabilitytocast "${SmallHeal}"
		if ${Return}
		{
			call executeability "${SmallHeal}" "Heal" "Neither"
			return
		}
		return
	}
}


