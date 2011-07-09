function EmergencyHeal_Disciple(int64 GN, int64 EN, int64 IN)
{
	If ${EN} > 1
	{
		if ${mobisfurious} || !${Me.InCombat}
		{
			call checkabilitytocast "${GroupHeal}"
			if ${Return}
			{
				call executeability "${GroupHeal}" "Heal" "Neither"
				return
			}
		}

		Pawn[ID,${Group[${GN}].ID}]:Target
		if ${Me.Ability[${HealCrit1}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit1}].IsReady} && ${fight.ShouldIAttack}
		{
			call executeability "${HealCrit1}" "MeleeHeal" "Neither"
			if ${Me.Ability[${HealCrit2}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit2}].IsReady} && ${fight.ShouldIAttack}
			{
				call executeability "${HealCrit2}" "MeleeHeal" "Neither"
			}
			return
		}

		if ${Me.Ability[${HealCrit1}].TriggeredCountdown} == 0 || !${Me.Ability[${HealCrit1}].IsReady}
		{
			if ${Me.Ability[Clarity](exists)} && ${Me.Ability[Clarity].IsReady} && ${fight.ShouldIAttack}
			{
				call executeability "Clarity" "Heal" "Neither"


				call checkabilitytocast "${InstantHotHeal}"
				if ${Return} && ${fight.ShouldIAttack}
				{
					call executeability "${InstantHotHeal}" "Heal" "Neither"
					if ${Me.Ability[${HealCrit1}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit1}].IsReady} && ${fight.ShouldIAttack}
					{
						call executeability "${HealCrit1}" "MeleeHeal" "Neither"
						if ${Me.Ability[${HealCrit2}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit2}].IsReady} && ${fight.ShouldIAttack}
						{
							call executeability "${HealCrit2}" "MeleeHeal" "Neither"
						}
						return
					}
				}
				call checkabilitytocast "${TapSoloHeal}"
				if ${Return} && ${fight.ShouldIAttack}
				{
					call executeability "${TapSoloHeal}" "Heal" "Neither"
					if ${Me.Ability[${HealCrit1}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit1}].IsReady} && ${fight.ShouldIAttack}
					{
						call executeability "${HealCrit1}" "MeleeHeal" "Neither"
						if ${Me.Ability[${HealCrit2}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit2}].IsReady} && ${fight.ShouldIAttack}
						{
							call executeability "${HealCrit2}" "MeleeHeal" "Neither"
						}
						return
					}
				}
			}
		}
		call checkabilitytocast "${GroupHeal}"
		if ${Return} && ${fight.ShouldIAttack}
		{
			call executeability "${GroupHeal}" "Heal" "Neither"
			return
		}
		return
	}
	If ${EN} == 1
	{
		Pawn[ID,${Group[${GN}].ID}]:Target
		if ${mobisfurious} || !${Me.InCombat}
		{
			call checkabilitytocast "${SmallHeal}"
			if ${Return}
			{
				call executeability "${SmallHeal}" "Heal" "Neither"
				return
			}
		}
		if ${GrpMemberClassType[${GN}].Equal[Tank]} && (${mobisfurious} || !${Me.InCombat})
		{
			call checkabilitytocast "${InstantHeal}"
			if ${Return}
			{
				call executeability "${InstantHeal}" "Heal" "Neither"
			}
			call checkabilitytocast "${BigHeal}"
			if ${Return}
			{
				call executeability "${BigHeal}" "Heal" "Neither"
				return
			}
		}
		if ${GrpMemberClassType[${GN}].Equal[Squishy]}
		{
			if ${Me.Ability[${HealCrit1}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit1}].IsReady} && ${fight.ShouldIAttack}
			{
				call executeability "${HealCrit1}" "MeleeHeal" "Neither"
				if ${Me.Ability[${HealCrit2}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit2}].IsReady} && ${fight.ShouldIAttack}
				{
					call executeability "${HealCrit2}" "MeleeHeal" "Neither"
				}
				return
			}
		}


		call checkabilitytocast "${InstantHeal}"
		if ${Return} && ${fight.ShouldIAttack}
		{
			call executeability "${InstantHeal}" "Heal" "Neither"
			call checkabilitytocast "${TapSoloHeal}"
			if ${Return} && ${fight.ShouldIAttack}
			{
				call executeability "${TapSoloHeal}" "MeleeHeal" "Neither"
			}
			return
		}
		if ${Me.Ability[${HealCrit1}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit1}].IsReady} && ${fight.ShouldIAttack}
		{
			call executeability "${HealCrit1}" "Heal" "Neither"
			if ${Me.Ability[${HealCrit2}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit2}].IsReady} && ${fight.ShouldIAttack}
			{
				call executeability "${HealCrit2}" "Heal" "Neither"
			}
			return
		}
		call checkabilitytocast "${SmallHeal}"
		if ${Return} && ${fight.ShouldIAttack}
		{
			call executeability "${SmallHeal}" "Heal" "Neither"
			call checkabilitytocast "${TapSoloHeal}"
			if ${Return} && ${fight.ShouldIAttack}
			{
				call executeability "${TapSoloHeal}" "MeleeHeal" "Neither"
			}
			return
		}
	}
}
function InjuryHeal_Disciple(int64 GN, int64 EN, int64 IN)
{
	If ${IN} > 1
	{
		Pawn[ID,${Group[${GN}].ID}]:Target
		if ${mobisfurious} || !${Me.InCombat}
		{
			call checkabilitytocast "${GroupHeal}"
			if ${Return}
			{
				call executeability "${GroupHeal}" "Heal" "Neither"
				return
			}
		}
		if ${Me.Ability[${HealCrit1}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit1}].IsReady} && ${fight.ShouldIAttack}
		{
			call executeability "${HealCrit1}" "MeleeHeal" "Neither"
			if ${Me.Ability[${HealCrit2}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit2}].IsReady} && ${fight.ShouldIAttack}
			{
				call executeability "${HealCrit2}" "MeleeHeal" "Neither"
			}
			return
		}

		if ${Me.Ability[${HealCrit1}].TriggeredCountdown} == 0 || !${Me.Ability[${HealCrit1}].IsReady} && ${fight.ShouldIAttack}
		{
			if ${Me.Ability[Clarity](exists)} && ${Me.Ability[Clarity].IsReady} && ${fight.ShouldIAttack}
			{
				call executeability "Clarity" "Heal" "Neither"


				call checkabilitytocast "${InstantHotHeal}"
				if ${Return} && ${fight.ShouldIAttack}
				{
					call executeability "${InstantHotHeal}" "Heal" "Neither"
					if ${Me.Ability[${HealCrit1}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit1}].IsReady} && ${fight.ShouldIAttack}
					{
						call executeability "${HealCrit1}" "MeleeHeal" "Neither"
						if ${Me.Ability[${HealCrit2}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit2}].IsReady} && ${fight.ShouldIAttack}
						{
							call executeability "${HealCrit2}" "MeleeHeal" "Neither"
						}
						return
					}
				}
				call checkabilitytocast "${TapSoloHeal}"
				if ${Return} && ${fight.ShouldIAttack}
				{
					call executeability "${TapSoloHeal}" "MeleeHeal" "Neither"
					if ${Me.Ability[${HealCrit1}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit1}].IsReady} && ${fight.ShouldIAttack}
					{
						call executeability "${HealCrit1}" "MeleeHeal" "Neither"
						if ${Me.Ability[${HealCrit2}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit2}].IsReady} && ${fight.ShouldIAttack}
						{
							call executeability "${HealCrit2}" "MeleeHeal" "Neither"
						}
						return
					}
				}
			}
		}
		call checkabilitytocast "${GroupHeal}"
		if ${Return} && ${fight.ShouldIAttack}
		{
			call executeability "${GroupHeal}" "Heal" "Neither"
			return
		}

	}
	If ${IN} == 1
	{
		Pawn[ID,${Group[${GN}].ID}]:Target

		if ${GrpMemberClassType[${GN}].Equal[Squishy]} || ${GrpMemberClassType[${GN}].Equal[Medium]}
		{
			if ${mobisfurious} || !${Me.InCombat}
			{
				call checkabilitytocast "${SmallHeal}"
				if ${Return}
				{
					call executeability "${SmallHeal}" "Heal" "Neither"
					return
				}
			}
			call checkabilitytocast "${InstantHeal}"
			if ${Return}&& ${fight.ShouldIAttack}
			{
				call executeability "${InstantHeal}" "Heal" "Neither"
				call checkabilitytocast "${TapSoloHeal}"
				if ${Return} && ${fight.ShouldIAttack}
				{
					call executeability "${TapSoloHeal}" "MeleeHeal" "Neither"
				}
				return
			}
			call checkabilitytocast "${SmallHeal}"
			if ${Return} && ${fight.ShouldIAttack}
			{
				call executeability "${SmallHeal}" "Heal" "Neither"
				return
			}

		}
		if ${GrpMemberClassType[${GN}].Equal[Tank]}
		{
			Pawn[ID,${Group[${GN}].ID}]:Target
			if ${mobisfurious} || !${Me.InCombat}
			{
				call checkabilitytocast "${BigHeal}"
				if ${Return}
				{
					call executeability "${BigHeal}" "Heal" "Neither"
					return
				}
			}
			if ${fight.ShouldIAttack}
			{
				call checkabilitytocast "${InstantHeal}"
				if ${Return} && ${fight.ShouldIAttack}
				{
					call executeability "${InstantHeal}" "Heal" "Neither"
					call checkabilitytocast "${TapSoloHeal}"
					if ${Return} && ${fight.ShouldIAttack}
					{
						call executeability "${TapSoloHeal}" "MeleeHeal" "Neither"
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
		}
	}
}


