function:bool checkgroupstats(int groupint)
{
	variable int gi

	for (gi:Set[1] ; ${gi}<=6 ; gi:Inc)
		{
		if ${RaidGroup[${gi}]} == ${groupint}
			{
			return TRUE
			}
		}
}
function checkinstantheal()
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


	if ${Me.IsGrouped}
	{
		if ${Group.Count} > 6
		{
			;-------------------------------------------
			; Let's figure out who and how many has the lowest health In Your Raid Group
			;-------------------------------------------
			for ( L:Set[1] ; ${Group[${L}].ID(exists)} ; L:Inc )
			{
				call checkgroupstats ${L}
				if ${Return}			
					{
					if ${GrpMemberClassType[${L}].Equal[Tank]} && ${Group[${L}].Health}<${TankEmerHealPct} && ${Group[${L}].Health}>0 && ${Group[${L}].Distance}<25
						{
						EmergencyInjuries:Inc
						if ${Group[${L}].Health} < ${ELO}
							{
							EmergencyHurt:Set[${L}]
							ELO:Set[${Group[${L}].Health}]
							}
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
					}
			}
		}
		if ${Group.Count} < 7
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
			}
		}
		if ${EmergencyInjuries} > 0
			{
			actionlog "Emergency Injury GPMemLo ${EmergencyHurt} Num ${EmergencyInjuries}"
			If ${MyClass.Equal[Disciple]}
				Call EmergencyHeal_Disciple "${EmergencyHurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Cleric]}
				Call EmergencyHeal_Cleric "${EmergencyHurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Shaman]}
				Call EmergencyHeal_Shaman "${EmergencyHurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Blood Mage]}
				Call EmergencyHeal_BloodMage "${EmergencyHurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Druid]}
				Call EmergencyHeal_Druid "${EmergencyHurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Ranger]}
				Call EmergencyHeal_Ranger "${EmergencyHurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Paladin]}
				Call EmergencyHeal_Paladin "${EmergencyHurt}" "${EmergencyInjuries}" "${Injuries}"
			
			return
			}
	}
}
function:bool CheckGroupDamage()
{
	variable int EmergencyInjuries
	variable int EmergencyHurt
	variable int Injuries
	variable int Hurt
	variable int L
	variable int ELO
	variable int HLO

	ELO:Set[100]
	HLO:Set[100]
	Hurt:Set[0]
	Injuries:Set[0]
	L:Set[1]


	if ${Me.IsGrouped}
	{
		if ${Group.Count} > 6
		{
		;-------------------------------------------
		; Let's figure out who and how many has the lowest health
		;-------------------------------------------
		for ( L:Set[1] ; ${Group[${L}].ID(exists)} ; L:Inc )
			{
			call checkgroupstats ${L}
			if ${Return}			
				{
				if ${GrpMemberClassType[${L}].Equal[Tank]} && ${Group[${L}].Health}<${TankEmerHealPct} && ${Group[${L}].Health}>0 && ${Group[${L}].Distance}<25
					{
					EmergencyInjuries:Inc
					if ${Group[${L}].Health} < ${ELO}
						{
						EmergencyHurt:Set[${L}]
						ELO:Set[${Group[${L}].Health}]
						}
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
			}
		}
		if ${Group.Count} < 7
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
		}
		if ${EmergencyInjuries} == 0 && ${Injuries} == 0
			return TRUE
		if ${EmergencyInjuries} > 0
			{
			actionlog "Emergency Injury GPMemLo ${EmergencyHurt} Num ${EmergencyInjuries}"
			If ${MyClass.Equal[Disciple]}
				Call EmergencyHeal_Disciple "${EmergencyHurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Cleric]}
				Call EmergencyHeal_Cleric "${EmergencyHurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Shaman]}
				Call EmergencyHeal_Shaman "${EmergencyHurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Blood Mage]}
				Call EmergencyHeal_BloodMage "${EmergencyHurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Druid]}
				Call EmergencyHeal_Druid "${EmergencyHurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Ranger]}
				Call EmergencyHeal_Ranger "${EmergencyHurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Paladin]}
				Call EmergencyHeal_Paladin "${EmergencyHurt}" "${EmergencyInjuries}" "${Injuries}"
			
			return
			}
		if ${Injuries} > 0
			{
			actionlog "Injury GPMemLo ${Hurt} Num ${Injuries}"
			If ${MyClass.Equal[Disciple]}
				Call InjuryHeal_Disciple "${Hurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Cleric]}
				Call InjuryHeal_Cleric "${Hurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Shaman]}
				Call InjuryHeal_Shaman "${Hurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Blood Mage]}
				Call InjuryHeal_BloodMage "${Hurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Druid]}
				Call InjuryHeal_Druid "${Hurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Ranger]}
				Call InjuryHeal_Ranger "${Hurt}" "${EmergencyInjuries}" "${Injuries}"
			If ${MyClass.Equal[Paladin]}
				Call InjuryHeal_Paladin "${Hurt}" "${EmergencyInjuries}" "${Injuries}"
			return
			}
	return
	}
}


function:bool SafeToCast()
{
	variable int L = 0
	variable int SafeZone = 70

	;; Check group if in safezone
	if ${Me.IsGrouped}
	{
		for ( L:Set[1] ;  ${Group[${L}].ID(exists)} ; L:Inc )
		{
			if ${Group[${L}].Health}>0 && ${Group[${L}].Distance}<25
			{
				if ${Group[${L}].Health} < ${SafeZone}
				{
					return FALSE
				}
			}
		}
	}
	
	;; Check self in safe zone
	if ${Me.HealthPct} < ${SafeZone}
	{
		return FALSE
	}
	return TRUE
}
