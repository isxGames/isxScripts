;*****************************************************
;Brigand.iss 20090618a
;by Pygar
;
;20090618a
; Updated for TSO AA and GU52 Spell Changes
;
;
;20070822a
; Fixed some typo's in spell list
; Removed Weapon Swapping
; Fixed feign on agro
; Fixed some range checks, should increase dps when combat is initiated when out of range.
;
;20070725a
; Fixed weapon swapping for new aa requirements,
; Adjusted announcement code
; Tweaked DPS Buff selections
; General fixes
;
;20070508a
; Fixed some old bugs brought back from consolidating versions.
;
;20070504a
; Source files diveraged, attempt to consolidate them back to single script
; May have introduced old bugs again, but fixed many.
;
;
; Final Tuning / AA configuration
; I believe this version represents the best a brigand can be botted
;*****************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20090618
	;;;;

	declare OffenseMode bool script 1
	declare DebuffMode bool script 0
	declare AoEMode bool script 0
	declare AnnounceMode bool script 0
	declare BuffLunge bool script 0
	declare MaintainPoison bool script 1
	declare DebuffPoisonShort string script
	declare DammagePoisonShort string script
	declare UtilityPoisonShort string script
	declare StartHO bool script 1
	declare PetMode bool script 1
	declare TankMode bool script 0
	declare BuffGuildGroupMember string script

	;POISON DECLERATIONS
	;EDIT THESE VALUES FOR THE POISONS YOU WISH TO USE
	;The SHORT name is the name of the poison buff icon
	DammagePoisonShort:Set[caustic poison]
	DebuffPoisonShort:Set[enfeebling poison]
	UtilityPoisonShort:Set[ignorant bliss]

	NoEQ2BotStance:Set[1]
	call EQ2BotLib_Init

	OffenseMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Offensive Spells,TRUE]}]
	DebuffMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	AnnounceMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Announce Debuffs,FALSE]}]
	TankMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Try to Tank,FALSE]}]
	BuffLunge:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff Lunge Reversal,FALSE]}]
	MaintainPoison:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[MaintainPoison,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	PetMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Pets,TRUE]}]
	BuffGuildGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffGuildGroupMember,]}]
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
	PreAction[1]:Set[Street_Smarts]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Reflexes]
	PreSpellRange[2,1]:Set[318]

	PreAction[3]:Set[Offensive_Stance]
	PreSpellRange[3,1]:Set[291]

	PreAction[4]:Set[Confound]
	PreSpellRange[4,1]:Set[27]

	PreAction[5]:Set[Deffensive_Stance]
	PreSpellRange[5,1]:Set[292]

	PreAction[6]:Set[Poisons]

	PreAction[7]:Set[AA_Lunge_Reversal]
	PreSpellRange[7,1]:Set[395]

	PreAction[8]:Set[AA_Evasiveness]
	PreSpellRange[8,1]:Set[397]
}

function Combat_Init()
{

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
		case Street_Smarts
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Reflexes
		case AA_Evasiveness
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Offensive_Stance
			if (${OffenseMode} || !${TankMode}) && !${Me.Maintained[${PreSpellRange[${xAction},1]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Confound
			if ${OffenseMode} && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
				wait 33
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
				Me:CreateCustomInventoryArray[nonbankonly]
				if !${Me.Maintained[${DammagePoisonShort}](exists)} && ${Me.CustomInventory[${DammagePoisonShort}](exists)}
					Me.CustomInventory[${DammagePoisonShort}]:Use

				if !${Me.Maintained[${DebuffPoisonShort}](exists)} && ${Me.CustomInventory[${DebuffPoisonShort}](exists)}
					Me.CustomInventory[${DebuffPoisonShort}]:Use

				if !${Me.Maintained[${UtilityPoisonShort}](exists)} && ${Me.CustomInventory[${UtilityPoisonShort}](exists)}
					Me.CustomInventory[${UtilityPoisonShort}]:Use
			}
			break
		case AA_Lunge_Reversal
			if ${BuffLunge}
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
	declare spellsused int local
	declare spellthreshold int local

	spellsused:Set[0]
	if ${Actor[${KillTarget}].IsEpic}
		spellthreshold:Set[5]
	else
		spellthreshold:Set[3]

	if (!${RetainAutoFollowInCombat} && ${Me.WhoFollowing(exists)})
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}

	if ${Actor[${KillTarget}].Distance}>${Position.GetMeleeMaxRange[${KillTarget}]} && ${Actor[${KillTarget}].Distance}<${Position.GetSpellMaxRange[${KillTarget},0,${Me.Ability[${SpellType[250]}].ToAbilityInfo.MaxRange}]}
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

	;if stealthed, use ambush
	if !${MainTank} && ${Me.IsStealthed} && ${Me.Ability[${SpellType[130]}].IsReady}
		call CastSpellRange 130 0 1 0 ${KillTarget} 0 0 0 0 1

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
		call CastSpellRange 303

	;if heroic and over 80% health, use dps buffs
	if (${Actor[${KillTarget}].IsHeroic} && ${Actor[${KillTarget}].Health}>80) || (${Actor[${KillTarget}].IsEpic} && ${Actor[${KillTarget}].Health}>5)
	{
		if ${Me.Ability[${SpellType[155]}].IsReady}
			call CastSpellRange 155 0 1 0 ${KillTarget} 0 0 0 0 1
		if ${Me.Ability[${SpellType[156]}].IsReady}
			call CastSpellRange 156 0 1 0 ${KillTarget} 0 0 0 0 1
	}

	if ${Actor[${KillTarget}].IsEpic} && ${Actor[${KillTarget}].Health}<8
		call CastSpellRange 503 0 1 0 ${KillTarget} 0 0 0 0 1

	;;; AoE Checks
	if ${Mob.Count}>1
	{
		if ${spellsused}<=${spellthreshold} && ${AoEMode} && ${Me.Ability[${SpellType[90]}].IsReady}
		{
			call CastSpellRange 78 0 1 0 ${KillTarget} 0 0 0 0 1
			spellsused:Inc
		}

		if ${PBAoEMode} && ${Me.Ability[${SpellType[95]}].IsReady}
		{
			call CastSpellRange 95 0 1 0 ${KillTarget} 0 0 0 0 1
			call CastSpellRange 319 0 1 0 ${KillTarget} 0 0 0 0 1
			spellsused:Inc
		}
	}

	if ${MainTank}
	{
		call CastSpellRange 385 0 1 0 ${KillTarget} 0 0 0 0 1
		if ${Me.Maintained[${SpellType[385]}](exists)}
			call CastSpellRange 101 0 1 0 ${KillTarget} 0 0 0 0 1

		call CastSpellRange 152 0 1 0 ${KillTarget} 0 0 0 0 1

		if ${Me.Maintained[${SpellType[152]}](exists)} || ${Me.Maintained[${SpellType[385]}](exists)}
			call CastSpellRange 102 0 1 0 ${KillTarget} 0 0 0 0 1

		if ${Me.Maintained[${SpellType[152]}](exists)} || ${Me.Maintained[${SpellType[385]}](exists)}
			call CastSpellRange 100 0 1 0 ${KillTarget} 0 0 0 0 1

		if ${Me.Maintained[${SpellType[152]}](exists)} || ${Me.Maintained[${SpellType[385]}](exists)}
			call CastSpellRange 319 0 1 0 ${KillTarget} 0 0 0 0 1

		call CastSpellRange 160 0 1 0 ${KillTarget} 0 0 0 0 1
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[130]}].IsReady} && ${Me.Ability[${SpellType[390]}].IsReady} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
	{
		call CastSpellRange 390 0 1 0 ${KillTarget} 0 0 0 0 1
		call CastSpellRange 130 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}
	elseif ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[130]}].IsReady} && ${Me.Ability[${SpellType[185]}].IsReady} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
	{
		call CastSpellRange 185 0 1 0 ${KillTarget} 0 0 0 0 1
		call CastSpellRange 130 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}
	elseif ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[130]}].IsReady} && ${Me.Ability[${SpellType[201]}].IsReady} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
	{
		call CastSpellRange 201 0 1 0 ${KillTarget} 0 0 0 0 1
		call CastSpellRange 130 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[501]}].IsReady}
	{
		call CastSpellRange 501 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if !${MainTank} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[500]}].IsReady}
	{
		call CastSpellRange 500 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[50]}].IsReady}
	{
		call CastSpellRange 50 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[154]}].IsReady} && !${MainTank}
	{
		call CastSpellRange 154 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[382]}].IsReady}
	{
		call CastSpellRange 382 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[502]}].IsReady}
	{
		call CastSpellRange 502 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[100]}].IsReady} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
	{
		call CastSpellRange 100 0 1 1 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[102]}].IsReady} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
	{
		call CastSpellRange 102 0 1 1 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[101]}].IsReady} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
	{
		call CastSpellRange 101 0 1 1 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if !${MainTank} && ${Target.Target.ID}!=${Me.ID}
	{
		if ${Me.Ability[Sinister Strike].IsReady} && ${Actor[${KillTarget}].Name(exists)} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
		{
			Target ${KillTarget}
			call CheckPosition 1 1 ${KillTarget}
			Me.Ability[Sinister Strike]:Use
			wait 4
		}
	}

	call CommonHeals 70

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[151]}].IsReady}
	{
		call CastSpellRange 151 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[319]}].IsReady}
	{
		call CastSpellRange 319 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[185]}].IsReady}
	{
		call CastSpellRange 185 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[150]}].IsReady}
	{
		call CastSpellRange 150 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if !${MainTank} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[110]}].IsReady}
	{
		call CastSpellRange 110 0 1 1 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if !${MainTank} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[103]}].IsReady} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
	{
		call CastSpellRange 103 0 1 1 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${PetMode} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[386]}].IsReady}
	{
		call CastSpellRange 386 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if !${MainTank} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[111]}].IsReady} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
	{
		call CastSpellRange 111 0 1 1 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[152]}].IsReady}
	{
		call CastSpellRange 152 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[153]}].IsReady}
	{
		call CastSpellRange 153 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[381]}].IsReady}
	{
		call CastSpellRange 381 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if !${MainTank} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[385]}].IsReady}
	{
		call CastSpellRange 385 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[120]}].IsReady} && (${Actor[${KillTarget}].Target.ID}!=${Me.ID} || !${Actor[${KillTarget}].CanTurn})
	{
		if ${Actor[${KillTarget}].Target.ID}!=${Me.ID}
			call CastSpellRange 120 0 1 3 ${KillTarget} 0 0 0 0 1
		else
			call CastSpellRange 120 0 1 2 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[76]}].IsReady}
	{
		call CastSpellRange 76 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[386]}].IsReady}
	{
		call CastSpellRange 386 0 1 0 ${KillTarget} 0 0 0 0 1
		call CastSpellRange 130 0 1 0 ${KillTarget} 0 0 0 0 1
		spellsused:Inc
	}
	if ${DoHOs}
		objHeroicOp:DoHO

	call ActionChecks

	return CombatComplete


}

function Post_Combat_Routine(int xAction)
{
	if ${Me.Maintained[Sneak](exists)}
	{
		Me.Maintained[Sneak]:Cancel
	}

	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro(int agroid)
{

	echo I have agro from ${agroid}
	if ${OffenseMode} && ${Me.Ability[${SpellType[387]}].IsReady} && ${agroid}>0
	{
		;Trickery
		call CastSpellRange 387 0 1 0 ${agroid} 0 0 0 0 1
	}
	elseif ${agroid}>0
	{
		if ${Me.Ability[${SpellType[185]}].IsReady}
		{
			;agro dump
			call CastSpellRange 185 0 1 0 ${agroid} 0 0 0 0 1
		}
		elseif ${Me.Ability[${SpellType[387]}].IsReady}
		{
			;feign
			call CastSpellRange 387 0 1 0 ${agroid} 0 0 0 0 1
		}
		else
		{
			call CastSpellRange 181 0 1 0 ${agroid} 0 0 0 0 1
		}

	}
}

function Lost_Aggro(int mobid)
{
	if ${Actor[${mobid}].Target.ID}!=${Me.ID}
	{

		call CastSpellRange 270 0 1 0 ${Actor[${mobid}].ID}

		if ${MainTank}
		{
			KillTarget:Set[${mobid}]
			target ${mobid}

			if ${Actor[${mobid}].Target.ID}!=${Me.ID}
			{
				call CastSpellRange 100 0 1 1 ${aggroid} 0 0 0 0 1
			}

			if ${Actor[${mobid}].Target.ID}!=${Me.ID}
			{
				call CastSpellRange 101 0 1 1 ${aggroid} 0 0 0 0 1
			}

			if ${Actor[${mobid}].Target.ID}!=${Me.ID}
			{
				call CastSpellRange 102 0 1 1 ${aggroid} 0 0 0 0 1
			}

			if ${Actor[${mobid}].Target.ID}!=${Me.ID}
			{
				call CastSpellRange 103 0 1 1 ${aggroid} 0 0 0 0 1
			}

			call CastSpellRange 160 0 1 0 ${aggroid} 0 0 0 0 1
		}
	}

}

function MA_Lost_Aggro()
{

	;if tank lost agro, and I don't have agro, save the warlocks ass
	if ${Actor[${KillTarget}].Target.ID}!=${Me.ID}
	{
		call CastSpellRange 270 0 1 0 ${KillTarget} 0 0 0 0 1
	}
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
	call CommonHeals 70

	if ${ShardMode}
		call Shard
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}
