;*************************************************************
;Inquisitor.iss
;version 20070725a (Pygar)
;
;20070725a (Pygar)
; Minor changes for AA adjustments in game
;
;20070504a (Pygar)
; Updated for latest eq2bot
; Tweaked cure loop to heal in case of emergency
; Fixed Mastery Spells
; Misc Healing Tweaks for efficiency
; Now uses group reactive on MT if in group to prevent stacking issues.
;
;20061208a
;Implemented EoF Mastery Spells
;Implemented EoF AA Maldroit
;Implemented EoF AA Battle Cleric Line
;Implemented Vampire Spell Theft of Vitae
;Implemented Symbol of Corruption
;Implemented Crystalize Spirit Healing
;Fixed a bug with curing uncurable afflictions
;by karye
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{

	declare OffenseMode bool script
	declare DebuffMode bool script
	declare AoEMode bool script
	declare CureMode bool script
	declare ConvertMode bool script
	declare YaulpMode bool script
	declare FanaticismMode bool script
	declare KeepReactiveUp bool script
	declare MezzMode bool script
	declare BattleClericMode bool Script

	declare BuffArcane bool script FALSE
	declare BuffMitigation bool script FALSE
	declare BuffProc bool script FALSE
	declare BuffDPS collection:string script
	declare BuffAuraGroupMember string script
	declare BuffShieldAllyGroupMember string script

	declare EquipmentChangeTimer int script

	declare MainWeapon string script
	declare OffHand string script
	declare OneHandedHammer string script
	declare TwoHandedHammer string script
	declare Symbols string script
	declare Buckler string script
	declare YaulpWeapon string script
	declare TwoHandedStaff string script

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
	BattleClericMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BattleCleric Mode,FALSE]}]

	BuffArcane:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffArcane,TRUE]}]
	BuffMitigation:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffMitigation,TRUE]}]
	BuffProc:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffProc,TRUE]}]
	BuffAuraGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffAuraGroupMember,]}]
	BuffShieldAllyGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffShieldAllyGroupMember,]}]

	MainWeapon:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[MainWeapon,]}]
	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OffHand,]}]
	OneHandedHammer:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OneHandedHammer,]}]
	TwoHandedHammer:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[TwoHandedHammer,]}]
	Symbols:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[WeaponSymbols,]}]
	Buckler:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buckler,]}]
	YaulpWeapon:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[YaulpWeapon,]}]
	TwoHandedStaff:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[TwoHandedStaff,]}]
}

function Buff_Init()
{

	PreAction[1]:Set[BuffDPS]
	PreSpellRange[1,1]:Set[35]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]
	PreSpellRange[2,2]:Set[26]

	PreAction[3]:Set[BuffAura]
	PreSpellRange[3,1]:Set[40]

	PreAction[4]:Set[BuffMitigation]
	PreSpellRange[4,1]:Set[20]

	PreAction[5]:Set[Group_Buff]
	PreSpellRange[5,1]:Set[280]
	PreSpellRange[5,2]:Set[282]

	PreAction[6]:Set[BuffShieldAlly]
	PreSpellRange[6,1]:Set[389]

	PreAction[7]:Set[BuffArcane]
	PreSpellRange[7,1]:Set[21]

	PreAction[8]:Set[BuffProc]
	PreSpellRange[8,1]:Set[22]

}

function Combat_Init()
{
	Action[1]:Set[Forced_Obedience]
	MobHealth[1,1]:Set[20]
	MobHealth[1,2]:Set[100]
	Power[1,1]:Set[30]
	Power[1,2]:Set[100]
	SpellRange[1,1]:Set[55]

	Action[2]:Set[Maladroit]
	MobHealth[2,1]:Set[20]
	MobHealth[2,2]:Set[100]
	Power[2,1]:Set[35]
	Power[2,2]:Set[100]
	SpellRange[2,1]:Set[384]

	Action[3]:Set[Debase]
	MobHealth[3,1]:Set[20]
	MobHealth[3,2]:Set[100]
	Power[3,1]:Set[30]
	Power[3,2]:Set[100]
	SpellRange[3,1]:Set[50]

	Action[4]:Set[Convict]
	MobHealth[4,1]:Set[20]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[30]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[51]

	Action[5]:Set[Mastery]

	Action[6]:Set[TheftOfVitality]
	MobHealth[6,1]:Set[1]
	MobHealth[6,2]:Set[100]
	Power[6,1]:Set[20]
	Power[6,2]:Set[100]
	SpellRange[6,1]:Set[56]

	Action[7]:Set[Absolving_Flames]
	MobHealth[7,1]:Set[20]
	MobHealth[7,2]:Set[100]
	Power[7,1]:Set[40]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[70]

	Action[8]:Set[Affliction]
	MobHealth[8,1]:Set[20]
	MobHealth[8,2]:Set[100]
	Power[8,1]:Set[40]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[71]

	Action[9]:Set[AoE]
	MobHealth[9,1]:Set[1]
	MobHealth[9,2]:Set[100]
	Power[9,1]:Set[30]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[90]

	Action[10]:Set[Proc]
	MobHealth[10,1]:Set[40]
	MobHealth[10,2]:Set[100]
	Power[10,1]:Set[40]
	Power[10,2]:Set[100]
	SpellRange[10,1]:Set[337]

	Action[11]:Set[SymbolOfCorruption]
	MobHealth[11,1]:Set[10]
	MobHealth[11,2]:Set[100]
	Power[11,1]:Set[30]
	Power[11,2]:Set[100]
	SpellRange[11,1]:Set[57]

	Action[12]:Set[Stifle]
	MobHealth[12,1]:Set[1]
	MobHealth[12,2]:Set[100]
	Power[12,1]:Set[30]
	Power[12,2]:Set[100]
	SpellRange[12,1]:Set[260]

	Action[13]:Set[Counterattack]
	MobHealth[13,1]:Set[40]
	MobHealth[13,2]:Set[100]
	Power[13,1]:Set[40]
	Power[13,2]:Set[100]
	SpellRange[13,1]:Set[336]

	Action[14]:Set[AA_DivineCastigation]
	MobHealth[14,1]:Set[1]
	MobHealth[14,2]:Set[100]
	Power[14,1]:Set[30]
	Power[14,2]:Set[100]
	SpellRange[14,1]:Set[395]

	Action[15]:Set[PreKill]
	MobHealth[15,1]:Set[5]
	MobHealth[15,2]:Set[15]
	Power[15,1]:Set[30]
	Power[15,2]:Set[100]
	SpellRange[15,1]:Set[312]

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
		call CastSpellRange 15
		call CastSpellRange 7 0 0 0 ${Actor[${MainAssist}].ID}
	}

	switch ${PreAction[${xAction}]}
	{
		case BuffDPS
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
					if ${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{

						tempvar:Set[1]
						do
						{

							BuffTarget:Set[${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}


						}
						while ${tempvar:Inc}<=${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
			if ${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{

				do
				{
					BuffTarget:Set[${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffDPS@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break

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
		case BuffAura
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.Name.Equal[${BuffAuraGroupMember}]}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffAuraGroupMember}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffAuraGroupMember}].ID}
			}

			break
		case BuffShieldAlly
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.Name.Equal[${BuffShieldAllyGroupMember}]}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffShieldAllyGroupMember}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffShieldAllyGroupMember}].ID}
			}
			break
		case BuffArcane
			if ${BuffArcane}
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
		case BuffProc
			if ${BuffProc}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		default
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

	if ${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}
	{
		; Use AA Divine Reovery
		call CastSpellRange 396
	}

	call CheckGroupHealth 75
	if ${DoHOs} && ${Return}
	{
		objHeroicOp:DoHO
	}

	if !${EQ2.HOWindowActive} && ${Me.InCombat}
	{
		call CastSpellRange 303
	}

	if ${MezzMode}
	{
		call Mezmerise_Targets
	}

	call WeaponChange

	call CheckHeals

	call RefreshPower

	call Yaulp

	call Fanaticism

	call CastVerdict

	if ${ShardMode}
	{
		call Shard
	}
	;echo BattleClericMode is ${BattleClericMode}
	;Before we do our Action, check to make sure our group doesnt need healing
	call CheckGroupHealth 60
	if ${Return}
	{
		switch ${Action[${xAction}]}
		{
			case TheftOfVitality
			case Forced_Obedience
			case Debase
			case Convict
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

			case Counterattack
			case Proc
				if ${OffenseMode}
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

			case Absolving_Flames
				if ${OffenseMode} || ${DebuffMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							;Check for Battle Cleric Strike of Flames
							if ${Me.Ability[${SpellType[381]}](exists)} && ${BattleClericMode}
							{
								call CastSpellRange 381 0 1 0 ${KillTarget}
							}
							else
							{
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
							}
						}
					}

				}
				break

			case Affliction
				if ${OffenseMode} || ${DebuffMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							;Check for Battle Cleric Writhing Strike
							if ${Me.Ability[${SpellType[382]}](exists)} && ${BattleClericMode}
							{
								call CastSpellRange 382 0 1 0 ${KillTarget}
							}
							else
							{
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
							}
						}
					}

				}
				break
			case Stifle
				if ${OffenseMode} || ${DebuffMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							;Check for Battle Cleric Invocation Strike
							if ${Me.Ability[${SpellType[383]}](exists)} && ${BattleClericMode}
							{
								call CastSpellRange 383 0 1 0 ${KillTarget}
							}
							else
							{
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
							}
						}
					}

				}
				break
			case SymbolOfCorruption
				if ${OffenseMode} || ${DebuffMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
						{
							;Check for Battle Cleric Strike of Corruption
							if ${Me.Ability[${SpellType[379]}](exists)} && ${BattleClericMode}
							{
								call CastSpellRange 379 0 1 0 ${KillTarget}
							}
							else
							{
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
							}
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
							;Check for Battle Cleric Litany Circle
							if ${Me.Ability[${SpellType[380]}](exists)} && ${BattleClericMode}
							{
								call CastSpellRange 380 0 1 0 ${KillTarget}
							}
							else
							{
								call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
							}
						}
					}

				}
				break
			case PreKill
				if ${AoEMode}
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
			default
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

	;turn off Yaulp
	if ${Me.Maintained[${SpellType[385]}](exists)}
	{
		Me.Maintained[${SpellType[385]}]:Cancel
	}

	;turn off fanaticism or zealotry
	if ${Me.Maintained[${SpellType[317]}](exists)}
	{
		Me.Maintained[${SpellType[317]}]:Cancel
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
	declare MTinMyGroup bool local FALSE

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
	while ${temphl:Inc}<${grpcnt}

	if ${Me.ToActor.Health}<80 && ${Me.ToActor.Health}>-99
	{
		grpheal:Inc
	}

	if ${Me.Arcane}>0 || ${Me.Elemental}>0
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
	if ${Me.ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health} && ${Me.Group[${lowest}].ToActor(exists)} || ${Me.ToActor.Health}<75
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

	}

	;MAINTANK HEALS
	;Only use a reactive if the MainAssist is in my group to avoid overwrting other cleric reactives during a raid
	if ${Actor[${MainTankPC}].Health} <90 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].InCombatMode} && ${Actor[${MainTankPC}].Health}>-99 && ${Actor[${MainTankPC}].ID}!=${Me.ID}
	{
		if ${MTinMyGroup} && ${Me.InRaid}
		{
			call CastSpellRange 15 0 0 0 ${Actor[${MainTankPC}].ID}
		}
		else
		{
			call CastSpellRange 7 0 0 0 ${Actor[${MainTankPC}].ID}
		}
	}

	if ${Actor[${MainTankPC}].Health} <75 && ${Actor[${MainTankPC}].Health} >-99 && ${Actor[${MainTankPC}](exists)}
	{
		call CastSpellRange 1 0 0 0 ${Actor[${MainTankPC}].ID}
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

	if ${Me.Group[${lowest}].ToActor.Health}<70 && ${Me.Group[${lowest}].ToActor.Health}>-99 && ${Me.Group[${lowest}].ToActor(exists)}
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
		if ${Me.Group[${tempgrp}].ToActor.Health}==-99
		{
			call CastSpellRange 300 301 0 0 ${Me.Group[${tempgrp}].ID} 1
		}
	}
	while ${tempgrp:Inc}<${grpcnt}

	call UseCrystallizedSpirit 60

}

function EmergencyHeal(int healtarget)
{

	call CastSpellRange 338 0 0 0 ${healtarget}

	if ${Me.Ability[${SpellType[335]}].IsReady}
	{
		call CastSpellRange 335 0 0 0 ${healtarget}
	}
	else
	{
		call CastSpellRange 334 0 0 0 ${healtarget}
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
	if ${Actor[${MainTankPC}].Health}<=0 && ${Actor[${MainTankPC}](exists)}
	{
		call 300 301 0 0 ${Actor[${MainTankPC}].ID} 1
	}
}

function Cancel_Root()
{

}

function CureMe()
{

	if  ${Me.Arcane}>0
	{
		call CastSpellRange 326
		wait 3
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

	do
	{
		call CheckGroupHealth 30
		if !${Return}
		{
			call CastSpellRange 10
		}
		if ${Me.Group[${gMember}].Health}<50 && ${Me.Group[${gMember}].Health}>-99
		{
			call CastSpellRange 4 0 0 0 ${Me.Group[${gMember}].ID}
		}
		if  ${Me.Group[${gMember}].Arcane}>0
		{
			call CastSpellRange 326
			wait 5
				if  ${Me.Group[${gMember}].Arcane}>0
				{
					call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}
				}
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


function CastVerdict()
{

	if ${Actor[${KillTarget}].IsEpic} && ${Actor[${KillTarget}].Health}<=2 && ${Actor[${KillTarget}](exists)}
	{
		call CastSpellRange 93 0 0 0 ${KillTarget}
		return
	}

	switch ${Actor[${KillTarget}].Difficulty}
	{
		case -3
		case -2
			if ${Actor[${KillTarget}].Health}<=50 && ${Actor[${KillTarget}](exists)}
			{
				call CastSpellRange 93 0 0 0 ${KillTarget}
				return
			}
			break

		case -1
		case 0
		case 1
			if ${Actor[${KillTarget}].Health}<=25 && ${Actor[${KillTarget}](exists)}
			{
				call CastSpellRange 93 0 0 0 ${KillTarget}
				return
			}
			break

		case 2
		case 3
			if ${Actor[${KillTarget}].Health}<=5 && ${Actor[${KillTarget}](exists)}
			{
				call CastSpellRange 93 0 0 0 ${KillTarget}
				return
			}
			break
	}

}

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

function Fanaticism()
{
	if ${FanaticismMode}
	{
		call CheckGroupHealth 70
		if ${Return}
		{
			call CastSpellRange 317
		}
		elseif ${Me.Maintained[${SpellType[317]}](exists)}
		{
			Me.Maintained[${SpellType[317]}]:Cancel
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