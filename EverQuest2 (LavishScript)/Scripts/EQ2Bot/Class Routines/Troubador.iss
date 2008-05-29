;*****************************************************
;Troubador.iss 20070905a
;by Karye
;updated by Pygar
;
;20080426a (Zeek)
; Reworked combat code to improve overall DPS
; Added DebuffMitMode.  Seperated debuffs into 2 categories, Mitigation debuffs (which are good to use
;  on all mobs) and Mob Offense buffs (which are good to use on epics and named etc).
; Added FullDebuffNamed.  This will use both Mitigation Debuffs and Offensive Debuffs on named mobs no matter
;  the state of DebuffMitMode or DebuffMode.
; Removed the Aria Cancel.
; Will not try to use JCap if on the move.
; Added Jcap Notification
;
;20070905a
; Removed Weaponswap as no longer required
; Moved Aria Cancel in Mez routine.  Now only cancels when a mob is found to be mezed.  Will maintain Aria until mez is required.
;
;20070725a
; Updated for new AA weapon requirements
;
;20070524a (Pygar)
;Charmtarget stickiness removed, wont charm / mez MA's current target anymore
;OffenseMode is now defaulted true
;Misc updates for maintanence.
;
;20061202a (kayre)
;Implemented EoF AAs
;Implemented EQ2Botlib cyrstalized spirit use
;Added EoF Mastery strikes
;*****************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
    ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
    declare ClassFileVersion int script 20080408
    ;;;;

	declare OffenseMode bool script 1
	declare DebuffMode bool script 0
	declare DebuffMitMode bool script 1
	declare FullDebuffNamed bool script 1
	declare AoEMode bool script 0
	declare MezzMode bool script 0
	declare BowAttacksMode bool script 0
	declare RangedAttackMode bool script 0

	declare BuffDefense bool script FALSE
	declare BuffPower bool script FALSE
	declare BuffArcane bool script FALSE
	declare BuffElemental bool script FALSE
	declare BuffHaste bool script FALSE
	declare BuffHealth bool script FALSE
	declare BuffReflection bool script FALSE
	declare BuffAria bool script FALSE
	declare BuffStamina bool script FALSE
	declare BuffCasting bool script FALSE
	declare BuffHate bool script FALSE
	declare BuffSelf bool script FALSE

	declare Charm bool script FALSE
	;Initialized by UI
	declare BuffJesterCapTimers collection:int script
	declare BuffJesterCapIterator iterator script
	declare BuffJesterCapMember int script 1

	declare mezTarget1 int script
	declare mezTarget2 int script
	declare CharmTarget int script

	call EQ2BotLib_Init

	OffenseMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,TRUE]}]
	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	DebuffMitMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Mit Debuff Spells,TRUE]}]
	FullDebuffNamedMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Named Debuff Spells,TRUE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	MezzMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Mezz Mode,FALSE]}]
	Charm:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Charm,FALSE]}]
	BowAttacksMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Bow Attack Spells,FALSE]}]
	RangedAttackMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Ranged Attacks Only,FALSE]}]
	JoustMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Listen to Joust Calls,FALSE]}]

	BuffDefense:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Defense","FALSE"]}]
	BuffPower:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Power","FALSE"]}]
	BuffArcane:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Arcane","FALSE"]}]
	BuffElemental:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Elemental","FALSE"]}]
	BuffHaste:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Haste","FALSE"]}]
	BuffHealth:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Health","FALSE"]}]
	BuffReflection:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Reflection","FALSE"]}]
	BuffAria:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Aria","FALSE"]}]
	BuffStamina:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Stamina","FALSE"]}]
	BuffCasting:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Casting","FALSE"]}]
	BuffHate:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Hate","FALSE"]}]
	BuffSelf:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Buff Self","FALSE"]}]

	PosionCureItem:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Poison Cure Item","Antivenom Hypo Bracer"]}]

	BuffJesterCap:GetIterator[BuffJesterCapIterator]

}

function Buff_Init()
{
	PreAction[1]:Set[Buff_Defense]
	PreSpellRange[1,1]:Set[20]

	PreAction[2]:Set[Buff_Power]
	PreSpellRange[2,1]:Set[21]

	PreAction[3]:Set[Buff_Arcane]
	PreSpellRange[3,1]:Set[22]

	PreAction[4]:Set[Buff_Elemental]
	PreSpellRange[4,1]:Set[23]

	PreAction[5]:Set[Buff_Haste]
	PreSpellRange[5,1]:Set[24]

	PreAction[6]:Set[Buff_Health]
	PreSpellRange[6,1]:Set[25]

	PreAction[7]:Set[Buff_Reflection]
	PreSpellRange[7,1]:Set[26]

	PreAction[8]:Set[Buff_Aria]
	PreSpellRange[8,1]:Set[27]

	PreAction[9]:Set[Buff_Stamina]
	PreSpellRange[9,1]:Set[28]

	PreAction[10]:Set[Buff_Casting]
	PreSpellRange[10,1]:Set[29]

	PreAction[11]:Set[Buff_Hate]
	PreSpellRange[11,1]:Set[30]

	PreAction[12]:Set[Buff_Self]
	PreSpellRange[12,1]:Set[31]

	PreAction[13]:Set[Buff_AAAllegro]
	PreSpellRange[13,1]:Set[390]

	PreAction[14]:Set[Buff_AADontKillTheMessenger]
	PreSpellRange[14,1]:Set[395]

	PreAction[15]:Set[Buff_AAHarmonization]
	PreSpellRange[15,1]:Set[383]

	PreAction[16]:Set[Buff_AAResonance]
	PreSpellRange[16,1]:Set[382]

	PreAction[17]:Set[Selos]
	PreSpellRange[17,1]:Set[381]

	PreAction[18]:Set[Buff_AAFortissimo]
	PreSpellRange[18,1]:Set[398]

}

function Combat_Init()
{
	Action[1]:Set[Bow_Attack]
	SpellRange[1,1]:Set[250]

	Action[2]:Set[Combat_Buff]
	SpellRange[2,1]:Set[155]

	Action[3]:Set[Nuke2]
	SpellRange[3,1]:Set[61]

	Action[4]:Set[AoE1]
	SpellRange[4,1]:Set[90]

	Action[5]:Set[AoE2]
	SpellRange[5,1]:Set[91]

	Action[6]:Set[AoE3]
	SpellRange[6,1]:Set[92]

	Action[7]:Set[Mastery]
	SpellRange[7,1]:Set[360]
	SpellRange[7,2]:Set[379]

	Action[8]:Set[Nuke1]
	SpellRange[8,1]:Set[60]

	Action[9]:Set[Melee_Attack1]
	SpellRange[9,1]:Set[151]

	Action[10]:Set[Flank_Attack]
	SpellRange[10,1]:Set[110]

	Action[11]:Set[Stealth_Attack]
	SpellRange[11,1]:Set[391]
	SpellRange[11,2]:Set[130]

	Action[12]:Set[Melee_Attack2]
	SpellRange[12,1]:Set[152]

	Action[13]:Set[Nuke2]
	SpellRange[13,1]:Set[61]

	Action[14]:Set[AARhythm_Blade]
	SpellRange[14,1]:Set[397]

	Action[15]:Set[Stun]
	SpellRange[15,1]:Set[190]

	Action[16]:Set[Debuff2]
	SpellRange[16,1]:Set[50]

	Action[17]:Set[AAHarmonizing_Shot]
	SpellRange[17,1]:Set[386]

}


function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{

	call ActionChecks

	call CheckHeals

	ExecuteAtom CheckStuck

	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	{
	    ExecuteAtom AutoFollowTank
		wait 5
	}

	if ${BDStatus} && ${Me.Ability[${SpellType[388]}].IsReady}
	{
		call CastSpellRange 388
		wait 5
		if ${Me.Maintained[${SpellType[388]}](exists)}
		{
			eq2execute /gsay BladeDance is up - 30 Seconds AoE Immunity for my group!
			BDStatus:Set[0]
		}

	}

	switch ${PreAction[${xAction}]}
	{
		case Buff_Defense
			if ${BuffDefense}
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

		case Buff_Arcane
			if ${BuffArcane}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break

		case Buff_Elemental
			if ${BuffElemental}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break

		case Buff_Haste
			if ${BuffHaste}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break

		case Buff_Health
			if ${BuffHealth}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break

		case Buff_Reflection
			if ${BuffReflection}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break

		case Buff_Aria
			if ${BuffAria}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break

		case Buff_Stamina
			if ${BuffStamina}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break

		case Buff_Casting
			if ${BuffCasting}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break

		case Buff_Hate
			if ${BuffHate}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
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

		case Buff_AAAllegro
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Selos
		case Buff_AAHarmonization
		case Buff_AAFortissimo
		case Buff_AAResonance
		case Buff_AADontKillTheMessenger
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
	declare DebuffCnt int  0

	AutoFollowingMA:Set[FALSE]
	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}

	if ${JoustMode}
	{
		if ${JoustStatus}==0 && ${RangedAttackMode}==1
		{
			;We've changed to in from an out status.
			RangedAttackMode:Set[0]
			EQ2Execute /toggleautoattack

			;if we're too far from killtarget, move in
			if ${Actor[${KillTarget}].Distance}>2
			{
				call CheckPosition 1 1
				wait 15
			}

		}
		elseif ${JoustStatus}==1 && ${RangedAttackMode}==0 && !${Me.Maintained[${SpellType[388]}](exists)} && !${Me.Maintained[${SpellType[387]}](exists)}
		{
			;We've changed to out from an in status.

			;if aoe avoidance is up, use it
			if ${Me.Ability[${SpellType[388]}].IsReady}
			{
				call CastSpellRange 388
				if ${AnnounceMode} && ${Me.Maintained[${SpellType[388]}](exists)}
				{
					eq2execute /gsay BladeDance is up - 30 Seconds AoE Immunity for my group!
				}
			}
			elseif ${Me.Ability[${SpellType[387]}].IsReady}
			{
				call CastSpellRange 387 0 1 0 ${KillTarget}
			}
			else
			{
				RangedAttackMode:Set[1]
				EQ2Execute /togglerangedattack

				;if we're not at our healer, lets move to him
				call FindHealer

				echo Healer - ${return}
				if ${Actor[${Return}].Distance}>2
				{
					call FastMove ${Actor[${return}].X} ${Actor[${return}].Z} 1
					wait 15
				}

			}
		}
	}

	if ${BDStatus} && ${Me.Ability[${SpellType[388]}].IsReady}
	{
		call CastSpellRange 388
		wait 5
		if ${Me.Maintained[${SpellType[388]}](exists)}
		{
			eq2execute /gsay BladeDance is up - 30 Seconds AoE Immunity for my group!
			BDStatus:Set[0]
		}
	}

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${DoHOs}
	{
		call CastSpellRange 303
	}

	if ${MezzMode}
	{
		call Mezmerise_Targets
	}

	if ${Charm}
	{
		call DoCharm
	}

	call PetAttack

	if !${Me.IsMoving}
		call DoJesterCap

	call CheckHeals

	if ${Actor[ID,${KillTarget}].Distance}>5 && !${RangedAttackMode} && ${Actor[${MainAssist}].Distance}<=${MARange} &&  ${Math.Distance[MA.X, MA,Z, Target.X, Target.Z]}<=8
		call CheckPosition 1 1

	if ${DebuffMitMode} || ${FullDebuffNamed}
	{
		if !${Me.Maintained[${SpellType[57]}](exists)} && ${Me.Ability[${SpellType[57]}].IsReady} && ${DebuffCnt}<1
		{
			call CastSpellRange 57 0 2 0 ${KillTarget} 0 0 1
			DebuffCnt:Inc
		}
		if !${Me.Maintained[${SpellType[51]}](exists)} && ${Me.Ability[${SpellType[51]}].IsReady} && !${RangedAttackMode} && ${DebuffCnt}<1
		{
			call CastSpellRange 51 0 1 0 ${KillTarget} 0 0 1
			DebuffCnt:Inc
		}
	}

	if (${DebuffMode} || ${FullDebuffNamed}) && ${DebuffCnt}<1
	{
		if !${Me.Maintained[${SpellType[55]}](exists)} && ${Me.Ability[${SpellType[55]}].IsReady} && ${DebuffCnt}<1
		{
			call CastSpellRange 55 0 2 0 ${KillTarget} 0 0 1
			DebuffCnt:Inc
		}
		if !${Me.Maintained[${SpellType[56]}](exists)} && ${Me.Ability[${SpellType[56]}].IsReady} && ${DebuffCnt}<1
		{
			call CastSpellRange 56 0 2 0 ${KillTarget} 0 0 1
			DebuffCnt:Inc
		}
		if !${Me.Maintained[${SpellType[58]}](exists)} && ${Me.Ability[${SpellType[58]}].IsReady} && ${DebuffCnt}<1
		{
			call CastSpellRange 56 0 2 0 ${KillTarget} 0 0 0
			DebuffCnt:Inc
		}
	}

	call ActionChecks

	; PoTM
	if !${Me.Maintained[${SpellType[155]}](exists)} && ${Me.Ability[${SpellType[155]}].IsReady} && (${Actor[${KillTarget}].Health}>=40 || ${Actor[${KillTarget}].Type.Equal[NamedNPC]})
	{
		call CastSpellRange 155 0 2 0 ${KillTarget} 0 0 0
		return
	}

	if ${OffenseMode}
	{
		; AoE+Dot
		if !${Me.Maintained[${SpellType[91]}](exists)} && ${Me.Ability[${SpellType[91]}].IsReady}
		{
			call CastSpellRange 91 0 2 0 ${KillTarget} 0 0 1
			return
		}

		; Master Strike
		if ${Me.Ability[Sinister Strike].IsReady} && !${RangedAttackMode} && !${InvalidMasteryTargets.Element[${Target.ID}](exists)}
		{
			Target ${KillTarget}
			call CheckPosition 1 1
			Me.Ability[Sinister Strike]:Use
			do
			{
				waitframe
			}
			while ${Me.CastingSpell}
			wait 1
		}

		; Flank debuff
		if ${Me.Ability[${SpellType[110]}].IsReady} && !${RangedAttackMode}
		{
			call CastSpellRange 110 0 1 1 ${KillTarget} 0 0 1
			;return
		}

		; Long casting AoE - Good for setting off proc gear
		if ${Me.Ability[${SpellType[92]}].IsReady}
		{
			call CastSpellRange 92 0 2 0 ${KillTarget} 0 0 1
			return
		}

		; Long Cast Nuke - Good for setting off proc gear - Mainstay of your damage
		if ${Me.Ability[${SpellType[61]}].IsReady} && ${Actor[id, ${KillTarget}].Distance}<=${Me.Ability[${SpellType[61]}].Range}
		{
			call CastSpellRange 61 0 2 0 ${KillTarget} 0 0 1
			return
		}

		; Stealth Attack Combo
		; Check if we have the bump AA and use it to stealth us, if we do not, skip it entirely
		if ${Me.Ability[${SpellType[391]}](exists)} && ${Me.Ability[${SpellType[391]}].IsReady} && !${RangedAttackMode}
		{
			call CastSpellRange 391 0 1 1 ${KillTarget}
			wait 3
			call CastSpellRange 130 0 1 1 ${KillTarget}
			return
		}

		; Fast Cast Nuke
		if ${Me.Ability[${SpellType[60]}].IsReady}
		{
			call CastSpellRange 60 0 2 0 ${KillTarget} 0 0 1
			return
		}

		; De-agro if not MainTank
		if ${Me.Ability[${SpellType[180]}].IsReady} && !${MainTank}
		{
			call CastSpellRange 180 0 2 0 ${KillTarget} 0 0 0
			return
		}

		; Low Damage Power Tap
		if ${Me.Ability[${SpellType[62]}].IsReady}
		{
			call CastSpellRange 62 0 2 0 ${KillTarget} 0 0 0
			return
		}

		; Moderate Melee Attack
		if ${Me.Ability[${SpellType[151]}].IsReady} && !${RangedAttackMode}
		{
			call CastSpellRange 151 0 2 0 ${KillTarget} 0 0 1
			return
		}
	}

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}

	switch ${Action[${xAction}]}
	{
		case AATurnstrike
			if !${RangedAttackMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Type.Equal[NamedNPC]})
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break

		case AARhythm_Blade
			if !${RangedAttackMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break

		case AAHarmonizing_Shot
		case Bow_Attack
			if ${BowAttacksMode}
			{
				if ${Target.Distance}>35
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 3 0 ${KillTarget}
				}
				else
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
			}
			break

		case Stun
			if !${RangedAttackMode} && !${Actor[${KillTarget}].IsEpic}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break

		Default
			return CombatComplete
			break
	}



}

function Post_Combat_Routine(int xAction)
{
	mezTarget1:Set[0]
	mezTarget2:Set[0]
	CharmTarget:Set[0]

	;turn off percisions of the maestro
	if ${Me.Maintained[${SpellType[155]}](exists)}
	{
		Me.Maintained[${SpellType[155]}]:Cancel
	}

	;cancel stealth
	if ${Me.ToActor.Effect[Shroud](exists)} || ${Me.Maintained[Shroud](exists)}
	{
		Me.Maintained[Shroud]:Cancel
	}

	;reset rangedattack in case it was modified by joust call.
	JoustMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Listen to Joust Calls,FALSE]}]
	RangedAttackMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Ranged Attacks Only,FALSE]}]

	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
			break
	}

}

function Have_Aggro()
{

	;if ${Me.AutoAttackOn}
	;{
	;	EQ2Execute /toggleautoattack
	;}

	;Cast evade if we get agro from the MT

	if ${agroid}==${KillTarget}
	{
		;evade
		call CastSpellRange 180 0 0 0 ${agroid}
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
		call UseCrystallizedSpirit 60
}

function ActionChecks()
{
	if ${ShardMode}
	{
		call Shard
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
			if ${CustomActor[${tcount}].ID}==${mezTarget1} || ${CustomActor[${tcount}].ID}==${mezTarget2} || ${Actor[${MainTankPC}].Target.ID}==${CustomActor[${tcount}].ID}
			{
				continue
			}


			if ${Mob.Target[${CustomActor[${tcount}].ID}]}
			{

				if ${Me.AutoAttackOn}
				{
					eq2execute /toggleautoattack
				}

				if ${Me.RangedAutoAttackOn}
				{
					eq2execute /togglerangedattack
				}

				;shut off aria so encounter debuffs dont break mezz
				;if ${Me.Maintained[${SpellType[27]}](exists)}
				;{
				;	Me.Maintained[${SpellType[27]}]:Cancel
				;}

				call CastSpellRange 352 0 0 0 ${CustomActor[${tcount}].ID} 0 15
			}
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}

	if ${Actor[${KillTarget}](exists)} && !${Actor[${KillTarget}].IsDead} && ${Mob.Detect}
	{
		Target ${KillTarget}
		wait 20 ${Me.ToActor.Target.ID}==${KillTarget}
	}
	else
	{
		EQ2Execute /target_none
		KillTarget:Set[]
	}
}

function DoCharm()
{
	declare tcount int local
	declare tempvar int local
	declare aggrogrp bool local FALSE

	tempvar:Set[1]

	if ${Me.Maintained[${SpellType[351]}](exists)}
	{
		return
	}

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


			if ${Mob.Target[${CustomActor[${tcount}].ID}]}
			{
				CharmTarget:Set[${CustomActor[${tcount}].ID}]
				break
			}
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}

	if ${Actor[${CharmTarget}](exists)} && ${CharmTarget}!=${mezTarget1} && ${CharmTarget}!=${mezTarget2} && ${Actor[${MainAssist}].Target.ID}!=${CharmTarget} && ${aggrogrp}
	{
		call CastSpellRange 351 0 0 0 ${CharmTarget}

		if ${Actor[${KillTarget}](exists)} && (${Me.Maintained[${SpellType[351]}].Target.ID}!=${KillTarget}) && ${Me.Maintained[${SpellType[351]}](exists)} && !${Actor[${KillTarget}].IsDead}
		{
			call PetAttack
		}
		else
		{
			EQ2Execute /target_none
		}
	}
}




function Cure()
{
	if !${Swapping} || ${Me.Equipment[LWrist].Name.Equals[${PosionCureItem}]}
	{
		OriginalItem:Set[${Me.Equipment[LWrist].Name}]
		ItemToBeEquipped:Set[${PosionCureItem}]
		call Swap
		Me.Equipment[${PosionCureItem}]:Use
	}
}

function DoJesterCap()
{
	variable string JCActor=${UIElement[lbBuffJesterCap@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${BuffJesterCapMember}].Text}
	if ${Me.Ability[${SpellType[156]}].IsReady}
	{

		if ${UIElement[lbBuffJesterCap@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
		{
			if ${Actor[${JCActor.Token[2,:]},${JCActor.Token[1,:]}].Distance}<25
			{
				;Jester Cap immunity is 2 mins so make sure we havn't cast on this Actor in the past 120 seconds
				if ${Math.Calc[${Time.Timestamp} - ${BuffJesterCapTimers.Element[${JCActor}]}]}>120
				{
					call CastSpellRange 156 0 0 0 ${Actor[${JCActor.Token[2,:]},${JCActor.Token[1,:]}].ID}
					if ${Return} != -1 && ${Me.Maintained[${SpellType[156]}](exists)}
					{
						eq2execute /tell ${JCActor.Token[1,:]} "You've been J-Capped!"
						;if we successfully cast Jester Cap, Add/Update the collection with the current timestamp
						BuffJesterCapTimers:Set[${JCActor}, ${Time.Timestamp}]
						BuffJesterCapMember:Inc
					}
				}
				else
				{
					;they still have immunity so advance to next
					BuffJesterCapMember:Inc
				}
			}
			else
			{
				;they are further than jester cap range so advance to next
				BuffJesterCapMember:Inc
			}
			;we have gone through everyone in the list so start back at the begining
			if ${BuffJesterCapMember}>${UIElement[lbBuffJesterCap@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			{
				BuffJesterCapMember:Set[1]
			}
		}

	}
}



