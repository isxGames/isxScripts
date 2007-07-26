;*****************************************************
;Dirge.iss 20070404a
;by Karye
;updated by Pygar
;
;20070404a
;updated for latest eq2bot
;updated master strikes
;
;fixed a bug with hate buffing
;*****************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	declare OffenseMode bool script 0
	declare DebuffMode bool script 0
	declare AoEMode bool script 0
	declare BowAttacksMode bool script 0
	declare RangedAttackMode bool script 0

	declare BuffParry bool script FALSE
	declare BuffPower bool script FALSE
	declare BuffNoxious bool script FALSE
	declare BuffDPS bool script FALSE
	declare BuffStoneSkin bool script FALSE
	declare BuffTombs bool script FALSE
	declare BuffAgility bool script FALSE
	declare BuffMelee bool script FALSE
	declare BuffHate bool script FALSE
	declare BuffSelf bool script FALSE
	declare BuffTarget string script

	;Custom Equipment
	declare WeaponRapier string script
	declare WeaponSword string script
	declare WeaponDagger string script
	declare PoisonCureItem string script
	declare WeaponMain string script

	declare EquipmentChangeTimer int script

	call EQ2BotLib_Init

	OffenseMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,TRUE]}]
	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	BowAttacksMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Bow Attack Spells,FALSE]}]
	RangedAttackMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Ranged Attacks Only,FALSE]}]

	BuffParry:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Parry","FALSE"]}]
	BuffPower:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Power","FALSE"]}]
	BuffNoxious:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Noxious","FALSE"]}]
	BuffDPS:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff DPS","FALSE"]}]
	BuffStoneSkin:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff StoneSkin","FALSE"]}]
	BuffTombs:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Tombs","FALSE"]}]
	BuffAgility:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Agility","FALSE"]}]
	BuffMelee:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Melee","FALSE"]}]
	BuffHate:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Hate","FALSE"]}]
	BuffSelf:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Self","FALSE"]}]

	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["MainWeapon",""]}]
	WeaponRapier:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Rapier",""]}]
	WeaponSword:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Sword",""]}]
	WeaponDagger:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Dagger",""]}]

}

function Buff_Init()
{
;echo buff init
	PreAction[1]:Set[Buff_Parry]
	PreSpellRange[1,1]:Set[20]

	PreAction[2]:Set[Buff_Power]
	PreSpellRange[2,1]:Set[21]

	PreAction[3]:Set[Buff_Noxious]
	PreSpellRange[3,1]:Set[22]

	PreAction[5]:Set[Buff_DPS]
	PreSpellRange[5,1]:Set[24]

	PreAction[7]:Set[Buff_StoneSkin]
	PreSpellRange[7,1]:Set[26]

	PreAction[8]:Set[Buff_Tombs]
	PreSpellRange[8,1]:Set[27]

	PreAction[9]:Set[Buff_Agility]
	PreSpellRange[9,1]:Set[28]

	PreAction[10]:Set[Buff_Melee]
	PreSpellRange[10,1]:Set[29]

	PreAction[11]:Set[Buff_Hate]
	PreSpellRange[11,1]:Set[30]

	PreAction[12]:Set[Buff_Self]
	PreSpellRange[12,1]:Set[31]

	PreAction[13]:Set[Buff_AAHarbingersSonnet]
	PreSpellRange[13,1]:Set[385]

	PreAction[14]:Set[Buff_AAAllegro]
	PreSpellRange[14,1]:Set[390]

	PreAction[15]:Set[Buff_AADontKillTheMessenger]
	PreSpellRange[15,1]:Set[395]

	PreAction[16]:Set[Buff_AALuckOfTheDirge]
	PreSpellRange[16,1]:Set[382]

	PreAction[16]:Set[Buff_AAHeroicStorytelling]
	PreSpellRange[16,1]:Set[396]

}

function Combat_Init()
{

	Action[1]:Set[AARhythm_Blade]
	SpellRange[1,1]:Set[397]

	Action[2]:Set[CacophonyOfBlades]
	SpellRange[2,1]:Set[155]

	Action[3]:Set[AoE1]
	SpellRange[3,1]:Set[62]

	Action[4]:Set[Luda]
	SpellRange[4,1]:Set[60]

	Action[5]:Set[InfectedBladed]
	SpellRange[5,1]:Set[150]

	Action[6]:Set[Mastery]

	Action[7]:Set[Flank_Attack]
	SpellRange[7,1]:Set[110]

	Action[8]:Set[Grievance]
	SpellRange[8,1]:Set[151]

	Action[9]:Set[ScreamOfDeath]
	SpellRange[9,1]:Set[391]
	SpellRange[9,2]:Set[135]

	Action[10]:Set[Stealth_Attack]
	SpellRange[10,1]:Set[391]
	SpellRange[10,2]:Set[136]

	Action[11]:Set[WailOfTheDead]
	SpellRange[11,1]:Set[152]

	Action[12]:Set[AATurnstrike]
	SpellRange[12,1]:Set[387]

	Action[13]:Set[Lanet]
	SpellRange[13,1]:Set[52]

	Action[14]:Set[AoE2]
	SpellRange[14,1]:Set[63]

	Action[15]:Set[Tarven]
	SpellRange[15,1]:Set[50]

	Action[16]:Set[Jael]
	SpellRange[16,1]:Set[250]

	Action[17]:Set[AAHarmonizingShot]
	SpellRange[17,1]:Set[386]

	Action[18]:Set[Stun]
	SpellRange[18,1]:Set[190]

}


function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{
	Call ActionChecks

	ExecuteAtom CheckStuck

	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
	}
	switch ${PreAction[${xAction}]}
	{
		case Buff_Parry
			if ${BuffParry}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Buff_Power
			if ${BuffPower}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Buff_Noxious
			if ${BuffNoxious}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Buff_DPS
			if ${BuffDPS}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break

		case Buff_StoneSkin
			if ${BuffStoneSkin}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Buff_Tombs
			if ${BuffTombs}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Buff_Agility
			if ${BuffAgility}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Buff_Melee
			if ${BuffMelee}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Buff_Hate
			BuffTarget:Set[${UIElement[cbBuffHateGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${BuffHate}
			{

				if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Buff_Self
			if ${BuffSelf}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Buff_AAHeroicStorytelling
		case Buff_AAHarbingersSonnet
		case Buff_AAAllegro
		case Buff_AALuckOfTheDirge
		case Buff_AADontKillTheMessenger

		Default
			xAction:Set[20]
			break
	}

}

function Combat_Routine(int xAction)
{
;echo combat routine

	AutoFollowingMA:Set[FALSE]
	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}

	if !${EQ2.HOWindowActive} && ${Me.InCombat}
	{
		call CastSpellRange 303
	}

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}

	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${WeaponMain}]}
	{
		Me.Inventory[${WeaponMain}]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}

	call ActionChecks

	call DoMagneticNote

	if ${DebuffMode}
	{
		;always keep encounter debuffs refreshed
		call CastSpellRange 55 57
	}

	if !${RangedAttackMode}
	{
		;Always keep mob disease Debuffed
		call CastSpellRange 51 0 1 0 ${KillTarget}
	}

	if ${RangedAttackMode}
	{
		if !${Me.RangedAutoAttackOn}
		{

			EQ2Execute /togglerangedattack
		}

		if  !${Me.CastingSpell}
		{
			Target ${KillTarget}
			call CheckPosition 3 0
		}
	}
	switch ${Action[${xAction}]}
	{
		case ScreamOfDeath
			if !${RangedAttackMode} && ${Me.Ability[Shroud].IsReady} && ${Me.Ability[Scream of Death].IsReady} && !${MainTank}  && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Type.Equal[NamedNPC]})
			{
				;check if we have the bump AA and use it to stealth us
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 1 ${KillTarget}
				}

				;if we didnt bardAA "Bump" into stealth use normal stealth
				if ${Me.ToActor.Effect[Shroud](exists)}
				{
					call CastSpellRange ${SpellRange[${xAction},2]} 0 1 1 ${KillTarget}
				}
				else
				{
					call CastSpellRange 200
					call CastSpellRange ${SpellRange[${xAction},2]} 0 1 1 ${KillTarget}
				}
			}
			break
		case Stealth_Attack
			if ${OffenseMode} && !${MainTank} && !${RangedAttackMode}
			{
				;check if we have the bump AA and use it to stealth us
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}](exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 1 ${KillTarget}
				}

				;if we didnt bardAA "Bump" into stealth use normal stealth
				if ${Me.ToActor.Effect[Shroud](exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},2]}]}].IsReady}
				{
					call CastSpellRange ${SpellRange[${xAction},2]} 0 1 1 ${KillTarget}
				}
				else
				{
					call CastSpellRange 200
					call CastSpellRange ${SpellRange[${xAction},2]} 0 1 1 ${KillTarget}
				}
			}
			break
		case AoE2
		case AoE1
			if ${AoEMode} && ${Mob.Count}>=2
			{
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 0 ${KillTarget}
			}
			break

		case AATurnstrike
			if !${RangedAttackMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Type.Equal[NamedNPC]})
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break
		case Mastery
			if !${MainTank} && ${Target.Target.ID}!=${Me.ID}
			{
				if ${Me.Ability[Sinister Strike].IsReady} && ${Actor[${KillTarget}](exists)}
				{
					Target ${KillTarget}
					call CheckPosition 1 1
					Me.Ability[Sinister Strike]:Use
				}
			}
			break
		case AAHarmonizingShot
		case Jael
			if ${BowAttacksMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 3 0 ${KillTarget}
			}
			break
		case AARhythm_Blade
		case Grievance
		case InfectedBladed
		case WailOfTheDead
		case Tarven
			if !${RangedAttackMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break

		case CacophonyOfBlades
			call CastSpellRange ${SpellRange[${xAction},1]}
			break

		case Flank_Attack
			if !${RangedAttackMode} && !${MainTank}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 1 ${KillTarget}
			}
			break

		case Luda
		case Lanet
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			break
		case Stun
			if !${RangedAttackMode}
			{
				if !${Target.IsEpic}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
			}
			break

		default
			xAction:Set[20]
			break
	}
}

function Post_Combat_Routine()
{
	if ${Me.Maintained[Shroud](exists)}
	{
		Me.Maintained[Shroud]:Cancel
	}
}

function Have_Aggro()
{

	if ${agroid}==${KillTarget}
	{
		;evade
		call CastSpellRange 180 0 0 0 ${agroid}
	}
	else
	{
		;fear it off since its an add
		call CastSpellRange 352 0 0 0 ${agroid}
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

}

function Cancel_Root()
{

}
function CheckHeals()
{

	declare temphl int local 1
	grpcnt:Set[${Me.GroupCount}]

	;oration of sacrifice heal
	do
	{

		;oration of sacrifice heal
		if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.Health}<40 && ${Me.Group[${temphl}].ToActor.Health}>1 && ${Me.ToActor.Health}>75 && !${haveaggro} && !${MainTank} && ${Me.Group[${temphl}].ToActor.Distance}<=20 && ${Me.Ability[${SpellType[1]}].IsReady}
		{
			EQ2Echo healing ${Me.Group[${temphl}].ToActor.Name}
			call CastSpellRange 1 0 0 0 ${Me.Group[${temphl}].ID}
			Target ${KillTarget}

		}

		;Res
		if ${Me.Group[${temphl}].ToActor.Health}==-99 && ${Me.Group[${temphl}].ToActor.Distance}<10 && ${Me.Group[${temphl}].ToActor(exists)}
		{
			call CastSpellRange 300 0 0 0 ${Me.Group[${temphl}].ID}
			Target ${KillTarget}
		}

	}
	while ${temphl:Inc}<${grpcnt}

	call UseCrystallizedSpirit 60
}



function ActionChecks()
{

	if ${ShardMode}
	{
		call Shard
	}

	call CheckHeals
}

function DoMagneticNote()
{
	declare tcount int local
	declare tempvar int local
	declare aggrogrp bool local FALSE

	tempvar:Set[1]

	grpcnt:Set[${Me.GroupCount}]

	EQ2:CreateCustomActorArray[byDist,35]

	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].Target(exists)}
		{

			if (${Actor[${MainTankPC}].Target.ID}==${CustomActor[${tcount}].ID})
			{
				continue
			}

			tempvar:Set[1]
			aggrogrp:Set[FALSE]
			if ${grpcnt}>1
			{
				do
				{
					if ${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ID} || (${CustomActor[${tcount}].Target.ID}==${Me.Group[${tempvar}].ToActor.Pet.ID} && ${Me.Group[${tempvar}].ToActor.Pet(exists)})
					{
						call IsFighter ${Me.Group[${tempvar}].ID}
						if ${Return} || ${Me.Group[${tempvar}].Name.Equal[${MainTankPC}]}
						{
							continue
						}
						else
						{
							aggrogrp:Set[TRUE]
							break
						}

					}
				}
				while ${tempvar:Inc}<=${grpcnt}
			}

			if ${CustomActor[${tcount}].Target.ID}==${Me.ID}  && !${MainTank}
			{
				aggrogrp:Set[TRUE]
			}

			if ${aggrogrp}
			{
				call CastSpellRange 383 0 0 0 ${Actor[${MainTankPC}].ID}

				return
			}

		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}


}
