;*****************************************************
;Dirge.iss 20081022a
;by Pygar & Kayre
;
;20081022a
; Updated for experimental eq2bot spell casting changes
; Should move to rez targets when needed now
; Should be smarter about casting while moving
;
;20080104a
; Added support for IsDead member
; Added a BD trigger /tell mydirge BD Now!
;
;20070919d
;Added Joust Mode - Dirge will move to group or raid healer when it see's the out message in raid chat or
;	tells and use ranged dps till it see's the in message in raid chat or tells.  Added
;	intelegent use of BladeDance and TurnSpike in joust mode, allowing the dirge to stay
;	in on joust calls when these are available. Be sure and edit the dps in and dps out
;	text in the Class_Declaration to the values you want to use
;RangeMode Adjusted - No longer uses MasterStrike when in range mode.  No longer moves to range 6 to use
;	Bow attacks providing the bow attack is already in range.  So you can position the
;	dirge at safe distance prior to fight and it will remain there
;AnnounceMode Added - Due to popular demand, added announcing Cacophony of Blades to group chat.
;Changed Rhythm Blade and Cacophony of Blades to be used whenever they are up.
;Fixed Selo's to be used all the time
;Fixed Heroic Storytelling to be used all the time
;Fixed Luck of the Dirge to be used all the time
;
;20070822a
;Removed Weapon Swapping as no longer required
;
;20070404a
;updated for latest eq2bot
;updated master strikes
;
;fixed a bug with hate buffing
;*****************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20090112
	;;;;

	declare OffenseMode bool script 0
	declare DebuffMode bool script 0
	declare AoEMode bool script 0
	declare BowAttacksMode bool script 0
	declare RangedAttackMode bool script 0
	declare AnnounceMode bool script 1
	declare MagNoteMode bool script 1

	declare BuffParry bool script FALSE
	declare BuffPower bool script FALSE
	declare BuffNoxious bool script FALSE
	declare BuffDPS bool script FALSE
	declare BuffStoneSkin bool script FALSE
	declare BuffTombs bool script FALSE
	declare BuffAgility bool script FALSE
	declare BuffMelee bool script FALSE
	declare BuffHate bool script FALSE
	declare BuffSelf bool script FALSE
	declare BuffTarget string script

	declare JoustMode bool script 0

	call EQ2BotLib_Init

	OffenseMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Offensive Spells,TRUE]}]
	DebuffMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	BowAttacksMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Bow Attack Spells,FALSE]}]
	RangedAttackMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Ranged Attacks Only,FALSE]}]
	AnnounceMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Announce Cacophony,TRUE]}]
	JoustMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Listen to Joust Calls,FALSE]}]
	MagNoteMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[MagNoteMode,TRUE]}]

	BuffParry:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Parry","FALSE"]}]
	BuffPower:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Power","FALSE"]}]
	BuffNoxious:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Noxious","FALSE"]}]
	BuffDPS:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff DPS","FALSE"]}]
	BuffStoneSkin:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff StoneSkin","FALSE"]}]
	BuffTombs:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Tombs","FALSE"]}]
	BuffAgility:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Agility","FALSE"]}]
	BuffMelee:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Melee","FALSE"]}]
	BuffHate:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Hate","FALSE"]}]
	BuffSelf:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting["Buff Self","FALSE"]}]

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

		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}

	if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer2}+1000]})
	{
		call ActionChecks

		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer2:Set[${Script.RunningTime}]
	}
}

function Class_Shutdown()
{

}

function Buff_Init()
{
	;echo buff init
	PreAction[1]:Set[Buff_Parry]
	PreSpellRange[1,1]:Set[20]

	PreAction[2]:Set[Buff_Power]
	PreSpellRange[2,1]:Set[21]

	PreAction[3]:Set[Buff_Noxious]
	PreSpellRange[3,1]:Set[22]

	PreAction[4]:Set[Selos]
	PreSpellRange[4,1]:Set[381]

	PreAction[5]:Set[Buff_DPS]
	PreSpellRange[5,1]:Set[24]

	PreAction[6]:Set[Buff_AAHeroicStorytelling]
	PreSpellRange[6,1]:Set[396]

	PreAction[7]:Set[Buff_StoneSkin]
	PreSpellRange[7,1]:Set[26]

	PreAction[8]:Set[Buff_Tombs]
	PreSpellRange[8,1]:Set[27]

	PreAction[9]:Set[Buff_Agility]
	PreSpellRange[9,1]:Set[28]

	PreAction[10]:Set[Buff_Melee]
	PreSpellRange[10,1]:Set[29]

	PreAction[11]:Set[Buff_Hate]
	PreSpellRange[11,1]:Set[30]

	PreAction[12]:Set[Buff_Self]
	PreSpellRange[12,1]:Set[31]

	PreAction[13]:Set[Buff_AAAllegro]
	PreSpellRange[13,1]:Set[390]

	PreAction[14]:Set[Buff_AADontKillTheMessenger]
	PreSpellRange[14,1]:Set[395]

	PreAction[15]:Set[Buff_AALuckOfTheDirge]
	PreSpellRange[15,1]:Set[382]

	PreAction[16]:Set[Buff_AAFortissimo]
	PreSpellRange[16,1]:Set[398]
}

function Combat_Init()
{

	Action[1]:Set[ScreamOfDeath]
	SpellRange[1,1]:Set[391]
	SpellRange[1,2]:Set[135]

	Action[2]:Set[TacticsHO]
	SpellRange[2,1]:Set[303]
	SpellRange[2,2]:Set[51]
	SpellRange[2,3]:Set[150]

	Action[3]:Set[Luda]
	SpellRange[3,1]:Set[60]

	Action[4]:Set[Flank_Attack]
	SpellRange[4,1]:Set[110]

	Action[5]:Set[Mastery]

	Action[6]:Set[Grievance]
	SpellRange[6,1]:Set[151]

	Action[7]:Set[WailOfTheDead]
	SpellRange[7,1]:Set[152]

	Action[8]:Set[AARhythm_Blade]
	SpellRange[8,1]:Set[397]

	Action[9]:Set[AAHarmonizingShot]
	SpellRange[9,1]:Set[386]

	Action[10]:Set[RhymingHO]
	SpellRange[10,1]:Set[303]
	SpellRange[10,2]:Set[50]
	SpellRange[10,3]:Set[110]

	Action[11]:Set[AATurnstrike]
	SpellRange[11,1]:Set[387]

	Action[12]:Set[AoE2]
	SpellRange[12,1]:Set[63]

	Action[13]:Set[Stealth_Attack]
	SpellRange[13,1]:Set[391]
	SpellRange[13,2]:Set[136]

	Action[14]:Set[Jael]
	SpellRange[14,1]:Set[250]

}


function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{

	switch ${PreAction[${xAction}]}
	{
		case Buff_Parry
			if ${BuffParry}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Power
			if ${BuffPower}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Noxious
			if ${BuffNoxious}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_DPS
			if ${BuffDPS}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_StoneSkin
			if ${BuffStoneSkin}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Tombs
			if ${BuffTombs}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Agility
			if ${BuffAgility}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Melee
			if ${BuffMelee}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Hate
			BuffTarget:Set[${UIElement[cbBuffHateGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${BuffHate}
			{
				if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 0 0 2
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_Self
			if ${BuffSelf}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case Buff_AAHeroicStorytelling
		case Buff_AAAllegro
		case Buff_AALuckOfTheDirge
		case Buff_AADontKillTheMessenger
		case Buff_AAFortissimo
		case Selos
			call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 0 0 0 0 2 0
			break
		Default
			return Buff Complete
			break
	}

}

function Combat_Routine(int xAction)
{
	declare DebuffCnt int  0

	if ${Actor[${KillTarget}].Distance}>${Position.GetMeleeMaxRange[${KillTarget}]} && ${Actor[${KillTarget}].Distance}<${Position.GetSpellMaxRange[${KillTarget},0,${Me.Ability[${SpellType[250]}].MaxRange}]}
	{
		eq2execute /useability ${SpellType[250]}
		eq2execute /auto 2

		if ${Me.Ability[${SpellType[62]}].IsReady}
		{
			eq2execute /useability ${SpellType[62]}
			call CheckPosition 1 0 ${KillTarget} 151 1
			if (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
				call CastSpellRange 151 0 1 1 ${KillTarget} 0 0 1 0
		}
	}

	if !${RangedAttackMode} && !${Me.AutoAttackOn} && ${Actor[${KillTarget}].Distance}<=${Position.GetMeleeMaxRange[${KillTarget}]}
		eq2execute /auto 1

	AutoFollowingMA:Set[FALSE]
	if ${Me.ToActor.WhoFollowing(exists)}
		EQ2Execute /stopfollow

	if ${BDStatus} && ${Me.Ability[${SpellType[388]}].IsReady}
	{
		call CastSpellRange 388 0 0 0 ${KillTarget} 0 0 1 0 1 0
		wait 5
		if ${Me.Maintained[${SpellType[388]}](exists)}
		{
			eq2execute /gsay BladeDance is up - 30 Seconds AoE Immunity for my group!
			BDStatus:Set[0]
		}
	}

	if ${JoustMode}
	{
		if ${JoustStatus}==0 && ${RangedAttackMode}==1
		{
			;We've changed to in from an out status.
			RangedAttackMode:Set[0]
			EQ2Execute /toggleautoattack

			;if we're too far from killtarget, move in
			if ${Actor[${KillTarget}].Distance}>10 && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
				call CheckPosition 1 1
		}
		elseif ${JoustStatus}==1 && ${RangedAttackMode}==0 && !${Me.Maintained[${SpellType[388]}](exists)} && !${Me.Maintained[${SpellType[387]}](exists)}
		{
			;We've changed to out from an in status.

			;if aoe avoidance is up, use it
			if ${Me.Ability[${SpellType[388]}].IsReady}
			{
				if ${AnnounceMode}
					eq2execute /gsay BladeDance is up - 30 Seconds AoE Immunity for my group!
				call CastSpellRange 388 0 0 0 ${KillTarget} 0 0 0 0 1 0
			}
			elseif ${Me.Ability[${SpellType[387]}].IsReady}
				call CastSpellRange 387 0 1 0 ${KillTarget} 0 0 0 0 1 0
			else
			{
				RangedAttackMode:Set[1]
				EQ2Execute /togglerangedattack

				;if we're not at our healer, lets move to him
				call FindHealer

				echo Healer - ${return}
				if ${Actor[${return}].Distance}>2
					call FastMove ${Actor[${return}].X} ${Actor[${return}].Z} 1
			}
		}
	}

	call ActionChecks

	if ${MagNoteMode}
		call DoMagneticNote

	;Always use Cacophony of Blades if available.
	if ${Me.Ability[${SpellType[155]}].IsReady}
	{
		if ${AnnounceMode}
		{
			eq2execute /raidsay Caco of Blades is up!
			eq2execute /g Caco of Blades is up!
		}
		call CastSpellRange 155 0 0 0 ${KillTarget} 0 0 1 0 1 0
		wait 20
	}

	if ${DebuffMode}
	{
		if !${Me.Maintained[${SpellType[55]}](exists)} && ${Me.Ability[${SpellType[55]}].IsReady}
		{
			call CastSpellRange 55 0 0 ${KillTarget} 0 0 1
			DebuffCnt:Inc
		}
		if !${Me.Maintained[${SpellType[56]}](exists)} && ${Me.Ability[${SpellType[56]}].IsReady} && ${DebuffCnt}<1
		{
			call CastSpellRange 56 0 0 ${KillTarget} 0 0 1
			DebuffCnt:Inc
		}
		if !${Me.Maintained[${SpellType[57]}](exists)} && ${Me.Ability[${SpellType[57]}].IsReady} && ${DebuffCnt}<1
		{
			call CastSpellRange 57 0 0 ${KillTarget} 0 0 1
			DebuffCnt:Inc
		}
	}

	if ${Me.Ability[${SpellType[62]}].IsReady}
	{
		call CastSpellRange 62 0 0 0 ${KillTarget} 0 0 1 0
		if (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
			call CastSpellRange 151 0 1 1 ${KillTarget} 0 0 1 0
	}


	if ${RangedAttackMode}
	{
		if !${Me.RangedAutoAttackOn}
			EQ2Execute /togglerangedattack

		if !${Me.CastingSpell} && ${Target.Distance}>35
		{
			Target ${KillTarget}
			call CheckPosition 3 0
		}
	}

	if ${DoHOs}
		objHeroicOp:DoHO

	switch ${Action[${xAction}]}
	{
		case TacticsHO
		case RhymingHO
			if !${RangedAttackMode}
			{
				eq2execute /useability "Lucky Break"
				call CastSpellRange ${SpellRange[${xAction},2]} 0 1 0 ${KillTarget} 0 0 1 0 2 0
				wait 30 ${EQ2.HOWindowActive}
				if !${EQ2.HOName.Equal[Bravo's Dance]}
				{
					if ${Me.Ability[${SpellType[180]}].IsReady}
						call CastSpellRange 180 0 1 0 ${KillTarget} 0 0 1 0 2 0
					elseif ${Me.Ability[${SpellType[55]}].IsReady}
						call CastSpellRange 55 0 1 0 ${KillTarget} 0 0 1 0 2 0
				}
				call CastSpellRange ${SpellRange[${xAction},3]} 0 1 0 ${KillTarget} 0 0 1 0 2 0
			}
			break
		case Stealth_Attack
			if !${RangedAttackMode} && (${Me.Ability[${SpellType[200]}].IsReady} || ${Me.Ability[${SpellType[391]}].IsReady}) && !${MainTank}
			{
				if ${Me.Ability[${SpellType[136]}].TimeUntilReady}<.1
				{
					while ${Me.CastingSpell}
					{
						wait 2
					}

					;	check if we have the bump AA and use it to stealth us
					if ${Me.Ability[${SpellType[391]}].IsReady} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
					{
						call CastSpellRange 391 0 1 1 ${KillTarget} 0 0 1 0 1
						call CheckPosition 1 1 ${KillTarget}
						eq2execute /useability ${SpellType[136]}
						wait 4
					}
					elseif ${Me.ToActor.IsInvis}
					{
						eq2execute /useability ${SpellType[136]}
						wait 4
					}
					elseif (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
					{
						call CastSpellRange 200 0 1 1 ${KillTarget} 0 0 1 0 1
						wait 5
						eq2execute /useability ${SpellType[136]}
						wait 4
					}

					while ${Me.CastingSpell}
					{
						wait 2
					}
				}
			}
			break
		case ScreamOfDeath
			if !${RangedAttackMode} && (${Me.Ability[${SpellType[200]}].IsReady} || ${Me.Ability[${SpellType[391]}].IsReady}) && !${MainTank}
			{
				if ${Me.Ability[${SpellType[135]}].TimeUntilReady}<.1
				{
					while ${Me.CastingSpell}
					{
						wait 2
					}

					;	check if we have the bump AA and use it to stealth us
					if ${Me.Ability[${SpellType[391]}].IsReady} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
					{
						call CastSpellRange 391 0 1 1 ${KillTarget} 0 0 1 0 1
						call CheckPosition 1 1 ${KillTarget}
						eq2execute /useability ${SpellType[135]}
						wait 4
					}
					elseif ${Me.ToActor.IsInvis}
					{
						eq2execute /useability ${SpellType[135]}
						wait 4
					}
					elseif (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
					{
						call CastSpellRange 200 0 1 1 ${KillTarget} 0 0 1 0 1
						wait 5
						eq2execute /useability ${SpellType[135]}
						wait 4
					}

					while ${Me.CastingSpell}
					{
						wait 2
					}
				}
			}
			break
		case AoE2
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			break
		case AATurnstrike
			if !${JoustMode} && !${RangedAttackMode}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			break
		case Mastery
			if !${MainTank} && ${Target.Target.ID}!=${Me.ID} && !${RangedAttackMode}
			{
				if ${Me.Ability[Sinister Strike].IsReady} && ${Actor[${KillTarget}](exists)} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
				{
					Target ${KillTarget}
					call CheckPosition 1 1 ${KillTarget}
					Me.Ability[Sinister Strike]:Use
				}
			}
			break
		case AAHarmonizingShot
		case Jael
			if ${BowAttacksMode}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 3 0 ${KillTarget} 0 0 1 0 2 0
			break
		case AARhythm_Blade
		case Grievance
		case WailOfTheDead
			if !${RangedAttackMode}
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			break
		case Flank_Attack
			if !${RangedAttackMode} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 1 ${KillTarget} 0 0 1 0 2 0
			break
		case Luda
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			break
		default
			return CombatComplete
			break
	}

}

function Post_Combat_Routine(int xAction)
{
	if ${Me.Maintained[Shroud](exists)}
		Me.Maintained[Shroud]:Cancel

	;reset rangedattack in case it was modified by joust call.
	JoustMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Listen to Joust Calls,FALSE]}]
	RangedAttackMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Ranged Attacks Only,FALSE]}]

	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro(int agroid)
{

	if ${agroid}==${KillTarget}
	{
		;evade
		call CastSpellRange 180 0 0 0 ${agroid} 0 0 1
	}
	else
	{
		;fear it off since its an add
		call CastSpellRange 352 0 0 0 ${agroid} 0 0 1
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
	declare temphl int local 1
	declare tempgrp int local 1
	declare tempraid int local 1
	grpcnt:Set[${Me.GroupCount}]

	call UseCrystallizedSpirit 60
	;oration of sacrifice heal
	do
	{
		;oration of sacrifice heal
		if !${MainTank} && ${Me.Ability[${SpellType[1]}].IsReady} && ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.Health}<40 && !${Me.Group[${temphl}].ToActor.IsDead} && ${Me.ToActor.Health}>75 && ${Me.Group[${temphl}].ToActor.Distance}<=20
		{
			EQ2Echo healing ${Me.Group[${temphl}].ToActor.Name}
			call CastSpellRange 1 0 0 0 ${Me.Group[${temphl}].ID} 0 0 1 0 2 0
		}
	}
	while ${temphl:Inc}<${grpcnt}

	;Res Fallen Groupmembers only if in range
	do
	{
		if ${Me.Group[${tempgrp}].ToActor.IsDead} && (${Me.Ability[${SpellType[300]}].IsReady} || ${Me.Ability[${SpellType[301]}].IsReady})
		{
			call CastSpellRange 300 301 1 0 ${Me.Group[${tempgrp}].ID} 1 0 0 0 1 0
			;short wait for accept
			wait 10
		}
	}
	while ${tempgrp:Inc}<${grpcnt}

	if ${Me.InRaid} && (${Me.Ability[${SpellType[300]}].IsReady} || ${Me.Ability[${SpellType[301]}].IsReady})
	{
		;Res Fallen RAID members only if in range
		do
		{
			if ${Me.Raid[${tempraid}].ToActor.IsDead} && (${Me.Ability[${SpellType[300]}].IsReady} || ${Me.Ability[${SpellType[301]}].IsReady}) && ${Me.Raid[${tempraid}].ToActor.Distance}<35
				call CastSpellRange 300 301 1 0 ${Me.Raid[${tempraid}].ID} 1 0 0 0 1 0
		}
		while ${tempraid:Inc}<=24 && (${Me.Ability[${SpellType[300]}].IsReady} || ${Me.Ability[${SpellType[301]}].IsReady})
	}
}

function ActionChecks()
{

	if ${ShardMode}
		call Shard 60

	call CheckHeals
}

function DoMagneticNote()
{
	declare tcount int local
	declare tempvar int local
	declare aggrogrp bool local FALSE

	tempvar:Set[1]

	grpcnt:Set[${Me.GroupCount}]

	if !${Me.Ability[${SpellType[383]}].IsReady}
		return

	EQ2:CreateCustomActorArray[byDist,${ScanRange},npc]

	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]} && ${CustomActor[${tcount}].Target(exists)}
		{

			if (${Actor[${MainTankPC}].Target.ID}==${CustomActor[${tcount}].ID})
				continue

			if ${Mob.Target[${CustomActor[${tcount}].ID}]}
			{
				call CastSpellRange 383 0 0 0 ${Actor[${MainTankPC}].ID} 0 0 0 0 1 0
				return
			}
		}
	}
	while ${tcount:Inc}<${EQ2.CustomActorArraySize}
}

function StartHO()
{
	if !${EQ2.HOWindowActive} && ${Me.InCombat}
		eq2execute /useability "Lucky Break"
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed
	return
}