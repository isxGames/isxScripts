;*************************************************************
;templar.iss
;version 20080207a
;by Pygar
;paypal - pygar@happyhacker.com
;
;20080207a
; Initial Release
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
    ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
    declare ClassFileVersion int script 20080408
    ;;;;

	declare OffenseMode bool script 0
	declare DebuffMode bool script 0
 	declare AoEMode bool script 0
 	declare CureMode bool script 0
 	declare FocusedMode bool script 0
 	declare PreHealMode bool script 0
	declare KeepReactiveUp bool script 0
	declare KeepGroupReactiveUp bool script 0
	declare PetMode bool script 1
	declare CombatRez bool script 1
	declare StartHO bool script 1
	declare MeleeMode bool script 1
	declare YaulpMode bool script 1
	declare ShieldAllyMode bool script 0
	declare HolyShieldMode bool script 0
	declare ManaCureMode bool script 0
	declare BuffCourage bool script
	declare BuffSymbol bool script
	declare RaidHealMode bool script


	declare BuffWaterBreathing bool script FALSE
	declare BuffGloryGroupMember string script
	declare BuffBennedictionGroupMember string script
    declare BuffPraetorateGroupMember string script
    declare BuffShieldAllyGroupMember string script
	declare HolyShieldGroupMember string script
	declare ManaCureGroupMember string script
	declare tempMH string script

	call EQ2BotLib_Init

	OffenseMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,FALSE]}]
	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	CureMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Cure Spells,FALSE]}]
	FocusedMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Focused Mode,FALSE]}]
	PreHealMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[PreHeal Mode,FALSE]}]
	KeepReactiveUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepReactiveUp,FALSE]}]
	KeepGroupReactiveUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepGroupReactiveUp,FALSE]}]
	PetMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Pets,TRUE]}]
	CombatRez:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Combat Rez,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
	MeleeMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[MeleeMode,FALSE]}]
	YaulpMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[YaulpMode,FALSE]}]
	ShieldAllyMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[ShieldAllyMode,FALSE]}]
	HolyShieldMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[HolyShieldMode,FALSE]}]
	ManaCureMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[ManaCureMode,FALSE]}]
	BuffCourage:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffCourage,FALSE]}]
	BuffSymbol:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffSymbol,FALSE]}]
	RaidHealMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[RaidHealMode,FALSE]}]

	BuffWaterBreathing:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffWaterBreathing,FALSE]}]
	BuffGloryGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffGloryGroupMember,]}]
	BuffBennedictionGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffBennedictionGroupMember,]}]
	BuffPraetorateGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffPraetorateGroupMember,]}]
	BuffShieldAllyGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffShieldAllyGroupMember,]}]
	HolyShieldGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[HolyShieldGroupMember,]}]
	ManaCureGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[ManaCureGroupMember,]}]
}

function Buff_Init()
{
	PreAction[1]:Set[BuffRedoubt]
	PreSpellRange[1,1]:Set[35]

	PreAction[2]:Set[BuffGlory]
	PreSpellRange[2,1]:Set[38]

	PreAction[3]:Set[Bennediction]
	PreSpellRange[3,1]:Set[39]

	PreAction[4]:Set[Praetorate]
	PreSpellRange[4,1]:Set[36]

	PreAction[5]:Set[Group_Buff]
	PreSpellRange[5,1]:Set[391]

	PreAction[6]:Set[ShieldAlly]
	PreSpellRange[6,1]:Set[383]

	PreAction[8]:Set[ManaCure]
	PreSpellRange[8,1]:Set[393]

	PreAction[9]:Set[WaterBreathing]
	PreSpellRange[9,1]:Set[22]

	PreAction[10]:Set[BuffCourage]
	PreSpellRange[10,1]:Set[20]

	PreAction[11]:Set[BuffSymbol]
	PreSpellRange[11,1]:Set[21]
}

function Combat_Init()
{
	Action[1]:Set[AoE]
	SpellRange[1,1]:Set[90]

	Action[2]:Set[Involuntary]
	SpellRange[2,1]:Set[52]

	Action[3]:Set[Reverence]
	SpellRange[3,1]:Set[155]

	Action[4]:Set[Hammer]
	MobHealth[4,1]:Set[1]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[50]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[230]

	Action[5]:Set[Stun]
	MobHealth[5,1]:Set[10]
	MobHealth[5,2]:Set[100]
	Power[5,1]:Set[30]
	Power[5,2]:Set[100]
	SpellRange[5,1]:Set[56]

	Action[6]:Set[Melee1]
	Power[6,1]:Set[30]
	Power[6,2]:Set[100]
	SpellRange[6,1]:Set[380]

	Action[7]:Set[Melee3]
	Power[7,1]:Set[30]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[382]

	Action[8]:Set[Dot1]
	MobHealth[8,1]:Set[10]
	MobHealth[8,2]:Set[100]
	Power[8,1]:Set[30]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[70]

	Action[9]:Set[Melee2]
	Power[9,1]:Set[30]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[385]

	Action[10]:Set[Dot2]
	MobHealth[10,1]:Set[10]
	MobHealth[10,2]:Set[100]
	Power[10,1]:Set[30]
	Power[10,2]:Set[100]
	SpellRange[10,1]:Set[71]

	Action[11]:Set[Turn_Undead]
	MobHealth[11,1]:Set[10]
	MobHealth[11,2]:Set[100]
	Power[11,1]:Set[20]
	Power[11,2]:Set[100]
	SpellRange[11,1]:Set[387]

	Action[12]:Set[Divine_Castigation]
	MobHealth[12,1]:Set[1]
	MobHealth[12,2]:Set[100]
	Power[12,1]:Set[20]
	Power[12,2]:Set[100]
	SpellRange[12,1]:Set[389]

	Action[13]:Set[Mastery]
	SpellRange[13,1]:Set[360]

	Action[14]:Set[DD1]
	MobHealth[14,1]:Set[1]
	MobHealth[14,2]:Set[100]
	Power[14,1]:Set[20]
	Power[14,2]:Set[100]
	SpellRange[14,1]:Set[60]

	Action[15]:Set[DD2]
	MobHealth[15,1]:Set[1]
	MobHealth[15,2]:Set[100]
	Power[15,1]:Set[20]
	Power[15,2]:Set[100]
	SpellRange[15,1]:Set[61]

	Action[16]:Set[Ammending]
	MobHealth[16,1]:Set[10]
	MobHealth[16,2]:Set[30]
	Power[16,1]:Set[1]
	Power[16,2]:Set[100]
	SpellRange[16,1]:Set[312]

	Action[17]:Set[ThermalShocker]
}

function PostCombat_Init()
{
	PostAction[1]:Set[Resurrection]
	PostSpellRange[1,1]:Set[300]
	PostSpellRange[1,2]:Set[301]
	PostSpellRange[1,3]:Set[302]
	PostSpellRange[1,4]:Set[303]
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local

	declare temp int local

	ExecuteAtom CheckStuck

	if ${ShardMode}
	{
		call Shard
	}

	call CheckHeals

	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	{
	    ExecuteAtom AutoFollowTank
		wait 5
	}

	if ${Me.ToActor.Power}>85 && ${PreHealMode}
	{
		if ${KeepReactiveUp}
		{
			call CastSpellRange 7 0 0 0 ${Actor[ExactName,${MainTankPC}].ID}
		}
		if ${KeepGroupReactiveUp}
		{
			call CastSpellRange 15
		}
	}

	switch ${PreAction[${xAction}]}
	{
		case BuffRedoubt
			Counter:Set[1]
			tempvar:Set[1]

			if !${Me.Equipment[The Impact of the Sacrosanct](exists)} && !${Me.Inventory[The Impact of the Sacrosanct](exists)}
			{
				;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
				do
				{
					BuffMember:Set[]
					;check if the maintained buff is of the spell type we are buffing
					if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
					{
						;iterate through the members to buff
						if ${UIElement[lbBuffRedoubt@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
						{
							tempvar:Set[1]
							do
							{
								BuffTarget:Set[${UIElement[lbBuffRedoubt@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]
								if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
								{
									BuffMember:Set[OK]
									break
								}
							}
							while ${tempvar:Inc}<=${UIElement[lbBuffRedoubt@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
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
				if ${UIElement[lbBuffRedoubt@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
				{
					do
					{
						BuffTarget:Set[${UIElement[lbBuffRedoubt@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
					}
					while ${Counter:Inc}<=${UIElement[lbBuffRedoubt@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
				}
			}
			else
			{
				; we have the templar mythical so using different logic for this buff
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				{
					if !${Me.Equipment[The Impact of the Sacrosanct](exists)}
					{
						tempMH:Set[${Me.Equipment[Primary].Name}]
						waitframe
						Me.Inventory[The Impact of the Sacrosanct]:Equip
						waitframe
						call CastSpellRange ${PreSpellRange[${xAction},1]}
						waitframe
						Me.Inventory[${tempMH}]:Equip
					}
					else
						call CastSpellRange ${PreSpellRange[${xAction},1]}
				}
			}
			break

		case BuffCourage
			if ${BuffCourage}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffSymbol
			if ${BuffSymbol}
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
		case BuffGlory
			BuffTarget:Set[${UIElement[cbBuffGloryGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case Bennediction
			BuffTarget:Set[${UIElement[cbBuffBennedictionGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case Praetorate
			BuffTarget:Set[${UIElement[cbBuffPraetorateGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case ShieldAlly
			if ${ShieldAllyMode}
			{
				BuffTarget:Set[${UIElement[cbBuffShieldAllyGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				}

				if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
			}
			break
		case ManaCure
			if ${ManaCureMode}
			{
				BuffTarget:Set[${UIElement[cbManaCureGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				}

				if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
			}
			break
		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		Default
			return Buff Complete
			break
	}
}

function Combat_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	declare spellsused int local

	spellsused:Set[0]
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
		call CastSpellRange 333
	}

	call PetAttack

	call CheckHeals
	call RefreshPower

	if ${DebuffMode} && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].IsHeroic})
	{
		;Divine Recovery first if up
		if ${Me.Ability[${SpellType[390]}].IsReady} && !${Me.Maintained[${SpellType[390]}](exists)}
		{
			call CastSpellRange 390 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[52]}].IsReady} && !${Me.Maintained[${SpellType[52]}](exists)} && ${spellsused}<1
		{
			call CastSpellRange 52 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[51]}].IsReady} && !${Me.Maintained[${SpellType[51]}](exists)} && ${spellsused}<1
		{
			call CastSpellRange 51 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[50]}].IsReady} && !${Me.Maintained[${SpellType[50]}](exists)} && ${spellsused}<1
		{
			call CastSpellRange 50 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}

	if ${ShardMode}
	{
		call Shard
	}

	if ${FocusedMode}
	{
		call CheckGroupHealth 60
		if ${Return}
		{
			call CastSpellRange 9
		}
		elseif ${Me.Maintained[${SpellType[9]}](exists)}
		{
			Me.Maintained[${SpellType[9]}]:Cancel
		}
	}
	elseif ${Me.Maintained[${SpellType[9]}](exists)}
	{
		Me.Maintained[${SpellType[9]}]:Cancel
	}

	;Before we do our Action, check to make sure our group doesnt need healing
	call CheckGroupHealth 50
	if ${Return}
	{

		if ${MeleeMode} && ${Actor[${KillTaget}].Distance}>4
		{
			call CheckPosition 1 ${Actor[${KillTarget}].IsEpic}
		}

		switch ${Action[${xAction}]}
		{
			case Ammending
			case DD1
			case DD2
			case Divine_Castigation
			case Turn_Undead
			case Stun
			case Dot1
			case Dot2
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]} && !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && ${OffenseMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break
			case Hammer
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]} && !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && ${OffenseMode} && ${PetMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break
			case Melee1
			case Melee2
			case Melee3
				;note: will only bash if within 5 meters, this is by design to prevent having to implement a range only mode
				if ${MeleeMode} && ${OffenseMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 1 ${KillTarget}
					}
				}
				break
			case Reverence
				if !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
				break
			case Involuntary
				echo Involuntary Cast ${SpellRange[${xAction},1]}
				if !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
				break
			case AoE
				if ${AoEMode} && ${OffenseMode} && ${Mob.Count}>2
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
				break
			case Mastery
				if ${Me.Ability[Master's Smite].IsReady} && ${Actor[${KillTarget}](exists)} && ${OffenseMode}
				{
					Me.Ability[Master's Smite]:Use
				}
				break
			case ThermalShocker
				if ${Me.Inventory[ExactName,"Brock's Thermal Shocker"](exists)} && ${Me.Inventory[ExactName,"Brock's Thermal Shocker"].IsReady} && ${OffenseMode}
				{
					Me.Inventory[ExactName,"Brock's Thermal Shocker"]:Use
				}
				break
			default
				return CombatComplete
				break
		}
	}
}

function Post_Combat_Routine(int xAction)
{

	;Turn off Focused so we can move
	if ${Me.Maintained[${SpellType[9]}](exists)}
	{
		Me.Maintained[${SpellType[9]}]:Cancel
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
				if ${Me.Group[${tempgrp}].ToActor.IsDead}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 1 0 ${Me.Group[${tempgrp}].ID} 1
				}
			}
			while ${tempgrp:Inc}<${grpcnt}
			break
		default
			return PostCombatRoutineComplete
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

	if !${MainTank}
	{
		call CastSpellRange 180
	}
}

function RefreshPower()
{
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
	declare MainTankID int local 0
	declare MTinMyGroup bool local FALSE
	declare HealUsed bool local FALSE

	MainTankID:Set[${Actor[ExactName,${MainTankPC}].ID}]
	grpcnt:Set[${Me.GroupCount}]
	hurt:Set[FALSE]
	HealUsed:Set[FALSE]

	temphl:Set[1]
	grpcure:Set[0]
	lowest:Set[1]

	;cancel Focused if up and tank dieing
	if ${Me.Maintained[${SpellType[9]}](exists)} && (${Actor[${MainTankPC}].Health}<50 && ${Actor[${MainTankPC}].Health}>-99 && ${Actor[${MainTankPC}](exists)} && ${Actor[${MainTankPC}].ID}!=${Me.ID}) || (!${FocusedMode} && ${Me.ToActor.Power}>10)
	{
		Me.Maintained[${SpellType[9]}]:Cancel
	}
	elseif ${Me.Maintained[${SpellType[9]}](exists)} && ${FocusedMode}
	{
		return
	}

	;Res the MT if they are dead
	if ${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)} && ${CombatRez}
	{
		call CastSpellRange 300 0 1 1 ${MainTankID}
	}

	do
	{
		if ${Me.Group[${temphl}].ToActor(exists)}
		{
			if ${Me.Group[${temphl}].ToActor.Health}<90 && !${Me.Group[${temphl}].ToActor.IsDead}
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

			if !${Me.Group[${temphl}].ToActor.IsDead} && ${Me.Group[${temphl}].ToActor.Health}<80
			{
				grpheal:Inc
			}

			if ${Me.Group[${temphl}].Arcane}>0 || ${Me.Group[${temphl}].Trauma}>0
			{
				grpcure:Inc
			}

			if ${Me.Group[${temphl}].Class.Equal[conjuror]}  || ${Me.Group[${temphl}].Class.Equal[necromancer]}
			{
				if ${Me.Group[${temphl}].ToActor.Pet.Health}<30 && ${Me.Group[${temphl}].ToActor.Pet.Health}>0
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

	;MAINTANK EMERGENCY HEAL
	if ${Actor[${MainTankID}].Health}<30 && ${Actor[${MainTankID}](exists)} && ${Actor[${MainTankID}].InCombatMode} && !${Actor[${MainTankID}].IsDead}
	{
		call EmergencyHeal ${MainTankID} ${MTinMyGroup}
	}

	if ${Me.ToActor.Health}<80 && !${Me.ToActor.IsDead}
	{
		grpheal:Inc
	}

	if ${Me.Arcane}>0 || ${Me.Trauma}>0
	{
		grpcure:Inc
	}

	;CURES
	if ${grpcure}>2 && ${CureMode}
	{
		call CastSpellRange 220
		call CastSpellRange 221
	}

	if ${Me.IsAfflicted} && ${CureMode}
	{
		call CureMe
	}

	if ${KeepReactiveUp} && !${Me.Maintained[${SpellType[7]}](exists)} && ${Me.Ability[${SpellType[7]}].IsReady} && ${Actor[${MainTankID}].InCombatMode} && !${Actor[${MainTankID}].IsDead}
	{
		if ${Actor[${MainTankID}].Health}<50 && ${Me.Ability[${SpellType[4]}].IsReady}
		{
			call CastSpellRange 4 0 0 0 ${Actor[ExactName,${MainTankPC}].ID}
		}
		call CastSpellRange 7 0 0 0 ${Actor[ExactName,${MainTankPC}].ID}
	}

	if ${KeepGroupReactiveUp} && !${Me.Maintained[${SpellType[15]}](exists)} && ${Me.Ability[${SpellType[15]}].IsReady} && ${Actor[${MainTankID}].InCombatMode} && !${Actor[${MainTankID}].IsDead}
	{
		if ${Actor[${MainTankID}].Health}<50 && ${Me.Ability[${SpellType[1]}].IsReady}
		{
			call CastSpellRange 1 0 0 0 ${Actor[ExactName,${MainTankPC}].ID}
		}
		call CastSpellRange 15
	}

	call CheckGroupHealth 30
	if ${mostafflicted} && ${CureMode} && ${Return} && ${Actor[${MainTankID}].Health}>50
	{
		;If MT is aflicted with uncurable arcane, try sanctuary.
		if ${Me.Group[${mostafflicted}].Name.Equal[${MainTankPC}]} && ${Me.Group[${mostafflicted}].IsAfflicted} && ${Me.Group[${mostafflicted}].Arcane}<0 && ${Me.Ability[${SpellType[222]}].IsReady}
		{
			call CastSpellRange 222
		}
		call CureGroupMember ${mostafflicted}
	}



	;MAINTANK HEALS
	if ${Actor[${MainTankID}].Health}<90 && ${Actor[${MainTankID}](exists)} && ${Actor[${MainTankID}].InCombatMode} && !${Actor[${MainTankID}].IsDead}
	{
		if ${MTinMyGroup} && ${RaidHealMode}
		{
			if ${Me.Ability[${SpellType[15]}].IsReady} && !${Me.Maintained[${SpellType[15]}](exists)}
			{
				call CastSpellRange 15
			}
			else
			{
				call CastSpellRange 1 0 0 0 ${MainTankID}
			}
		}
		elseif !${MTinMyGroup} && ${RaidHealMode}
		{
			if ${Me.Ability[${SpellType[7]}].IsReady} && !${Me.Maintained[${SpellType[7]}](exists)}
			{
				call CastSpellRange 7 0 0 0 ${MainTankID}
			}
			else
			{
				call CastSpellRange 4 0 0 0 ${MainTankID}
			}
		}
		else
		{
			if ${Me.Ability[${SpellType[7]}].IsReady} && !${Me.Maintained[${SpellType[7]}](exists)}
			{
				call CastSpellRange 7 0 0 0 ${MainTankID}
			}
			elseif !${Me.Maintained[${SpellType[7]}](exists)}
			{
				call CastSpellRange 1 0 0 0 ${MainTankID}
			}
		}
	}

	if ${Actor[${MainTankID}].Health}<50 && ${Actor[${MainTankID}](exists)} && ${Actor[${MainTankID}].InCombatMode} && !${Actor[${MainTankID}].IsDead}
	{
		if ${Me.Ability[${SpellType[2]}].IsReady}
		{
			call CastSpellRange 2 0 0 0 ${MainTankID}
		}
		else
		{
			call CastSpellRange 4 0 0 0 ${MainTankID}
		}
	}

	if ${Actor[${MainTankID}].Health}<80 && ${Actor[${MainTankID}](exists)} && ${Actor[${MainTankID}].InCombatMode} && ${RaidHealMode}
	{
		if ${Me.Ability[${SpellType[1]}].IsReady}
		{
			call CastSpellRange 1 0 0 0 ${MainTankID}
		}
		elseif ${Me.Ability[${SpellType[2]}].IsReady}
		{
			call CastSpellRange 2 0 0 0 ${MainTankID}
		}
		elseif ${Me.Ability[${SpellType[4]}].IsReady}
		{
			call CastSpellRange 4 0 0 0 ${MainTankID}
		}
	}


	if ${Actor[${MainTankID}].Health}<50 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)}
	{
		if ${Me.Ability[${SpellType[2]}].IsReady}
		{
			call CastSpellRange 2 0 0 0 ${MainTankID}
		}
		elseif ${Me.Ability[${SpellType[4]}].IsReady}
		{
			call CastSpellRange 4 0 0 0 ${MainTankID}
		}
		elseif ${Me.Ability[${SpellType[1]}].IsReady}
		{
			call CastSpellRange 1 0 0 0 ${MainTankID}
		}
	}

	;ME HEALS
	if ${Me.ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health} && ${Me.Group[${lowest}].ToActor(exists)}
	{
		if ${Me.ToActor.Health}<70 && ${Me.ToActor.InCombatMode}
		{
			; if i have summoned a defiler crystal use that to heal first
			if ${Me.Inventory[Crystallized Spirit](exists)}
			{
				Me.Inventory[Crystallized Spirit]:Use
			}
		}

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

		if ${Me.ToActor.Health}<55
		{
			call CastSpellRange 1 0 0 0 ${Me.ID}
		}


		if ${Me.ToActor.Health}<25
		{
			if ${haveaggro}
			{
				call EmergencyHeal ${Me.ID} 0
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

	;GROUP HEALS
	if ${grpheal}>2
	{
		if ${Me.Ability[${SpellType[10]}].IsReady}
		{
			call CastSpellRange 10
		}
	}

	if ${Me.Group[${lowest}].ToActor.Health}<80 && !${Me.Group[${lowest}].ToActor.IsDead} && ${Me.Group[${lowest}].ToActor(exists)}
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

	;PET HEALS
	if ${PetToHeal} && ${Actor[ExactName,${PetToHeal}](exists)}
	{
		if ${Actor[ExactName,${PetToHeal}].InCombatMode}
		{
			call CastSpellRange 7 0 0 0 ${PetToHeal}
		}
		else
		{
			call CastSpellRange 387
			call CastSpellRange 1 0 0 0 ${PetToHeal}
		}
	}

	if ${CombatRez} || !${Me.InCombat}
	{
		grpcnt:Set[${Me.GroupCount}]
		tempgrp:Set[1]
		do
		{
			if ${Me.Group[${tempgrp}].ToActor(exists)} && ${Me.Group[${tempgrp}].ToActor.IsDead}
			{
				call CastSpellRange 301 303 1 1 ${Me.Group[${tempgrp}].ID} 1
			}
		}
		while ${tempgrp:Inc}<${grpcnt}
	}
	call UseCrystallizedSpirit 60

}

function EmergencyHeal(int healtarget, MTinMyGroup)
{

	if ${Me.Ability[${SpellType[11]}].IsReady} && ${MTinMyGroup}
	{
		call CastSpellRange 11
		call CastSpellRange 16
	}
	elseif ${Me.Ability[${SpellType[8]}].IsReady}
	{
		call CastSpellRange 8 0 0 0 ${healtarget}
	}
	else
	{
		;Death Save
		call CastSpellRange 316 0 0 0 ${healtarget}
	}

}


function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{
	if ${Me.Ability[${SpellType[392]}].IsReady}
	{
		call CastSpellRange 392 0 0 0 ${healtarget}
	}
}

function MA_Dead()
{
	if ${Actor[ExactName,PC,${MainTankPC}].IsDead} && ${Actor[ExactName,PC,${MainTankPC}](exists)} && ${CombatRez}
	{
		call 300 301 1 1 ${Actor[ExactName,PC,${MainTankPC}].ID} 1
	}
}

function CureMe()
{
	if ${Me.Arcane}>0
	{
		if ${Me.Arcane}>0
		{
			if !${Me.Ability[${SpellType[381]}].IsReady}
			{
				call CastSpellRange 381 0 0 0 ${Me.ID}
			}
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

	if (${gMember} == 0)
	{
	    call CureMe
	    return
	}


	tmpcure:Set[0]
	if !${Me.Group[${gMember}].ToActor(exists)}
	{
		return
	}

	do
	{
		if  ${Me.Group[${gMember}].Arcane}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}
			tmpcure:Inc
			wait 2
		}

		if  ${Me.Group[${gMember}].Noxious}>0
		{
			call CastSpellRange 213 0 0 0 ${Me.Group[${gMember}].ID}
			tmpcure:Inc
			wait 2
		}

		if  ${Me.Group[${gMember}].Elemental}>0
		{
			call CastSpellRange 211 0 0 0 ${Me.Group[${gMember}].ID}
			tmpcure:Inc
			wait 2
		}

		if  ${Me.Group[${gMember}].Trauma}>0
		{
			call CastSpellRange 212 0 0 0 ${Me.Group[${gMember}].ID}
			tmpcure:Inc
			wait 2
		}
	}
	while ${Me.Group[${gMember}].IsAfflicted} && ${CureMode} && ${tmpcure:Inc}<3 && ${Me.Group[${gMember}].ToActor(exists)}

	gMember:Set[1]

	do
	{
		if ${Me.Group[${gMember}]].IsAfflicted}
		{
			if  ${Me.Group[${gMember}].Arcane}>0
			{
				call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}
				tmpcure:Inc
				wait 2
			}

			if  ${Me.Group[${gMember}].Noxious}>0
			{
				call CastSpellRange 213 0 0 0 ${Me.Group[${gMember}].ID}
				tmpcure:Inc
				wait 2
			}

			if  ${Me.Group[${gMember}].Elemental}>0
			{
				call CastSpellRange 211 0 0 0 ${Me.Group[${gMember}].ID}
				tmpcure:Inc
				wait 2
			}

			if  ${Me.Group[${gMember}].Trauma}>0
			{
				call CastSpellRange 212 0 0 0 ${Me.Group[${gMember}].ID}
				tmpcure:Inc
				wait 2
			}
		}
	}
	while ${gMember:Inc}<${${Me.GroupCount}} && ${tmpcure:Inc}<4

}

function CheckAfflicted()
{
	declare temphl int local 0
	declare tmpafflictions int local 0
	declare mostafflictions int local 0
	declare mostafflictions int local 0

	do
	{
		if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].IsAfflicted}
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
	}
	while ${temphl:Inc}<${grpcnt}

	return ${mostafflicted}

}
