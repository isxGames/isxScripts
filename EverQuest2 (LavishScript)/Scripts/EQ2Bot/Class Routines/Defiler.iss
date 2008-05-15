;*************************************************************
;Defiler.iss
;version 20080513a
;by karye
;updated by pygar
;
;20080513a
; * Complete re-write of all heal and curing logic.  Cures will be greatly prioritized durring epic battles.
; * Heal and cure checks should all be much less overhead and provide performance boosts for the bot
;
;20070503a
; Toggle Pet Use
; Toggle Combat Rez
;	Added health check to cure routine
; Added Toggle for Innitiating HO
;
;20070404a
;Updated for latest eq2bot
;
;20061201a
;Fixed Cyrstalize Spirit line
;implemented EoF Mastery attacks
;implemented Turgur's Spirit Sight
;implemented Vampire Theft Of Vitality
;Implemented AA Cannibalize
;Implemented AA Hexation
;Implemented AA Soul Ward
;Fixed a bug with AE healing group members out of zone
;Fixed a bug with curing uncurable afflictions
;The defiler will now use spiritual circle more often
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20080513
	;;;;

	declare OffenseMode bool script 0
	declare DebuffMode bool script 0
	declare AoEMode bool script 0
	declare CureMode bool script 0
	declare MaelstromMode bool script 0
	declare KeepWardUp bool script
	declare PetMode bool script 1
	declare CombatRez bool script 1
	declare StartHO bool script 1

	declare BuffNoxious bool script FALSE
	declare BuffMitigation bool script FALSE
	declare BuffStrength bool script FALSE
	declare BuffWaterBreathing bool script FALSE
	declare BuffProcGroupMember string script
	declare BuffHorrorGroupMember string script
	declare BuffAlacrityGroupMember string script

	declare EquipmentChangeTimer int script

	call EQ2BotLib_Init

	PetMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Pets,TRUE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	CureMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Cure Spells,FALSE]}]
	CombatRez:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Combat Rez,FALSE]}]
	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	KeepWardUp:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[KeepWardUp,FALSE]}]
	OffenseMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,FALSE]}]
	MaelstromMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Maelstrom Mode,FALSE]}]

	BuffNoxious:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffNoxious,TRUE]}]
	BuffStrength:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffStrength,TRUE]}]
	BuffMitigation:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffMitigation,TRUE]}]
	BuffWaterBreathing:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffWaterBreathing,FALSE]}]
	BuffProcGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffProcGroupMember,]}]
	BuffHorrorGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffHorrorGroupMember,]}]
	BuffAlacrityGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffAlacrityGroupMember,]}]
}

function Buff_Init()
{

	PreAction[1]:Set[BuffPower]
	PreSpellRange[1,1]:Set[35]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]
	PreSpellRange[2,2]:Set[26]

	PreAction[3]:Set[BuffProc]
	PreSpellRange[3,1]:Set[41]

	PreAction[4]:Set[BuffNoxious]
	PreSpellRange[4,1]:Set[23]

	PreAction[5]:Set[Group_Buff]
	PreSpellRange[5,1]:Set[281]
	PreSpellRange[5,2]:Set[283]

	PreAction[6]:Set[SpiritCompanion]
	PreSpellRange[6,1]:Set[385]

	PreAction[7]:Set[SpecialVision]
	PreSpellRange[7,1]:Set[314]

	PreAction[8]:Set[AA_Immunities]
	PreSpellRange[8,1]:Set[383]

	PreAction[9]:Set[AA_RitualisticAggression]
	PreSpellRange[9,1]:Set[396]
	PreSpellRange[9,2]:Set[397]

	PreAction[10]:Set[AA_InfectiveBites]
	PreSpellRange[10,1]:Set[394]

	PreAction[11]:Set[AA_Coagulate]
	PreSpellRange[11,1]:Set[395]

	PreAction[12]:Set[BuffHorror]
	PreSpellRange[12,1]:Set[40]

	PreAction[13]:Set[BuffMitigation]
	PreSpellRange[13,1]:Set[21]

	PreAction[14]:Set[BuffStrength]
	PreSpellRange[14,1]:Set[20]

	PreAction[15]:Set[BuffWaterBreathing]
	PreSpellRange[15,1]:Set[280]

}

function Combat_Init()
{
	Action[1]:Set[AoE1]
	SpellRange[1,1]:Set[90]

	Action[2]:Set[AoE2]
	SpellRange[2,1]:Set[91]

	Action[3]:Set[AARabies]
	SpellRange[3,1]:Set[352]

	Action[4]:Set[Proc_Ward]
	MobHealth[4,1]:Set[1]
	MobHealth[4,2]:Set[100]
	Power[4,1]:Set[1]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[322]

	Action[5]:Set[Malaise]
	MobHealth[5,1]:Set[1]
	MobHealth[5,2]:Set[100]
	Power[5,1]:Set[1]
	Power[5,2]:Set[100]
	SpellRange[5,1]:Set[71]

	Action[6]:Set[Imprecation]
	MobHealth[6,1]:Set[1]
	MobHealth[6,2]:Set[100]
	Power[6,1]:Set[60]
	Power[6,2]:Set[100]
	SpellRange[6,1]:Set[80]

	Action[7]:Set[AA_Hexation]
	MobHealth[7,1]:Set[1]
	MobHealth[7,2]:Set[100]
	Power[7,1]:Set[20]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[382]

	Action[8]:Set[TheftOfVitality]
	MobHealth[8,1]:Set[1]
	MobHealth[8,2]:Set[100]
	Power[8,1]:Set[20]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[55]

	Action[9]:Set[Mastery]
	SpellRange[9,1]:Set[360]
	SpellRange[9,2]:Set[379]

	Action[10]:Set[UmbralTrap]
	MobHealth[10,1]:Set[1]
	MobHealth[10,2]:Set[100]
	SpellRange[10,1]:Set[54]

	Action[11]:Set[Fuliginous_Sphere]
	MobHealth[11,1]:Set[1]
	MobHealth[11,2]:Set[100]
	Power[11,1]:Set[1]
	Power[11,2]:Set[100]
	SpellRange[11,1]:Set[51]

	Action[12]:Set[Curse]
	MobHealth[12,1]:Set[1]
	MobHealth[12,2]:Set[100]
	Power[12,1]:Set[1]
	Power[12,2]:Set[100]
	SpellRange[12,1]:Set[50]

	Action[13]:Set[Loathsome_Seal]
	MobHealth[13,1]:Set[1]
	MobHealth[13,2]:Set[100]
	Power[13,1]:Set[1]
	Power[13,2]:Set[100]
	SpellRange[13,1]:Set[53]

	Action[14]:Set[Repulsion]
	MobHealth[14,1]:Set[1]
	MobHealth[14,2]:Set[100]
	Power[14,1]:Set[1]
	Power[14,2]:Set[100]
	SpellRange[14,1]:Set[52]

	Action[15]:Set[ThermalShocker]

	Action[16]:Set[AA_CripplingBash]
	MobHealth[16,1]:Set[1]
	MobHealth[16,2]:Set[100]
	SpellRange[16,1]:Set[393]

	Action[17]:Set[UmbralTrap]
	MobHealth[17,1]:Set[1]
	MobHealth[17,2]:Set[100]
	SpellRange[17,1]:Set[54]
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

	declare temp int local

	ExecuteAtom CheckStuck

	if ${ShardMode}
		call Shard

	call CheckHeals

	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	{
		ExecuteAtom AutoFollowTank
		wait 5
	}

	if ${Me.ToActor.Power}>85 && ${KeepWardUp}
	{
		call CastSpellRange 15
		call CastSpellRange 7 0 0 0 ${Actor[ExactName,${MainTankPC}].ID}
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
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break
		case SpiritCompanion
			if ${PetMode} && !${Me.InCombat}
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case BuffNoxious
			if ${BuffNoxious}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffMitigation
			if ${BuffMitigation}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffStrength
			if ${BuffStrength}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffWaterBreathing
			if ${BuffWaterBreathing}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffProc
			BuffTarget:Set[${UIElement[cbBuffProcGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case BuffHorror
			BuffTarget:Set[${UIElement[cbBuffHorrorGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		case AA_Coagulate
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case AA_Immunities
			if !${Me.ToActor.Effect[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Me.ToActor.Pet(exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case AA_RitualisticAggression
		case AA_RitualOfAbsolution
		case AA_InfectiveBites
			if ${Me.ToActor.Pet(exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		case SpecialVision
			if ${Me.ToActor.Race.Equal[Euridite]}
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
		EQ2Execute /stopfollow

	call CheckGroupHealth 60
	if ${DoHOs} && ${Return}
		objHeroicOp:DoHO

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
		call CastSpellRange 303

	call PetAttack

	if ${CureMode}
		call CheckCures

	call CheckHeals
	call RefreshPower

	if ${DebuffMode} && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].IsHeroic})
	{
		if ${Me.Ability[${SpellType[54]}].IsReady} && !${Me.Maintained[${SpellType[54]}](exists)}
		{
			call CastSpellRange 54 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[51]}].IsReady} && !${Me.Maintained[${SpellType[51]}](exists)}
		{
			call CastSpellRange 51 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[52]}].IsReady} && !${Me.Maintained[${SpellType[52]}](exists)} && ${spellsused}<2
		{
			call CastSpellRange 52 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[53]}].IsReady} && !${Me.Maintained[${SpellType[53]}](exists)} && ${spellsused}<2
		{
			call CastSpellRange 53 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[322]}].IsReady} && !${Me.Maintained[${SpellType[322]}](exists)} && ${spellsused}<2
		{
			call CastSpellRange 322 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}

	;keep Leg Bite up at all times if we have a pet
	if ${Me.Maintained[${SpellType[385]}](exists)}
		call CastSpellRange 388

	if ${ShardMode}
		call Shard

	if ${MaelstromMode}
	{
		call CheckGroupHealth 60
		if ${Return}
		{
			call CastSpellRange 317
		}
		elseif ${Me.Maintained[${SpellType[317]}](exists)}
		{
			Me.Maintained[${SpellType[317]}]:Cancel
		}
	}
	elseif ${Me.Maintained[${SpellType[317]}](exists)}
	{
		Me.Maintained[${SpellType[317]}]:Cancel
	}

	;Cast Alacrity if available
	if ${Me.Ability[${SpellType[398]}].IsReady}
	{
		BuffTarget:Set[${UIElement[cbBuffProcGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

		if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			call CastSpellRange 398 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
	}

	;Before we do our Action, check to make sure our group doesnt need healing
	call CheckGroupHealth 50
	if ${Return}
	{
		switch ${Action[${xAction}]}
		{
			case Repulsion
			case Loathsome_Seal
			case Curse
			case UmbralTrap
			case TheftOfVitality
			case AA_Hexation
				if ${DebuffMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]} && !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break
			case AA_CripplingBash
				;note: will only bash if within 5 meters, this is by design to prevent having to implement a range only mode
				if ${DebuffMode} && ${Me.Maintained[${SpellType[385]}](exists)}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break

			case Proc_Ward
				if (${Actor[${KillTarget}].Difficulty} == 3)  || ${MainTank} || ${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Type.Equal[NamedNPC]}
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]} && !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
				break
			case Forced_Cannibalize
			case Malaise
			case Imprecation
			case Fuliginous_Sphere
				if ${OffenseMode} && !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
					{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break
			case Soul_Essence
				if ${OffenseMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckHealerMob
						if ${Return}
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break
			case AoE1
			case AoE2
			case AARabies
				if ${AoEMode} && ${Mob.Count}>2
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				break
			case Mastery
				;;;; Make sure that we do not spam the mastery spell for creatures invalid for use with our mastery spell
				;;;;;;;;;;
				if (${InvalidMasteryTargets.Element[${Actor[${KillTarget}].ID}](exists)})
						break
				;;;;;;;;;;;
				if ${Me.Ability[Master's Smite].IsReady} && ${Actor[${KillTarget}](exists)}
				{
					Target ${KillTarget}
					Me.Ability[Master's Smite]:Use
				}
				break
			case ThermalShocker
				if ${Me.Inventory[ExactName,"Brock's Thermal Shocker"](exists)} && ${Me.Inventory[ExactName,"Brock's Thermal Shocker"].IsReady}
					Me.Inventory[ExactName,"Brock's Thermal Shocker"]:Use
			default
				return CombatComplete
				break
		}
	}
}

function Post_Combat_Routine(int xAction)
{
	declare tempgrp int 1
	;Turn off Maelstrom so we can move
	if ${Me.Maintained[${SpellType[317]}](exists)}
		Me.Maintained[${SpellType[317]}]:Cancel

	call CheckCures

	TellTank:Set[FALSE]

	if ${Me.AutoAttackOn}
		EQ2Execute /toggleautoattack

	switch ${PostAction[${xAction}]}
	{
		case Resurrection
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1]
			do
			{
				if ${Me.Group[${tempgrp}].ToActor.IsDead}
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 1 0 ${Me.Group[${tempgrp}].ID} 1
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
		;Try AE fear hate reduction first
		call CastSpellRange 180

		;if something is still on me single fear it
		if ${Actor[${aggroid}].Distance}<=5 && (${Actor[${aggroid}].Target.ID} == ${Me.ID})
		{
			call CastSpellRange 181 0 0 0 ${aggroid}
		}
	}
}

function RefreshPower()
{
	;AA Cannibalize
	if ${Me.ToActor.Power}<35  && ${Me.ToActor.Health}>50
	{
		call CastSpellRange 387
		call CastSpellRange 381
	}

	;Forced Canabalize
	if ${Me.ToActor.Power}<85 && ${Me.InCombat}  && !${Actor[${KillTarget}].Name.Upper.Find[DRUSELLA]}
		call CastSpellRange 72 0 0 0 ${KillTarget}

	if ${Me.InCombat} && ${Me.ToActor.Power}<25  && ${Me.ToActor.Health}>25 && ${Me.Equipment[ExactName,"Tribal Spiritist's Hat"].IsReady}
		call UseItem "Tribal Spiritist's Hat"

	if ${Me.InCombat} && ${Me.ToActor.Power}<25 && ${Me.Equipment[ExactName,"Spiritise Censer"].IsReady}
		call UseItem "Spiritise Censer"

	if ${Me.InCombat} && ${Me.ToActor.Power}<15 && ${Me.Equipment[ExactName,"Stein of the Everling Lord"].IsReady}
		call UseItem "Stein of the Everling Lord"
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
	if ${Actor[ExactName,PC,${MainTankPC}].IsDead} && ${Actor[ExactName,PC,${MainTankPC}](exists)} && ${CombatRez}
		call 300 301 1 0 ${Actor[ExactName,PC,${MainTankPC}].ID} 1
}

function CheckCures()
{
	declare temphl int local 1
	declare grpcure int local 0

	grpcnt:Set[${Me.GroupCount}]

	;check for group cures, if it is ready and we are in a large enough group
	if ${Me.Ability[${SpellType[220]}].IsReady} && ${Me.GroupCount}>3
	{
		;check ourselves
		if ${Me.IsAfflicted}
		{
			;add ticks for group cures based upon our afflicions
			if ${Me.Noxious}>0
				grpcure:Inc

			if ${Me.Trauma}>0
				grpcure:Inc
		}

		;loop group members, and check for group curable afflictions
		do
		{
			;make sure they in zone and in range
			if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].ToActor.Distance}<35
			{
				if ${Me.Group[${temphl}].Noxious}>0
					grpcure:Inc

				if ${Me.Group[${temphl}].Trauma}>0
					grpcure:Inc
			}
		}
		while ${temphl:Inc}<${grpcnt}

		;Use group cure if more than 3 afflictions will be removed
		if ${grpcure}>3
			call CastSpellRange 220
	}

	;Cure Ourselves first
	do
	{
		call CureMe

		if ${Me.ToActor.Health}<30 && ${EpicMode}
			call HealMe
	}
	while ${Me.IsAfflicted} && (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Trauma}>0 || ${Me.Elemental}>0)

	;Cure Group Members - This will cure a single person unless epicmode is checkd on extras tab, in which case it will cure
	;	all afflictions unless group health or mt health gets low
	do
	{
		call FindAfflicted
		if ${Return}>0
			call CureGroupMember ${Return}
		else
			break

		;break if we need heals
		call CheckGroupHealth 30
		if !${Return}
		{
			call CheckHeals
			break
		}

		;Check MT health and heal him if needed
		if ${Actor[pc,ExactName,${MainTankPC}].Health}<50
		{
			if ${Actor[pc,ExactName,${MainTankPC}].ID}==${Me.ID}
				call HealMe
			else
				call HealMT
		}

		;epicmode is set in eq2botextras, we will cure only one person per call unless in epic mode.
		if !${EpicMode}
			break

	}
	while ${Me.ToActor.Health}>30 && (${Me.Arcane}<1 && ${Me.Noxious}<1 && ${Me.Elemental}<1 && ${Me.Trauma}<1)
}

function FindAfflicted()
{
	declare temphl int local 1
	declare tmpafflictions int local 0
	declare mostafflictions int local 0
	declare mostafflicted int local 0

	;check for single target cures
	do
	{
		if ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.Distance}<35
		{
			if ${Me.Group[${temphl}].Arcane}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Arcane}]}]

			if ${Me.Group[${temphl}].Noxious}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Noxious}]}]

			if ${Me.Group[${temphl}].Elemental}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Elemental}]}]

			if ${Me.Group[${temphl}].Trauma}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Trauma}]}]

			if ${tmpafflictions}>${mostafflictions}
			{
				mostafflictions:Set[${tmpafflictions}]
				mostafflicted:Set[${temphl}]
			}
		}
	}
	while ${temphl:Inc}<${grpcnt}

	if ${mostafflicted}>0
		return ${mostafflicted}
	else
		return 0
}

function CureMe()
{
	declare AffCnt int 0

	;check if we are not in control, and use control cure if needed
	if !${Me.ToActor.CanTurn} || ${Me.ToActor.IsRooted}
		call CastSpellRange 326

	if !${Me.IsAfflicted}
		return

	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	do
	{
		if ${Me.Arcane}>0
		{
			AffCnt:Set[${Me.Arcane}]
			call CastSpellRange 210 0 0 0 ${Me.ID}

			;if we tried to cure and it failed to work, we might be charmed, use control cure
			if ${Me.Arcane}==${AffCnt}
				call CastSpellRange 326
		}

		if  ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0
			call CastSpellRange 210 0 0 0 ${Me.ID}
	}
	while ${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0
}

function HealMe()
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	;ME HEALS
	; if i have summoned a defiler crystal use that to heal first
	if ${Me.Inventory[Crystallized Spirit](exists)} && ${Me.ToActor.Health}<70 && ${Me.ToActor.InCombatMode}
		Me.Inventory[Crystallized Spirit]:Use

	if ${Me.ToActor.Health}<25
	{
		if ${haveaggro}
			call EmergencyHeal ${Me.ID}
		else
		{
			if ${Me.Ability[${SpellType[1]}].IsReady}
			{
				call CastSpellRange 387
				call CastSpellRange 1 0 0 0 ${Me.ID}
			}
			else
			{
				call CastSpellRange 387
				call CastSpellRange 4 0 0 0 ${Me.ID}
			}
		}
	}

	if ${Me.ToActor.Health}<85
	{
		if ${haveaggro} && ${Me.ToActor.InCombatMode}
			call CastSpellRange 7 0 0 0 ${Me.ID}
		else
		{
			call CastSpellRange 387
			call CastSpellRange 4 0 0 0 ${Me.ID}
		}
	}
}

function CheckHeals()
{
	declare tempgrp int local 1
	declare temphl int local 1
	declare grpheal int local 0
	declare lowest int local 0
	declare PetToHeal int local 0
	declare MainTankID int local 0
	declare MainTankInGroup bool local 0

	MainTankID:Set[${Actor[pc,ExactName,${MainTankPC}].ID}]
	grpcnt:Set[${Me.GroupCount}]

	;curses cause heals to do damage and must be cleared off healer
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	;Res the MT if they are dead
	if (!${Me.ToActor.InCombatMode} || ${CombatRez}) && ${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)}
		call CastSpellRange 300 0 1 1 ${MainTankID}

	do
	{
		if ${Me.Group[${temphl}].ToActor(exists)}
		{

			if ${Me.Group[${temphl}].ToActor.Health}<100 && !${Me.Group[${temphl}].ToActor.IsDead}
			{
				if ${Me.Group[${temphl}].ToActor.Health}<=${Me.Group[${lowest}].ToActor.Health} || ${lowest}==0
				{
					lowest:Set[${temphl}]
				}
			}

			if ${Me.Group[${temphl}].ID}==${MainTankID}
				MainTankInGroup:Set[1]

			if !${Me.Group[${temphl}].ToActor.IsDead} && ${Me.Group[${temphl}].ToActor.Health}<80
				grpheal:Inc

			if (${Me.Group[${temphl}].Class.Equal[conjuror]}  || ${Me.Group[${temphl}].Class.Equal[necromancer]}) && ${Me.Group[${temphl}].ToActor.Pet.Health}<60 && ${Me.Group[${temphl}].ToActor.Pet.Health}>0
				PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}

			if ${Me.ToActor.Pet.Health}<60
				PetToHeal:Set[${Me.ToActor.Pet.ID}]
		}
	}
	while ${temphl:Inc}<=${grpcnt}

	if ${Me.ToActor.Health}<80 && !${Me.ToActor.IsDead}
		grpheal:Inc

	if ${PetMode} && ${grpheal}>2 && ${Me.Ability[${SpellType[220]}].IsReady}
		call CastSpellRange 16

	if ${grpheal}>2
		call GroupHeal

	if ${Actor[${MainTankID}].Health}<90
	{
		if ${Me.ID}==${MainTankID}
			call HealMe
		else
			call HealMT ${MainTankID} ${MainTankInGroup}
	}

	if ${EpicMode}
		call CheckCures

	;Check My health after MT
	if ${Me.ID}!=${MainTankID} && ${Me.ToActor.Health}<90
		call HealMe

	;now lets heal individual groupmembers if needed
	if ${lowest}
	{
		call UseCrystallizedSpirit 60

		if ${EpicMode}
			call CheckCures

		if ${Me.Group[${lowest}].ToActor.Health}<50 && !${Me.Group[${lowest}].ToActor.IsDead} && ${Me.Group[${lowest}].ToActor(exists)}
			call CastSpellRange 387

		if ${Me.Group[${lowest}].ToActor.Health}<70 && !${Me.Group[${lowest}].ToActor.IsDead} && ${Me.Group[${lowest}].ToActor(exists)}
		{
			if ${Me.Ability[${SpellType[1]}].IsReady}
				call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
			else
				call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		}
	}

	;Persist wards if selected.
	if ${KeepWardUp} && ${Me.InCombatMode}
	{
		if ${MainTankInGroup}
			call CastSpellRange 15

		call CastSpellRange 7 0 0 0 ${Actor[ExactName,${MainTankPC}].ID}
	}

	;PET HEALS
	if ${PetToHeal} && ${Actor[ExactName,${PetToHeal}](exists)} && ${Actor[ExactName,${PetToHeal}].InCombatMode}
		call CastSpellRange 4 0 0 0 ${PetToHeal}

	;Check Rezes
	if ${CombatRez} || !${Me.InCombat}
	{
		grpcnt:Set[${Me.GroupCount}]
		temphl:Set[1]
		do
		{
			if ${EpicMode}
				call CheckCures

			if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.IsDead}
				call CastSpellRange 300 301 0 0 ${Me.Group[${temphl}].ID} 1
		}
		while ${temphl:Inc}<${grpcnt}
	}
}

function HealMe()
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	if ${Me.Inventory[Crystallized Spirit](exists)} && ${Me.ToActor.Health}<70 && ${Me.ToActor.InCombatMode}
		Me.Inventory[Crystallized Spirit]:Use

	if ${Me.ToActor.Health}<25
	{
		if ${haveaggro}
			call EmergencyHeal ${Me.ID}
		else
		{
			if ${Me.Ability[${SpellType[1]}].IsReady}
			{
				call CastSpellRange 387
				call CastSpellRange 1 0 0 0 ${Me.ID}
			}
			else
			{
				call CastSpellRange 387
				call CastSpellRange 4 0 0 0 ${Me.ID}
			}
		}
	}

	if ${Me.ToActor.Health}<85
	{
		if ${haveaggro} && ${Me.ToActor.InCombatMode}
			call CastSpellRange 7 0 0 0 ${Me.ID}
		else
		{
			call CastSpellRange 387
			call CastSpellRange 4 0 0 0 ${Me.ID}
		}
	}
}

function HealMT(int MainTankID, int MTInMyGroup)
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	;DeathWard Check
	if ${Actor[${MainTankID}].Health}<50 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)}
	{
		call CastSpellRange 387
		call CastSpellRange 8 0 0 0 ${MainTankID}
	}

	;MAINTANK EMERGENCY HEAL
	if ${Actor[${MainTankID}].Health}<30 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)}
		call EmergencyHeal ${MainTankID}

	;MAINTANK HEALS
	; Use Wards first, then Patch Heals
	if ${Actor[${MainTankID}].Health}<90 && ${Actor[${MainTankID}](exists)} && !${Actor[${MainTankID}].IsDead}
	{
		if ${Me.Ability[${SpellType[15]}].IsReady} && ${MTInMyGroup}
		{
			call CastSpellRange 387
			call CastSpellRange 15
			if ${EpicMode}
				call CheckCures
		}
		else
			call CastSpellRange 7 0 0 0 ${MainTankID}

		if ${Me.Ability[${SpellType[7]}].IsReady} && ${EpicMode}
			call CastSpellRange 7 0 0 0 ${MainTankID}
	}

	if ${Actor[${MainTankID}].Health}<80 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)}
	{
		call CastSpellRange 387
		call CastSpellRange 1 0 0 0 ${MainTankID}
	}
}

function GroupHeal()
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	call CastSpellRange 387

	if ${Me.Ability[${SpellType[10]}].IsReady}
		call CastSpellRange 10
	else
		call CastSpellRange 15
}

function EmergencyHeal(int healtarget)
{

	;Soul Ward
	call CastSpellRange 380 0 0 0 ${healtarget}

	;if we cast soulward exit emergency heal
	if ${Me.Maintained[${SpellType[380]}](exists)}
		return

	;Avenger Death Save
	call CastSpellRange 338 0 0 0 ${healtarget}

	if ${Me.Ability[${SpellType[335]}].IsReady}
		call CastSpellRange 335 0 0 0 ${healtarget}
	else
		call CastSpellRange 334 0 0 0 ${healtarget}

}

function CureGroupMember(int gMember)
{
	declare tmpcure int local 0

	if !${Me.Group[${gMember}].ToActor(exists)} || ${Me.Group[${gMember}].ToActor.IsDead}
		return

	do
	{
		if ${Me.Group[${gMember}].Arcane}>0 || ${Me.Group[${gMember}].Noxious}>0 || ${Me.Group[${gMember}].Elemental}>0 || ${Me.Group[${gMember}].Trauma}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}
			wait 2
		}
		tmpcure:Inc
	}
	while ${Me.Group[${gMember}].IsAfflicted} && ${CureMode} && ${tmpcure:Inc}<4 && ${Me.Group[${gMember}].ToActor(exists)} && !${Me.Group[${gMember}].ToActor.IsDead}
}

