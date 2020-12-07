;Monk.iss 20090622a (Pygar)
;
;20090622
;	Updated for TSO and GU52
;
;20070725a (Pygar)
; Update for AA requirement changes
;
;20070117a by Karye
;TODO AA MAntis Leap


#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20080408
	;;;;

	declare AoEMode bool script FALSE
	declare PBAoEMode bool script FALSE
	declare DefensiveMode bool script TRUE
	declare TauntMode bool Script TRUE
	declare FullAutoMode bool Script FALSE
	declare CraneTwirlMode bool Script FALSE
	declare StanceType int script
	declare BuffProtectGroupMember string script
	declare BuffAltruismMember string script
	declare RangedAttackMode bool script TRUE
	declare ThrownAttacksMode bool script TRUE

	;Alias DebugSpew "Redirect -append c:/Monk.txt"
	;Script:EnableDebugLogging[c:/Monk.txt]
	;DebugSpew echo +++++++ Start Monk+++++++

	echo Initializing EQ2BotLib...
	call EQ2BotLib_Init

	StanceType:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Stance Type,1]}]
	FullAutoMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Full Auto Mode,FALSE]}]
	TauntMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Taunt Spells,TRUE]}]
	DefensiveMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Defensive Spells,TRUE]}]
	CraneTwirlMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff Crane Twirl,FALSE]}]
	BuffProtectGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffProtectGroupMember,]}]
	BuffAltruismMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffAltruismMember,]}]
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
	if (${StartBot} && ${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+500]})
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
	PreAction[1]:Set[DragonStance]
	;normal dragon stance (hate proc)
	PreSpellRange[1,1]:Set[29]
	;AA Mongoose Stance (anti hate)
	PreSpellRange[1,2]:Set[391]

	PreAction[2]:Set[Swiftness]
	PreSpellRange[2,1]:Set[20]

	PreAction[3]:Set[Protect_Target]
	PreSpellRange[3,1]:Set[30]

	PreAction[4]:Set[MartialFocus]
	PreSpellRange[4,1]:Set[35]

	PreAction[5]:Set[EverburningFlame]
	PreSpellRange[5,1]:Set[26]

	PreAction[6]:Set[AACraneTwirl]
	PreSpellRange[6,1]:Set[394]

	PreAction[7]:Set[Altruism_Target]
	PreSpellRange[7,1]:Set[386]
}

function Combat_Init()
{

	Action[1]:Set[AoE_Taunt]
	SpellRange[1,1]:Set[170]

	Action[2]:Set[Taunt1]
	SpellRange[2,1]:Set[160]

	Action[3]:Set[MountainStance]
	SpellRange[3,1]:Set[156]

	Action[4]:Set[AACraneSweep]
	SpellRange[4,1]:Set[395]

	Action[5]:Set[AACraneFlock]
	SpellRange[5,1]:Set[393]

	Action[6]:Set[CobraCircle]
	SpellRange[6,1]:Set[95]

	Action[7]:Set[DragonBreath]
	SpellRange[7,1]:Set[96]

	Action[8]:Set[MantisJabs]
	SpellRange[8,1]:Set[154]

	Action[9]:Set[WintersTalon]
	SpellRange[9,1]:Set[190]

	Action[10]:Set[ThrustKick]
	SpellRange[10,1]:Set[152]

	Action[11]:Set[PowerStrike]
	SpellRange[11,1]:Set[80]

	Action[12]:Set[ColdFist]
	SpellRange[12,1]:Set[140]

	Action[13]:Set[SilentPalm]
	SpellRange[13,1]:Set[260]

	Action[14]:Set[AAPressurePoint]
	SpellRange[14,1]:Set[399]

	Action[15]:Set[AAChi]
	SpellRange[15,1]:Set[387]

	Action[16]:Set[AABatonFlurry]
	SpellRange[16,1]:Set[398]

	Action[17]:Set[AAMantisStar]
	SpellRange[17,1]:Set[397]

	Action[18]:Set[AAEagleSpin]
	SpellRange[18,1]:Set[392]

	Action[19]:Set[ForwardStrike]
	SpellRange[19,1]:Set[15]

	Action[20]:Set[Kick]
	SpellRange[20,1]:Set[151]

	Action[21]:Set[PouncingLeopard]
	SpellRange[21,1]:Set[153]

	Action[22]:Set[SwoopingDragon]
	SpellRange[22,1]:Set[70]

	Action[23]:Set[AAEvade]
	SpellRange[23,1]:Set[390]

}

function PostCombat_Init()
{
	;Turn off Mountain Stance
	PostAction[1]:Set[MountainStance]
	PostSpellRange[1,1]:Set[156]

	;Turn off Stone Stance
	PostAction[2]:Set[StoneStance]
	PostSpellRange[2,1]:Set[157]

}

function Buff_Routine(int xAction)
{
	declare BuffTarget string local

	call ApplyStance

	switch ${PreAction[${xAction}]}
	{
		case DragonStance
			if ${MainTank}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},2]}]}]:Cancel
				;normal dragon stance (hate proc)
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 1
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				;AA mongoose stance (anti hate)
				call CastSpellRange ${PreSpellRange[${xAction},2]} 0 0 0 0 0 0 1
			}
			break
		case EverburningFlame
		case MartialFocus
		case Swiftness
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break

		case Protect_Target
			BuffTarget:Set[${UIElement[cbBuffProtectGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Me.GroupCount}>1
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case Altruism_Target
			BuffTarget:Set[${UIElement[cbBuffAltruismMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Me.GroupCount}>1
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
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

	call CheckHeals

	if ${DoHOs}
		objHeroicOp:DoHO

	if !${EQ2.HOWindowActive} && ${Me.InCombat}
		call CastSpellRange 303

	if ${Me.Health}<50 && ${Me.Ability[${SpellType[503]}].IsReady}
		call CastSpellRange 503

	if ${Me.Health}<70 && ${Me.Ability[${SpellType[505]}].IsReady}
		call CastSpellRange 505

	;Always keep Thundering Hand Buffed
	call CastSpellRange 155 0 0 0 0 0 0 1

	;Always try for the AA Combination
	if !${RangedAttackMode} && ${Me.Ability[${SpellType[389]}].IsReady}
		call CastSpellRange 389 0 1 0 ${KillTarget} 0 0 1

	if ${ShardMode}
		call Shard

	;always keep AA Berserk up
	call CastSpellRange 393

	;echo in combat
	if ${FullAutoMode}
	{

		switch ${Action[${xAction}]}
		{

			case MountainStance
				if ${DefensiveMode}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 0 0 0 1
				}
				break
			case AoE_Taunt
			case Taunt1
				if ${TauntMode} && !${RangedAttacksMode}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				break
			case DragonBreath
			case ThrustKick
			case ColdFist
			case Kick
			case PouncingLeopard
			case ThunderingHand
			case PowerStrike
			case MantisJabs
			case SwoopingDragon
			case SilentPalm
			case WintersTalon
			case ForwardStrike
				if !${RangedAttackMode}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				break
			case AAEagleSpin
				if !${RangedAttackMode} && ${Me.GroupCount}<=1
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				break
			case AAEvade
				if !${RangedAttackMode} && !${MainTank}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
				break

			case CobraCircle
			case AACraneFlock
				if ${PBAoEMode} && ${Mob.Count}>2 && !${RangedAttackMode}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				break
			case AAPressurePoint
				if !${RangedAttackMode} && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				break
			case AAChi
				if (${Actor[${KillTarget}].Type.Equal[NamedNPC]} || ${Actor[${KillTarget}].IsEpic}) && ${Actor[${KillTarget}].Health}<60 && !${RangedAttackMode}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 0 0 0 1
				}
				break
			case AABatonFlurry
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && !${RangedAttackMode}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				break
			case AACraneSweep
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && !${RangedAttackMode}  && ${PBAoEMode} && ${Mob.Count}>2
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				break
			case AAMantisStar
				if ${ThrownAttacksMode} && !${MainTank}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 3 0 ${KillTarget}
				}
				break
			case Default
				return CombatComplete
				break
		}
	}
}

function Post_Combat_Routine(int xAction)
{
	switch ${PostAction[${xAction}]}
	{

		case MountainStance
		case StoneStance
			 if ${Me.Maintained[${SpellType[${PostSpellRange[${xAction},1]}]}](exists)}
			 {
			    Me.Maintained[${SpellType[${PostSpellRange[${xAction},1]}]}]:Cancel
			 }
			break
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro()
{

	;Feign Death if I am very low on health
	;while not MT
	if !${MainTank} && ${Me.Health}<15
	{
		call CastSpellRange 368 0 0 0 0 0 0 1
	}

	;apply mountain stance if I got aggro and am hurt
	;while not MT
	if !${MainTank} && ${Me.Health}<70
	{
		call CastSpellRange 156 0 0 0 0 0 0 1
	}

}

function Lost_Aggro(int mobid)
{
	if ${FullAutoMode} && ${Me.Power}>5
	{
		if ${TauntMode} && !${RangedAttacksMode}
		{
			if ${Actor[${KillTarget}].Target.ID}!=${Me.ID} && ${Me.Ability[${SpellType[321]}].IsReady}
				call CastSpellRange 321 0 1 0 ${Actor[${KillTarget}].ID}

			;use rescue if new agro target is under 65 health
			if ${Me.Target.Target.Health}<65
			{
				call CastSpellRange 320 0 1 0 ${mobid} 0 0 1
			}

			;intercept damage on the person now with agro
			call CastSpellRange 120 0 1 0 ${mobid} 0 0 1

			;try and taunt the mob back
			call CastSpellRange 170 0 1 0 ${mobid} 0 0 1
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
	variable int grpcnt = ${Me.GroupCount}
	declare temphl int local 1

	;Feign Death if I am solo and low on health
	if ${Me.Health}<15 && ${Me.GroupCount}==1
	{
		call CastSpellRange 368 0 0 0 0 0 0 1
	}

	;Use Chi if low health
	if ${Me.Health}<35 && ${Me.InCombat} && ${Me.Ability[${SpellType[387]}].IsReady}
	{
		call CastSpellRange 387 0 0 0 0 0 0 1
	}

	;Cancel Feign if Health is better
	if ${Me.Effect[${SpellType[368]}](exists)} && ${Me.Health}>60
	{
		Me.Effect[${SpellType[368]}]:Cancel
	}

	;Tsunami
	if ${Me.Health}<25
	{
		call CastSpellRange 300 0 0 0 0 0 0 1
	}

	;Toggle Stone Stance
	if ${Me.Health}<50 && ${DefensiveMode}
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
	if ${Me.Health}<30
	{
		call CastSpellRange 366 0 0 0 ${Me.ID} 0 0 1

	}

	do
	{
		;Check Group members
		if ${Me.Group[${temphl}].Health}<30 && ${Me.Group[${temphl}].Health}>-99 && ${Me.Group[${temphl}].InZone} && ${Me.Group[${temphl}].Health(exists)}
		{
			call CastSpellRange 366 0 0 0 ${Me.Group[${temphl}].ID} 0 0 1

		}
	}
	while ${temphl:Inc}<${grpcnt}

	;Outward Calm
	if ${Me.Health}<50
	{
		call CastSpellRange 369 0 0 0 ${Me.ID} 0 0 1
		call CastSpellRange 300 0 0 0 ${Me.ID} 0 0 1
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