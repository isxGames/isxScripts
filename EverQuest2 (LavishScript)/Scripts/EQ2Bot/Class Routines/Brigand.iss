;*****************************************************
;Brigand.iss 20070822a
;by Pygar
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
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
  ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
  declare ClassFileVersion int script 20080408
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

	;POISON DECLERATIONS - Still Experimental, but is working for these 3 for me.
	;EDIT THESE VALUES FOR THE POISONS YOU WISH TO USE
	;The SHORT name is the name of the poison buff icon
	DammagePoisonShort:Set[caustic poison]
	DebuffPoisonShort:Set[enfeebling poison]
	UtilityPoisonShort:Set[ignorant bliss]

	NoEQ2BotStance:Set[1]

	call EQ2BotLib_Init

	OffenseMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,TRUE]}]
	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	AnnounceMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Announce Debuffs,FALSE]}]
	TankMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Try to Tank,FALSE]}]
	BuffLunge:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Lunge Reversal,FALSE]}]
	MaintainPoison:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[MaintainPoison,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
	PetMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Pets,TRUE]}]

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

	ExecuteAtom CheckStuck

	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	{
	    ExecuteAtom AutoFollowTank
		wait 5
	}

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
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break

		case Confound
			if ${OffenseMode} && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
				wait 33
			}
			if !${OffenseMode}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Deffensive_Stance
			if (${TankMode} && !${OffenseMode}) && !${Me.Maintained[${PreSpellRange[${xAction},1]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break
		case Poisons
			if ${MaintainPoison}
			{
				Me:CreateCustomInventoryArray[nonbankonly]
				if !${Me.Maintained[${DammagePoisonShort}](exists)} && ${Me.CustomInventory[${DammagePoisonShort}](exists)}
				{
					Me.CustomInventory[${DammagePoisonShort}]:Use
				}

				if !${Me.Maintained[${DebuffPoisonShort}](exists)} && ${Me.CustomInventory[${DebuffPoisonShort}](exists)}
				{
					Me.CustomInventory[${DebuffPoisonShort}]:Use
				}

				if !${Me.Maintained[${UtilityPoisonShort}](exists)} && ${Me.CustomInventory[${UtilityPoisonShort}](exists)}
				{
					Me.CustomInventory[${UtilityPoisonShort}]:Use
				}
			}
			break
		case AA_Lunge_Reversal
			if ${BuffLunge}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break

		Default
			xAction:Set[40]
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


	if !${Me.AutoAttackOn}
		EQ2Execute /toggleautoattack

	AutoFollowingMA:Set[FALSE]
	if ${Me.ToActor.WhoFollowing(exists)}
		EQ2Execute /stopfollow



	;if stealthed, use ambush
	if !${MainTank} && ${Me.ToActor.IsStealthed} && ${Me.Ability[${SpellType[130]}].IsReady}
		call CastSpellRange 130 0 1 0 ${KillTarget}

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
		call CastSpellRange 303

	;use best debuffs on target if epic
	if ${Actor[${KillTarget}].IsEpic}
	{
		if ${Me.Ability[${SpellType[155]}].IsReady}
			call CastSpellRange 155 0 1 0 ${KillTarget} 0 0 1

		if ${Me.Ability[${SpellType[156]}].IsReady}
			call CastSpellRange 156 0 1 0 ${KillTarget} 0 0 1
	}

	;if heroic and over 80% health, use dps buffs
	if (${Actor[${KillTarget}].IsHeroic} && ${Actor[${KillTarget}].Health}>80) || (${Actor[${KillTarget}].IsEpic} && ${Actor[${KillTarget}].Health}>20)
	{
		if ${Me.Ability[${SpellType[155]}].IsReady}
			call CastSpellRange 155 0 1 0 ${KillTarget} 0 0 1
		if ${Me.Ability[${SpellType[156]}].IsReady}
			call CastSpellRange 156 0 1 0 ${KillTarget} 0 0 1
	}


	;;; AoE Checks
	if ${Mob.Count}>1
	{
		if ${spellsused}<=${spellthreshold} && ${AoEMode} && ${Me.Ability[${SpellType[90]}].IsReady}
		{
			call CastSpellRange 78 0 1 0 ${KillTarget}
			spellsused:Inc
		}

		if ${PBAoEMode} && ${Me.Ability[${SpellType[95]}].IsReady}
		{
			call CastSpellRange 95 0 1 0 ${KillTarget}
			call CastSpellRange 319 0 1 0 ${KillTarget}
			spellsused:Inc
		}
	}

	if ${MainTank}
	{
		call CastSpellRange 385 0 1 0 ${KillTarget}
		if ${Me.Maintained[${SpellType[385]}](exists)}
			call CastSpellRange 101 0 1 0 ${KillTarget}

		call CastSpellRange 152 0 1 0 ${KillTarget}

		if ${Me.Maintained[${SpellType[152]}](exists)} || ${Me.Maintained[${SpellType[385]}](exists)}
			call CastSpellRange 102 0 1 0 ${KillTarget}

		if ${Me.Maintained[${SpellType[152]}](exists)} || ${Me.Maintained[${SpellType[385]}](exists)}
			call CastSpellRange 100 0 1 0 ${KillTarget}

		if ${Me.Maintained[${SpellType[152]}](exists)} || ${Me.Maintained[${SpellType[385]}](exists)}
			call CastSpellRange 319 0 1 0 ${KillTarget}

		call CastSpellRange 160 0 1 0 ${KillTarget}
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[130]}].IsReady} && ${Me.Ability[${SpellType[201]}].IsReady}
	{
		call CastSpellRange 201 0 1 0 ${KillTarget}
		call CastSpellRange 130 0 1 0 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[50]}].IsReady}
	{
		call CastSpellRange 50 0 1 0 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[154]}].IsReady} && !${MainTank}
	{
		call CastSpellRange 154 0 1 0 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[382]}].IsReady}
	{
		call CastSpellRange 382 0 1 0 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[100]}].IsReady} && !${MainTank}
	{
		call CastSpellRange 100 0 1 1 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[102]}].IsReady} && !${MainTank}
	{
		call CastSpellRange 102 0 1 1 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[101]}].IsReady} && !${MainTank}
	{
		call CastSpellRange 101 0 1 1 ${KillTarget}
		spellsused:Inc
	}

	if !${MainTank} && ${Target.Target.ID}!=${Me.ID}
	{
		if ${Me.Ability[Sinister Strike].IsReady} && ${Actor[${KillTarget}](exists)} && !${InvalidMasteryTargets.Element[${Actor[${KillTarget}].ID}](exists)}
		{
			Target ${KillTarget}
			call CheckPosition 1 1
			Me.Ability[Sinister Strike]:Use
		}
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[151]}].IsReady}
	{
		call CastSpellRange 151 0 1 0 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[319]}].IsReady}
	{
		call CastSpellRange 319 0 1 0 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[185]}].IsReady}
	{
		call CastSpellRange 185 0 1 0 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[150]}].IsReady}
	{
		call CastSpellRange 150 0 1 0 ${KillTarget}
		spellsused:Inc
	}

	if !${MainTank} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[110]}].IsReady}
	{
		call CastSpellRange 110 0 1 1 ${KillTarget}
		spellsused:Inc
	}

	if !${MainTank} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[103]}].IsReady}
	{
		call CastSpellRange 103 0 1 1 ${KillTarget}
		spellsused:Inc
	}

	if ${PetMode} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[386]}].IsReady}
	{
		call CastSpellRange 386 0 1 0 ${KillTarget}
		spellsused:Inc
	}

	if !${MainTank} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[111]}].IsReady}
	{
		call CastSpellRange 111 0 1 1 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[152]}].IsReady}
	{
		call CastSpellRange 152 0 1 0 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[153]}].IsReady}
	{
		call CastSpellRange 153 0 1 0 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[381]}].IsReady}
	{
		call CastSpellRange 381 0 1 0 ${KillTarget}
		spellsused:Inc
	}

	if !${MainTank} && ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[385]}].IsReady}
	{
		call CastSpellRange 385 0 1 0 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[120]}].IsReady}
	{
		if ${Actor[${KillTarget}].Target.ID}!=${Me.ID}
			call CastSpellRange 120 0 1 3 ${KillTarget}
		else
			call CastSpellRange 120 0 1 2 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[76]}].IsReady}
	{
		call CastSpellRange 76 0 1 0 ${KillTarget}
		spellsused:Inc
	}

	if ${spellsused}<=${spellthreshold} && ${Me.Ability[${SpellType[386]}].IsReady}
	{
		call CastSpellRange 386 0 1 0 ${KillTarget}
		call CastSpellRange 130 0 1 0 ${KillTarget}
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
		call CastSpellRange 387 0 1 0 ${agroid} 0 0 1
	}
	elseif ${agroid}>0
	{
		if ${Me.Ability[${SpellType[185]}].IsReady}
		{
			;agro dump
			call CastSpellRange 185 0 1 0 ${agroid} 0 0 1
		}
		elseif ${Me.Ability[${SpellType[387]}].IsReady}
		{
			;feign
			call CastSpellRange 387 0 1 0 ${agroid} 0 0 1
		}
		else
		{
			call CastSpellRange 181 0 1 0 ${agroid} 0 0 1
		}

	}
}

function Lost_Aggro(int mobid)
{
	if ${Actor${mobid}].Target.ID}!=${Me.ID}
	{

		call CastSpellRange 270 0 1 0 ${Actor[${mobid}].ID}

		if ${MainTank}
		{
			KillTarget:Set[${mobid}]
			target ${mobid}

			if ${Actor${mobid}].Target.ID}!=${Me.ID}
			{
				call CastSpellRange 100 0 1 1 ${aggroid} 0 0 1
			}

			if ${Actor${mobid}].Target.ID}!=${Me.ID}
			{
				call CastSpellRange 101 0 1 1 ${aggroid} 0 0 1
			}

			if ${Actor${mobid}].Target.ID}!=${Me.ID}
			{
				call CastSpellRange 102 0 1 1 ${aggroid} 0 0 1
			}

			if ${Actor${mobid}].Target.ID}!=${Me.ID}
			{
				call CastSpellRange 103 0 1 1 ${aggroid} 0 0 1
			}

			call CastSpellRange 160 0 1 0 ${aggroid} 0 0 1
		}
	}

}

function MA_Lost_Aggro()
{

	;if tank lost agro, and I don't have agro, save the warlocks ass
	if ${Actor[${KillTarget}].Target.ID}!=${Me.ID}
	{
		call CastSpellRange 270 0 1 0 ${KillTarget} 0 0 1
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
	call UseCrystallizedSpirit 60

	if ${ShardMode}
		call Shard
}


