;*************************************************************
;Mystic.iss 20070725a
;version
;
;20070725a
; Minor AA weapon change tweaks
;
;20070503a (LostOne)
;Defiler Orginal by karye & updated by pygar
;ported to Mystic by LostOne

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	declare OffenseMode bool script 0
	declare DebuffMode bool script 0
 	declare AoEMode bool script 0
 	declare CureMode bool script 0
 	declare OberonMode bool script 0
 	declare TorporMode bool script 0
	declare KeepWardUp bool script 0
	declare KeepMTWardUp bool script 0
	declare KeepGroupWardUp bool script 0
	declare PetMode bool script 1
	declare CombatRez bool script 1
	declare StartHO bool script 1

	declare BuffNoxious bool script FALSE
	declare BuffMitigation bool script FALSE
	declare BuffStrength bool script FALSE
	declare BuffWaterBreathing bool script FALSE
	declare BuffProcGroupMember string script
	declare BuffAvatarGroupMember string script

	declare EquipmentChangeTimer int script

	declare MainWeapon string script
	declare OffHand string script
	declare OneHandedSpear string script
	declare TwoHandedSpear string script
	declare Symbols string script
	declare Buckler string script
	declare Staff string script

	call EQ2BotLib_Init

	OffenseMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,FALSE]}]
	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	CureMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Cure Spells,FALSE]}]
	OberonMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Oberon Mode,FALSE]}]
	TorporMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Torpor Mode,FALSE]}]
	KeepWardUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepWardUp,FALSE]}]
	KeepMTWardUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepMTWardUp,FALSE]}]
	KeepGroupWardUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepGroupWardUp,FALSE]}]
	PetMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Pets,TRUE]}]
	CombatRez:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Combat Rez,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]

	BuffNoxious:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffNoxious,TRUE]}]
	BuffMitigation:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffMitigation,TRUE]}]
	BuffStrength:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffStrength,TRUE]}]
	BuffWaterBreathing:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffWaterBreathing,FALSE]}]
	BuffProcGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffProcGroupMember,]}]
	BuffAvatarGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffAvatarGroupMember,]}]

	MainWeapon:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[MainWeapon,]}]
	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OffHand,]}]
	OneHandedSpear:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OneHandedSpear,]}]
	TwoHandedSpear:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[TwoHandedSpear,]}]
	Symbols:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[WeaponSymbols,]}]
	Buckler:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buckler,]}]
	Staff:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Staff,]}]
}

function Buff_Init()
{

	PreAction[1]:Set[BuffPower]
	PreSpellRange[1,1]:Set[20]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]

	PreAction[3]:Set[BuffNoxious]
	PreSpellRange[3,1]:Set[31]

	PreAction[4]:Set[BuffAvatar]
	PreSpellRange[4,1]:Set[22]

	PreAction[5]:Set[BuffMitigation]
	PreSpellRange[5,1]:Set[30]

	PreAction[6]:Set[BuffStrength]
	PreSpellRange[6,1]:Set[32]

	PreAction[7]:Set[BuffWaterBreathing]
	PreSpellRange[7,1]:Set[33]

	PreAction[8]:Set[SpiritCompanion]
	PreSpellRange[8,1]:Set[360]

	PreAction[9]:Set[AA_AuraOfHaste]
	PreSpellRange[9,1]:Set[362]

	PreAction[10]:Set[AA_AuraOfWarding]
	PreSpellRange[10,1]:Set[363]

	PreAction[11]:Set[SpecialVision]
	PreSpellRange[11,1]:Set[314]

	PreAction[12]:Set[AA_SpiritualForesight]
	PreSpellRange[12,1]:Set[364]

	PreAction[13]:Set[AA_Immunities]
	PreSpellRange[13,1]:Set[375]

	PreAction[14]:Set[AA_RitualisticAggression]
	PreSpellRange[14,1]:Set[370]
	PreSpellRange[14,2]:Set[371]

	PreAction[15]:Set[AA_InfectiveBites]
	PreSpellRange[15,1]:Set[367]

	PreAction[16]:Set[AA_Coagulate]
	PreSpellRange[16,1]:Set[368]

	PreAction[17]:Set[AA_Virulence]
	PreSpellRange[17,1]:Set[374]

}

function Combat_Init()
{

	Action[1]:Set[Bolster]
	SpellRange[1,1]:Set[21]

	Action[2]:Set[AoE1]
	SpellRange[2,1]:Set[90]

	Action[3]:Set[AARabies]
	SpellRange[3,1]:Set[352]

	Action[4]:Set[Fever]
	MobHealth[4,1]:Set[1]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[1]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[82]

	Action[5]:Set[ChillingWinds]
	MobHealth[5,1]:Set[1]
	MobHealth[5,2]:Set[100]
	Power[5,1]:Set[60]
	Power[5,2]:Set[100]
	SpellRange[5,1]:Set[80]

	Action[6]:Set[TheftOfVitality]
	MobHealth[6,1]:Set[1]
	MobHealth[6,2]:Set[100]
	Power[6,1]:Set[20]
	Power[6,2]:Set[100]
	SpellRange[6,1]:Set[55]

	Action[7]:Set[Mastery]

	Action[8]:Set[UmbralTrap]
	MobHealth[8,1]:Set[1]
	MobHealth[8,2]:Set[100]
	SpellRange[8,1]:Set[54]

	Action[9]:Set[Cold_Flame]
	MobHealth[9,1]:Set[1]
	MobHealth[9,2]:Set[100]
	Power[9,1]:Set[1]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[81]

	Action[10]:Set[Haze]
	MobHealth[10,1]:Set[1]
	MobHealth[10,2]:Set[100]
	Power[10,1]:Set[1]
	Power[10,2]:Set[100]
	SpellRange[10,1]:Set[50]

	Action[11]:Set[Enfeeble]
	MobHealth[11,1]:Set[1]
	MobHealth[11,2]:Set[100]
	Power[11,1]:Set[1]
	Power[11,2]:Set[100]
	SpellRange[11,1]:Set[52]

	Action[12]:Set[Mourning_Soul]
	MobHealth[12,1]:Set[1]
	MobHealth[12,2]:Set[100]
	Power[12,1]:Set[1]
	Power[12,2]:Set[100]
	SpellRange[12,1]:Set[53]

	Action[13]:Set[ThermalShocker]

	Action[14]:Set[AA_CripplingBash]
	MobHealth[14,1]:Set[1]
	MobHealth[14,2]:Set[100]
	SpellRange[14,1]:Set[366]

	Action[15]:Set[Slothful_Spirit]
	MobHealth[15,1]:Set[1]
	MobHealth[15,2]:Set[100]
	Power[15,1]:Set[1]
	Power[15,2]:Set[100]
	SpellRange[15,1]:Set[83]

}

function PostCombat_Init()
{
	PostAction[1]:Set[Resurrection]
	PostSpellRange[1,1]:Set[300]
	PostSpellRange[1,2]:Set[301]

	PostAction[2]:Set[LoadDefaultEquipment]
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local

	variable int temp

	call WeaponChange

	ExecuteAtom CheckStuck

	if ${ShardMode}
	{
		call Shard
	}

	call CheckWards
	call CheckHeals

	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
	}

	if ${Me.ToActor.Power}>85 && ${KeepWardUp}
	{
		call CastSpellRange 15
		call CastSpellRange 7 0 0 0 ${Actor[${MainTankPC}].ID}
	}


	switch ${PreAction[${xAction}]}
	{
		case BuffPower
			Counter:Set[1]
			tempvar:Set[1]

			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			do
			{
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
				{
					;iterate through the members to buff
					if ${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{

						tempvar:Set[1]
						do
						{

							BuffTarget:Set[${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}


						}
						while ${tempvar:Inc}<=${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
						;we went through the buff collection and had no match for this maintaned target so cancel it
						if !${BuffMember.Equal[OK]}
						{
							;we went through the buff collection and had no match for this maintaned target so cancel it
							Me.Maintained[${Counter}]:Cancel
						}
					}
					else
					{
						;our buff member collection is empty so this maintained target isnt in it
						Me.Maintained[${Counter}]:Cancel
					}
				}

			}
			while ${Counter:Inc}<=${Me.CountMaintained}


			Counter:Set[1]
			;iterate through the to be buffed Selected Items and buff them
			if ${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{

				do
				{
					BuffTarget:Set[${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					;continue of pc is out of your group
					if ${BuffTarget.Token[2,:].Equal[PC]} && !${Me.Group[${Actor[id,${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}].Name}](exists)}
					{
						continue
					}
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}

				}
				while ${Counter:Inc}<=${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break
		case SpiritCompanion
			if ${PetMode} && !${Me.InCombat}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			}
			break

		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case AA_Coagulate
			if ${Actor[${MainTankPC}](exists)}
			{
				;If the MA changed during the fight cancel so we can rebuff original MA
				if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}!=${Actor[${MainTankPC}].ID}
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${MainTankPC}].ID}
			}
			break
		case BuffNoxious
			if ${BuffNoxious}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffMitigation
			if ${BuffMitigation}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffStrength
			if ${BuffStrength}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffWaterBreathing
			if ${BuffWaterBreathing}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffAvatar
			BuffTarget:Set[${UIElement[cbBuffAvatarGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				;break of pc is out of your group
				if ${BuffTarget.Token[2,:].Equal[PC]} && !${Me.Group[${Actor[id,${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}].Name}](exists)}
				{
					break
				}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case Resurrection
			temp:Set[1]
			do
			{
				if ${Me.Group[${temp}].ToActor.Health}==-99 && ${Me.Group[${temp}].ToActor(exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 1 0 ${Me.Group[${temp}].ID} 1
				}
			}
			while ${temp:Inc}<${Me.GroupCount}
			break
		case AA_Immunities
		case AA_AuraOfHaste
			if !${Me.ToActor.Effect[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Me.ToActor.Pet(exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break
		case AA_SpiritualForesight
		case AA_RitualisticAggression
		case AA_RitualOfAbsolution
		case AA_InfectiveBites
		case AA_Virulence
		case AA_AuraOfWarding
			if ${Me.ToActor.Pet(exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			}
			break
		Default
			xAction:Set[40]
			break
	}
}

function Combat_Routine(int xAction)
{

	AutoFollowingMA:Set[FALSE]
	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
		wait 5
	}

	call CheckGroupHealth 60
	if ${DoHOs} && ${Return}
	{
		objHeroicOp:DoHO
	}

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
	{
		call CastSpellRange 303
	}

	ExecuteAtom PetAttack

	call CheckWards
	call CheckHeals
	call RefreshPower

	;keep Leg Bite up at all times if we have a pet
	if ${Me.Maintained[${SpellType[360]}](exists)}
	{
		call CastSpellRange 360
	}

	if ${ShardMode}
	{
		call Shard
	}

	if ${OberonMode}
	{
		call CheckGroupHealth 60

		if !${Return} && ${Me.Maintained[${SpellType[317]}](exists)}
		{
			Me.Maintained[${SpellType[317]}]:Cancel
		}

	}
	elseif ${Me.Maintained[${SpellType[317]}](exists)}
	{
		Me.Maintained[${SpellType[317]}]:Cancel
	}

	;Before we do our Action, check to make sure our group doesnt need healing
	call CheckGroupHealth 60
	if ${Return}
	{
		switch ${Action[${xAction}]}
		{
			case Enfeeble
			case Haze
			case Mourning_Soul
			case Slothful_Spirit
			case UmbralTrap
			case TheftOfVitality
			case AA_Hexation
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
			case AA_CripplingBash
				;note: will only bash if within 5 meters, this is by design to prevent having to implement a range only mode
				if ${DebuffMode} && ${Me.Maintained[${SpellType[360]}](exists)}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							if ${Me.Equipment[1].Name.Equal[${Buckler}]}
							{
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
							}
							elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
							{
								Me.Inventory[${Buckler}]:Equip
								EquipmentChangeTimer:Set[${Time.Timestamp}]
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
							}

						}
					}
				}
				break
			case Fever
			case ChillingWinds
			case Cold_Flame
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
			case AoE1
			case AARabies
				if ${AoEMode}
				{
					if ${Mob.Count}>2
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
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
			case ThermalShocker
				if ${Me.Inventory[ExactName,"Brock's Thermal Shocker"](exists)} && ${Me.Inventory[ExactName,"Brock's Thermal Shocker"].IsReady}
				{
					Me.Inventory[ExactName,"Brock's Thermal Shocker"]:Use
				}
			case Bolster
			if ${Actor[${MainTankPC}].Health}>80
			{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${Actor[${MainTankPC}].ID} 1
			}
			break
			default
				xAction:Set[40]
				break
		}
	}
}

function Post_Combat_Routine(int xAction)
{

	;Turn off Oberon so we can move
	if ${Me.Maintained[${SpellType[317]}](exists)}
	{
		Me.Maintained[${SpellType[317]}]:Cancel
	}

	TellTank:Set[FALSE]

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
				if ${Me.Group[${tempgrp}].ToActor.Health}==-99
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 1 0 ${Me.Group[${tempgrp}].ID} 1
				}
			}
			while ${tempgrp:Inc}<${grpcnt}
			break
		case LoadDefaultEquipment
			ExecuteAtom LoadEquipmentSet "Default"
		default
			xAction:Set[20]
			break
	}
}

function Have_Aggro()
{

	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTankPC}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	if !${MainTank}
	{
		;Try AE mez hate reduction
		call CastSpellRange 180
	}



}
function RefreshPower()
{

	if ${Me.InCombat} && ${Me.ToActor.Power}<65  && ${Me.ToActor.Health}>25
	{
		call UseItem "Tribal Spiritist's Hat"
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<45
	{
		call UseItem "Spiritise Censer"
	}

	if ${Me.InCombat} && ${Me.ToActor.Power}<15
	{
		call UseItem "Stein of the Everling Lord"
	}

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
	declare MTinMyGroup bool local FALSE

	grpcnt:Set[${Me.GroupCount}]
	hurt:Set[FALSE]

	temphl:Set[1]
	grpcure:Set[0]
	lowest:Set[1]

	;Cancel Oberon if up and tank dieing
	if ${Me.Maintained[${SpellType[317]}](exists)} && (${Actor[${MainTankPC}].Health}<30 && ${Actor[${MainTankPC}].Health}>-99 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].ID}!=${Me.ID}) && ${Me.ToActor.Power} >20 || !${OberonMode}
	{
		Me.Maintained[${SpellType[317]}]:Cancel
	}

	;Res the MT if they are dead
	if ${Actor[PC,${MainTankPC}].Health}==-99 && ${Actor[PC,${MainTankPC}](exists)} && ${CombatRez}
	{
		call CastSpellRange 300 0 0 0 ${Actor[${MainTankPC}].ID}
	}

	do
	{
		if ${Me.Group[${temphl}].ToActor(exists)}
		{

			if ${Me.Group[${temphl}].ToActor.Health}==-99 && !${Me.InCombat}
			{
				call CastSpellRange 300 301 1 0 ${Me.Group[${temphl}].ID} 1
			}

			if ${Me.Group[${temphl}].ToActor.Health}<100 && ${Me.Group[${temphl}].ToActor.Health}>-99
			{
				if ${Me.Group[${temphl}].ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health}
				{
					lowest:Set[${temphl}]
				}
			}

			if ${Me.Group[${temphl}].IsAfflicted}

			{
				if ${Me.Group[${temphl}].Arcane}>0
				{
					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Arcane}]}]
				}

				if ${Me.Group[${temphl}].Noxious}>0
				{
					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Noxious}]}]
				}

				if ${Me.Group[${temphl}].Elemental}>0
				{
					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Elemental}]}]
				}

				if ${Me.Group[${temphl}].Trauma}>0
				{
					tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Trauma}]}]
				}

				if ${tmpafflictions}>${mostafflictions}
				{
					mostafflictions:Set[${tmpafflictions}]
					mostafflicted:Set[${temphl}]
				}
			}

			if ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}].ToActor.Health}<80
			{
				grpheal:Inc
			}

			if ${Me.Group[${temphl}].Noxious}>0 || ${Me.Group[${temphl}].Trauma}>0
			{
				grpcure:Inc
			}

			if ${Me.Group[${temphl}].Class.Equal[conjuror]}  || ${Me.Group[${temphl}].Class.Equal[necromancer]}
			{
				if ${Me.Group[${temphl}].ToActor.Pet.Health}<60 && ${Me.Group[${temphl}].ToActor.Pet.Health}>0
				{
					PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}
				}
			}

			if ${Me.ToActor.Pet.Health}<60
			{
				PetToHeal:Set[${Me.ToActor.Pet.ID}]

			}

			if ${Me.Group[${temphl}].Name.Equal[${MainTankPC}]}
			{
				MTinMyGroup:Set[TRUE]
			}
		}

	}
	while ${temphl:Inc}<${grpcnt}

	if ${Me.ToActor.Health}<80 && ${Me.ToActor.Health}>-99
	{
		grpheal:Inc
	}

	if ${Me.Noxious}>0 || ${Me.Trauma}>0
	{
		grpcure:Inc
	}

	;CURES
	if ${grpcure}>2 && ${CureMode}
	{
		call CastSpellRange 220
		;fire off group noxious ward
		call CastSpellRange 17
	}

	if ${Me.IsAfflicted} && ${CureMode}
	{
		call CureMe
	}

	call CheckGroupHealth 30
	if ${mostafflicted} && ${CureMode} && ${Return}
	{
		call CureGroupMember ${mostafflicted}
	}

	;MAINTANK EMERGENCY HEAL
	if ${Me.Group[${lowest}].ToActor.Health}<30 && ${Me.Group[${lowest}].Name.Equal[${MainTankPC}]} && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)}
	{
		call EmergencyHeal ${Actor[${MainTankPC}].ID}
	}

	;ME HEALS
	if ${Me.ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health} && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.ToActor.Health}<85
		{
			if ${haveaggro} && ${Me.ToActor.InCombatMode}
			{
				call CastSpellRange 7 0 0 0 ${Me.ID}
			}
			else
			{
				call CastSpellRange 4 0 0 0 ${Me.ID}
			}
		}

		if ${Me.ToActor.Health}<25
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
		}

	}

	;MAINTANK HEALS
	if ${Actor[${MainTankPC}].Health} <90 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].InCombatMode} && ${Actor[${MainTankPC}].Health}>-99
	{
		if !${KeepMTWardUp}
		{
			call CastSpellRange 7 0 0 0 ${Actor[${MainTankPC}].ID}
		}

		if !${KeepGroupWardUp} && ${MTinMyGroup}
		{
			call CastSpellRange 15
		}

		if ${OberonMode} && ${MTinMyGroup} && ${Me.Ability[${SpellType[317]}].IsReady} && ${Actor[${MainTankPC}].ID}!=${Me.ID} && ${Me.ToActor.Power}<40
		{
			call CastSpellRange 317 0 0 0 ${Actor[${MainTankPC}].ID}
		}
	}

	if ${Actor[${MainTankPC}].Health} <90 && ${Actor[${MainTankPC}].Health} >-99 && ${Actor[${MainTankPC}](exists)}
	{
		call CastSpellRange 1 0 0 0 ${Actor[${MainTankPC}].ID}
	}

	if ${Actor[${MainTankPC}].Health} <60 && ${Actor[${MainTankPC}].Health} >-99 && ${Actor[${MainTankPC}](exists)} && ${Actor[${KillTarget}].IsEpic} && ${TorporMode}
	{
		call CastSpellRange 8 0 0 0 ${Actor[${MainTankPC}].ID}
	}

	;GROUP HEALS
	if ${grpheal}>=2
	{
		if ${Me.Ability[${SpellType[10]}].IsReady}
		{
			call CastSpellRange 10
		}
		elseif ${Me.Ability[${SpellType[15]}].IsReady} && !${KeepGroupWardUp}
		{
			call CastSpellRange 15
		}

		; Cast shadowy attendant
		if ${PetMode}
		{
			call CastSpellRange 16
		}
	}

	if ${Me.Group[${lowest}].ToActor.Health}<80 && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.Ability[${SpellType[1]}].IsReady}
		{
			call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ToActor.ID}

		}
		else
		{
			call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		}
		hurt:Set[TRUE]
	}

	if ${Me.Group[${lowest}].ToActor.Health}<60 && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)} && ${TorporMode}
	{
		call CastSpellRange 8 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
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

	;Res Fallen Groupmembers only if in range
	grpcnt:Set[${Me.GroupCount}]
	tempgrp:Set[1]
	do
	{
		if ${Me.Group[${tempgrp}].ToActor.Health}==-99 && ${Me.Group[${tempgrp}].ToActor(exists)} && ${CombatRez}
		{
			call CastSpellRange 300 301 0 0 ${Me.Group[${tempgrp}].ID} 1
		}
	}
	while ${tempgrp:Inc}<${grpcnt}

}

function CheckWards()
{

	;===============================================;
	;First off, lets make sure the MT has a ward on	;
	;Loop through maintained spells, find a ward	;
	;===============================================;
	declare tempvar int local 1
	declare ward1 int local 0
	declare grpward int local 0
	ward1:Set[0]
	grpward:Set[0]
	if ${Me.InCombat} || ${Actor[exactname,${MainTankPC}].InCombatMode}
	{
		do
		{
			if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[7]}]}&&${Me.Maintained[${tempvar}].Target.ID}==${Actor[${MainTankPC}].ID}
			{
			;===============================================;
			;Set the var Ward1 if ward is still present	;
			;===============================================;
				;echo Ward is present.
			ward1:Set[1]
			break
			}
			elseif ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[15]}]}
			{
				;echo Group ward Present
			grpward:Set[1]
			}
		}
		while ${tempvar:Inc}<=${Me.CountMaintained}

		if ${KeepMTWardUp}
		{
			if ${ward1}==0&&${Me.Power}>${Me.Ability[${SpellType[7]}].PowerCost}
			{
				call CastSpellRange 7 0 0 0 ${Actor[${MainTankPC}].ID}
				ward1:Set[1]
			}
		}

		if ${KeepGroupWardUp}
		{
			if ${grpward}==0&&${Me.Power}>${Me.Ability[${SpellType[15]}].PowerCost}
			{
				call CastSpellRange 15
			}
		}

		;=======================================================================;
		;  Next, See if ward2 needs to be used (Long recast, emergency ward     ;
		;=======================================================================;
		if ${Actor[${MainTankPC}].Health}<30
		{
			call CastSpellRange 8 0 0 0 ${Actor[${MainTankPC}].ID}
		}
	}
}

function EmergencyHeal(int healtarget)
{

	;Use Eidolic Savior (single target group only)
	if ${Me.Ability[${SpellType[338]}].IsReady} && (${Me.ID}==${healtarget} || ${Me.Group[${Actor[id,${healtarget}].Name}](exists)})
	{
		call CastSpellRange 338 0 0 0 ${healtarget}
	}

  ;Use Eidolic Ward if ready else use Wards of the Eidolon
	if ${Me.Ability[${SpellType[335]}].IsReady}
	{
		call CastSpellRange 335 0 0 0 ${healtarget}
	}
	elseif ${Me.Ability[${SpellType[334]}].IsReady} && (${Me.ID}==${healtarget} || ${Me.Group[${Actor[id,${healtarget}].Name}](exists)})
	{
		call CastSpellRange 334 0 0 0 ${healtarget}
	}

}

function CheckHealerMob()
{
	declare tcount int local 2

	EQ2:CreateCustomActorArray[byDist,15]
	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]}
		{
			switch ${CustomActor[${tcount}].Class}
			{
				case templar
				case inquisitor
				case fury
				case warden
				case defiler
				case mystic
					return TRUE
			}
		}
	}
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

	return FALSE
}

function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{

}

function MA_Dead()
{
	if ${Actor[${MainTankPC}].Health}==-99 && ${Actor[${MainTankPC}](exists)} && ${CombatRez}
	{
		call 300 301 0 0 ${Actor[${MainTankPC}].ID} 1
	}
}

function CureMe()
{
	if ${Me.Arcane}>0
	{
		call CastSpellRange 326

		if ${Me.Arcane}>0
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
	if !${Me.Group[${gMember}].ToActor(exists)}
	{
		return
	}

	do
	{
		;first use Ancient Balm if up (single target cure all)
		call CastSpellRange 214 0 0 0 ${Me.Group[${gMember}].ID}

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
	while ${Me.Group[${gMember}].IsAfflicted} && ${CureMode} && ${tmpcure:Inc}<3 && ${Me.Group[${gMember}].ToActor(exists)}
}

function WeaponChange()
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