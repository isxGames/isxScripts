;*****************************************************
;Swashbuckler.iss 20090616a
;by Pygar
;
;20090616a
; Updated for TSO and GU52
;
;20070822a
; Removed Weapon Swaps
;20070725a
; Updated for new AA changes
;
;20070514a
;DPS Tuning
;
; 20070427a
; Fixed Hurricane Buffing
; Fixed some misplaced CastCaRange calls
;	Fixed spelling on Hurricane
; Cleanup on UI
;	Can no longer attempt to hate transfer to self.
;*****************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
  ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
  declare ClassFileVersion int script 20090616
  ;;;;

	declare OffenseMode bool script 1
	declare AoEMode bool script 0
	declare SnareMode bool script 0
	declare TankMode bool script 0
	declare AnnounceMode bool script 0
	declare BuffLunge bool script 0
	declare MaintainPoison bool script 1
	declare DebuffPoisonShort string script
	declare DamagePoisonShort string script
	declare UtilityPoisonShort string script
	declare StartHO bool script 1
	declare HurricaneMode bool script 1

	;POISON DECLERATIONS
	;EDIT THESE VALUES FOR THE POISONS YOU WISH TO USE
	;The SHORT name is the name of the poison buff icon
	DamagePoisonShort:Set[caustic poison]
	UtilityPoisonShort:Set[turgor]
	DebuffPoisonShort:Set[enfeebling poison]

	NoEQ2BotStance:Set[1]

	call EQ2BotLib_Init

	OffenseMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Offensive Spells,TRUE]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	SnareMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Snares,FALSE]}]
	TankMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Try to Tank,FALSE]}]
	BuffHateGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffHateGroupMember,]}]
	HurricaneMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Hurricane,TRUE]}]
	BuffLunge:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff Lunge Reversal,FALSE]}]
	MaintainPoison:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[MaintainPoison,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
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


	;; This has to be set WITHIN any 'if' block that uses the timer.
	;ClassPulseTimer:Set[${Script.RunningTime}]
}

function Class_Shutdown()
{
}

function Buff_Init()
{

	PreAction[1]:Set[Foot_Work]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Bravado]
	PreSpellRange[2,1]:Set[26]

	PreAction[3]:Set[Offensive_Stance]
	PreSpellRange[3,1]:Set[291]

	PreAction[4]:Set[Avoid]
	PreSpellRange[4,1]:Set[27]

	PreAction[5]:Set[Deffensive_Stance]
	PreSpellRange[5,1]:Set[292]

	PreAction[6]:Set[Poisons]

	PreAction[7]:Set[AA_Lunge_Reversal]
	PreSpellRange[7,1]:Set[395]

	PreAction[8]:Set[AA_Evasiveness]
	PreSpellRange[8,1]:Set[397]

	PreAction[9]:Set[Hurricane]
	PreSpellRange[9,1]:Set[28]

	PreAction[10]:Set[BuffHate]
	PreSpellRange[10,1]:Set[40]
}

function Combat_Init()
{
	Action[1]:Set[AoE1]
	SpellRange[1,1]:Set[95]

	Action[2]:Set[AoE2]
	SpellRange[2,1]:Set[96]

	Action[3]:Set[Melee_Attack1]
	SpellRange[3,1]:Set[150]

;	Action[2]:Set[Debuff1]
;	Power[2,1]:Set[20]
;	Power[2,2]:Set[100]
;	SpellRange[2,1]:Set[191]

	Action[4]:Set[Front_Attack]
	SpellRange[4,1]:Set[120]

	Action[5]:Set[Melee_Attack2]
	SpellRange[5,1]:Set[151]

	Action[6]:Set[Melee_Attack3]
	SpellRange[6,1]:Set[152]

	Action[7]:Set[Melee_Attack4]
	SpellRange[7,1]:Set[153]

	Action[8]:Set[Melee_Attack5]
	SpellRange[8,1]:Set[154]

	Action[9]:Set[Melee_Attack6]
	SpellRange[9,1]:Set[149]

	Action[10]:Set[AA_WalkthePlank]
	SpellRange[10,1]:Set[385]

	Action[11]:Set[Rear_Attack1]
	SpellRange[11,1]:Set[101]

	Action[12]:Set[Rear_Attack2]
	SpellRange[12,1]:Set[100]

;	Action[8]:Set[Debuff2]
;	Power[8,1]:Set[20]
;	Power[8,2]:Set[100]
;	SpellRange[8,1]:Set[190]

	Action[13]:Set[Mastery]

	Action[14]:Set[Flank_Attack1]
	SpellRange[14,1]:Set[110]

	Action[15]:Set[Flank_Attack2]
	SpellRange[15,1]:Set[111]

;	Action[12]:Set[Taunt]
;	Power[12,1]:Set[20]
;	Power[12,2]:Set[100]
;	MobHealth[12,1]:Set[10]
;	MobHealth[12,2]:Set[100]
;	SpellRange[12,1]:Set[160]



;	Action[19]:Set[Snare]
;	Power[19,1]:Set[60]
;	Power[19,2]:Set[100]
;	SpellRange[19,1]:Set[235]

;	Action[20]:Set[AA_Torporous]
;	SpellRange[20,1]:Set[381]

;	Action[21]:Set[AA_Traumatic]
;	SpellRange[21,1]:Set[382]

;	Action[22]:Set[AA_BootDagger]
;	SpellRange[22,1]:Set[386]
}


function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{
	declare BuffTarget string local
	Call ActionChecks

	switch ${PreAction[${xAction}]}
	{
		case Foot_Work
		case Bravado
		case AA_Evasiveness
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Offensive_Stance
			if (${OffenseMode} || !${TankMode}) && !${Me.Maintained[${PreSpellRange[${xAction},1]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			break

		case Avoid
			if ${OffenseMode} && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
				wait 30
			}
			if !${OffenseMode}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Deffensive_Stance
			if (${TankMode} && !${OffenseMode}) && !${Me.Maintained[${PreSpellRange[${xAction},1]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Poisons
			if ${MaintainPoison}
			{
				if !${Me.Maintained[${DamagePoisonShort}](exists)} && ${Me.Inventory[AtHand,${DamagePoisonShort}](exists)}
				{
					Me.Inventory[AtHand,${DamagePoisonShort}]:Use
				}

				if !${Me.Maintained[${DebuffPoisonShort}](exists)} && ${Me.Inventory[AtHand,${DebuffPoisonShort}](exists)}
				{
					Me.Inventory[AtHand,${DebuffPoisonShort}]:Use
				}

				if !${Me.Maintained[${UtilityPoisonShort}](exists)} && ${Me.Inventory[AtHand,${UtilityPoisonShort}](exists)}
				{
					Me.Inventory[AtHand,${UtilityPoisonShort}]:Use
				}
			}
			break
		case AA_Lunge_Reversal
			if ${BuffLunge}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Hurricane
			if ${HurricaneMode} && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
				wait 30
			}
			elseif !${HurricaneMode}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffHate
			BuffTarget:Set[${UIElement[cbBuffHateGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].Name(exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		Default
			return Buff Complete
			break
	}

}

function Combat_Routine(int xAction)
{
	
	if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if !${Me.AutoAttackOn}
		EQ2Execute /toggleautoattack


	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
		call CastSpellRange 303

	if ${DoHOs}
		objHeroicOp:DoHO

	;call ActionChecks

	;if stealthed, use ambush
	if !${MainTank} && ${Me.IsStealthed} && ${Me.Ability[${SpellType[130]}].IsReady}
		call CastSpellRange 130 0 1 1 ${KillTarget} 0 0 0 0 1

	;use best debuffs on target if epic
	if ${Actor[${KillTarget}].IsEpic}
	{
		if ${Me.Ability[${SpellType[150]}].IsReady}
			call CastSpellRange 150 0 0 1 ${KillTarget} 0 0 0 0 1

		if ${Me.Ability[${SpellType[191]}].IsReady}
			call CastSpellRange 191 0 1 1 ${KillTarget} 0 0 0 0 1

		if ${Me.Ability[${SpellType[381]}].IsReady} && ${Target.Target.ID}!=${Me.ID}
			call CastSpellRange 381 0 1 1 ${KillTarget} 0 0 0 0 1

		if ${Me.Ability[${SpellType[382]}].IsReady} && ${Target.Target.ID}!=${Me.ID}
			call CastSpellRange 382 0 1 1 ${KillTarget} 0 0 0 0 1

		if ${Me.Ability[${SpellType[386]}].IsReady} && ${Target.Target.ID}!=${Me.ID}
			call CastSpellRange 386 0 1 1 ${KillTarget} 0 0 0 0 1

		if ${Me.Ability[${SpellType[101]}].IsReady} && ${Target.Target.ID}!=${Me.ID}
			call CastSpellRange 101 0 1 1 ${KillTarget} 0 0 0 0 1
	}

	;if Named or Epic and over 60% health, use dps buffs
	if ${Actor[${KillTarget}].IsEpic} || (${Actor[${KillTarget}].IsHeroic} && ${Actor[${KillTarget}].IsNamed})
	{
		call CheckCondition MobHealth 60 100
		if ${Return.Equal[OK]} || ${Actor[${KillTarget}].IsEpic}
		{
			call CheckPosition 1 1
			if ${Me.Ability[${SpellType[155]}].IsReady} || ${Me.Ability[${SpellType[157]}].IsReady}
			{
				call CastSpellRange 155 158 1 0 ${KillTarget} 0 0 0 0 1
				call CastSpellRange 151 0 1 0 ${KillTarget} 0 0 0 0 1
				call CastSpellRange 153 0 1 0 ${KillTarget} 0 0 0 0 1
			}
		}
	}

	switch ${Action[${xAction}]}
	{
		case Melee_Attack1
		case Melee_Attack2
		case Melee_Attack3
		case Melee_Attack4
		case Melee_Attack5
		case Melee_Attack6
			;echo call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			;echo Melee Attack
			break
		case AoE1
		case AoE2
			if ${AoEMode} && ${Mob.Count}>=2
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			break
		case Snare
			if ${SnareMode}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break
		case Rear_Attack1
		case Rear_Attack2
			if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-25 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<25) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>335 || ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-335
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 
			elseif ${Target.Target.ID}!=${Me.ID}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 1 ${KillTarget} 
			break
		case Mastery
			if !${MainTank} && ${Target.Target.ID}!=${Me.ID}
			{
				if ${Me.Ability[Sinister Strike].IsReady} && ${Actor[${KillTarget}].Name(exists)}
				{
					Target ${KillTarget}
					call CheckPosition 1 1 ${KillTarget}
					Me.Ability[Sinister Strike]:Use
					wait 4
				}
			}
			break
		case AA_WalkthePlank
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 0 0 1
			break
		case AA_Torporous
		case AA_Traumatic
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 0 0 1
			break
		case AA_BootDagger
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 0 0 1
			break

		case Flank_Attack1
		case Flank_Attack2
			if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-25 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<25) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>335 || ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-335
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 0 0 1
			elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}>65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-295)
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 0 0 1
			elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<295)
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 0 0 1
			elseif ${Target.Target.ID}!=${Me.ID}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 3 ${KillTarget} 0 0 0 0 1
		case Debuff1
		case Debuff2
		case Taunt
			if ${TankMode}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 0 0 1
			break
		case Front_Attack
			if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-295)
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 0 0 1
			elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<295)
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 0 0 1
			elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}>125 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<235) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-235 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-125)
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 0 0 1
			elseif ${Target.Target.ID}!=${Me.ID}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 3 ${KillTarget} 0 0 0 0 1
			else
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 2 ${KillTarget} 0 0 0 0 1
			break

		case Stun
			if !${Target.IsEpic}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 0 0 1
			break
		default
			return CombatComplete
			break
	}
}

function Post_Combat_Routine(int xAction)
{
	eq2loc port yimhome

	
	if ${Me.Maintained[Stealth](exists)}
		Me.Maintained[Stealth]:Cancel

	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro()
{

	echo I have agro from ${agroid}
	if ${OffenseMode} && ${Me.Ability[${SpellType[388]}].IsReady} && ${agroid}>0
	{
		;Feign
		call CastSpellRange 388 0 1 0 ${agroid} 0 0 0 0 1
	}
	elseif ${agroid}>0
	{
		if ${Me.Ability[${SpellType[185]}].IsReady}
		{
			;agro dump
			call CastSpellRange 185 0 1 0 ${agroid} 0 0 0 0 1
		}
		else
			call CastSpellRange 181 0 1 0 ${agroid} 0 0 0 0 1

	}
}

function Lost_Aggro()
{
	if ${Target.Target.ID}!=${Me.ID}
	{
		if ${TankMode}
		{
			call CastSpellRange 100 101 1 1 ${KillTarget} 0 0 0 0 1
			call CastSpellRange 160 0 1 0 ${KillTarget} 0 0 0 0 1
		}
	}

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
}

function ActionChecks()
{
	call CommonHeals 60

	if ${ShardMode}
		call Shard
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}

