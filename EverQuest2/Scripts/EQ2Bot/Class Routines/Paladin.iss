;*************************************************************
;Paladin.iss
;version 20101209
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20101209
	;;;;

	declare HealerMode bool script FALSE
	declare HealOthersMode bool script FALSE
	declare AoEMode bool script FALSE
	declare Start_HO bool script FALSE
	declare DefensiveMode bool script FALSE

	declare BuffProcGroupMember string script
	declare Secondary_Assist string script
	declare BuffAmendsGroupMember string script

	NoEQ2BotStance:Set[1]
	call EQ2BotLib_Init

	;XML Setup for clickbox options
	HealerMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[HealerMode,FALSE]}]
	HealOthersMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[HealOthersMode,FALSE]}]
	Start_HO:Set{${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start_HO,FALSE]}]
	DefensiveMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[DefensiveMode,FALSE]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[AoEMode,FALSE]}]

	BuffProcGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffProcGroupMember,]}]
	BuffAmendsGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffAmendsGroupMember,]}]
	Secondary_Assist:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Secondary Assist,]}]
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

	if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+500]}) && \
		${Me.Ability[${SpellType[7]}].IsReady} && \
		(!${Me.Maintained[${SpellType[7]}](exists)} || ${Me.Maintained[${SpellType[7]}].Duration} < ${Me.Ability[${SpellType[7]}].CastingTime})
	{
		if ${Target.Type.Equal[NPC]}
		{
			;Debug:Echo["Casting PreWard"]
			call CastSpellRange 7 0 0 0 ${Actor[pc,exactname,${MainTankPC}].ID}
			ClassPulseTimer:Set[${Script.RunningTime}]
		}
	}

	;; This has to be set WITHIN any 'if' block that uses the timer.
	;ClassPulseTimer:Set[${Script.RunningTime}]
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	;Avoidance Lend
	PreAction[1]:Set[Resolute_Faith]
	PreSpellRange[1,1]:Set[32]

	PreAction[2]:Set[Self_Buffs]
	PreSpellRange[2,1]:Set[25]
	PreSpellRange[2,2]:Set[27]

	PreAction[3]:Set[Group_Buffs]
	PreSpellRange[3,1]:Set[20]
	PreSpellRange[3,2]:Set[21]

	PreAction[4]:Set[AA_Trample]
	PreSpellRange[4,1]:Set[383]

	PreAction[5]:Set[AA_Caveliers_Shout]
	PreSpellRange[5,1]:Set[384]

	PreAction[6]:Set[AA_Leadership]
	PreSpellRange[6,1]:Set[388]

	PreAction[7]:Set[AA_Aura_Leadership]
	PreSpellRange[7,1]:Set[389]

	PreAction[8]:Set[AA_Fearless]
	PreSpellRange[8,1]:Set[392]

	PreAction[9]:Set[AA_Raid_Armament]
	PreSpellRange[9,1]:Set[394]

	PreAction[10]:Set[Amends]
	PreSpellRange[10,1]:Set[30]

	PreAction[11]:Set[SA_Buff]
	PreSpellRange[11,1]:Set[31]

	PreAction[12]:Set[Stances]
	PreSpellRange[12,1]:Set[295]
	PreSpellRange[12,2]:Set[290]
}

function Combat_Init()
{

}

function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{
	declare BuffMember string local
	declare BuffTarget string local

	if ${ShardMode}
		call Shard

	switch ${PreAction[${xAction}]}
	{
		case Resolute_Faith
			BuffTarget:Set[${UIElement[cbBuffProcGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case SA_Buff
			if !${MainTank}
			{
				BuffTarget:Set[${UIElement[cbSecondary_Assist@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
					;Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

				if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				break
			}
			else
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			break
		case Amends
			BuffTarget:Set[${UIElement[cbBuffAmendsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case Self_Buffs
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		case Group_Buffs
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		case AA_Trample
		case AA_Caveliers_Shout
		case AA_Leadership
		case AA_Aura_Leadership
		case AA_Raid_Armament
		case AA_Fearless
			if ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady} && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Stances
			if ${DefensiveMode} && ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].TimeUntilReady}<.1 && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},2]}]}](exists)}
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},2]}]}]:Cancel
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			elseif !${DefensiveMode} && ${Me.Ability[${SpellType[${PreSpellRange[${xAction},2]}]}].TimeUntilReady}<.1 && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},2]}]}](exists)}
			{
				if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				{
					Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				}
				call CastSpellRange ${PreSpellRange[${xAction},2]}
			}
			break

		default
		    return BuffComplete
	 }
}

function Combat_Routine(int xAction)
{
	declare spellsused int local
	declare spellthreshold int local

	spellsused:Set[0]


	if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if ${Me.Health}<25
		call EmergencyHeal ${Me.ID}

	if ${HealerMode}
		call MeHeals

	if ${HealOthersMode}
		call CheckHeals

	;group proc buff, always use if avail
	if ${Me.Ability[${SpellType[387]}].IsReady}
		call CastSpellRange 387

	if ${Me.Ability[${SpellType[396]}].IsReady}
		call CastSpellRange 396

	if ${AoEMode} && ${Mob.Count}>1
	{
	  ;AoE

		if ${EpicMode}
			spellthreshold:Set[1]
		else
			spellthreshold:Set[3]

		;Zealous Smite
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[505]}].IsReady} && !${Me.Maintained[${SpellType[505]}](exists)}
		{
			call CastSpellRange 505 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		;Consecrate
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[97]}].IsReady} && !${Me.Maintained[${SpellType[97]}](exists)}
		{
			call CastSpellRange 97 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Faithful Cry
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[402]}].IsReady} && !${Me.Maintained[${SpellType[402]}](exists)}
		{
			call CastSpellRange 402 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Doom Judgement
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[94]}].IsReady} && !${Me.Maintained[${SpellType[94]}](exists)}
		{
			call CastSpellRange 94 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Lance
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[382]}].IsReady} && !${Me.Maintained[${SpellType[382]}](exists)}
		{
			call CastSpellRange 382 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Ancient Wrath
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[95]}].IsReady} && !${Me.Maintained[${SpellType[95]}](exists)}
		{
			call CastSpellRange 95 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Holy Strike
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[155]}].IsReady} && !${Me.Maintained[${SpellType[155]}](exists)}
		{
			call CastSpellRange 155 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Smite Evil
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[397]}].IsReady} && !${Me.Maintained[${SpellType[397]}](exists)}
		{
			call CastSpellRange 397 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Refusal of Atonement
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[61]}].IsReady} && !${Me.Maintained[${SpellType[61]}](exists)}
		{
			call CastSpellRange 61 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Castigate
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[98]}].IsReady} && !${Me.Maintained[${SpellType[98]}](exists)}
		{
			call CastSpellRange 98 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Decree
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[96]}].IsReady} && !${Me.Maintained[${SpellType[96]}](exists)}
		{
			call CastSpellRange 96 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Divine Vengence
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[152]}].IsReady} && !${Me.Maintained[${SpellType[152]}](exists)}
		{
			call CastSpellRange 152 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Heroic Dash
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[153]}].IsReady} && !${Me.Maintained[${SpellType[153]}](exists)}
		{
			call CastSpellRange 153 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Holy Circle
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[99]}].IsReady} && !${Me.Maintained[${SpellType[99]}](exists)}
		{
			call CastSpellRange 99 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Joust
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[380]}].IsReady} && !${Me.Maintained[${SpellType[380]}](exists)}
		{
			call CastSpellRange 380 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;;;; Master Strike
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[Master's Strike].IsReady} && ${Mob.CheckActor[${KillTarget}]}
		{
			Target ${KillTarget}
			Me.Ability[Master's Strike]:Use
			spellsused:Inc
		}
		;Judgement
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[62]}].IsReady} && !${Me.Maintained[${SpellType[62]}](exists)}
		{
			call CastSpellRange 62 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Swift Attack
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[381]}].IsReady} && !${Me.Maintained[${SpellType[381]}](exists)}
		{
			call CastSpellRange 381 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Clarion
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[160]}].IsReady} && !${Me.Maintained[${SpellType[160]}](exists)}
		{
			call CastSpellRange 160 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Power Cleave
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[154]}].IsReady} && !${Me.Maintained[${SpellType[154]}](exists)}
		{
			call CastSpellRange 154 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Penitent Kick
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[151]}].IsReady} && !${Me.Maintained[${SpellType[151]}](exists)}
		{
			call CastSpellRange 151 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Hammer Ground
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[385]}].IsReady} && !${Me.Maintained[${SpellType[385]}](exists)}
		{
			call CastSpellRange 385 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Faith Strike
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[150]}].IsReady} && !${Me.Maintained[${SpellType[150]}](exists)}
		{
			call CastSpellRange 150 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Righteousness
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[170]}].IsReady} && !${Me.Maintained[${SpellType[170]}](exists)}
		{
			call CastSpellRange 170 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Legionaire's Smite(4pt)
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[391]}].IsReady} && !${Me.Maintained[${SpellType[391]}](exists)}
		{
			call CastSpellRange 391 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}
	elseif ${Mob.Count}==1 || (!${AoEMode} && ${Mob.Count}>1)
	{
		;single target
		if ${EpicMode}
			spellthreshold:Set[1]
		else
			spellthreshold:Set[3]

		;Faithful Cry
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[402]}].IsReady} && !${Me.Maintained[${SpellType[402]}](exists)}
		{
			call CastSpellRange 402 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Consecrate
		if ${spellsused}<=${spellthreshold} && ${AoEMode} && ${Me.Ability[${SpellType[97]}].IsReady} && !${Me.Maintained[${SpellType[97]}](exists)}
		{
			call CastSpellRange 97 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Lance
		if ${spellsused}<=${spellthreshold} && ${AoEMode} && ${Me.Ability[${SpellType[382]}].IsReady} && !${Me.Maintained[${SpellType[382]}](exists)}
		{
			call CastSpellRange 382 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Holy Strike
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[155]}].IsReady} && !${Me.Maintained[${SpellType[155]}](exists)}
		{
			call CastSpellRange 155 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Refusal of Atonement
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[61]}].IsReady} && !${Me.Maintained[${SpellType[61]}](exists)}
		{
			call CastSpellRange 61 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Divine Vengence
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[152]}].IsReady} && !${Me.Maintained[${SpellType[152]}](exists)}
		{
			call CastSpellRange 152 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Zealous Smite
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[505]}].IsReady} && !${Me.Maintained[${SpellType[505]}](exists)}
		{
			call CastSpellRange 505 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Doom Judgement
		if ${spellsused}<=${spellthreshold} && ${AoEMode} && ${Me.Ability[${SpellType[94]}].IsReady} && !${Me.Maintained[${SpellType[94]}](exists)}
		{
			call CastSpellRange 94 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Heroic Dash
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[153]}].IsReady} && !${Me.Maintained[${SpellType[153]}](exists)}
		{
			call CastSpellRange 153 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Joust
		if ${spellsused}<=${spellthreshold} && ${AoEMode} && ${Me.Ability[${SpellType[380]}].IsReady} && !${Me.Maintained[${SpellType[380]}](exists)}
		{
			call CastSpellRange 380 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Ancient Wrath
		if ${spellsused}<=${spellthreshold} && ${AoEMode} && ${Me.Ability[${SpellType[95]}].IsReady} && !${Me.Maintained[${SpellType[95]}](exists)}
		{
			call CastSpellRange 95 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;;;; Master Strike
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[Master's Strike].IsReady} && ${Mob.CheckActor[${KillTarget}]}
		{
			Target ${KillTarget}
			Me.Ability[Master's Strike]:Use
			spellsused:Inc
		}
		;Judgement
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[62]}].IsReady} && !${Me.Maintained[${SpellType[62]}](exists)}
		{
			call CastSpellRange 62 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Swift Attack
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[381]}].IsReady} && !${Me.Maintained[${SpellType[381]}](exists)}
		{
			call CastSpellRange 381 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Clarion
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[160]}].IsReady} && !${Me.Maintained[${SpellType[160]}](exists)}
		{
			call CastSpellRange 160 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Smite Evil
		if ${spellsused}<=${spellthreshold} && ${AoEMode} && ${Me.Ability[${SpellType[397]}].IsReady} && !${Me.Maintained[${SpellType[397]}](exists)}
		{
			call CastSpellRange 397 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Castigate
		if ${spellsused}<=${spellthreshold} && ${AoEMode} && ${Me.Ability[${SpellType[98]}].IsReady} && !${Me.Maintained[${SpellType[98]}](exists)}
		{
			call CastSpellRange 98 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Power Cleave
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[154]}].IsReady} && !${Me.Maintained[${SpellType[154]}](exists)}
		{
			call CastSpellRange 154 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Penitent Kick
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[151]}].IsReady} && !${Me.Maintained[${SpellType[151]}](exists)}
		{
			call CastSpellRange 151 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Faith Strike
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[150]}].IsReady} && !${Me.Maintained[${SpellType[150]}](exists)}
		{
			call CastSpellRange 150 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Righteousness
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[170]}].IsReady} && !${Me.Maintained[${SpellType[170]}](exists)}
		{
			call CastSpellRange 170 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Legionaire's Smite(4pt)
		if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[391]}].IsReady} && !${Me.Maintained[${SpellType[391]}](exists)}
		{
			call CastSpellRange 391 0 0 0 ${KillTarget}
			spellsused:Inc
		}
		;Hammer Ground
		if ${spellsused}<=${spellthreshold} && ${AoEMode} && ${Me.Ability[${SpellType[385]}].IsReady} && !${Me.Maintained[${SpellType[385]}](exists)}
		{
			call CastSpellRange 385 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}

	call CommonHeals 70

	if ${DoHOs}
		objHeroicOp:DoHO

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${Start_HO}
		call CastSpellRange 303

	if ${Me.IsAfflicted}
		call CheckCures

	if ${RezMode}
		call CheckRez


	return CombatComplete

}

function Post_Combat_Routine(int xAction)
{
	
	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
	}
}

function Have_Aggro()
{

}

function Lost_Aggro(int mobid)
{

	if ${Actor[${KillTarget}].Target.ID}!=${Me.ID} && ${Me.Ability[${SpellType[270]}].IsReady}
		call CastSpellRange 270 0 1 0 ${Actor[${KillTarget}].ID}

	if ${Me.Ability[${SpellType[172]}].IsReady}
    call CastSpellRange 172 0 0 0 ${mobid}
	elseif ${Me.Ability[${SpellType[398]}].IsReady}
    call CastSpellRange 398 0 0 0 ${mobid}
	elseif ${Me.Ability[${SpellType[161]}].IsReady}
    call CastSpellRange 161 0 0 0 ${mobid}
	elseif ${Me.Ability[${SpellType[171]}].IsReady}
    call CastSpellRange 171 0 0 0 ${mobid}

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
	declare temphl int local
	declare grpheal int local 0
	declare lowest int local 0
	declare grpcure int local 0
	declare mostafflicted int local 0
	declare mostafflictions int local 0
	declare tmpafflictions int local 0
	declare PetToHeal int local 0

	temphl:Set[1]
	grpcure:Set[0]
	lowest:Set[1]

	do
	{
		if ${Me.Group[${temphl}].ZoneName.Equal[${Zone.Name}]}
		{
			if ${Me.Group[${temphl}].Health}<80 && ${Me.Group[${temphl}].Health}>-99 && ${Me.Group[${temphl}](exists)}
			{
				grpheal:Inc
				if ${Me.Group[${temphl}].Health}<=${Me.Group[${lowest}].Health}
					lowest:Set[${temphl}]
			}
		}
	}
	while ${temphl:Inc} <= ${Me.GroupCount}

	if ${Me.Health}<80 && ${Me.Health}>-99
		grpheal:Inc

	;MAINTANK EMERGENCY HEAL
	if ${Me.Group[${lowest}].Health}<30 && ${Me.Group[${lowest}].Name.Equal[${MainAssist}]} && ${Me.Group[${lowest}](exists)}
		call EmergencyHeal ${Actor[${MainAssist}].ID}

	;ME HEALS
	if ${Me.Health}<=${Me.Group[${lowest}].Health} && ${Me.Group[${lowest}](exists)}
	{
		call MeHeals
	}
	;MAINTANK HEALS
	if ${Actor[${MainTankPC}].Health}<50 && ${Actor[${MainTankPC}].Health}>-99 && ${Actor[${MainTankPC}](exists)}
		call CastSpellRange 5 0 0 0 ${Actor[${MainAssist}].ID}

	if ${Actor[${MainTankPC}].Health}<25 && ${Actor[${MainTankPC}].Health}>-99 && ${Actor[${MainTankPC}](exists)}
		call CastSpellRange 9 0 0 0 ${Actor[${MainAssist}].ID}

	;GROUP HEALS
	if ${grpheal}>2
	{
		if ${Me.Ability[${SpellType[10]}].IsReady}
			call CastSpellRange 15
	}

	if ${Me.Group[${lowest}].Health}<50 && ${Me.Group[${lowest}](exists)}
	{
		if ${Me.Ability[${SpellType[393]}].IsReady} && ${Me.Group[${lowest}].Health}>-99 && ${Me.Group[${lowest}](exists)}
			call CastSpellRange 393 0 0 0 ${Me.Group[${lowest}].ID}
		elseif ${Me.Ability[${SpellType[5]}].IsReady} && ${Me.Group[${lowest}].Health}>-99 && ${Me.Group[${lowest}](exists)}
			call CastSpellRange 5 0 0 0 ${Me.Group[${lowest}].ID}
		elseif && ${Me.Group[${lowest}].Health}>-99 && ${Me.Group[${lowest}](exists)}
			call CastSpellRange 9 0 0 0 ${Me.Group[${lowest}].ID}

	}
}

function MeHeals()
{

	if ${Me.Health}<50
	{
		if ${Me.Health}<25
			call EmergencyHeal ${Me.ID}

		if ${Me.Ability[${SpellType[393]}].IsReady}
			call CastSpellRange 393 0 0 0 ${Me.ID}
		elseif ${Me.Ability[${SpellType[5]}].IsReady}
			call CastSpellRange 5 0 0 0 ${Me.ID}
		elseif
			call CastSpellRange 6 0 0 0 ${Me.ID}
		else
			call CastSpellRange 9 0 0 0 ${Me.ID}
	}

	if ${Me.Health}<70 && ${Me.Ability[${SpellType[7]}].IsReady}
		call CastSpellRange 7 0 0 0 ${Me.ID}

	if ${Me.Health}<90 && ${Me.Ability[${SpellType[401]}].IsReady}
		call CastSpellRange 401 0 0 0 ${Me.ID}

	if ${Me.Health}<80 && ${Me.Ability[${SpellType[390]}].IsReady}
		call CastSpellRange 390 0 0 0 ${Me.ID}

}

function EmergencyHeal(int healtarget)
{
	;use stonewall
	if ${Me.Health}<50 && ${Me.Ability[${SpellType[400]}].IsReady}
		call CastSpellRange 400

	;use divine aura
	if ${Me.Health}<20 && ${Me.Ability[${SpellType[386]}].IsReady}
		call CastSpellRange 386

	if ${Me.Ability[${SpellType[9]}].IsReady}
		call CastSpellRange 9 0 0 0 ${healtarget}
	else
		call CastSpellRange 1 0 0 0 ${healtarget}
}

function CheckCures()
{

	;check if we are not in control, and use control cure if needed
	if !${Me.CanTurn} || ${Me.IsRooted}
		call CastSpellRange 399

	;use Castigate or Aura Self Cure
	if ${Me.IsAfflicted}
	{
		if ${AoEMode} && ${Me.Ability[${SpellType[98]}].IsReady}
			call CastSpellRange 98
		elseif ${Me.Ability[${SpellType[395]}].IsReady}
			call CastSpellRange 395
	}
}

function CheckRez()
{
	;Res Fallen Groupmembers only if in range
	do
	{
		if ${Me.Group[${tempgrp}].IsDead} && (${Me.Ability[${SpellType[300]}].IsReady})
		{
			call CastSpellRange 300 0 1 0 ${Me.Group[${tempgrp}].ID}
			;short wait for accept
			wait 50
		}
	}
	while ${tempgrp:Inc}<${grpcnt}
	if ${Me.InRaid} && (${Me.Ability[${SpellType[300]}].IsReady}
	{
		;Res Fallen RAID members only if in range
		do
		{
			if ${Me.Raid[${tempraid}].IsDead} && (${Me.Ability[${SpellType[300]}].IsReady}) && ${Me.Raid[${tempraid}].Distance}<25
			{
				call CastSpellRange 300 0 1 0 ${Me.Raid[${tempraid}].ID}
				;short wait for accept
				wait 50
			}
		}
		while ${tempraid:Inc}<=24 && (${Me.Ability[${SpellType[300]}].IsReady})
	}
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}
