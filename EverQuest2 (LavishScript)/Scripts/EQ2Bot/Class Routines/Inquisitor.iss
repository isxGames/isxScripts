;*************************************************************
;Inquisitor.iss
;version 20090622a (Pygar)
;
;20090622
;	Update for TSO AA and GU 52 spell changes
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
; Implemented EoF Mastery Spells
; Implemented EoF AA Maldroit
; Implemented EoF AA Battle Cleric Line
; Implemented Vampire Spell Theft of Vitae
; Implemented Symbol of Corruption
; Implemented Crystalize Spirit Healing
; Fixed a bug with curing uncurable afflictions
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
  ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
  declare ClassFileVersion int script 20090622
  ;;;;

	;UIElement[EQ2Bot Tabs@EQ2 Bot]:AddTab[Buffs]
	;UIElement[EQ2Bot Tabs@EQ2 Bot].Tab[Buffs]:Move[4]
	;ui -load -parent "Buffs@EQ2Bot Tabs@EQ2 Bot" -skin eq2 "${PATH_UI}/${Me.SubClass}_Buffs.xml"

	declare OffenseMode bool script
	declare DebuffMode bool script
	declare AoEMode bool script
	declare CureMode bool script
	declare CurseMode bool script
	declare ConvertMode bool script
	declare YaulpMode bool script
	declare FanaticismMode bool script
 	declare PreHealMode bool script 0
	declare KeepReactiveUp bool script
	declare KeepGroupReactiveUp bool script
	declare MezzMode bool script
	declare BattleClericMode bool Script
	declare InquisitionMode bool script
	declare Stance int script 1

	declare BuffArcane bool script FALSE
	declare BuffMitigation bool script FALSE
	declare BuffProc bool script FALSE
	declare BuffDPS collection:string script
	declare BuffAuraGroupMember string script
	declare BuffShieldAllyGroupMember string script

	declare EquipmentChangeTimer int script

	call EQ2BotLib_Init

	OffenseMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Offensive Spells,FALSE]}]
	DebuffMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	CureMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Cure Spells,FALSE]}]
	CurseMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Cusre Spells,FALSE]}]
	ConvertMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Convert Mode,FALSE]}]
	YaulpMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Yaulp Mode,FALSE]}]
	FanaticismMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Fanaticism Mode,FALSE]}]
	KeepReactiveUp:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[KeepReactiveUp,FALSE]}]
	KeepGroupReactiveUp:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[KeepGroupReactiveUp,FALSE]}]
	MezzMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Mezz Mode,FALSE]}]
	BattleClericMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BattleCleric Mode,FALSE]}]
	InquisitionMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Inquisition Mode,FALSE]}]
	Stance:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Stance,]}]

	BuffArcane:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffArcane,TRUE]}]
	BuffMitigation:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffMitigation,TRUE]}]
	BuffProc:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffProc,TRUE]}]
	BuffAuraGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffAuraGroupMember,]}]
	BuffShieldAllyGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffShieldAllyGroupMember,]}]
}

function Pulse()
{
	;;;;;;;;;;;;
	;; Note:  This function will be called every pulse, so intensive routines may cause lag.  Therefore, the variable 'ClassPulseTimer' is
	;;        provided to assist with this.  An example is provided.
	;
	;			if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+2000]})
	;			{
	;				Debug:Echo["Anything within this bracket will be called every two seconds.
	;			}
	;
	;         Also, do not forget that a 'pulse' of EQ2Bot may take as long as 2000 ms.  So, even if you use a lower value, it may not be called
	;         that often (though, if the number is lower than a typical pulse duration, then it would automatically be called on the next pulse.)
	;;;;;;;;;;;;

	;; check this at least every 0.5 seconds
	if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+500]})
	{
		call CheckHeals

		if ${Me.ToActor.Power}>85 && ${KeepReactiveUp}
			call CheckReactives

		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[BuffDPS]
	PreSpellRange[1,1]:Set[35]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]

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

	PreAction[9]:Set[AA_Stance]
	PreSpellRange[9,1]:Set[508]
	PreSpellRange[9,2]:Set[507]
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

	Action[6]:Set[AA_HammerSmite]
	SpellRange[6,1]:Set[391]

	Action[7]:Set[TheftOfVitality]
	MobHealth[7,1]:Set[1]
	MobHealth[7,2]:Set[100]
	Power[7,1]:Set[20]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[56]

	Action[8]:Set[Absolving_Flames]
	MobHealth[8,1]:Set[20]
	MobHealth[8,2]:Set[100]
	Power[8,1]:Set[40]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[70]

	Action[9]:Set[Affliction]
	MobHealth[9,1]:Set[20]
	MobHealth[9,2]:Set[100]
	Power[9,1]:Set[40]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[71]

	Action[10]:Set[AA_SkullCrack]
	SpellRange[10,1]:Set[387]

	Action[11]:Set[AoE]
	MobHealth[11,1]:Set[1]
	MobHealth[11,2]:Set[100]
	Power[11,1]:Set[30]
	Power[11,2]:Set[100]
	SpellRange[11,1]:Set[90]

	Action[12]:Set[Proc]
	MobHealth[12,1]:Set[40]
	MobHealth[12,2]:Set[100]
	Power[12,1]:Set[40]
	Power[12,2]:Set[100]
	SpellRange[12,1]:Set[337]

	Action[13]:Set[SymbolOfCorruption]
	MobHealth[13,1]:Set[10]
	MobHealth[13,2]:Set[100]
	Power[13,1]:Set[30]
	Power[13,2]:Set[100]
	SpellRange[13,1]:Set[57]

	Action[14]:Set[Stifle]
	MobHealth[14,1]:Set[1]
	MobHealth[14,2]:Set[100]
	Power[14,1]:Set[30]
	Power[14,2]:Set[100]
	SpellRange[14,1]:Set[260]

	Action[15]:Set[Counterattack]
	MobHealth[15,1]:Set[40]
	MobHealth[15,2]:Set[100]
	Power[15,1]:Set[40]
	Power[15,2]:Set[100]
	SpellRange[15,1]:Set[336]

	Action[16]:Set[AA_DivineCastigation]
	MobHealth[16,1]:Set[1]
	MobHealth[16,2]:Set[100]
	Power[16,1]:Set[30]
	Power[16,2]:Set[100]
	SpellRange[16,1]:Set[395]

	Action[17]:Set[PreKill]
	MobHealth[17,1]:Set[5]
	MobHealth[17,2]:Set[15]
	Power[17,1]:Set[30]
	Power[17,2]:Set[100]
	SpellRange[17,1]:Set[312]
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
	
	; Pass out feathers on initial script startup
if !${InitialBuffsDone}
{
	if (${Me.GroupCount} > 1)
	{
		call CastSpellRange 339
		InitialBuffsDone:Set[TRUE]
  }
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
					if ${UIElement[EQ2 Bot].FindUsableChild[lbBuffDPS,listbox].SelectedItems}>0
					{
						tempvar:Set[1]
						do
						{

							BuffTarget:Set[${UIElement[EQ2 Bot].FindUsableChild[lbBuffDPS,listbox].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[exactname,${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}
						}
						while ${tempvar:Inc}<=${UIElement[EQ2 Bot].FindUsableChild[lbBuffDPS,listbox].SelectedItems}
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
			if ${UIElement[EQ2 Bot].FindUsableChild[lbBuffDPS,listbox].SelectedItems}>0
			{
				do
				{
					BuffTarget:Set[${UIElement[EQ2 Bot].FindUsableChild[lbBuffDPS,listbox].SelectedItem[${Counter}].Text}]
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[exactname,${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				}
				while ${Counter:Inc}<=${UIElement[EQ2 Bot].FindUsableChild[lbBuffDPS,listbox].SelectedItems}
			}
			break
		case Self_Buff
			if ${ConvertMode}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case AA_Stance
			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},${Stance}]}]}](exists)})
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},${Stance}]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},${Stance}]}
			}
			break
		case BuffAura
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.Name.Equal[${BuffAuraGroupMember.Token[1,:]}]}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffAuraGroupMember.Token[2,:]},${BuffAuraGroupMember.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[exactname,${BuffAuraGroupMember.Token[2,:]},${BuffAuraGroupMember.Token[1,:]}].ID}
			break
		case BuffShieldAlly
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.Name.Equal[${BuffShieldAllyGroupMember.Token[1,:]}]}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffShieldAllyGroupMember.Token[2,:]},${BuffShieldAllyGroupMember.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[exactname,${BuffShieldAllyGroupMember.Token[2,:]},${BuffShieldAllyGroupMember.Token[1,:]}].ID}
			break
		case BuffArcane
			if ${BuffArcane}
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
		case BuffProc
			if ${BuffProc}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		default
			return Buff Complete
			break
	}
}

function Combat_Routine(int xAction)
{
	if (!${RetainAutoFollowInCombat} && ${Me.ToActor.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}
	
	if ${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}
		call CastSpellRange 396

	call CheckGroupHealth 75
	if ${DoHOs} && ${Return}
		objHeroicOp:DoHO

	if !${EQ2.HOWindowActive} && ${Me.InCombat}
		call CastSpellRange 303

	if ${MezzMode}
		call Mezmerise_Targets

	if ${CureMode}
		call CheckCures

	call CheckHeals
	call RefreshPower
	call Yaulp
	call Fanaticism
	call CastVerdict

	if ${ShardMode}
		call Shard

	;echo BattleClericMode is ${BattleClericMode}
	if ${BattleClericMode}
		call CheckPosition 1 0 ${KillTarget}

	switch ${Action[${xAction}]}
	{
		case TheftOfVitality
		case Forced_Obedience
		case Debase
		case Convict
		case Maladroit
			if ${DebuffMode}
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
		case Counterattack
		case Proc
			if ${OffenseMode} && ${Mob.Count}>1
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
							call CastSpellRange 381 0 1 0 ${KillTarget}
						else
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
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
							call CastSpellRange 382 0 1 0 ${KillTarget}
						else
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
			}
			break
		case AA_SkullCrack
		case AA_HammerSmite
			if (${OffenseMode} || ${DebuffMode}) && ${BattleClericMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
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
							call CastSpellRange 383 0 1 0 ${KillTarget}
						else
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
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
							call CastSpellRange 379 0 1 0 ${KillTarget}
						else
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
						;Check for Battle Cleric Litany Circle
						if ${Me.Ability[${SpellType[505]}](exists)} && ${BattleClericMode}
							call CastSpellRange 505 0 1 0 ${KillTarget}
						else
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
			}
			break
		case PreKill
			if ${AoEMode} && ${Mob.Count}>1
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
		case AA_DivineCastigation
			if ${OffenseMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
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
			return CombatComplete
			break
	}
}

function Post_Combat_Routine(int xAction)
{
    declare tempgrp int 1
	TellTank:Set[FALSE]

	;turn off Yaulp
	if ${Me.Maintained[${SpellType[385]}](exists)}
		Me.Maintained[${SpellType[385]}]:Cancel

	;turn off fanaticism or zealotry
	if ${Me.Maintained[${SpellType[317]}](exists)}
		Me.Maintained[${SpellType[317]}]:Cancel

	; turn off auto attack if we were casting while the last mob died
	if ${Me.AutoAttackOn}
		EQ2Execute /toggleautoattack

	switch ${PostAction[${xAction}]}
	{
		case Resurrection
			tempgrp:Set[1]
			do
			{
				if ${Me.Group[${tempgrp}].ToActor.IsDead} && ${Me.Group[${tempgrp}](exists)}
					call CastSpellRange ${PostSpellRange[${xAction},1]} ${PostSpellRange[${xAction},2]} 0 0 ${Me.Group[${tempgrp}].ToActor.ID} 1
			}
			while ${tempgrp:Inc} <= ${Me.GroupCount}
			break
		default
			return PostCombatRoutineComplete
			break
	}
}

function RefreshPower()
{
	if ${Me.InCombat} && ${Me.ToActor.Power}<65  && ${Me.ToActor.Health}>25
		call UseItem "Helm of the Scaleborn"

	if ${Me.InCombat} && ${Me.ToActor.Power}<45
		call UseItem "Spiritise Censer"

	if ${Me.InCombat} && ${Me.ToActor.Power}<15
		call UseItem "Stein of the Everling Lord"

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

function CheckCures()
{
	declare temphl int local 1
	declare grpcure int local 0
	declare Affcnt int local 0

	;check for group cures, if it is ready and we are in a large enough group
	if ${Me.Ability[${SpellType[220]}].IsReady} && ${Me.GroupCount}>2
	{
		;check ourselves
		if ${Me.IsAfflicted}
		{
			;add ticks for group cures based upon our afflicions
			if ${Me.Arcane}>0 || ${Me.Elemental}>0
				grpcure:Inc
		}

		;loop group members, and check for group curable afflictions
		do
		{
			;make sure they in zone and in range
			if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].ToActor.Distance}<${Me.Ability[${SpellType[220]}].Range}
			{
				if ${Me.Group[${temphl}].Arcane}>0 || ${Me.Group[${temphl}].Elemental}>0
					grpcure:Inc
			}
		}
		while ${temphl:Inc} <= ${Me.GroupCount}

		if ${grpcure}>2
		{
			call CastSpellRange 220
			call CastSpellRange 221
		}
	}

	;Cure Ourselves first
  if ${Me.IsAfflicted} && (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Trauma}>0 || ${Me.Elemental}>0 || ${Me.Cursed})
		call CureMe


	;Cure Group Members - This will cure a single person unless epicmode is checkd on extras tab, in which case it will cure
	;	all afflictions unless group health or mt health gets low
	while ${Affcnt:Inc}<7 && ${Me.ToActor.Health}>30 && (${Me.Arcane}<1 && ${Me.Noxious}<1 && ${Me.Elemental}<1 && ${Me.Trauma}<1)
	{
		call FindAfflicted
		if ${Return}>0
			call CureGroupMember ${Return}
		else
			break

		;epicmode is set in eq2botextras, we will cure only one person per call unless in epic mode.
		if !${EpicMode}
			break

		;break if we need heals
		call CheckGroupHealth 30
		if !${Return}
			break

		;Check MT health and heal him if needed
		if ${Actor[pc,ExactName,${MainTankPC}].Health}<50
		{
			if ${Actor[pc,ExactName,${MainTankPC}].ID}==${Me.ID}
				call HealMe
			else
				call HealMT
		}
	}

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
		if ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.Distance}<=${Me.Ability[${SpellType[210]}].Range}
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
	while ${temphl:Inc} <= ${Me.GroupCount}

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

	while ${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0
	{
		if ${Me.Arcane}>0
		{
			AffCnt:Set[${Me.Arcane}]
			call CastSpellRange 210 0 0 0 ${Me.ID}
			wait 2

			;if we tried to cure and it failed to work, we might be charmed, use control cure
			if ${Me.Arcane}==${AffCnt}
				call CastSpellRange 326
		}

		if  ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.ID}
			wait 2
		}
	}
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
				call CastSpellRange 1 0 0 0 ${Me.ID}
			else
				call CastSpellRange 4 0 0 0 ${Me.ID}
		}
	}

	if ${Me.ToActor.Health}<75
	{
		if ${Actor[pc,ExactName,${MainTankPC}].ID}==${Me.ID} && ${Me.ToActor.InCombatMode}
			call CastSpellRange 7 0 0 0 ${Me.ID}
		else
			call CastSpellRange 4 0 0 0 ${Me.ID}
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
	declare MainTankExists bool local 1

	if ${Me.Name.Equal[${MainTankPC}]}
		MainTankID:Set[${Me.ID}]
	else
		MainTankID:Set[${Actor[PC,ExactName,${MainTankPC}].ID}]

    if !${Actor[${MainTankID}](exists)}
    {
        ;Debug:Echo["EQ2Bot-CheckHeals() -- MainTank does not exist! (MainTankID/MainTankPC: ${MainTankID}/${MainTankPC}"]
        MainTankExists:Set[FALSE]
    }
    else
        MainTankExists:Set[TRUE]


	;curses cause heals to do damage and must be cleared off healer
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	;Res the MT if they are dead
	if (${MainTankExists})
	{
   	if (!${Me.ToActor.InCombatMode} || ${CombatRez}) && ${Actor[${MainTankID}].IsDead}
   		call CastSpellRange 300 0 1 1 ${MainTankID}

   	if ${Actor[${MainTankID}].Health}<50 && ${Me.Ability[${SpellType[4]}].IsReady}
   		call CastSpellRange 4 0 0 0 ${MainTankID}
  }

	call CheckReactives

	if ${InquisitionMode} && ${Me.InCombat} && ${Me.Ability[${SpellType[11]}].IsReady} && !${Me.Maintained[${SpellType[11]}](exists)}
		call CastSpellRange 11 0 0 0 ${KillTarget}

  if ${Me.GroupCount} > 1
  {
		do
		{
			if ${Me.Group[${temphl}].ToActor(exists)}
			{
				if ${Me.Group[${temphl}].ToActor.Health}<100 && !${Me.Group[${temphl}].ToActor.IsDead}
				{
					if (${Me.Group[${temphl}].ToActor.Health}<${Me.Group[${lowest}].ToActor.Health} || ${lowest}==0) && ${Me.Group[${temphl}].ToActor.Distance}<=${Me.Ability[${SpellType[1]}].Range}
						lowest:Set[${temphl}]
				}

				if ${Me.Group[${temphl}].ID}==${MainTankID}
					MainTankInGroup:Set[1]

				if !${Me.Group[${temphl}].ToActor.IsDead} && ${Me.Group[${temphl}].ToActor.Health}<80 && ${Me.Group[${temphl}].ToActor.Distance}<=${Me.Ability[${SpellType[15]}].Range}
					grpheal:Inc

				if (${Me.Group[${temphl}].Class.Equal[conjuror]}  || ${Me.Group[${temphl}].Class.Equal[necromancer]}) && ${Me.Group[${temphl}].ToActor.Pet.Health}<60 && ${Me.Group[${temphl}].ToActor.Pet.Health}>0
					PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}

				if ${Me.ToActor.Pet.Health}<60
					PetToHeal:Set[${Me.ToActor.Pet.ID}]
			}
		}
		while ${temphl:Inc} <= ${Me.GroupCount}

		if ${Me.ToActor.Health}<80 && !${Me.ToActor.IsDead}
			grpheal:Inc
	}

	if ${grpheal}>2
		call GroupHeal

  if (${MainTankExists})
  {
  	if ${Actor[${MainTankID}].Health}<90
  	{
  		if ${Me.ID}==${MainTankID}
  			call HealMe
  		else
  			call HealMT ${MainTankID} ${MainTankInGroup}
  	}

  	;Check My health after MT
    if ${Me.ID}!=${MainTankID} && ${Me.ToActor.Health}<50
	    call HealMe
  }
  else
  {
    if ${Me.ToActor.Health}<70
      call HealMe
  }

	;now lets heal individual groupmembers if needed
	if ${lowest}
	{
		call UseCrystallizedSpirit 60

		if ${Me.Group[${lowest}].ToActor(exists)} && ${Me.Group[${lowest}].ToActor.Health}<70 && !${Me.Group[${lowest}].ToActor.IsDead} && ${Me.Group[${lowest}].ToActor.Distance}<=${Me.Ability[${SpellType[1]}].Range}
		{
			if ${Me.Ability[${SpellType[4]}].IsReady}
				call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
			else
				call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ToActor.ID}
		}
	}

	if ${EpicMode}
		call CheckCures

	;PET HEALS
	if ${PetToHeal} && ${Actor[ExactName,${PetToHeal}](exists)} && ${Actor[ExactName,${PetToHeal}].InCombatMode} && !${EpicMode}
		call CastSpellRange 4 0 0 0 ${PetToHeal}

	;Check Rezes
	if ${CombatRez} || !${Me.InCombat}
	{
		temphl:Set[1]
		do
		{
			if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.IsDead} && ${Me.Group[${temphl}].ToActor.Distance}<=20
			{
				if !${Me.InCombat} && ${Me.Ability[${SpellType[500]}].IsReady}
					call CastSpellRange 506 0 0 0 ${Me.Group[${temphl}].ID} 1 0 0 0 2 0
				else
					call CastSpellRange 300 303 1 0 ${Me.Group[${temphl}].ID} 1 0 0 0 2 0
			}
		}
		while ${temphl:Inc} <= ${Me.GroupCount}
	}
}

function HealMT(int MainTankID, int MTInMyGroup)
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	;MAINTANK EMERGENCY HEAL
	if ${Actor[${MainTankID}].Health}<30 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)}
		call EmergencyHeal ${MainTankID}

	;MAINTANK HEALS
	if ${Actor[${MainTankID}].Health}<50 && ${Actor[${MainTankID}](exists)} && !${Actor[${MainTankID}].IsDead}
	{
		if ${Me.Ability[${SpellType[4]}].IsReady}
			call CastSpellRange 4 0 0 0 ${MainTankID}
		else
			call CastSpellRange 1 0 0 0 ${MainTankID}
	}

	if ${Actor[${MainTankID}].Health}<70 && ${Actor[${MainTankID}](exists)} && !${Actor[${MainTankID}].IsDead}
	{
		if !${Me.Maintained[${SpellType[7]}](exists)} && ${Me.Ability[${SpellType[7]}].IsReady}
			call CastSpellRange 7 0 0 0 ${MainTankID}
		elseif !${Me.Maintained[${SpellType[15]}](exists)} && ${Me.Ability[${SpellType[15]}].IsReady}
			call CastSpellRange 15 0 0 0 ${MainTankID}

		if ${Me.Ability[${SpellType[1]}].IsReady} && ${Actor[${MainTankID}].Health}<70
			call CastSpellRange 1 0 0 0 ${MainTankID}
		elseif ${Me.Ability[${SpellType[4]}].IsReady} && ${Actor[${MainTankID}].Health}<70
			call CastSpellRange 4 0 0 0 ${MainTankID}
	}

	if ${Actor[${MainTankID}].Health}<90 && ${Actor[${MainTankID}](exists)} && !${Actor[${MainTankID}].IsDead}
	{
		if ${MTInMyGroup} && ${EpicMode} && ${Me.Ability[${SpellType[15]}].IsReady} && !${Me.Maintained[${SpellType[15]}](exists)}
			call CastSpellRange 15
		elseif !${Me.Maintained[${SpellType[7]}](exists)}
			call CastSpellRange 7 0 0 0 ${MainTankID}

		if ${Me.Ability[${SpellType[7]}].IsReady} && !${Me.Maintained[${SpellType[7]}](exists)} && ${EpicMode}
			call CastSpellRange 7 0 0 0 ${MainTankID}
	}
}

function GroupHeal()
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	if ${Me.Ability[${SpellType[10]}].IsReady}
		call CastSpellRange 10
	else
		call CastSpellRange 15
}

function CureGroupMember(int gMember)
{
	declare tmpcure int local 0

	if !${Me.Group[${gMember}].ToActor(exists)} || ${Me.Group[${gMember}].ToActor.IsDead} || !${Me.Group[${gMember}].IsAfflicted} || ${Me.Group[${gMember}].ToActor.Distance}>${Me.Ability[${SpellType[210]}].Range}
		return

	while ${Me.Group[${gMember}].IsAfflicted} && ${CureMode} && ${tmpcure:Inc}<6 && ${Me.Group[${gMember}].ToActor(exists)} && !${Me.Group[${gMember}].ToActor.IsDead}
	{
		if ${Me.Group[${gMember}].Arcane}>0 || ${Me.Group[${gMember}].Noxious}>0 || ${Me.Group[${gMember}].Elemental}>0 || ${Me.Group[${gMember}].Trauma}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}
			wait 2
		}
	}
}

function CheckReactives()
{
	declare tempvar int local 1
	declare hot1 int local 0
	declare grphot int local 0
	hot1:Set[0]
	grphot:Set[0]

	if ${KeepReactiveUp} || ${KeepGroupReactiveUp} || ${PreHealMode}
	{
		do
		{
			if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[7]}]} && ${Me.Maintained[${tempvar}].Target.ID}==${Actor[pc,exactname,${MainTankPC}].ID}
			{
				;echo Single react is Present on MT
				hot1:Set[1]
			}
			elseif ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[15]}]}
			{
				;echo Group react is Present
				grphot:Set[1]
			}
		}
		while ${tempvar:Inc}<=${Me.CountMaintained}

		if ${KeepReactiveUp} || ${PreHealMode}
		{
			if ${hot1}==0 && ${Me.Power}>${Me.Ability[${SpellType[7]}].PowerCost}
			{
				call CastSpellRange 7 0 0 0 ${Actor[pc,exactname,${MainTankPC}].ID}
				hot1:Set[1]
			}
		}

		if ${KeepGroupReactiveUp} || ${PreHealMode}
		{
			if ${grphot}==0 && ${Me.Power}>${Me.Ability[${SpellType[15]}].PowerCost}
				call CastSpellRange 15
		}
	}
}

function EmergencyHeal(int healtarget)
{
	if ${Me.Ability[${SpellType[401]}].IsReady}
	{
		call CastSpellRange 401 0 0 0 ${healtarget}
	}
	else
	{
		call CastSpellRange 338 0 0 0 ${healtarget}
	}

	if ${Me.Ability[${SpellType[335]}].IsReady}
		call CastSpellRange 335 0 0 0 ${healtarget}
	else
		call CastSpellRange 334 0 0 0 ${healtarget}

}

function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{

}

function MA_Dead()
{
	if ${Actor[${MainTankPC}].IsDead} && ${Actor[${MainTankPC}](exists)}
		call 300 301 1 0 ${Actor[exactname,${MainTankPC}].ID} 1
}

function Cancel_Root()
{

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
				continue

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
				aggrogrp:Set[TRUE]


			if ${aggrogrp}
			{
				if ${Me.AutoAttackOn}
					eq2execute /toggleautoattack

				if ${Me.RangedAutoAttackOn}
					eq2execute /togglerangedattack

				;check for wonderous buckling
				if ${Me.Ability[${SpellType[386]}](exists)}
				{
					;check if we have a our buckler equipped if not equip and cast wonderous buckling
					if ${Me.Equipment[2].Name.Equal[${Buckler}]}
						call CastSpellRange 386 0 1 0 ${CustomActor[${tcount}].ID}
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
			EQ2Execute /toggleautoattack

		if  !${Me.CastingSpell}
		{
			Target ${KillTarget}
			call CheckPosition 1 0
		}
	}
	else
	{
		if ${Me.Maintained[${SpellType[385]}](exists)}
			Me.Maintained[${SpellType[385]}]:Cancel
	}
}

function Fanaticism()
{
	if ${FanaticismMode}
	{
		call CheckGroupHealth 70
		if ${Return}
			call CastSpellRange 317
		elseif ${Me.Maintained[${SpellType[317]}](exists)}
			Me.Maintained[${SpellType[317]}]:Cancel
	}
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}