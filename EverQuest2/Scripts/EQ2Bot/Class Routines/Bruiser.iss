#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

; this script is the suck, someone port monk please (pygar)
function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20090623
	;;;;

	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare DefensiveMode bool script TRUE
	declare TauntMode bool Script TRUE
	declare FullAutoMode bool Script FALSE
	declare CraneTwirlMode bool Script FALSE
	declare StanceType int script
	declare BuffProtectGroupMember string script
	declare RangedAttackMode bool script TRUE
	declare ThrownAttacksMode bool script TRUE

	;Alias DebugSpew "Redirect -append c:/Bruiser.txt"
	;Script:EnableDebugLogging[c:/Bruiser.txt]
	;DebugSpew echo +++++++ Start Bruiser+++++++

	call EQ2BotLib_Init

	StanceType:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Stance Type,1]}]
	FullAutoMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Full Auto Mode,FALSE]}]
	TauntMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Taunt Spells,TRUE]}]
	DefensiveMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Defensive Spells,TRUE]}]
	CraneTwirlMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff Crane Twirl,TRUE]}]
	BuffProtectGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffProtectGroupMember,]}]
	RangedAttackMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Ranged Attacks Only,FALSE]}]
	ThrownAttacksMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Thrown Attack Spells,FALSE]}]

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

	;; check this at least every 0.5 seconds
	if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+500]})
	{
		call CheckHeals
		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]
	PreSpellRange[1,2]:Set[26]

	PreAction[2]:Set[Group_Buff]
	PreSpellRange[2,1]:Set[22]

	PreAction[3]:Set[Combat_Buff]
	PreSpellRange[3,1]:Set[155]

	PreAction[4]:Set[Protect_Target]
	PreSpellRange[4,1]:Set[30]
	PreSpellRange[4,2]:Set[32]

	PreAction[5]:Set[Cure_Trauma]
	PreSpellRange[5,1]:Set[211]

	PreAction[6]:Set[AACraneTwirl]
	PreSpellRange[6,1]:Set[394]
}

function Combat_Init()
{
	Action[1]:Set[Combat_Buff]
	SpellRange[1,1]:Set[155]
	SpellRange[1,2]:Set[156]

	Action[2]:Set[AoE_Taunt]
	SpellRange[2,1]:Set[170]

	Action[3]:Set[Taunt1]
	SpellRange[3,1]:Set[160]

	Action[4]:Set[Cure_Trauma]
	SpellRange[4,1]:Set[211]

	Action[5]:Set[Self_Heal]
	SpellRange[5,1]:Set[320]

	Action[6]:Set[DoT]
	SpellRange[6,1]:Set[70]
	SpellRange[6,2]:Set[71]

	Action[7]:Set[Stun]
	SpellRange[7,1]:Set[190]

	Action[8]:Set[Melee_Attack]
	SpellRange[8,1]:Set[150]
	SpellRange[8,2]:Set[154]

	Action[9]:Set[High_Attack]
	SpellRange[9,1]:Set[321]

	Action[10]:Set[AoE_All]
	SpellRange[10,1]:Set[95]
	SpellRange[10,2]:Set[96]

	Action[11]:Set[AoE]
	SpellRange[11,1]:Set[90]

	Action[12]:Set[Combat_Defense]
	SpellRange[12,1]:Set[307]

	Action[13]:Set[AACraneSweep]
	SpellRange[13,1]:Set[395]

	Action[14]:Set[AACraneFlock]
	SpellRange[14,1]:Set[393]

	Action[15]:Set[AAPressurePoint]
	SpellRange[15,1]:Set[399]

	Action[16]:Set[AAChi]
	SpellRange[16,1]:Set[387]

	Action[17]:Set[AABatonFlurry]
	SpellRange[17,1]:Set[398]

	Action[18]:Set[AAMantisStar]
	SpellRange[18,1]:Set[397]

	Action[19]:Set[AAEagleSpin]
	SpellRange[19,1]:Set[392]

	Action[20]:Set[AAEvade]
	SpellRange[20,1]:Set[390]

	Action[21]:Set[Bruising]
	SpellRange[21,1]:Set[402]

	Action[22]:Set[Eye_Gouge]
	SpellRange[22,1]:Set[80]

}

function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{

	declare BuffTarget string local

	call CheckHeals
	call ApplyStance

	switch ${PreAction[${xAction}]}
	{
		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case Group_Buff
		case Combat_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break

		case Protect_Target
			BuffTarget:Set[${UIElement[cbBuffProtectGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Me.GroupCount}>1
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				call CastSpellRange ${PreSpellRange[${xAction},2]} 0 0 0
			}
			break
		case AACraneTwirl
			if ${CraneTwirlMode}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Cure_Trauma
			if ${Me.Trauma}
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
	if (!${RetainAutoFollowInCombat} && ${Me.ToActor.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	;check if we are not in control, and use control cure if needed
	if !${Me.ToActor.CanTurn} || ${Me.ToActor.IsRooted}
		call CastSpellRange 403

	call CommonHeals 70

	if ${DoHOs}
		objHeroicOp:DoHO

	if !${EQ2.HOWindowActive} && ${Me.InCombat}
		call CastSpellRange 303

	if ${ShardMode}
		call Shard

	;stoneskin
	if ${Me.ToActor.Health}<50 && ${Me.Ability[${SpellType[502]}].IsReady}
		call CastSpellRange 502

	;magic stoneskin
	if ${Me.ToActor.Health}<40 && ${Me.Ability[${SpellType[401]}].IsReady}
		call CastSpellRange 401

	;parry
	if ${Me.ToActor.Health}<30 && ${Me.Ability[${SpellType[503]}].IsReady}
		call CastSpellRange 503

	;dev fist
	if !${MainTank} && ${Actor[${KillTarget}].IsEpic} && ${Actor[${KillTarget}].Health}<4
		call CastSpellRange 405
	elseif !${MainTank} && !${Actor[${KillTarget}].IsEpic} && ${Actor[${KillTarget}].Health}<40
		call CastSpellRange 405



	switch ${Action[${xAction}]}
	{
		case Combat_Buff
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			break
		case AoE_Taunt
		case Taunt1
			if ${TauntMode} && !${RangedAttacksMode}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			break
		case Self_Heal
			if ${Me.ToActor.Health}<50
				call CastSpellRange ${SpellRange[${xAction},1]}
			break
		case Cure_Trauma
			if ${Me.Trauma}
				call CastSpellRange ${SpellRange[${xAction},1]}
			break
		case DoT
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			break
		case Eye_Gouge
		case Bruising
		case Stun
			call CastSpellRange ${SpellRange[${xAction},1]}
			break
		case Melee_Attack
			if !${EQ2.HOWindowActive} && ${Me.InCombat}
				call CastSpellRange 303
			call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			break
		case High_Attack
			if ${Me.ToActor.Health}>60
				call CastSpellRange ${SpellRange[${xAction},1]}
			break
		case AoE_All
		case AoE
			if ${Mob.Count}>2
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]}
			break
		case Combat_Defense
			if !${lostaggro}
				call CastSpellRange ${SpellRange[${xAction},1]}
			elseif ${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
				Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}]:Cancel
			break
		case AAEagleSpin
			if !${RangedAttackMode} && ${Me.GroupCount}<=1
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			break
		case AAEvade
			if !${RangedAttackMode} && !${MainTank}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			break
		case AACraneFlock
			if ${PBAoEMode} && ${Mob.Count}>2 && !${RangedAttackMode}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			break
		case AAPressurePoint
			if !${RangedAttackMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			break
		case AAChi
			if (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${Actor[${KillTarget}].Health}<60 && !${RangedAttackMode}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 0 0 0 1
			break
		case AABatonFlurry
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && !${RangedAttackMode}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			break
		case AACraneSweep
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && !${RangedAttackMode}  && ${PBAoEMode} && ${Mob.Count}>2
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			break
		case AAMantisStar
			if ${ThrownAttacksMode} && !${MainTank}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 3 0 ${KillTarget}
			break
		Default
			return Combat Complete
			break
	}
}

function Post_Combat_Routine(int xAction)
{
	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro()
{
	if ${Me.AutoAttackOn}
	{
		EQ2Execute /toggleautoattack
	}

	if !${homepoint}
	{
		return
	}

	if !${avoidhate} && ${Actor[${aggroid}].Distance}<5
	{
		if ${Mob.Count}<3
		{
			press -hold ${backward}
			wait 3
			press -release ${backward}
			avoidhate:Set[TRUE]
		}
	}
}

function Lost_Aggro(int mobid)
{
	if ${Me.ToActor.Power}>5
	{
		if ${Me.Maintained[${SpellType[307]}](exists)}
		{
			Me.Maintained[${SpellType[307]}]:Cancel
		}

		call CastSpellRange 170 171

		if ${Me.Ability[${SpellType[400]}].IsReady}
		{
			call CastSpellRange 400 0 0 0 ${mobid}
		}
		elseif ${Me.Ability[${SpellType[404]}].IsReady}
		{
			call CastSpellRange 404 0 0 0 ${mobid}
		}
		elseif ${Me.Ability[${SpellType[500]}].IsReady}
		{
			call CastSpellRange 500 0 0 0 ${mobid}
		}
		elseif ${Me.Ability[${SpellType[505]}].IsReady}
		{
			call CastSpellRange 505 0 0 0 ${mobid}
		}
		elseif ${Me.Ability[${SpellType[323]}].IsReady}
		{
			call CastSpellRange 323 0 0 0 ${mobid}
		}
	}
}

function MA_Lost_Aggro()
{

}

function Cancel_Root()
{

}

function CheckHeals()
{
	declare grpcnt int local
	declare temphl int local 1
	grpcnt:Set[${Me.GroupCount}]

	;Feign Death if I am solo and low on health
	if ${Me.ToActor.Health}<15 && ${Me.GroupCount}==1
	{
		call CastSpellRange 368 0 0 0 0 0 0 1
	}

	;Use Chi if low health
	if ${Me.ToActor.Health}<35 && ${Me.InCombat} && ${Me.Ability[${SpellType[387]}].IsReady}
	{
		call CastSpellRange 387 0 0 0 0 0 0 1
	}

	;Cancel Feign if Health is better
	if ${Me.Maintained[${SpellType[368]}](exists)} && ${Me.ToActor.Health}>60
	{
		Me.Maintained[${SpellType[368]}]:Cancel
	}

	;Tsunami
	if ${Me.ToActor.Health}<25 && ${DefensiveMode}
	{
		call CastSpellRange 300 0 0 0 0 0 0 1
	}

	;Toggle Stone Stance
	if ${Me.ToActor.Health}<50 && ${DefensiveMode}
	{
		call CastSpellRange 157 0 0 0 0 0 0 1
	}
	elseif ${Me.Maintained[${SpellType[157]}](exists)}
	{
		Me.Maintained[${SpellType[157]}]:Cancel
	}

	; Cure afflictions Me
	if ${Me.Arcane}>=1 || ${Me.Noxious}>=1 || ${Me.Elemental}>=1
	{
		call CastSpellRange 367 0 0 0 0 0 0 1

	}

	;Check Me first for mending,
	if ${Me.ToActor.Health}<30
	{
		call CastSpellRange 366 0 0 0 ${Me.ToActor.ID} 0 0 1

	}

	do
	{
		;Check Group members
		if ${Me.Group[${temphl}].ToActor.Health}<30 && ${Me.Group[${temphl}].ToActor.Health}>-99 && ${Me.Group[${temphl}].ToActor(exists)}
		{
			call CastSpellRange 366 0 0 0 ${Me.Group[${temphl}].ToActor.ID} 0 0 1

		}
	}
	while ${temphl:Inc}<${grpcnt}

	;Outward Calm
	if ${Me.ToActor.Health}<50
	{
		call CastSpellRange 369 0 0 0 ${Me.ToActor.ID} 0 0 1

	}

	call UseCrystallizedSpirit 60

}

function ApplyStance()
{
;1=Offensive,2=Defensive,3=Mixed

	switch ${StanceType}
	{
		case 1
			call CastSpellRange 291
			break

		case 2
			call CastSpellRange 296
			break

		case 3
			call CastSpellRange 292
			break

		case default
			call CastSpellRange 291
			break
	}
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}