;*************************************************************
;Fury.iss 20070226a
;version 
;
;20070226a
; Full support for KoS and EoF AA lines
; Toggle of incombat rez
; Toggle of initiating HO
; Added Missing Spells (Carnal Mask, Maddening Swarm, Barbarous Intimidation)
; Fixed bug in Storms Usage
; Fixed a bug in UI file 
;
;20070201a
; Intelligent Casting of Int Buffs
; Crystalized Shard usage added to checkheals
; Fixed Curing of uncurables
; Added toggle for buffing Thorns on MA (raid stacking contention with other furies/wardens)
; Optomized Storms/Ring of fire when selected
; Added AA Lines
; Optomized DPS
;
;20061130a
; Tweaked Rez, fixed some spell list errors.  Hacked buff canceling
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{

	declare OffenseMode bool script
	declare DebuffMode bool script
	declare AoEMode bool script
	declare PBAoEMode bool script
	declare CureMode bool script
	declare StormsMode bool script
	declare KeepReactiveUp bool script
	declare BuffEel bool script 1
	declare BuffThorns bool script 1
	declare VortexMode bool script 1
	declare CombatRez bool script 1
	declare StartHO bool script 1
	
	
	declare BuffBatGroupMember string script
	declare BuffSavageryGroupMember string script
	declare BuffVerveGroupMember string script
	
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
	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast PBAoE Spells,FALSE]}]
	CureMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Cure Spells,FALSE]}]
	StormsMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Call of Storms,FALSE]}]
	BuffThorns:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Thorns,FALSE]}]
	VortexMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Vortex,FALSE]}]
	KeepReactiveUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepReactiveUp,FALSE]}]
	CombatRez:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Combat Rez,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
	
	BuffBatGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffBatGroupMember,]}]
	BuffSavageryGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffSavageryGroupMember,]}]
	BuffVerveGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffVerveGroupMember,]}]
	
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

	PreAction[3]:Set[BuffEel]
	PreSpellRange[3,1]:Set[280]

	PreAction[4]:Set[BuffVerve]
	PreSpellRange[4,1]:Set[36]

	PreAction[5]:Set[Group_Buff]
	PreSpellRange[5,1]:Set[20]
	PreSpellRange[5,2]:Set[21]
	PreSpellRange[5,3]:Set[23]
	
	PreAction[6]:Set[SOW]
	PreSpellRange[6,1]:Set[31]
	
	PreAction[7]:Set[BuffBat]
	PreSpellRange[7,1]:Set[35]
	
	PreAction[8]:Set[BuffSavagery]
	PreSpellRange[8,1]:Set[38]
	
	PreAction[9]:Set[AA_Rebirth]
	PreSpellRange[9,1]:Set[390]

	PreAction[10]:Set[AA_Infusion]
	PreSpellRange[10,1]:Set[391]
	
	PreAction[11]:Set[AA_Shapeshift]
	PreSpellRange[11,1]:Set[396]	
}

function Combat_Init()
{
	Action[1]:Set[Storms]
	MobHealth[1,1]:Set[20]
	MobHealth[1,2]:Set[100]
	Power[1,1]:Set[40]
	Power[1,2]:Set[100]
	SpellRange[1,1]:Set[96]

	Action[2]:Set[PBAoE]
	MobHealth[2,1]:Set[20]
	MobHealth[2,2]:Set[100]
	Power[2,1]:Set[40]
	Power[2,2]:Set[100]
	SpellRange[2,1]:Set[95]

	Action[3]:Set[AoE]
	MobHealth[3,1]:Set[5]
	MobHealth[3,2]:Set[100]
	Power[3,1]:Set[30]
	Power[3,2]:Set[100]
	SpellRange[5,1]:Set[90]

	Action[4]:Set[Nuke]
	MobHealth[4,1]:Set[1]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[30]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[60]

	Action[5]:Set[Mastery]
	
	Action[6]:Set[AA_Nature_Blade]
	MobHealth[6,1]:Set[10]
	MobHealth[6,2]:Set[100]
	Power[6,1]:Set[40]
	Power[6,2]:Set[100]
	SpellRange[6,1]:Set[381]	

	Action[7]:Set[AA_Primordial_Strike]
	MobHealth[7,1]:Set[10]
	MobHealth[7,2]:Set[100]
	Power[7,1]:Set[40]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[382]
	
	Action[8]:Set[AA_Thunderspike]
	MobHealth[8,1]:Set[10]
	MobHealth[8,2]:Set[100]
	Power[8,1]:Set[40]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[383]	

	Action[9]:Set[DoT]
	MobHealth[9,1]:Set[1]
	MobHealth[9,2]:Set[100]
	Power[9,1]:Set[30]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[70]

	Action[10]:Set[Proc]
	MobHealth[10,1]:Set[30]
	MobHealth[10,2]:Set[100]
	Power[10,1]:Set[40]
	Power[10,2]:Set[100]
	SpellRange[10,1]:Set[157]

	Action[11]:Set[Feast]
	MobHealth[11,1]:Set[5]
	MobHealth[11,2]:Set[50]
	Power[11,1]:Set[30]
	Power[11,2]:Set[100]
	SpellRange[11,1]:Set[312]

	Action[12]:Set[Debuff]
	MobHealth[12,1]:Set[20]
	MobHealth[12,2]:Set[100]
	Power[12,1]:Set[30]
	Power[12,2]:Set[100]
	SpellRange[12,1]:Set[50]
	SpellRange[12,2]:Set[51]
	SpellRange[12,3]:Set[52]

	Action[13]:Set[Snare]
	MobHealth[13,1]:Set[20]
	MobHealth[13,2]:Set[100]
	Power[13,1]:Set[30]
	Power[13,2]:Set[100]
	SpellRange[13,1]:Set[235]
	
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
	
	call CheckHeals
	
	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
	}

	if ${Me.ToActor.Power}>85 && ${KeepReactiveUp}
	{
		if !${Me.Maintained[${SpellType[11]}](exists)}
		{
			call CastSpellRange 11
		}
		call CastSpellRange 15
		call CastSpellRange 7 0 0 0 ${Actor[${MainAssist}].ID}
	}
	
	switch ${PreAction[${xAction}]}
	{
		case BuffThorns
			if ${BuffThorns}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${MainAssist}].ID}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Self_Buff
		case AA_Rebirth
		case AA_Infusion
		case AA_Shapeshift
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			
		case BuffEel
			if ${BuffEel}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break	
		case BuffVerve
			BuffTarget:Set[${UIElement[cbBuffVerveGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
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
				;buff the group
				tempvar:Set[1]
				do
				{
					if ${Me.Group[${tempvar}].ToActor.Distance}<15
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempvar}].ToActor.ID}
					}
				}
				while ${tempvar:Inc}<${Me.GroupCount}
			}
			break
		case BuffBat
			BuffTarget:Set[${UIElement[cbBuffBatGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				;Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}			

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break		
		case BuffSavagery
			BuffTarget:Set[${UIElement[cbBuffSavageryGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				;Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}			

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
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
	
	call CheckGroupHealth 75
	if ${DoHOs} && ${Return}
	{
		objHeroicOp:DoHO
	}	

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
	{
		call CastSpellRange 304
	}

	call WeaponChange
	
	call CheckHeals
	
	call RefreshPower
	
	if ${ShardMode}
	{
		call Shard
	}
	
	;if named epic, maintain debuffs
	if ${Actor[${KillTarget}].IsEpic} && ${Actor[${KillTarget}].IsNamed} && ${Me.ToActor.Power}>30
	{
		if !${Me.Maintained[${SpellType[50]}](exists)}
		{
			call CastSpellRange 50 0 0 0 ${KillTarget}
		}
		if !${Me.Maintained[${SpellType[51]}](exists)}
		{
			call CastSpellRange 51 0 0 0 ${KillTarget}
		}
		if !${Me.Maintained[${SpellType[52]}](exists)}
		{
			call CastSpellRange 52 0 0 0 ${KillTarget}
		}
	}

	if ${Me.Ability[${SpellType[385]}].IsReady} && ${VortexMode}
	{
		call CastSpellRange 385
	}


	switch ${Action[${xAction}]}
	{
		case Debuff
			;need to check if each spell is maintained before recasting
			if ${DebuffMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},3]} 0 0 ${KillTarget}
					}
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
						;echo nuke
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
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
								call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
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
		case AoE
			if ${OffenseMode} && ${AoEMode}
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
		case Proc
			if ${OffenseMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						if ${Me.GroupCount}>1
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
						}
					}
				}

			}
			break

		case DoT
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

		case PBAoE
			;need to add disable to heal routine to prevent stun lock
			if ${PBAoEMode} && ${OffenseMode}
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
		case Snare	
		case Feast
			if ${DebuffMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						if ${Mob.Count}>1
						{
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
						}
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

		case Storms
			;need to add disable to heal routine to prevent stun lock
			if ${StormsMode} && ${Mob.Count}>=2
			{ 
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
						call CastSpellRange ${SpellRange[${xAction},2]} 0 1 0 ${KillTarget}
					}
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
					if ${Me.Ability[${SpellType[300]}].IsReady}
					{
						call CastSpellRange 300 0 0 0 ${Me.Group[${tempgrp}].ID} 1
						wait 100
					}
					elseif ${Me.Ability[${SpellType[301]}].IsReady}
					{
						call CastSpellRange 301 0 0 0 ${Me.Group[${tempgrp}].ID} 1
						wait 100
					}
					elseif ${Me.Ability[${SpellType[302]}].IsReady}
					{
						call CastSpellRange 302 0 0 0 ${Me.Group[${tempgrp}].ID} 1
						wait 100
					}
					else
					{
						call CastSpellRange 303 0 0 0 ${Me.Group[${tempgrp}].ID} 1
						wait 100
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
	
	grpcnt:Set[${Me.GroupCount}]
	hurt:Set[FALSE]

	temphl:Set[1]
	grpcure:Set[0]
	lowest:Set[1]
	
	;Res the MT if they are dead
	if ${Actor[${MainAssist}].Health}==-99 && ${Actor[${MainAssist}](exists)}
	{
		call CastSpellRange 300 0 0 0 ${Actor[${MainAssist}].ID}
	}

	do
	{
		if ${Me.Group[${temphl}].ZoneName.Equal["${Zone.Name}"]}
		{

			if ${Me.Group[${temphl}].ToActor.Health} < 100 && ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}].ToActor(exists)}
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

			if ${Me.Group[${temphl}].Arcane}>0 || ${Me.Group[${temphl}].Elemental}>0
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
			
			if ${Me.Group[${temphl}].Name.Equal[${MainAssist}]}
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
	
	if ${Me.Arcane} || ${Me.Elemental}
	{
		grpcure:Inc
	}
	
	;CURES
	if ${grpcure}>2 && ${CureMode}
	{
		call CastSpellRange 220
	}
	
	if ${Me.IsAfflicted} && ${CureMode}
	{
		call CureMe
	}

	if ${mostafflicted} && ${CureMode}
	{
		call CureGroupMember ${mostafflicted}
	}
	
	;MAINTANK EMERGENCY HEAL
	if ${Me.Group[${lowest}].ToActor.Health}<30 && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].Name.Equal[${MainTankPC}]} && ${Me.Group[${lowest}].ToActor(exists)}
	{
		call EmergencyHeal ${Actor[${MainTankPC}].ID}
	}
	
	;ME HEALS
	if ${Me.ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health} && ${Me.Group[${lowest}].ToActor(exists)} || ${Me.ID}==${Actor[${MainAssist}].ID}
	{
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
	}
	
	;MAINTANK HEALS
	;Will cast HoT's on MT outside of group.
	;Need to come back here and configure raid healing.  If MainAssist in group, use groupHoT, if not in group use direct HoT
	if ${Actor[${MainTankPC}].Health}<90 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].InCombatMode} && ${Actor[${MainTankPC}].Health}>-99 && ${Actor[${MainTankPC}].ID}!=${Me.ID}
	{
		call CastSpellRange 7 0 0 0 ${Actor[${MainTankPC}].ID}
	}
	
	if ${Actor[${MainAssist}].Health}<80 && ${Actor[${MainTankPC}].Health} >-99 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].ID}!=${Me.ID}
	{
		call CastSpellRange 1 0 0 0 ${Actor[${MainTankPC}].ID}
	}
	
	if ${Actor[${MainAssist}].Health}<60 && ${Actor[${MainTankPC}].Health} >-99 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].ID}!=${Me.ID}
	{
		call CastSpellRange 4 0 0 0 ${Actor[${MainTankPC}].ID}
	}
	if ${Actor[${MainAssist}].Health}<50 && ${Actor[${MainTankPC}].Health} >-99 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].ID}!=${Me.ID}
	{
		call CastSpellRange 2 0 0 0 ${Actor[${MainTankPC}].ID}
	}
	
	;GROUP HEALS
	if ${grpheal}>2
	{
		if ${Me.Ability[${SpellType[10]}].IsReady}
		{
			call CastSpellRange 10
			if !${Me.Maintained[${SpellType[11]}](exists)}
			{
				call CastSpellRange 11
			}
		}
		else
		{
			call CastSpellRange 15
			;add check to not cast if maintained already
			if !${Me.Maintained[${SpellType[11]}](exists)}
			{
				call CastSpellRange 11
			}
		}
	}

	;Use back into the Frey if group member under 50
	if ${Me.Group[${lowest}].ToActor.Health}<50 && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)} && ${Me.Group[${lowest}].ToActor.ID}!=${Me.ID}
	{
		call CastSpellRange 2 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
	}

	if ${Me.Group[${lowest}].ToActor.Health}<70 && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)} 
	{
		if ${Me.Ability[${SpellType[1]}].IsReady}
		{
			call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
			if !${Me.Maintained[${SpellType[11]}](exists)}
			{
				call CastSpellRange 11
			}
		}
		else
		{
			call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
			if !${Me.Maintained[${SpellType[11]}](exists)}
			{
				call CastSpellRange 11
			}
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
	
	
	if ${CombatRez}
	{
		;Res Fallen Groupmembers only if in range
		grpcnt:Set[${Me.GroupCount}]
		tempgrp:Set[1]
		do
		{
			if ${Me.Group[${tempgrp}].ToActor.Health}==-99
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
	
	call UseCrystallizedSpirit 60
}

function EmergencyHeal(int healtarget)
{
	
	if ${Me.Ability[${SpellType[8]}].IsReady}
	{
		call CastSpellRange 8 0 0 0 ${healtarget}
		call CastSpellRange 316 0 0 0 ${healtarget}
	}
	else
	{
		call CastSpellRange 16 0 0 0 ${healtarget}
		call CastSpellRange 316 0 0 0 ${healtarget}
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
	if ${Actor[${MainAssist}].Health}<=0 && ${Actor[${MainAssist}](exists)} && ${CombatRez}
	{
		call 300 0 0 0 ${Actor[${MainAssist}].ID} 1
	}
}

function Cancel_Root()
{

}

function CureMe()
{
	
	if  ${Me.Arcane} && !${Me.ToActor.Effect[Revived Sickness](exists)}
	{
		if ${Me.Arcane} && !${Me.ToActor.Effect[Revived Sickness](exists)}
		{
			call CastSpellRange 213 0 0 0 ${Me.ID}
			return
		}
	}
	
	if  ${Me.Noxious}
	{
		call CastSpellRange 210 0 0 0 ${Me.ID}
		return
	}

	if  ${Me.Elemental}
	{
			call CastSpellRange 212 0 0 0 ${Me.ID}
			return
	}

	if  ${Me.Trauma}
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
		if  ${Me.Group[${gMember}].Arcane} && !${Me.Group[${gMember}].ToActor.Effect[Revived Sickness](exists)}
		{
			call CastSpellRange 213 0 0 0 ${Me.Group[${gMember}].ID}
		}

		if  ${Me.Group[${gMember}].Noxious}
		{
			if ${Me.Group[${gMember}].Noxious}
			{
				call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}
			}
		}

		if  ${Me.Group[${gMember}].Elemental}
		{
			if ${Me.Group[${gMember}].Noxious}
			{
				call CastSpellRange 212 0 0 0 ${Me.Group[${gMember}].ID}
			}
		}

		if  ${Me.Group[${gMember}].Trauma}
		{
			call CastSpellRange 211 0 0 0 ${Me.Group[${gMember}].ID}
		}
	}
	while ${Me.Group[${gMember}].IsAfflicted} && ${CureMode} && ${tmpcure:Inc}<3
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

