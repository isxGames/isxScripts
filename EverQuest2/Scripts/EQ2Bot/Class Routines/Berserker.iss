;*************************************************************
;Berserker.iss
;version 20090616a
;by Pygar
;
;20090616a
; Updated for TSO and GU52
;
;20070725a (Pygar)
; Update AA strikes for new weapon requirements
;
;20061201a
;Implemented AA Berserk
;Implemented AA Gut Roar
;Implemented EQ2botlib Crystalize Spirit
;by karye
;*************************************************************
#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20090616
	;;;;

	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare OffensiveMode bool script TRUE
	declare DefensiveMode bool script TRUE
	declare TauntMode bool Script TRUE
	declare FullAutoMode bool Script FALSE
	declare DragoonsCycloneMode bool Script FALSE
	declare MezMode bool Script FALSE

	call EQ2BotLib_Init

	FullAutoMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Full Auto Mode,FALSE]}]
	TauntMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Taunt Spells,TRUE]}]
	DefensiveMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Defensive Spells,TRUE]}]
	OffensiveMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Offensive Spells,FALSE]}]
	DragoonsCycloneMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff Dragoons Cyclone,FALSE]}]
	MezMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use MezMode,FALSE]}]

	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	PBAoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast PBAoE Spells,FALSE]}]

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
	ClassPulseTimer:Set[${Script.RunningTime}]
}

function Class_Shutdown()
{
}


function Buff_Init()
{
   PreAction[1]:Set[Protect_Target]
   PreSpellRange[1,1]:Set[30]

   PreAction[2]:Set[Self_Buff]
   PreSpellRange[2,1]:Set[25]
   PreSpellRange[2,2]:Set[28]

   PreAction[3]:Set[Group_Buff]
   PreSpellRange[3,1]:Set[20]
   PreSpellRange[3,2]:Set[22]

   PreAction[4]:Set[AA_DragoonsCyclone]
   PreSpellRange[4,1]:Set[29]

}

function Combat_Init()
{
   Action[1]:Set[AoE_Taunt]
   SpellRange[1,1]:Set[170]

   Action[2]:Set[Taunt1]
   SpellRange[2,1]:Set[160]

   Action[3]:Set[Taunt2]
   SpellRange[3,1]:Set[161]

   Action[4]:Set[AA_Accel]
   SpellRange[4,1]:Set[399]

   Action[5]:Set[Combat_Buff1]
   SpellRange[5,1]:Set[155]

   Action[6]:Set[Combat_Buff2]
   SpellRange[6,1]:Set[156]

   Action[7]:Set[AA_Wrath]
   SpellRange[7,1]:Set[397]

   Action[8]:Set[AoE1]
   Power[8,1]:Set[20]
   Power[8,2]:Set[100]
   SpellRange[8,1]:Set[90]

   Action[9]:Set[AoETaunt]
   Power[9,1]:Set[1]
   Power[9,2]:Set[100]
   SpellRange[9,1]:Set[503]

   Action[10]:Set[AoE2]
   Power[10,1]:Set[20]
   Power[10,2]:Set[100]
   SpellRange[10,1]:Set[91]

   Action[11]:Set[AoE3]
   Power[11,1]:Set[20]
   Power[11,2]:Set[100]
   SpellRange[11,1]:Set[92]

   Action[12]:Set[PBAoE1]
   Power[12,1]:Set[20]
   Power[12,2]:Set[100]
   SpellRange[12,1]:Set[93]

   Action[13]:Set[PBAoE2]
   Power[13,1]:Set[20]
   Power[13,2]:Set[100]
   SpellRange[13,1]:Set[94]

   Action[14]:Set[PBAoE3]
   Power[14,1]:Set[20]
   Power[14,2]:Set[100]
   SpellRange[14,1]:Set[95]

   Action[15]:Set[Damage_Debuff1]
   MobHealth[15,1]:Set[5]
   MobHealth[15,2]:Set[100]
   Power[15,1]:Set[20]
   Power[15,2]:Set[100]
   SpellRange[15,1]:Set[80]

   Action[16]:Set[Damage_Debuff2]
   MobHealth[16,1]:Set[5]
   MobHealth[16,2]:Set[100]
   Power[16,1]:Set[20]
   Power[16,2]:Set[100]
   SpellRange[16,1]:Set[81]

   Action[17]:Set[Damage_Debuff3]
   MobHealth[17,1]:Set[5]
   MobHealth[17,2]:Set[100]
   Power[17,1]:Set[20]
   Power[17,2]:Set[100]
   SpellRange[17,1]:Set[82]

   Action[18]:Set[Melee_Attack1]
   Power[18,1]:Set[5]
   Power[18,2]:Set[100]
   SpellRange[18,1]:Set[150]

   Action[19]:Set[Melee_Attack2]
   Power[19,1]:Set[5]
   Power[19,2]:Set[100]
   SpellRange[19,1]:Set[151]

   Action[20]:Set[Shield_Attack]
   Power[20,1]:Set[5]
   Power[20,2]:Set[100]
   SpellRange[20,1]:Set[240]

   Action[21]:Set[Belly_Smash]
   Power[21,1]:Set[5]
   Power[21,2]:Set[100]
   SpellRange[21,1]:Set[400]

   Action[22]:Set[Melee_Attack3]
   Power[22,1]:Set[5]
   Power[22,2]:Set[100]
   SpellRange[22,1]:Set[152]

   Action[23]:Set[Melee_Attack4]
   Power[23,1]:Set[5]
   Power[23,2]:Set[100]
   SpellRange[23,1]:Set[153]

}

function PostCombat_Init()
{
   PostAction[1]:Set[Cancel_Root]
   PostSpellRange[1,1]:Set[324]

   PostAction[2]:Set[AA_BindWound]
   PostSpellRange[2,1]:Set[398]

   PostAction[3]:Set[AA_AccelterationStrike]
   PostSpellRange[3,1]:Set[399]

}

function Buff_Routine(int xAction)
{

	switch ${PreAction[${xAction}]}
	{
		case Protect_Target

			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				if ${EQ2Bot.ProtectHealer}
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${EQ2Bot.ProtectHealer}
				elseif ${Me.Grouped} && ${Me.Group[1](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[1].ID}]
			}

			break

		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		case AA_DragoonsCyclone
			if ${DragoonsCycloneMode}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		Default
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
	
	if ${DoHOs}
		objHeroicOp:DoHO

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${DoHOs}
		call CastSpellRange 303

	if ${ShardMode}
		call Shard

	;always keep AA Berserk up
	call CastSpellRange 393

	;use Wall of Force if health is low
	if ${Me.Ability[${SpellType[501]}].IsReady} && ${Me.ToActor.Health}<40
		call CastSpellRange 501

	;echo in combat
	if ${FullAutoMode}
	{
		call CommonHeals 70
		;AA Gut Roar
		if ${AoEMode}
			call CastSpellRange 392

		if ${Me.ToActor.Health}<50
			call CastSpellRange 324

		switch ${Action[${xAction}]}
		{

			case Combat_Buff1
			case Combat_Buff2
				if ${DefensiveMode}
					call CastSpellRange ${SpellRange[${xAction},1]}
				break
			case Taunt1
				if ${TauntMode}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0
				break
			case Taunt2
				if ${TauntMode} && ${OffensiveMode}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0
				break
			case AoE_Taunt
				if ${TauntMode}
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0
				break
			case Damage_Debuff1
			case Damage_Debuff2
			case Damage_Debuff3
				if ${OffensiveMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
							call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0
					}
				}
				break
			case AoE1
			case AoE2
			case AoE3
				if ${AoEMode} && ${Mob.Count}>1
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0
				}
				break
			case PBAoE1
			case PBAoE2
			case PBAoE3
				if ${TauntMode} && ${Me.Ability[${SpellType[505]}].IsReady}
					call CastSpellRange 505

				if !${TauntMode} && ${Me.Ability[${SpellType[506]}].IsReady}
					call CastSpellRange 506

				if ${PBAoEMode} && ${Mob.Count}>1
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0
				}
				break
			case AoETaunt
				if ${PBAoEMode} && ${Mob.Count}>1 && ${TauntMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0
				}
				break
			case Melee_Attack1
			case Melee_Attack2
			case Melee_Attack3
			case Melee_Attack4
				if ${OffensiveMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0
				}
				break
			case Shield_Attack
				if ${OffensiveMode}
				{
					If ${Me.Equipment[Secondary].Type.Equal[Shield]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
							call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0
					}
				}
				break
			case Belly_Smash
				if ${OffensiveMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
				break
			case AA_Wrath
			case AA_Accel
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				break
			case default
				return Combat Complete
				break
		}
	}
}

function Post_Combat_Routine(int xAction)
{
	switch ${PostAction[${xAction}]}
	{
		case Cancel_Root
			 if ${Me.Maintained[${SpellType[${PostSpellRange[${xAction},1]}]}](exists)}
			    Me.Maintained[${SpellType[${PostSpellRange[${xAction},1]}]}]:Cancel
			break
		case AA_AccelterationStrike
			if ${Me.Ability[${SpellType[${PostSpellRange[${xAction},1]}]}].IsReady}
				call CastSpellRange ${SpellRange[${xAction},1]}
			break
		case AA_BindWound
			if ${Me.Ability[${SpellType[${PostSpellRange[${xAction},1]}]}].IsReady}
				call CastSpellRange ${PostSpellRange[${xAction},1]}
			break
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro()
{

}

function Lost_Aggro(int mobid)
{
	if ${FullAutoMode} && ${Me.ToActor.Power}>5
	{
		if ${TauntMode}
		{
			if !${MezMode} && ${Actor[${mobid}].Target.ID}!=${Me.ID}
			{
				KillTarget:Set[${mobid}]
				target ${mobid}
			}

			if ${Actor[${KillTarget}].Target.ID}!=${Me.ID} && ${Me.Ability[${SpellType[270]}].IsReady}
				call CastSpellRange 270 0 1 0 ${Actor[${mobid}].ID}

			if ${Me.Ability[${SpellType[500]}].IsReady} && ${Actor[${KillTarget}].Target.ID}!=${Me.ID}
				call CastSpellRange 500 0 1 0 ${Actor[${KillTarget}].ID}
			elseif ${Me.Ability[${SpellType[502]}].IsReady} && ${Actor[${KillTarget}].Target.ID}!=${Me.ID}
				call CastSpellRange 502 0 1 0 ${Actor[${KillTarget}].ID}
			elseif ${Me.Ability[${SpellType[160]}].IsReady} && ${Actor[${KillTarget}].Target.ID}!=${Me.ID}
				call CastSpellRange 160 161 1 0 ${Actor[${KillTarget}].ID}

			;use rescue if new agro target is under 65 health
			if ${Me.ToActor.Target.Target.Health}<65 && ${Actor[${KillTarget}].Target.ID}!=${Me.ID}
				call CastSpellRange 320 0 1 0 ${mobid}
		}
	}
}

function MA_Lost_Aggro()
{

}

function MA_Dead()
{
	MainTank:Set[TRUE]
	MainAssist:Set[${Me.Name}]
	KillTarget:Set[]
}

function Cancel_Root()
{
}

function CheckHeals()
{
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}

