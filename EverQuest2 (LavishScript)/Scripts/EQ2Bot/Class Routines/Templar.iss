;*************************************************************
;Templar.iss
;version 20070725a
;variation on Inquisitor script for Templar by karye
;Edited by Cybris,Pygar
;
;20070725a (Pygar)
; Defaulted Heal %'s to rational numbers
; Removed duplicate HO Object Calls
; Fixed group cures to work on trauma and arcane (not elemental)
; Minor clean up in cure functions
; Minor Update for AA weapon requirements
;
;20070719a (Cybris)
; See release thread
;
;TODO List
; Add StartHO UI element
; Only cast after reactive if health continue's to decrease
; Don't cast reactive if already up
; Toggle using Group or Single Target reactive for Raid efficiency
;
;*************************************************************
#include "${LavishScript.HomeDirectory}/Scripts/EQ2HOLib.iss"

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{

	addtrigger IncomingMob "@${Actor[${MainAssist}].ID}@ says to the group,\"MOB Incoming...!!""

	declare OffenseMode bool script
	declare DebuffMode bool script
	declare AoEMode bool script
	declare CureMode bool script
	declare ConvertMode bool script
	declare YaulpMode bool script
	declare FanaticismMode bool script
	declare KeepReactiveUp bool script
	declare MezzMode bool script
	declare ReactiveOnlyMode bool script

	declare EquipmentChangeTimer int script
	declare HealMTPercent int script
	declare HealGroupPercent int script
	declare HealPetPercent int script

	declare MainWeapon string script
	declare OffHand string script
	declare OneHandedHammer string script
	declare TwoHandedHammer string script
	declare Symbols string script
	declare Buckler string script
	declare YaulpWeapon string script
	declare TwoHandedStaff string script

	declare Incoming bool script FALSE

	call EQ2BotLib_Init

	OffenseMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,FALSE]}]
	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	CureMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Cure Spells,FALSE]}]
	ConvertMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Convert Mode,FALSE]}]
	YaulpMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Yaulp Mode,FALSE]}]
	FanaticismMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Fanaticism Mode,FALSE]}]
	KeepReactiveUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepReactiveUp,FALSE]}]
	MezzMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Mezz Mode,FALSE]}]
	ReactiveOnlyMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Reactive Only Mode,FALSE]}]

	HealMTPercent:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetInt[Main Tank Heal Percent,90]}]
	HealGroupPercent:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetInt[Group Heal Percent,70]}]
	HealPetPercent:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetInt[Pet Heal Percent,40]}]

	MainWeapon:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[MainWeapon,]}]
	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OffHand,]}]
	OneHandedHammer:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[WeaponOneHandedHammer,]}]
	TwoHandedHammer:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[WeaponTwoHandedHammer,]}]
	Symbols:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[WeaponSymbols,]}]
	Buckler:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buckler,]}]
	YaulpWeapon:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[YaulpWeapon,]}]
	TwoHandedStaff:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[TwoHandedStaff,]}]
}

function Buff_Init()
{

	PreAction[1]:Set[Single_Buff_Conc]
	PreSpellRange[1,1]:Set[35]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[36]

	PreAction[3]:Set[Tank_Buff]
	PreSpellRange[3,1]:Set[42]

	PreAction[4]:Set[Group_Buff_Conc]
	PreSpellRange[4,1]:Set[20]
	PreSpellRange[4,2]:Set[21]

	;PreAction[5]:Set[Group_Buff]
	;PreSpellRange[5,1]:Set[280]
	;PreSpellRange[5,2]:Set[282]

	;PreAction[6]:Set[AA_ShieldAlly]
	;PreSpellRange[6,1]:Set[389]
}

function Combat_Init()
{
	Action[1]:Set[Sign_of_Fraility]
	MobHealth[1,1]:Set[10]
	MobHealth[1,2]:Set[100]
	Power[1,1]:Set[30]
	Power[1,2]:Set[100]
	SpellRange[1,1]:Set[55]

	Action[2]:Set[Spurn]
	MobHealth[2,1]:Set[10]
	MobHealth[2,2]:Set[100]
	Power[2,1]:Set[30]
	Power[2,2]:Set[100]
	SpellRange[2,1]:Set[50]


	Action[3]:Set[Mastery]
	SpellRange[3,1]:Set[360]
	SpellRange[3,2]:Set[379]

	Action[4]:Set[Involuntary_Restoration]
	MobHealth[4,1]:Set[40]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[40]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[336]

	Action[5]:Set[Warring_Axiom]
	MobHealth[5,1]:Set[10]
	MobHealth[5,2]:Set[100]
	Power[5,1]:Set[40]
	Power[5,2]:Set[100]
	SpellRange[5,1]:Set[70]

	Action[6]:Set[Smite]
	MobHealth[6,1]:Set[1]
	MobHealth[6,2]:Set[100]
	Power[6,1]:Set[40]
	Power[6,2]:Set[100]
	SpellRange[6,1]:Set[61]
	SpellRange[6,2]:Set[62]

	Action[7]:Set[Stifle]
	MobHealth[7,1]:Set[10]
	MobHealth[7,2]:Set[100]
	Power[7,1]:Set[30]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[190]

	Action[8]:Set[PreKill]
	MobHealth[8,1]:Set[5]
	MobHealth[8,2]:Set[50]
	Power[8,1]:Set[30]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[312]

	Action[9]:Set[AoE]
	MobHealth[9,1]:Set[25]
	MobHealth[9,2]:Set[100]
	Power[9,1]:Set[30]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[90]

	Action[10]:Set[AA_DivineCastigation]
	MobHealth[10,1]:Set[1]
	MobHealth[10,2]:Set[100]
	Power[10,1]:Set[30]
	Power[10,2]:Set[100]
	SpellRange[10,1]:Set[395]
}

function PostCombat_Init()
{
	PostAction[1]:Set[Resurrection]
	PostSpellRange[1,1]:Set[300]
	PostSpellRange[1,2]:Set[301]
}

function Buff_Routine(int xAction)
{

	declare tempvar int local

	call WeaponChange

	ExecuteAtom CheckStuck

	if ${ShardMode}
	{
		call Shard
	}

	call CheckHeals

	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
	}

	;Need to add/write a check for NPCs nearby that might be aggro to stop from buffing like a bot...
	if (${Me.ToActor.Power}>85 && ${KeepReactiveUp} && ${Mob.Detect}) || ${Incoming}
	{
		call CastSpellRange 15
		call CastSpellRange 7 0 0 0 ${Actor[${MainAssist}].ID}
		call CastSpellRange 22 0 0 0 ${Actor[${MainAssist}].ID}
		Incoming:Set[FALSE]
	}

	switch ${PreAction[${xAction}]}
	{
		case Single_Buff_Conc
			if ${Me.UsedConc}<5
			{
				grpcnt:Set[${Me.GroupCount}]
				tempvar:Set[1]
				do
				{
					switch ${Me.Group[${tempvar}].ToActor.Class}
					{
						case berserker
							if ${Me.UsedConc}<5
							{
								call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
								call CastSpellRange 315 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
							}
						case guardian
							if ${Me.UsedConc}<5
							{
								call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
								call CastSpellRange 315 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
							}
						case bruiser
						case monk
						case paladin
						case shadowknight
						case swashbuckler
						case brigand
						case troubador
						case dirge
						case ranger
						case assassin

					}
				}
				while ${tempvar:Inc}<${grpcnt}
			}
			break
		call CheckHeals
		case Self_Buff
			if ${ConvertMode}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case AA_ShieldAlly
		call CheckHeals
		case Tank_Buff
			;If the MA changed during the fight cancel so we can rebuff original MA
			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}!=${Actor[${MainAssist}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${MainAssist}].ID}
			break

		case Group_Buff_Conc
			if ${Me.UsedConc}<5
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			}
			break


		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		Default
			xAction:Set[20]
			break
	}
}

function Combat_Routine(int xAction)
{

	AutoFollowingMA:Set[FALSE]
	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}

	call CheckHeals

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}

	if !${EQ2.HOWindowActive} && ${Me.InCombat}
	{
		call CastSpellRange 303
	}

	if ${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}
	{
		; Use AA Divine Reovery
		call CastSpellRange 396
	}

	if ${MezzMode}
	{
		call Mezmerise_Targets
	}

	call WeaponChange

	call CheckHeals

	call Yaulp

	if ${ShardMode}
	{
		call Shard
	}

	switch ${Action[${xAction}]}
	{
		case Sign_of_Fraility
			if ${DebuffMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}

			}
			break

		case Spurn
			if ${DebuffMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}

			}
			break

		case Involuntary_Restoration
			if ${DebuffMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
						call CastSpellRange 313 0 0 0 ${KillTarget}
					}
				}

			}
			break
		case Warring_Axiom
			if ${OffenseMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}

			}
			break
		case Smite
			if ${OffenseMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 0 0 ${KillTarget}
					}
				}

			}
			break
		call CheckHeals
		case Stifle
			if ${OffenseMode} || ${DebuffMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}

			}
			break

		case AoE
			if ${AoEMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}

			}
			break
		case PreKill
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
			break
		case AA_DivineCastigation
			if ${OffenseMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}

			}
			break
		case Mastery
			if ${OffenseMode} || ${DebuffMode}
			{
					if ${Me.Ability[Master's Smite].IsReady}
					{
						Target ${KillTarget}
						Me.Ability[Master's Smite]:Use
					}
			}
			break
		Default
			xAction:Set[40]
			break
	}
}

function Post_Combat_Routine(int xAction)
{

	TellTank:Set[FALSE]

	call CheckHeals

	;turn off Yaulp
	if ${Me.Maintained[${SpellType[385]}](exists)}
	{
		Me.Maintained[${SpellType[385]}]:Cancel
	}

	; turn off auto attack if we were casting while the last mob died
	if ${Me.AutoAttackOn}
	{
		EQ2Execute /toggleautoattack
	}

	switch ${PostAction[${xAction}]}
	{
		case Resurrection
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1]
			do
			{
				if ${Me.Group[${tempgrp}].ToActor.Health}==-99 && ${Me.Group[${tempgrp}](exists)}
				{
					call CastSpellRange ${PostSpellRange[${xAction},1]} ${PostSpellRange[${xAction},2]} 0 0 ${Me.Group[${tempgrp}].ToActor.ID} 1
				}
			}
			while ${tempgrp:Inc}<${grpcnt}
			break

		Default
			xAction:Set[20]
			break
	}
}

function Have_Aggro()
{

	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTank}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	call CastSpellRange 180 182 0 0 ${aggroid}

}

function CheckHeals()
{
	declare temphl int local
	declare grpheal int local 0
	declare lowest int local 0
	declare grpcure int local 0
	declare mostafflicted int local 0
	declare mostafflictions int local 0
	declare tmpafflictions int local 0
	declare PetToHeal int local 0

	grpcnt:Set[${Me.GroupCount}]
	hurt:Set[FALSE]

	temphl:Set[1]
	grpcure:Set[0]
	lowest:Set[1]

	;Res the MT if they are dead
	if ${Actor[${MainTankPC}].Health}==-99 && ${Actor[${MainTankPC}](exists)}
	{
		call CastSpellRange 300 0 0 0 ${Actor[${MainTankPC}].ID}
	}

	do
	{
		if ${Me.Group[${temphl}].ZoneName.Equal[${Zone.Name}]}
		{

			if ${Me.Group[${temphl}].ToActor.Health}<100 && ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}](exists)}
			{
				if ${Me.Group[${temphl}].ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health}
				{
					lowest:Set[${temphl}]
				}
			}

			if ${Me.Group[${temphl}].IsAfflicted}
			{
				tmpafflictions:Set[${Math.Calc[${Me.Group[${temphl}].Arcane}+${Me.Group[${temphl}].Trauma}+${Me.Group[${temphl}].Elemental}+${Me.Group[${temphl}].Noxious}]}]

				if ${tmpafflictions}>${mostafflictions}
				{
					mostafflictions:Set[${tmpafflictions}]
					mostafflicted:Set[${temphl}]
				}
			}

			if ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}].ToActor.Health}<${HealGroupPercent}
			{
				grpheal:Inc
			}

			if ${Me.Group[${temphl}].Arcane} || ${Me.Group[${temphl}].Trauma}
			{
				grpcure:Inc
			}

			if ${Me.Group[${temphl}].Class.Equal[conjuror]}  || ${Me.Group[${temphl}].Class.Equal[necromancer]}
			{
				if ${Me.Group[${temphl}].ToActor.Pet.Health}<${HealPetPercent} && ${Me.Group[${temphl}].ToActor.Pet.Health}>0
				{
					PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}
				}
			}
		}

	}
	while ${temphl:Inc}<${grpcnt}

	if ${Me.ToActor.Health}<80 && ${Me.ToActor.Health}>-99
	{
		grpheal:Inc
	}

	if ${Me.Arcane} || ${Me.Trauma}
	{
		grpcure:Inc
	}

	;MAINTANK EMERGENCY HEAL
	if ${Me.Group[${lowest}].ToActor.Health}<30 && ${Me.Group[${lowest}].Name.Equal[${MainTankPC}]} && ${Me.Group[${lowest}].ToActor(exists)}
	{
		call EmergencyHeal ${Actor[${MainTankPC}].ID}
	}

	;ME HEALS
	if ${Me.ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health} && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.ToActor.Health}<40
		{
			if ${haveaggro}
			{
				call EmergencyHeal ${Me.ID}
			}
			else
			{
				if ${Me.Ability[${SpellType[1]}].IsReady}
				{
					call CastSpellRange 1 0 0 0 ${Me.ID}
				}
				else
				{
					call CastSpellRange 4 0 0 0 ${Me.ID}
				}
			}
			hurt:Set[TRUE]
		}
		else
		{
			if ${Me.ToActor.Health}<85
			{
				if ${haveaggro}
				{
					call CastSpellRange 7 0 0 0 ${Me.ID}
				}

			}
		}
	}
	;MAINTANK HEALS
	if ${Actor[${MainTankPC}].Health} < ${HealMTPercent} && ${ReactiveOnlyMode} == TRUE && ${Actor[${MainTankPC}].InCombatMode} && ${Actor[${MainTankPC}].Health}>-99
	{
		call CastSpellRange 7 0 0 0 ${Actor[${MainTankPC}].ID}
	}
	else
	{
		if ${Actor[${MainTankPC}].Health} < ${HealMTPercent} && ${Actor[${MainAssist}](exists)} && ${Actor[${MainTankPC}].InCombatMode} && ${Actor[${MainTankPC}].Health}>-99
		{
			call CastSpellRange 7 0 0 0 ${Actor[${MainTankPC}].ID}
		}

		if ${Actor[${MainAssist}].Health} < ${HealMTPercent} && ${Actor[${MainTankPC}].Health} >-99 && ${Actor[${MainTankPC}](exists)}
		{
			call CastSpellRange 1 0 0 0 ${Actor[${MainTankPC}].ID}
		}
	}
	;GROUP HEALS
	if ${grpheal}>2
	{
		if ${Me.Ability[${SpellType[10]}].IsReady}
		{
			call CastSpellRange 10
		}
		else
		{
			call CastSpellRange 15
		}
	}

	if ${Me.Group[${lowest}].ToActor.Health}< ${HealGroupPercent} && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.Ability[${SpellType[1]}].IsReady} && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)}
		{
			call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ToActor.ID}

		}
		else
		{
			call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		}

		hurt:Set[TRUE]
	}

	;CURES
	if ${grpcure}>2 && ${CureMode}
	{
		call CastSpellRange 181
	}

	if ${Me.IsAfflicted} && ${CureMode}
	{
		call CureMe
	}

	if ${mostafflicted} && ${CureMode}
	{
		call CureGroupMember ${mostafflicted}
	}

	;PET HEALS
	if ${PetToHeal} && ${Actor[${PetToHeal}](exists)}
	{
		if ${Actor[${PetToHeal}].InCombatMode}
		{
			call CastSpellRange 7 0 0 0 ${PetToHeal}
		}
		else
		{
			call CastSpellRange 1 0 0 0 ${PetToHeal}
		}
	}



}

function EmergencyHeal(int healtarget)
{

	call CastSpellRange 316 0 0 0 ${healtarget}

	if ${Me.Ability[${SpellType[335]}].IsReady}
	{
		call CastSpellRange 335 0 0 0 ${healtarget}
	}
	else
	{
		call CastSpellRange 17 0 0 0 ${healtarget}
	}

}

function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{

}

function MA_Dead()
{
	if ${Actor[${MainAssist}].Health}==-99 && ${Actor[${MainTankPC}](exists)}
	{
		call 300 301 0 0 ${Actor[${MainTankPC}].ID} 1
	}
}

function Cancel_Root()
{

}

function CureMe()
{
	if  ${Me.Arcane}>0 && !${Me.ToActor.Effect[Revived Sickness](exists)}
	{
		;call CastSpellRange 326
		if ${Me.Arcane} && !${Me.ToActor.Effect[Revived Sickness](exists)}
		{
			call CastSpellRange 210 0 0 0 ${Me.ID}
			return
		}
	}

	if  ${Me.Noxious}>0
	{
		call CastSpellRange 213 0 0 0 ${Me.ID}
		return
	}

	if  ${Me.Elemental}>0
	{
		call CastSpellRange 211 0 0 0 ${Me.ID}
		return
	}

	if  ${Me.Trauma}>0
	{
		call CastSpellRange 212 0 0 0 ${Me.ID}
		return
	}


}

function CureGroupMember(int gMember)
{
	declare tmpcure int local

	tmpcure:Set[0]
	if !${Me.Group[${gMember}].ZoneName.Equal[${Zone.Name}]}
	{
		return
	}

	do
	{
		if  ${Me.Group[${gMember}].Arcane}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}
		}

		if  ${Me.Group[${gMember}].Noxious}>0
		{
			call CastSpellRange 213 0 0 0 ${Me.Group[${gMember}].ID}
		}

		if  ${Me.Group[${gMember}].Elemental}>0
		{
			call CastSpellRange 211 0 0 0 ${Me.Group[${gMember}].ID}
		}

		if  ${Me.Group[${gMember}].Trauma}>0
		{
			call CastSpellRange 212 0 0 0 ${Me.Group[${gMember}].ID}
		}
	}
	while ${Me.Group[${gMember}].IsAfflicted} && ${CureMode} && ${tmpcure:Inc}<3
}



; This is not called/active in this script at present since Templar mez is weak at best.
function Mezmerise_Targets()
{
	declare tcount int local 1
	declare tempvar int local
	declare aggrogrp bool local FALSE

	grpcnt:Set[${Me.GroupCount}]

	EQ2:CreateCustomActorArray[byDist,15]

	do
	{
		if (${CustomActor[${tcount}].Type.Equal[NPC]} || ${CustomActor[${tcount}].Type.Equal[NamedNPC]}) && ${CustomActor[${tcount}](exists)} && !${CustomActor[${tcount}].IsLocked} && !${CustomActor[${tcount}].IsEpic}
		{
			if ${Actor[${MainAssist}].Target.ID}==${CustomActor[${tcount}].ID}
			{
				continue
			}

			tempvar:Set[1]
			aggrogrp:Set[FALSE]
			do
			{
				if ${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ID}
				{
					aggrogrp:Set[TRUE]
					break
				}
			}
			while ${tempvar:Inc}<${grpcnt}

			if ${CustomActor[${tcount}].Target.ID}==${Me.ID}
			{
				aggrogrp:Set[TRUE]
			}


			if ${aggrogrp}
			{

				if ${Me.AutoAttackOn}
				{
					eq2execute /toggleautoattack
				}

				if ${Me.RangedAutoAttackOn}
				{
					eq2execute /togglerangedattack
				}

				;check for wonderous buckling
				if ${Me.Ability[${SpellType[386]}](exists)}
				{
				;check if we have a our buckler equipped if not equip and cast wonderous buckling
					if ${Me.Equipment[2].Name.Equal[${Buckler}]}
					{
						call CastSpellRange 386 0 1 0 ${CustomActor[${tcount}].ID}
					}
					elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
					{
						Me.Inventory[${Buckler}]:Equip
						EquipmentChangeTimer:Set[${Time.Timestamp}]
						call CastSpellRange 386 0 1 0 ${CustomActor[${tcount}].ID}
					}
				}
				aggrogrp:Set[FALSE]
				break

			}


		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}

	Target ${MainAssist}
	wait 10 ${Me.ToActor.Target.ID}==${Actor[${MainAssist}].ID}
}

function Yaulp()
{

	if ${YaulpMode} && ${Me.ToActor.Power}>30
	{
		call CastSpellRange 385


		if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${YaulpWeapon}]}
		{
			Me.Inventory[${YaulpWeapon}]:Equip
			EquipmentChangeTimer:Set[${Time.Timestamp}]
		}

		if !${Me.AutoAttackOn}
		{

			EQ2Execute /toggleautoattack
		}

		if  !${Me.CastingSpell}
		{
			Target ${KillTarget}
			call CheckPosition 1 0
		}
	}
	else
	{

		if ${Me.Maintained[${SpellType[385]}](exists)}
		{
			Me.Maintained[${SpellType[385]}]:Cancel
		}

	}
}


function WeaponChange()
{
	if ${YaulpMode}
	{
		if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${YaulpWeapon}]}
		{
			;equip yaulp weapon
			Me.Inventory[${YaulpWeapon}]:Equip
			EquipmentChangeTimer:Set[${Time.Timestamp}]
		}
	}
	else
	{
		;equip main hand
		if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${MainWeapon}]}
		{
			Me.Inventory[${MainWeapon}]:Equip
			EquipmentChangeTimer:Set[${Time.Timestamp}]
		}

		;equip off hand
		if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[2].Name.Equal[${OffHand}]} && !${Me.Equipment[1].WieldStyle.Find[Two-Handed]}
		{
			Me.Inventory[${OffHand}]:Equip
			EquipmentChangeTimer:Set[${Time.Timestamp}]
		}
	}
}

function IncomingMob()
{
	Incoming:Set[TRUE]
}