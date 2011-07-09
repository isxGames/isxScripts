function CheckGroupDamage()
{
	variable int EmergencyInjuries
	variable int EmergencyHurt
	variable int Injuries
	variable int HURT
	variable int L
	variable int ELO
	variable int HLO

	ELO:Set[100]
	HLO:Set[100]
	HURT:Set[0]
	Injuries:Set[0]
	L:Set[1]


	if ${Me.IsGrouped} && ${Group.Count} < 7
	{
		;-------------------------------------------
		; Let's figure out who and how many has the lowest health
		;-------------------------------------------
		for ( L:Set[1] ; ${Group[${L}].ID(exists)} ; L:Inc )
		{
			if ${GrpMemberClassType[${L}].Equal[Tank]} && ${Group[${L}].Health}<${TankEmerHealPct} && ${Group[${L}].Health}>0 && ${Group[${L}].Distance}<25
			{
				EmergencyInjuries:Inc
				if ${Group[${L}].Health} < ${ELO}
				{
					EmergencyHurt:Set[${L}]
					ELO:Set[${Group[${L}].Health}]
				}
				if ${GrpMemberClassType[${L}].Equal[Medium]} && ${Group[${L}].Health}<${MedEmerHealPct} && ${Group[${L}].Health}>0 && ${Group[${L}].Distance}<25
				{
					EmergencyInjuries:Inc
					if ${Group[${L}].Health} < ${ELO}
					{
						EmergencyHurt:Set[${L}]
						ELO:Set[${Group[${L}].Health}]
					}
				}
				if ${GrpMemberClassType[${L}].Equal[Squishy]} && ${Group[${L}].Health}<${SquishyEmerHealPct} && ${Group[${L}].Health}>0 && ${Group[${L}].Distance}<25
				{
					EmergencyInjuries:Inc
					if ${Group[${L}].Health} < ${ELO}
					{
						EmergencyHurt:Set[${L}]
						ELO:Set[${Group[${L}].Health}]
					}
				}
				if ${GrpMemberClassType[${L}].Equal[Tank]} && ${Group[${L}].Health}<${TankHealPct} && ${Group[${L}].Health}>${TankEmerHealPct} && ${Group[${L}].Health}>0 && ${Group[${L}].Distance}<25
				{
					Injuries:Inc
					if ${Group[${L}].Health} < ${HLO}
					{
						Hurt:Set[${L}]
						HLO:Set[${Group[${L}].Health}]
					}
				}
				if ${GrpMemberClassType[${L}].Equal[Medium]} && ${Group[${L}].Health}<${MedHealPct} && ${Group[${L}].Health}>${MedEmerHealPct} && ${Group[${L}].Health}>0 && ${Group[${L}].Distance}<25
				{
					Injuries:Inc
					if ${Group[${L}].Health} < ${HLO}
					{
						Hurt:Set[${L}]
						HLO:Set[${Group[${L}].Health}]
					}
				}
				if ${GrpMemberClassType[${L}].Equal[Squishy]} && ${Group[${L}].Health}<${SquishyHealPct} && ${Group[${L}].Health}>${SquishyEmerHealPct} && ${Group[${L}].Health}>0 && ${Group[${L}].Distance}<25
				{
					Injuries:Inc
					if ${Group[${L}].Health} < ${HLO}
					{
						Hurt:Set[${L}]
						HLO:Set[${Group[${L}].Health}]
					}
				}
			}
			if ${EmergencyInjuries} > 0
			{
				If ${MyClass.Equal[Disciple]}
				Call EmergencyHeal_Disciple ${EmergencyHurt} ${EmergencyInjuries} ${Injuries}
				If ${MyClass.Equal[Cleric]}
				Call EmergencyHeal_Cleric ${EmergencyHurt} ${EmergencyInjuries} ${Injuries}
				If ${MyClass.Equal[Shaman]}
				Call EmergencyHeal_Shaman ${EmergencyHurt} ${EmergencyInjuries} ${Injuries}
				If ${MyClass.Equal[Blood Mage]}
				Call EmergencyHeal_BloodMage ${EmergencyHurt} ${EmergencyInjuries} ${Injuries}
				If ${MyClass.Equal[Druid]}
				Call EmergencyHeal_Druid ${EmergencyHurt} ${EmergencyInjuries} ${Injuries}
				If ${MyClass.Equal[Ranger]}
				Call EmergencyHeal_Ranger ${EmergencyHurt} ${EmergencyInjuries} ${Injuries}
				If ${MyClass.Equal[Paladin]}
				Call EmergencyHeal_Paladin ${EmergencyHurt} ${EmergencyInjuries} ${Injuries}

				return
			}
			if ${Injuries} > 0
			{
				If ${MyClass.Equal[Disciple]}
				Call InjuryHeal_Disciple ${EmergencyHurt} ${EmergencyInjuries} ${Injuries}
				If ${MyClass.Equal[Cleric]}
				Call InjuryHeal_Cleric ${EmergencyHurt} ${EmergencyInjuries} ${Injuries}
				If ${MyClass.Equal[Shaman]}
				Call InjuryHeal_Shaman ${EmergencyHurt} ${EmergencyInjuries} ${Injuries}
				If ${MyClass.Equal[Blood Mage]}
				Call InjuryHeal_BloodMage ${EmergencyHurt} ${EmergencyInjuries} ${Injuries}
				If ${MyClass.Equal[Druid]}
				Call InjuryHeal_Druid ${EmergencyHurt} ${EmergencyInjuries} ${Injuries}
				If ${MyClass.Equal[Ranger]}
				Call InjuryHeal_Ranger ${EmergencyHurt} ${EmergencyInjuries} ${Injuries}
				If ${MyClass.Equal[Paladin]}
				Call InjuryHeal_Paladin ${EmergencyHurt} ${EmergencyInjuries} ${Injuries}
				return
			}
			return
		}
	}

	function GroupEmergencyHeal(int GN)
	{
		if ${HealTimer.TimeLeft} == 0
		{
			Pawn[ID,${Group[${GN}].ID}]:Target

			If ${MyClass.Equal[Disciple]}
			{
				if ${Me.Ability[${HealCrit1}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit1}].IsReady}
				{
					call executeability "${HealCrit1}" "Heal" "Neither"
					if ${Me.Ability[${HealCrit2}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit2}].IsReady}
					{
						call executeability "${HealCrit2}" "Heal" "Neither"
					}
					return
				}

				if ${Me.Ability[${HealCrit1}].TriggeredCountdown} == 0 || !${Me.Ability[${HealCrit1}].IsReady}
				{
					if ${Me.Ability[Clarity](exists)} && ${Me.Ability[Clarity].IsReady}
					{
						call executeability "Clarity" "Heal" "Neither"


						call checkabilitytocast "${Blooming}"
						if ${Return}
						{
							call executeability "${Blooming}" "Heal" "Neither"
							if ${Me.Ability[${HealCrit1}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit1}].IsReady}
							{
								call executeability "${HealCrit1}" "Heal" "Neither"
								if ${Me.Ability[${HealCrit2}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit2}].IsReady}
								{
									call executeability "${HealCrit2}" "Heal" "Neither"
								}
								return
							}
						}
						call checkabilitytocast "${HotHeal}"
						if ${Return}
						{
							call executeability "${HotHeal}" "Heal" "Neither"
							if ${Me.Ability[${HealCrit1}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit1}].IsReady}
							{
								call executeability "${HealCrit1}" "Heal" "Neither"
								if ${Me.Ability[${HealCrit2}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit2}].IsReady}
								{
									call executeability "${HealCrit2}" "Heal" "Neither"
								}
								return
							}
						}
					}
					call checkabilitytocast "${GroupHeal}"
					if ${Return}
					{
						call executeability "${GroupHeal}" "Heal" "Neither"
						return
					}
					return
				}
				If ${MyClass.Equal[Blood Mage]}
				{
					if ${Me.Ability[${HealCrit1}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit1}].IsReady}
					{
						call executeability "${HealCrit1}" "Heal" "Neither"
						if ${Me.Ability[${HealCrit2}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit2}].IsReady}
						{
							call executeability "${HealCrit2}" "Heal" "Neither"
						}
						return
					}

					if ${Me.Ability[${HealCrit1}].TriggeredCountdown} == 0 || !${Me.Ability[${HealCrit1}].IsReady}
					{
						if ${Me.Ability[Clarity](exists)} && ${Me.Ability[Clarity].IsReady}
						{
							call executeability "Clarity" "Heal" "Neither"


							call checkabilitytocast "${Blooming}"
							if ${Return}
							{
								call executeability "${Blooming}" "Heal" "Neither"
								if ${Me.Ability[${HealCrit1}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit1}].IsReady}
								{
									call executeability "${HealCrit1}" "Heal" "Neither"
									if ${Me.Ability[${HealCrit2}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit2}].IsReady}
									{
										call executeability "${HealCrit2}" "Heal" "Neither"
									}
									return
								}
							}
							call checkabilitytocast "${HotHeal}"
							if ${Return}
							{
								call executeability "${HotHeal}" "Heal" "Neither"
								if ${Me.Ability[${HealCrit1}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit1}].IsReady}
								{
									call executeability "${HealCrit1}" "Heal" "Neither"
									if ${Me.Ability[${HealCrit2}].TriggeredCountdown} > 0 && ${Me.Ability[${HealCrit2}].IsReady}
									{
										call executeability "${HealCrit2}" "Heal" "Neither"
									}
									return
								}
							}
						}
						call checkabilitytocast "${GroupHeal}"
						if ${Return}
						{
							call executeability "${GroupHeal}" "Heal" "Neither"
							return
						}
						return
					}
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
			}

			function:string SingleEmergencyHeal(int GN)
			{
				if ${HealTimer.TimeLeft} == 0
				{
					Pawn[ID,${Group[${GN}].ID}]:Target
					wait 3
					If ${MyClass.Equal[Disciple]}
					{
						if ${Me.Ability[${ConcordHand}].TriggeredCountdown} > 0 && ${Me.Ability[${ConcordHand}].IsReady}
						{
							call executeability "${ConcordHand}" "Heal" "Neither"
						}
						if ${Me.Ability[${ConcordPalm}].TriggeredCountdown} > 0 && ${Me.Ability[${ConcordPalm}].IsReady}
						{
							call executeability "${ConcordPalm}" "Heal" "Neither"
							return
						}
						if ${Me.Ability[${ConcordHand}].TriggeredCountdown} > 0 && ${Me.Ability[${ConcordHand}].TimeRemaining} < 3 && ${Me.Stat[Adventuring,Jin]} > 1
						{
							call checkabilitytocast "${InstantHeal}"
							if ${Return}
							{
								call executeability "${InstantHeal}" "Heal" "Neither"
							}
							call checkabilitytocast "${HotHeal}"
							if ${Return}
							{
								call executeability "${HotHeal}" "Heal" "Neither"
							}
							call checkabilitytocast "${ConcordHand}"
							if ${Return}
							{
								call executeability "${ConcordHand}" "Heal" "Neither"
							}
							call checkabilitytocast "${ConcordPalm}"
							if ${Return}
							{
								call executeability "${ConcordPalm}" "Heal" "Neither"
								return
							}
						}
						If ${Me.Stat[Adventuring,Jin]} > 4
						{
							call checkabilitytocast "${InstantHeal}"
							if ${Return}
							{
								call executeability "${InstantHeal}" "Heal" "Neither"
							}
							call checkabilitytocast "${kiss}"
							if ${Return}
							{
								call executeability "${kiss}" "Heal" "Neither"
								return
							}
							return
						}
						If ${Me.Stat[Adventuring,Jin]} > 1 && ${Me.Stat[Adventuring,Jin]} < 5
						{
							call checkabilitytocast "${InstantHeal}"
							if ${Return}
							{
								call executeability "${InstantHeal}" "Heal" "Neither"
							}
							call checkabilitytocast "${HotHeal}"
							if ${Return}
							{
								call executeability "${HotHeal}" "Heal" "Neither"
								return
							}
							return
						}
						If ${Me.Stat[Adventuring,Jin]} < 2
						{
							call checkabilitytocast "${SmallHeal}"
							if ${Return}
							{
								call executeability "${SmallHeal}" "Heal" "Neither"
							}
							return
							call checkabilitytocast "${HotHeal}"
							if ${Return}
							{
								call executeability "${HotHeal}" "Heal" "Neither"
								return
							}
							return
						}
					}
					If ${MyClass.Equal[Blood Mage]}
					{
						call checkabilitytocast "${InstantGroupHeal}"
						if ${Return}
						{
							call executeability "${InstantGroupHeal}" "Heal" "Neither"
							return
						}
					}
					If ${MyClass.Equal[Cleric]}
					{
						call checkabilitytocast "${InstantHeal}"
						if ${Return}
						{
							call executeability "${InstantHeal}" "Heal" "Neither"
							return
						}
						if !${Group[${GN}].Name.Equal[${MyName}]}
						{
							call checkabilitytocast "${InstantHeal2}"
							if ${Return}
							{
								call executeability "${InstantHeal2}" "Heal" "Neither"
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
					If ${MyClass.Equal[Shaman]}
					{
						call checkabilitytocast "${GroupHotHeal}"
						if ${Return}
						{
							call executeability "${GroupHotHeal}" "Heal" "Neither"
						}
						call checkabilitytocast "${InstantHeal}"
						if ${Return}
						{
							call executeability "${InstantHeal}" "Heal" "Neither"
						}
						call checkabilitytocast "${InstantGroupHeal}"
						if ${Return}
						{
							call executeability "${InstantGroupHeal}" "Heal" "Neither"
							return
						}
						call checkabilitytocast "${SmallHeal}"
						if ${Return}
						{
							call executeability "${SmallHeal}" "Heal" "Neither"
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
					return
				}
			}




