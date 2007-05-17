;*************************************************************
;Warden.iss
;version 20070514a
; by Pygar
;
;20070514a
; Fixed a rez loop issue
; optomized me heals
; will cancel Genesis and Duststorm after fight or when needed.
;
;20070503a
; Fized Combat Rez check to all rezes
; Added toggle for Pet usage
; Fixed Heal routine for Maintankpc
; Tweaked heal routine heavily
;	Added group heal check to cure loop
; Added epic check to root and snare calls
; Added support for Nature Walk AA ability
;	Fixed numerous spellkey issues
;
;20070201a
;Combat Rez is now a toggle
;Initiating HO's is now a toggle
;Added KoS and EoF AA line
;Added support for combat CA line
;Tweaked DPS
;Upgraded for EQ2Bot 2.5.2
;
;
;20061130a
; Fixed some spellKey and buffing bugs
; Also removed from debugging that was still active.
; Also fixed rezing loop
;
; 20071222a
; Improved Cure Routine
; Improvied Heal Routine
; Added Genesis Support
; Fixed Offensive mode toggles to preserver power for heals
; Added SoW
; Fixed Curing uncurable effects
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{

	declare OffenseMode bool script
	declare AoEMode bool script
	declare CureMode bool script
	declare GenesisMode bool script
	declare KeepReactiveUp bool script
	declare BuffBoon bool script 1
	declare UseCAs bool script 1
	declare BuffThorns bool script 1
	declare CombatRez bool script 1
	declare StartHO bool script 1
	declare PetMode bool script 1

	declare BuffBatGroupMember string script
	declare BuffInstinctGroupMember string script
	declare BuffSporesGroupMember string script
	declare BuffVigorGroupMember string script

	declare EquipmentChangeTimer int script

	declare MainWeapon string script
	declare OffHand string script
	declare OneHandedHammer string script
	declare TwoHandedHammer string script
	declare Symbols string script
	declare Buckler string script
	declare TwoHandedStaff string script

	call EQ2BotLib_Init

	OffenseMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,FALSE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	CureMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Cure Spells,FALSE]}]
	GenesisMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Genesis,FALSE]}]
	KeepReactiveUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepReactiveUp,FALSE]}]
	UseCAs:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[UseCAs,FALSE]}]
	CombatRez:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Combat Rez,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
	BuffThorns:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Thorns,FALSE]}]
	PetMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Pets,TRUE]}]

	BuffBatGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffBatGroupMember,]}]
	BuffInstinctGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffInstinctGroupMember,]}]
	BuffSporesGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffSporesGroupMember,]}]
	BuffVigorGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffVigorGroupMember,]}]

	MainWeapon:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[MainWeapon,]}]
	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OffHand,]}]
	OneHandedHammer:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OneHandedHammer,]}]
	TwoHandedHammer:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[TwoHandedHammer,]}]
	Symbols:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[WeaponSymbols,]}]
	Buckler:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buckler,]}]
	TwoHandedStaff:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[TwoHandedStaff,]}]
}

function Buff_Init()
{

	PreAction[1]:Set[BuffThorns]
	PreSpellRange[1,1]:Set[40]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]

	PreAction[3]:Set[BuffBoon]
	PreSpellRange[3,1]:Set[280]

	PreAction[4]:Set[BuffVigor]
	PreSpellRange[4,1]:Set[36]

	PreAction[5]:Set[Group_Buff]
	PreSpellRange[5,1]:Set[20]
	PreSpellRange[5,2]:Set[21]
	PreSpellRange[5,3]:Set[23]

	PreAction[7]:Set[SOW]
	PreSpellRange[7,1]:Set[31]

	PreAction[8]:Set[BuffBat]
	PreSpellRange[8,1]:Set[35]

	PreAction[9]:Set[BuffInstinct]
	PreSpellRange[9,1]:Set[38]

	PreAction[10]:Set[BuffSpores]
	PreSpellRange[10,1]:Set[37]

	PreAction[11]:Set[AA_Rebirth]
	PreSpellRange[11,1]:Set[380]

	PreAction[12]:Set[AA_Infusion]
	PreSpellRange[12,1]:Set[391]

	PreAction[13]:Set[AA_Force_of_Nature]
	PreSpellRange[13,1]:Set[393]

	PreAction[14]:Set[AA_Nature_Walk]
	PreSpellRange[14,1]:Set[392]
}

function Combat_Init()
{
	Action[1]:Set[Nuke]
	MobHealth[1,1]:Set[1]
	MobHealth[1,2]:Set[100]
	Power[1,1]:Set[30]
	Power[1,2]:Set[100]
	SpellRange[1,1]:Set[60]
	SpellRange[1,2]:Set[61]

	Action[2]:Set[Mastery]

	Action[3]:Set[AoE]
	MobHealth[3,1]:Set[11]
	MobHealth[3,2]:Set[100]
	Power[3,1]:Set[40]
	Power[3,2]:Set[100]
	SpellRange[3,1]:Set[90]

	Action[4]:Set[DoT]
	MobHealth[4,1]:Set[1]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[30]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[70]

	Action[5]:Set[AA_Nature_Blade]
	MobHealth[5,1]:Set[1]
	MobHealth[5,2]:Set[100]
	Power[5,1]:Set[40]
	Power[5,2]:Set[100]
	SpellRange[5,1]:Set[381]

	Action[6]:Set[AA_Primordial_Strike]
	MobHealth[6,1]:Set[1]
	MobHealth[6,2]:Set[100]
	Power[6,1]:Set[40]
	Power[6,2]:Set[100]
	SpellRange[6,1]:Set[382]

	Action[7]:Set[AA_Thunderspike]
	MobHealth[7,1]:Set[1]
	MobHealth[7,2]:Set[100]
	Power[7,1]:Set[40]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[383]

	Action[8]:Set[Grove]
	MobHealth[8,1]:Set[50]
	MobHealth[8,2]:Set[100]
	Power[8,1]:Set[30]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[330]

	Action[9]:Set[Ally]
	MobHealth[9,1]:Set[50]
	MobHealth[9,2]:Set[100]
	Power[9,1]:Set[30]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[329]

	Action[10]:Set[Root]
	MobHealth[10,1]:Set[20]
	MobHealth[10,2]:Set[100]
	Power[10,1]:Set[30]
	Power[10,2]:Set[100]
	SpellRange[10,1]:Set[230]
	SpellRange[10,2]:Set[233]

	Action[11]:Set[Snare]
	MobHealth[11,1]:Set[20]
	MobHealth[11,2]:Set[100]
	Power[11,1]:Set[30]
	Power[11,2]:Set[100]
	SpellRange[11,1]:Set[235]

}

function PostCombat_Init()
{
	PostAction[1]:Set[Resurrection]
	PostSpellRange[1,1]:Set[300]
	PostSpellRange[1,2]:Set[302]
	PostSpellRange[1,3]:Set[301]
	PostSpellRange[1,4]:Set[303]
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

	call UseCrystallizedSpirit 60

	call CheckHeals

	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
	}

	if ${Me.ToActor.Power}>85 && ${KeepReactiveUp}
	{
		call CastSpellRange 15
		call CastSpellRange 7 0 0 0 ${Actor[${MainTankPC}].ID}
	}

	switch ${PreAction[${xAction}]}
	{
		case BuffThorns
			if ${BuffThorns}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${MainTankPC}].ID}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case BuffBoon
			if ${BuffBoon}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffVigor
			BuffTarget:Set[${UIElement[cbBuffVigorGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
			break
		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},3]} 0 0
			break
		case SOW
			if ${Me.ToActor.NumEffects}<15  && !${Me.Effect[Spirit of the Wolf](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
				wait 40
				;buff the group
				tempvar:Set[1]
				do
				{
					if ${Me.Group[${tempvar}].ToActor.Distance}<15
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
						wait 40
					}
				}
				while ${tempvar:Inc}<${Me.GroupCount}
			}
			break
		case BuffBat
			BuffTarget:Set[${UIElement[cbBuffBatGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case BuffInstinct
			BuffTarget:Set[${UIElement[cbBuffInstinctGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case BuffSpores
			BuffTarget:Set[${UIElement[cbBuffSporesGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case AA_Nature_Walk
		case AA_Force_of_Nature
		case AA_Rebirth
		case AA_Infusion
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
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
	}

	call CheckGroupHealth 60
	if ${DoHOs} && ${Return}
	{
		objHeroicOp:DoHO
	}

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
	{
		call CastSpellRange 305
	}

	call WeaponChange

	call CheckHeals

	call RefreshPower

	if ${ShardMode}
	{
		call Shard
	}

	if ${UseCAs} && ${Me.Power}>10
	{
		call CheckPosition 1 1
		if ${Me.Ability[Fire Strike].IsReady}
		{
			call CastSpell "Fire Strike"
		}
		if ${Me.Ability[Cold Slice].IsReady}
		{
			call CastSpell "Cold Slice"
		}
		if ${Me.Ability[Cold Strike].IsReady}
		{
			call CastSpell "Cold Strike"
		}
		if ${Me.Ability[Whirl of Frost].IsReady}
		{
			call CastSpell "Whirl of Frost"
		}
	}

	;Before we do our Action, check to make sure our group doesnt need healing
	call CheckGroupHealth 75
	if ${Return}
	{
		;echo Offensive - ${OffenseMode}
		switch ${Action[${xAction}]}
		{
			case Root
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]} && ${OffenseMode} && !${Actor[${KillTarget}].IsEpic}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						if ${Mob.Count}>=2
						{
							call CastSpellRange ${SpellRange[${xAction},2]} 0 0 0 ${KillTarget}
						}
						else
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
						}
					}
				}
				break
			case Snare
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]} && ${OffenseMode}  && !${Actor[${KillTarget}].IsEpic}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break
			case Nuke
				if ${OffenseMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							if ${UseCAs}
							{
								call CastSpellRange 385 387 1 0 ${KillTarget}
							}
							else
							{
								call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 0 ${KillTarget}
							}
						}
					}

				}
				break
			case AoE
				if ${OffenseMode} && ${AoEMode} && ${Mob.Count}>=2
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							if ${UseCAs}
							{
								call CastSpellRange 388 0 1 0 ${KillTarget} 0 0 1
							}
							else
							{
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
							}
						}
					}

				}
				break
			case AA_Primordial_Strike
			case AA_Nature_Blade
				if ${OffenseMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
							{
								if ${Me.Equipment[1].Name.Equal[${WeaponSword}]}
								{
									call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
								}
								elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
								{
									Me.Inventory[${WeaponSword}]:Equip
									EquipmentChangeTimer:Set[${Time.Timestamp}]
									call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
								}
							}
						}
					}
				}
				break
			case AA_Thunderspike
				if ${OffenseMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
							{
								if ${Me.Equipment[1].Name.Equal[${OneHandedHammer}]}
								{
									call CastCARange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
								}
								elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
								{
									Me.Inventory[${OneHandedHammer}]:Equip
									EquipmentChangeTimer:Set[${Time.Timestamp}]
									call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
								}
							}
						}
					}
				}
				break
			case DoT
				if ${OffenseMode}
				{
					;echo DoT
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{

							if ${UseCAs}
							{
								call CastSpellRange 421 0 1 0 ${KillTarget} 0 0 1
							}
							else
							{
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
							}

						}
					}

				}
				break

			case Ally
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]} && ${OffenseMode}  && ${PetMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break

			case Grove
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]} && ${PetMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
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

			Default
				xAction:Set[40]
				break
		}
	}
	else
	{
		call CheckHeals
	}
}

function Post_Combat_Routine(int xAction)
{

	TellTank:Set[FALSE]

	; turn off auto attack if we were casting while the last mob died
	if ${Me.AutoAttackOn}
	{
		EQ2Execute /toggleautoattack
	}

	;cancel Genesis if up
	if ${Me.Maintained[${SpellType[9]}](exists)}
	{
		Me.Maintained[${SpellType[9]}]:Cancel
	}

	;cancel Duststorm if up
	if ${Me.Maintained[${SpellType[365]}](exists)}
	{
		Me.Maintained[${SpellType[365]}]:Cancel
	}


	switch ${PostAction[${xAction}]}
	{
		case Resurrection
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1]
			do
			{
				if ${Me.Group[${tempgrp}](exists)} && ${Me.Group[${tempgrp}].ToActor.Health}==-99
				{
					if ${Me.Ability[${SpellType[300]}].IsReady}
					{
						call CastSpellRange 300 0 0 0 ${Me.Group[${tempgrp}].ID} 1
					}
					elseif ${Me.Ability[${SpellType[301]}].IsReady}
					{
						call CastSpellRange 301 0 0 0 ${Me.Group[${tempgrp}].ID} 1
					}
					elseif ${Me.Ability[${SpellType[302]}].IsReady}
					{
						call CastSpellRange 302 0 0 0 ${Me.Group[${tempgrp}].ID} 1
					}
					else
					{
						call CastSpellRange 303 0 0 0 ${Me.Group[${tempgrp}].ID} 1
					}
				}
			}
			while ${tempgrp:Inc}<${grpcnt}
			break

		Default
			xAction:Set[20]
			break
	}
}

function RefreshPower()
{


	if ${Me.InCombat} && ${Me.ToActor.Power}<65  && ${Me.ToActor.Health}>25
	{
		call UseItem "Helm of the Scaleborn"
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

function Have_Aggro()
{

	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTankPC}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	call CastSpellRange 180 0 0 0 ${aggroid}

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
	declare tempgrp int local 0

	grpcnt:Set[${Me.GroupCount}]
	hurt:Set[FALSE]

	temphl:Set[1]
	grpcure:Set[0]
	lowest:Set[1]

	;cancel Genesis if up and tank dieing
	if ${Me.Maintained[${SpellType[9]}](exists)} && (${Actor[${MainTankPC}].Health}<30 && ${Actor[${MainTankPC}].Health}>-99 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].ID}!=${Me.ID}) || !${GenesisMode}
	{
		Me.Maintained[${SpellType[9]}]:Cancel
	}
	elseif ${Me.Maintained[${SpellType[9]}](exists)} && ${GenesisMode}
	{
		return
	}


	;Res the MT if they are dead
	if ${Actor[${MainTankPC}].Health}==-99 && ${Actor[${MainTankPC}](exists)} && ${CombatRez}
	{
		call CastSpellRange 300 0 0 0 ${Actor[${MainTankPC}].ID}
	}

	do
	{
		if ${Me.Group[${temphl}].ToActor(exists)}
		{

			if ${Me.Group[${temphl}].ToActor.Health} < 100 && ${Me.Group[${temphl}].ToActor.Health}>-99
			{
				if ${Me.Group[${temphl}].ToActor.Health} < ${Me.Group[${lowest}].ToActor.Health}
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

			if ${Me.Group[${temphl}].Trauma}>0 || ${Me.Group[${temphl}].Elemental}>0
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

	if ${Me.Trauma}>0 || ${Me.Elemental}>0
	{
		grpcure:Inc
	}

	;CURES
	if ${grpcure}>2 && ${CureMode}
	{
		call CastSpellRange 220
		call CastSpellRange 363
	}

	if ${Me.IsAfflicted} && ${CureMode}
	{
		call CureMe
	}


	if ${mostafflicted} && ${CureMode}
	{
		call CheckGroupHealth 30
		if ${Return}
		{
			call CureGroupMember ${mostafflicted}
		}
		else
		{
			call CastSpellRange 10
			call CureGroupMember ${mostafflicted}
		}
	}


	;MAINTANK EMERGENCY HEAL
	if ${Me.Group[${lowest}].ToActor.Health}<30 && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].Name.Equal[${MainTankPC}]} && ${Me.Group[${lowest}].ToActor(exists)}
	{
		call EmergencyHeal ${Actor[${MainTankPC}].ID}
	}
	elseif !${MTinMyGroup} && ${Actor[${MainTankPC}].Health}<30
	{
		if ${Me.Ability[${SpellType[316]}].IsReady}
		{
			call CastSpellRange 316 0 0 0 ${Actor[${MainTankPC}].ID}
		}

		if ${Me.Ability[${SpellType[8]}].IsReady}
		{
			call CastSpellRange 8 0 0 0 ${Actor[${MainTankPC}].ID}
		}
	}

	;ME HEALS
	if ${Me.ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health} && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.ToActor.Health}<75
		{
			if ${haveaggro}
			{
				call CastSpellRange 7 0 0 0 ${Me.ID}
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

		if ${Me.ToActor.Health}<50 && ${haveagro}
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

	;MAINTANK HEALS
	;Will cast HoT's on MT outside of group.
	;Need to come back here and configure raid healing.  If MainTankPC in group, use groupHoT, if not in group use direct HoT
	if ${Actor[${MainTankPC}].Health}<50 && ${Actor[${MainTankPC}].Health}>-99 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].ID}!=${Me.ID}
	{
		if ${MTinMyGroup} && ${Me.Ability[${SpellType[9]}].IsReady} && ${Me.Power}<10
		{
			call CastSpellRange 9 0 0 0 ${Actor[${MainTankPC}].ID}
		}
		else
		{
			call CastSpellRange 4 0 0 0 ${Actor[${MainTankPC}].ID}
		}
	}

	if ${Actor[${MainTankPC}].Health}<70 && ${Actor[${MainTankPC}].Health}>-99 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].ID}!=${Me.ID}
	{
		if ${MTinMyGroup} && ${Me.Ability[${SpellType[9]}].IsReady} && ${Me.Power}<10
		{
			call CastSpellRange 9 0 0 0 ${Actor[${MainTankPC}].ID}
		}
		else
		{
			call CastSpellRange 1 0 0 0 ${Actor[${MainTankPC}].ID}
		}
	}


	if ${Actor[${MainTankPC}].Health}<90 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].InCombatMode} && ${Actor[${MainTankPC}].Health}>-99 && ${Actor[${MainTankPC}].ID}!=${Me.ID}
	{
		if ${GenesisMode} && ${MTinMyGroup} && ${Me.Ability[${SpellType[9]}].IsReady}
		{
			call CastSpellRange 9 0 0 0 ${Actor[${MainTankPC}].ID}
		}
		elseif !${MTinMyGroup}
		{
			call CastSpellRange 7 0 0 0 ${Actor[${MainTankPC}].ID}
		}
		else
		{
			call CastSpellRange 10 0 0 0 ${Actor[${MainTankPC}].ID}
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
		if ${PetMode}
		{
			call CastSpellRange 330
		}
	}

	if ${Me.Group[${lowest}].ToActor.Health}<30 && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.Ability[${SpellType[4]}].IsReady}
		{
			call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		}
		else
		{
			call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		}

	}


	if ${Me.Group[${lowest}].ToActor.Health}<50 && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.Ability[${SpellType[1]}].IsReady}
		{
			call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		}
		else
		{
			call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		}

	}

	if ${Me.Group[${lowest}].ToActor.Health}<70 && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.Ability[${SpellType[7]}].IsReady}
		{
			call CastSpellRange 7 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		}
		else
		{
			call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		}

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
	tempgrp:Set[0]
	do
	{
		if ${Me.Group[${tempgrp}].ToActor.Health}==-99 && ${CombatRez}
		{
			if ${Me.Ability[${SpellType[300]}].IsReady}
			{
				call CastSpellRange 300 0 0 0 ${Me.Group[${tempgrp}].ID} 1
			}
			elseif ${Me.Ability[${SpellType[301]}].IsReady}
			{
				call CastSpellRange 301 0 0 0 ${Me.Group[${tempgrp}].ID} 1
			}
			elseif ${Me.Ability[${SpellType[302]}].IsReady}
			{
				call CastSpellRange 302 0 0 0 ${Me.Group[${tempgrp}].ID} 1
			}
			else
			{
				call CastSpellRange 303 0 0 0 ${Me.Group[${tempgrp}].ID} 1
			}
		}
	}
	while ${tempgrp:Inc}<${grpcnt}

}

function EmergencyHeal(int healtarget)
{

	if ${Me.Ability[${SpellType[316]}].IsReady}
	{
		call CastSpellRange 316 0 0 0 ${healtarget}
	}
	else
	{
		call CastSpellRange 317 0 0 0 ${healtarget}
	}
	if ${Me.Ability[${SpellType[8]}].IsReady}
	{
		call CastSpellRange 8 0 0 0 ${healtarget}
	}
	if ${Me.Ability[${SpellType[16]}].IsReady}
	{
		call CastSpellRange 16 0 0 0 ${healtarget}
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

	if ${Actor[${MainTankPC}].Health}<=0 && ${Actor[${MainTankPC}](exists)} && ${CombatRez}
	{
		if ${Me.Ability[${SpellType[300]}].IsReady}
		{
			call CastSpellRange 300 0 0 0 ${MainTankPC} 1
		}
		elseif ${Me.Ability[${SpellType[301]}].IsReady}
		{
			call CastSpellRange 301 0 0 0 ${MainTankPC} 1
		}
		elseif ${Me.Ability[${SpellType[302]}].IsReady}
		{
			call CastSpellRange 302 0 0 0 ${MainTankPC} 1
		}
		else
		{
			call CastSpellRange 303 0 0 0 ${MainTankPC} 1
		}
	}
}

function Cancel_Root()
{

}

function CureMe()
{

	if  ${Me.Arcane}>0
	{
		call CastSpellRange 213 0 0 0 ${Me.ID}
		return
	}

	if  ${Me.Noxious}>0
	{
		call CastSpellRange 210 0 0 0 ${Me.ID}
		return
	}

	if  ${Me.Elemental}>0
	{
			call CastSpellRange 212 0 0 0 ${Me.ID}
			return
	}

	if  ${Me.Trauma}>0
	{
		call CastSpellRange 211 0 0 0 ${Me.ID}
		return
	}


}

function CureGroupMember(int gMember)
{
	declare tmpcure int local

	tmpcure:Set[0]
	if !${Me.Group[${gMember}].ZoneName.Equal["${Zone.Name}"]}
	{
		return
	}

	do
	{
		call CheckGroupHealth 30
		if !${Return}
		{
			call CastSpellRange 10
		}

		if  ${Me.Group[${gMember}].Arcane}>0 && !${Me.Group[${gMember}].ToActor.Effect[Revived Sickness](exists)}
		{
			if ${Me.Ability[${SpellType[214]}].IsReady}
			{
				call CastSpellRange 214 0 0 0 ${Me.Group[${gMember}].ID}
			}
			else
			{
				call CastSpellRange 213 0 0 0 ${Me.Group[${gMember}].ID}
			}
		}

		if  ${Me.Group[${gMember}].Noxious}>0
		{
			if ${Me.Ability[${SpellType[214]}].IsReady}
			{
				call CastSpellRange 214 0 0 0 ${Me.Group[${gMember}].ID}
			}
			else
			{
				call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}
			}
		}

		if  ${Me.Group[${gMember}].Elemental}>0
		{
			if ${Me.Ability[${SpellType[214]}].IsReady}
			{
				call CastSpellRange 214 0 0 0 ${Me.Group[${gMember}].ID}
			}
			else
			{
				call CastSpellRange 212 0 0 0 ${Me.Group[${gMember}].ID}
			}
		}

		if  ${Me.Group[${gMember}].Trauma}>0
		{
			if ${Me.Ability[${SpellType[214]}].IsReady}
			{
				call CastSpellRange 214 0 0 0 ${Me.Group[${gMember}].ID}
			}
			else
			{
				call CastSpellRange 211 0 0 0 ${Me.Group[${gMember}].ID}
			}
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

