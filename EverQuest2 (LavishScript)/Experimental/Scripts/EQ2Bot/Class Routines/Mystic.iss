/********************************************************************************
Mystic SubScript for Blazers EQ2Bot
Version 1.26
	By Mandrake

REQUIRES:  "eq2botlib", and "Heroic Op Object"


Todo:
- Fix rezes?
- Better organize the order debuffs are cast (Slow first)
- Improve method for casting feathers (on group change?)
- implement Eidolic Savior (oh shit buff)
- implement Prophetic Shield (poison/disease ward)

v. 1.26
-  Removed depenancy on bottools.iss, and just included in this file
-  Spell list is up to date to 70
-  Increased the use of the healing badger dude....
-  Casts a group ward if MA looses agro



v. 1.25
-  Integrated HO object
-  Integrated EQ2BotLib
-  Added UI
-  Implemented Cures (just group for now)
-  Spell list to 69

v. 1.23
- Somewhat updated spell list to 60(unverified, guesswork)
- Filled in blank spell list to 70
- Implemented Group Heals
- Moved Shadowy Attendant casting to a heal
- Heals pet in autohunt mode

v. 1.22
- Spell lists to 56
- Updated some heals
- Made bot check heals more often.

v. 1.21 Broke off BotTools

v. 1.20
- Started to implement "BotTools" objects.. crude so far
	- BotTools objects will be a collection of commonly used loops and routines, put in easy to call object form
- Spell list to 45
- Added code for Shadowy Attendant

v. 1.14
- Re-fixed stupid typo on power checks.. /sigh
- Somewhat fixed an issue with having too many effects to check for sow
- Added the AA "ritual" before casting a heal

v. 1.13
- Fixed the power checks for nukes/debuffs/etc...
- Some modifications to the combat routines to fix autohunting
- Tweaked the pet attack to use killtarget instead of MT target
- Brought spells up to 43
*not tested in group yet.

V. 1.12
- More minor bug fixes

V. 1.11
- Minor bug fix with combat rez

V. 1.1
- Update for eq2bot 2.2 (heal routines)
- Added Sow
- Added Combat Rez
- Added Feathers (Sorta)
- Spell list to 41
********************************************************************************/
#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif
function Class_Declaration()
{
	;===============================================;
	;CurState variable for display on the UI	;
	;===============================================;

	declare CurState string script
	declare debugoutput bool script 0
	objHeroicOp:Intialize
	objHeroicOp:LoadUI

	;=======================================;
	;Set the window Title to player name	;
	;=======================================;
	Windowtext ${Me.Name}(${Session})
	Declare Tools BotTools script
	call EQ2BotLib_Init


}

function Buff_Init()
{
	;=======================================;
	;Using generic 25-29 for self buffs	;
	;Even tho there are none		;
	;=======================================;
	PreAction[1]:Set[Self_Buff]
	PreSpellRange[1,1]:Set[25]
	PreSpellRange[1,2]:Set[29]

	;===============================;
	;Group Buffs W/O Concentration	;
	; There are none poon!		;
	;===============================;
	;PreAction[2]:Set[Group_Buff]
	;PreSpellRange[2,1]:Set[280]
	;PreSpellRange[2,2]:Set[282]

	;===============================;
	;Group Buffs WITH Concentration	;
	;===============================;
	PreAction[2]:Set[Group_Conc_Buff]
	PreSpellRange[2,1]:Set[21]
	PreSpellRange[2,2]:Set[24]

	;===============================;
	;Single Target Conc Buffs	;
	;===============================;
	PreAction[3]:Set[Single_Conc_Buff]
	PreSpellRange[3,1]:Set[35]
	PreSpellRange[3,2]:Set[37]

	;===============================;
	;Tank Buff (Needs Fixing)	;
	;===============================;
	PreAction[4]:Set[Tank_Buff]
	PreSpellRange[4,1]:Set[40]
	PreSpellRange[4,2]:Set[42]

	;=======;
	;Rez up	;
	;=======;
	PreAction[5]:Set[Resurrection]
	PreSpellRange[5,1]:Set[300]


	;=======;
	;Pet	;
	;=======;
	PreAction[6]:Set[Cast_Pet]
	PreSpellRange[6,1]:Set[600]
	;PreSpellRange[6,2]:Set[602]



	;=======================;
	;SOw (Experimental)	;
	;=======================;
	;PreAction[8]:Set[SoW]
	;PreSpellRange[8,1]:Set[302]
}

function Combat_Init()
{

	;===============;
	;Bolster        ;
	;===============;
	Action[1]:Set[Bolster]
	SpellRange[1,1]:Set[155]

	;=======================;
	;Send in the AA pet	;
	;=======================;

	Action[2]:Set[Pet_Attack]

	;===============================;
	;Debuff	(if mob is > 50%	;
	;===============================;
	Action[3]:Set[Debuff]
	SpellRange[3,1]:Set[50]
	SpellRange[3,2]:Set[54]
	MobHealth[3,1]:Set[50]
	MobHealth[3,2]:Set[90]
	Power[3,1]:Set[60]
	Power[3,2]:Set[100]

	;===============================;
	;Dot	(if mob is > 50%)	;
	;===============================;
	Action[4]:Set[Dot]
	SpellRange[4,1]:Set[70]
	SpellRange[4,2]:Set[72]
	MobHealth[4,1]:Set[30]
	MobHealth[4,2]:Set[70]
	Power[4,1]:Set[40]
	Power[4,2]:Set[100]

	;===============;
	;Nuke + Debuff	;
	;===============;
	Action[5]:Set[Nuke]
	SpellRange[5,1]:Set[80]
	SpellRange[5,2]:Set[82]
	Power[5,1]:Set[40]
	Power[5,2]:Set[100]

	;===============;
	;Combat Rez	;
	;===============;
	Action[6]:Set[Combat_Rez]
	SpellRange[6,1]:Set[320]
	SpellRange[6,2]:Set[321]


	;=======================;
	;AOE Nuke		;
	;(ehh, what did i do?)	;
	;=======================;
	;Action[5]:Set[AOE_Nuke]
	;SpellRange[5,1]:Set[80]
	;SpellRange[5,2]:Set[82]
	;Power[5,1]:Set[80]
	;Power[5,2]:Set[100]



}

function PostCombat_Init()
{
	;=======================================;
	;We'll need to check for rezes here	;
	;=======================================;
	PostAction[1]:Set[Resurrection]
	PostSpellRange[1,1]:Set[300]
	PostSpellRange[1,2]:Set[301]
}


function Buff_Routine(int xAction)
{
	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
	}
	if !${Me.ToActor.IsInvis}
	{
		grpcnt:Set[${Me.GroupCount}]
		tempgrp:Set[1]
		CurState:Set["Buffing: ${PreAction[${xAction}]}"]
		call CheckHeals
		switch ${PreAction[${xAction}]}
		{
			case Self_Buff
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
				break

			case Group_Buff
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
				break

			case Group_Conc_Buff
				;===============================================;
				;Check that we have concentration available	;
				;===============================================;
				if ${Me.UsedConc}<5
				{
					if ${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[${Me.SubClass}].GetString[Use Aegis]}
					{
						call CastSpellRange 20
					}
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
				}
				break

			case Single_Conc_Buff
				;=======================================================;
				;Check that we have concentration available		;
				;TODO: Decide who gets HP buff when (MT Only for now)	;
				;=======================================================;
				if ${Me.UsedConc}<5
				{
					if ${MainTank}
					{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
					}
					else
					{
					target ${Actor[${MainTankPC}].ID}
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${MainTankPC}].ID}
					}
				}
				break

			case Tank_Buff
				;===============================================;
				;Check that we have concentration available	;
				;===============================================;
				if ${Me.UsedConc}<5
				{
					if ${MainTank}
					{
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 0 0 ${Me.ID}
					}
					else
					{
						if ${Tools.InGroup[${Actor[${MainTankPC}].ID}]}
						{
						call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 0 0 ${Actor[${MainTankPC}].ID}
						}
					}
				}
				break

			case Resurrection
				grpcnt:Set[${Me.GroupCount}]
				tempgrp:Set[1]
				do
				{
					if ${Me.Group[${tempgrp}].ZoneName.Equal["${Zone.Name}"]}
					{

						if ${Me.Group[${tempgrp}].ToActor.Health}<=0 && ${Me.Group[${tempgrp}](exists)} && ${Me.Group[${tempgrp}].ToActor.Distance} < 50
						{
							call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 1 0 ${Me.Group[${tempgrp}].ID} 1
						}
					}
				}
				while ${tempgrp:Inc}<${grpcnt}
				break
			case Cast_Pet
					if "!(${Actor[MyPet](exists)})"
					{

						call CastSpellRange 400
						;move pet buffs to another sequence
						call CastSpellRange 396 399
					}
				break
			case SoW
				;=======================================================;
				;Check sow on self first				;
				;Lame hack, using this as a timer for feathers too	;
				;=======================================================;
				if !${Me.ToActor.Effect[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				{
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
					call CastSpellRange 350
				}
				grpcnt:Set[${Me.GroupCount}]
				tempgrp:Set[1]
				do
				{
					if !${Me.Group[${tempgrp}].ToActor.Effect[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Me.Group[${tempgrp}](exists)} && ${Me.ToActor.NumEffects} < 15
					{
						;=======================================================================================================;
						;Having more effects on that can be displayed on the screen sometimes causes a casting loop of sow	;
						;=======================================================================================================;
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.Group[${tempgrp}].ID}
					}
				}
				while ${tempgrp:Inc}<${grpcnt}
				break

			Default
				xAction:Set[40]
				break
		}
	}
	else
	{
		CurState:Set["INVIS! Not Buffing"]
	}
}


function Combat_Routine(int xAction)
{
	objHeroicOp:DoHO
	AutoFollowingMA:Set[FALSE]
	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}
	CurState:Set["Combat: ${Action[${xAction}]}"]
	call CheckWards

	/********************************
	*Stay in Heal Routine if needed	*
	********************************/
	do
	{
		call CheckHeals
	}
	while ${return}==TRUE
	if ${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[${Me.SubClass}].GetString[Cast Cure Spells]}
	{
		call CheckCures
	}
		switch ${Action[${xAction}]}
		{
		case Debuff
			if ${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[${Me.SubClass}].GetString[Cast Debuff Spells]}
			{
				;=======================================;
				;Check Mob health before Debuffing	;
				;=======================================;
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 0 ${KillTarget} 1
					}
				}
			}
			break
		case Pet_Attack
			if ${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[${Me.SubClass}].GetString[Pet_Attack]}
			{
				if ${Actor[MyPet].Target.ID}!=${KillTarget} && ${Actor[MyPet](exists)} && ${Actor[${KillTarget}].Health} <= 98
				{
					EQ2Execute /pet attack
				}
			}
			break

		case DoT
			;=======================================;
			;Check Mob Health before dotting	;
			;=======================================;
			if ${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[${Me.SubClass}].GetString[Cast Offensive Spells]}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 0 ${KillTarget} 1
					}
				}
			}
			break
		case Nuke
			if ${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[${Me.SubClass}].GetString[Cast Offensive Spells]}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 0 ${KillTarget} 1
				}
			}
			break
		case AOE_Nuke
			if ${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[${Me.SubClass}].GetString[Cast Offensive Spells]} && ${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[${Me.SubClass}].GetString[Cast AoE Spells]}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call NPCCount
					if ${Return}>2
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${KillTarget} 1
					}
				}
			}
			break
		case Combat_Rez
			if ${Actor[${MainAssist}].Health}<95
			{
				grpcnt:Set[${Me.GroupCount}]
				tempgrp:Set[1]
				do
				{
					if ${Me.Group[${tempgrp}].ZoneName.Equal["${Zone.Name}"]}
					{
						if ${Me.Group[${tempgrp}].ToActor.Health}<=-99 && ${Me.Group[${tempgrp}](exists)} && ${Me.Group[${tempgrp}].ToActor.Distance} < 50
						{
							call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 1 0 ${Me.Group[${tempgrp}].ID} 1
						}
					}
				}
				while ${tempgrp:Inc}<${grpcnt}
			}
			break
		case Bolster
			if ${Actor[${MainTankPC}].Health}>80
			{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${Actor[${MainTankPC}].ID} 1
			}
			break

		Default
			xAction:Set[40]
			break
		}

}
function CheckCures()
{
declare grpcnt int
declare temp2 int
declare tempgrp int
	grpcnt:Set[${Me.GroupCount}]
	CurState:Set["Cures: Checking Group Cures"]
	temp2:Set[1]
	do
	{
		echo Checking Group Member ${temp2}
		if !${Me.Group[${temp2}].ToActor.Effect[Revived Sickness](exists)} && ${Me.Group[${temp2}].IsAfflicted}
		{
			grpCureCount:Inc
		}

	}
	while ${temp2:Inc}<${grpcnt}

	if ${grpCureCount} > 3
	{
		call CastSpellRange 220
	}
	CurState:Set["Cures: Checking Single Cures"]
	tempgrp:Set[1]
	do
	{
		if ${Me.Group[${tempgrp}].ZoneName.Equal["${Zone.Name}"]}
		{
			if  ${Me.Group[${tempgrp}].Arcane}>0 && !${Me.Group[${tempgrp}].ToActor.Effect[Revived Sickness](exists)}
			{
				call CastSpellRange 213 0 0 0 ${Me.Group[${tempgrp}].ID}
			}
			if  ${Me.Group[${tempgrp}].Noxious}>0
			{
				call CastSpellRange 210 0 0 0 ${Me.Group[${tempgrp}].ID}
			}
			if  ${Me.Group[${tempgrp}].Elemental}>0
			{
				call CastSpellRange 212 0 0 0 ${Me.Group[${tempgrp}].ID}
			}
			if  ${Me.Group[${tempgrp}].Trauma}>0
			{
				call CastSpellRange 211 0 0 0 ${Me.Group[${tempgrp}].ID}
			}
		}
	}
	while ${tempgrp:Inc}<${grpcnt}
	;===============================================;
	;Now check yourself				;
	;There should be a better way to do this	;
	;===============================================;

			if  ${Me.Arcane}>0 && !${Me.ToActor.Effect[Revived Sickness](exists)}
			{
				call CastSpellRange 213 0 0 0 ${Me.ID}
			}
			if  ${Me.Noxious}>0
			{
				call CastSpellRange 210 0 0 0 ${Me.ID}
			}
			if  ${Me.Elemental}>0
			{
				call CastSpellRange 212 0 0 0 ${Me.ID}
			}
			if  ${Me.Trauma}>0
			{
				call CastSpellRange 211 0 0 0 ${Me.ID}
			}
}

function CheckWards()
{

	CurState:Set["Heals: Checking Wards"]

	;===============================================;
	;First off, lets make sure the MT has a ward on	;
	;Loop through maintained spells, find a ward	;
	;===============================================;
	declare tempvar int local 1
	declare ward1 int local 0
	declare grpward int local 0
	ward1:Set[0]
	grpward:Set[0]
	if ${Me.InCombat}
	{
		do
		{
			if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[7]}]}&&${Me.Maintained[${tempvar}].Target.ID}==${Actor[${MainTankPC}].ID}
			{
			;===============================================;
			;Set the var Ward1 if ward is still present	;
			;===============================================;
				;echo Ward is present.
			ward1:Set[1]
			break
			}
			elseif ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[15]}]}
			{
				;echo Group ward Present
			grpward:Set[1]
			}
		}
		while ${tempvar:Inc}<=${Me.CountMaintained}

		if ${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[${Me.SubClass}].GetString[Single_Wards]}
		{
			if ${ward1}==0&&${Me.Power}>${Me.Ability[${SpellType[7]}].PowerCost}
			{
				CurState:Set["Heals: Setting Ward"]
				call CastSpellRange 7 0 0 0 ${Actor[${MainAssist}].ID}
				ward1:Set[1]
			}
		}

		if ${SettingXML[Scripts/EQ2Bot/Character Config/${Me.Name}.xml].Set[${Me.SubClass}].GetString[Group_Wards]}
		{
			if ${grpward}==0&&${Me.Power}>${Me.Ability[${SpellType[15]}].PowerCost}
			{
				echo Casting Group Ward
			call CastSpellRange 15 0 0 0 ${Actor[${MainAssist}].ID}
			}
		}



		;=======================================================================;
		;Next, See if ward2 needs to be used (Long recast, emergency ward)	;
		;=======================================================================;
		if ${Actor[${MainAssist}].Health}<30
		{
			CurState:Set["Heal: Emergency Ward"]
			call CastSpellRange 8 0 0 0 ${Actor[${MainAssist}].ID}
		}
	}
}
function CheckHeals()
{
	declare tmpgrp int local 1
	declare healreturn bool local FALSE
/****************************************
quick check on pet if autohunting
****************************************/
if ${PathType}==4
{
	if ${Actor[MyPet].Health}<70&&${Actor[MyPet](exists)}
	{
		call CastSpellRange 4 0 0 0 ${Actor[MyPet].ID}
		healreturn:Set[TRUE]
	}
}

/****************************************
*   Check for needed group heals	*
****************************************/
if ${Tools.LowHealthCount[50]}>3&&${Me.Ability[${SpellType[16]}].IsReady}
{
	;Cast an emergency group ward
	call CastSpellRange 16
	healreturn:Set[TRUE]
}
elseif ${Tools.LowHealthCount[70]} > 3
{
	;Cast a normal Group Heal
	call CastSpellRange 10
	healreturn:Set[TRUE]
}

if ${Tools.LowHealthCount[90]} > 3
{
	;Cast lil healer badger dude
	call CastSpellRange 351
	healreturn:Set[TRUE]
}
;=======================================================;
;Now, Pick the appropriate Heal for the assesed damage	;
;Prioritize MT and other healers			;
;=======================================================;
	if ${Actor[${Tools.LowestHealth}](exists)}
	{
	;=======================================================================;
	;Adding code to cast "Ritual" AA					;
	;Need to do a check here, to swap a symbol into secondary, and back out	;
	;=======================================================================;
		if ${Me.Ability[Ritual].IsReady} && ${Me.Equipment[Secondary].Name.Find[Symbol]}
		{
		call CastSpellRange 356
		healreturn:Set[TRUE]
		}

		if ${Actor[${Tools.LowestHealth}].Health} <= 20
		{
			call CastSpellRange 312 0 0 0 ${Actor[${Tools.LowestHealth}].ID}
			healreturn:Set[TRUE]
		}
		elseif ${Actor[${Tools.LowestHealth}].Health} <= 60
		{
			;=======================;
			;Use a Big heal		;
			;=======================;
			CurState:Set["Healing: ${Actor[${Tools.LowestHealth}].Name} (Large)"]
			if ${Me.Ability[${SpellType[9]}].IsReady}
			{
				call CastSpellRange 9 0 0 0 ${Actor[${Tools.LowestHealth}].ID}
				healreturn:Set[TRUE]
			}
			elseif ${Me.Power} > ${Me.Ability[${SpellType[1]}].PowerCost}
			{
				;target ${Actor[${lowest}].ID}
				call CastSpellRange 1 0 0 0 ${Actor[${Tools.LowestHealth}].ID}
				healreturn:Set[TRUE]
			}
			return ${healreturn}
		}
		elseif ${Actor[${Tools.LowestHealth}].Health} < 80
		{
			;=======================;
			;Use a Small heal	;
			;=======================;
			if ${Me.Power} > ${Me.Ability[${SpellType[4]}].PowerCost}
			{
				;target ${Actor[${Tools.LowestHealth}].ID}
				;CurState:Set["Healing: ${Actor[${Tools.LowestHealth}].Name} (Small)"]
				call CastSpellRange 4 0 0 0 ${Actor[${Tools.LowestHealth}].ID}
				healreturn:Set[TRUE]
			}
			return ${healreturn}
		}
		else
		{
			;===============================;
			;Suck it up, and quit whinin!	;
			;===============================;
			Return
		}
	}
	else
	{
	if ${debugoutput}
		echo Actor does not exists
	Return
	}


}

function Post_Combat_Routine()
{
call CheckHeals
call CheckCures
PetEngage:Set[FALSE]
	switch ${PostAction[${xAction}]}
	{
		case Resurrection
			grpcnt:Set[${Me.GroupCount}]
			tempgrp:Set[1]
			do
			{
				if ${Me.Group[${tempgrp}].ZoneName.Equal["${Zone.Name}"]}
				{
					if ${Me.Group[${tempgrp}].ToActor.Health}<=-99 && ${Me.Group[${tempgrp}](exists)} && ${Me.Group[${tempgrp}].ToActor.Distance} < 50
					{
						call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 1 0 ${Me.Group[${tempgrp}].ID} 1
					}
				}
			}
			while ${tempgrp:Inc}<${grpcnt}
			break

		Default
			xAction:Set[20]
			break
	}
}

function Lost_Aggro()
{

}
function Have_Aggro()
{
 call CastSpellRange 180 0 0 0 ${Actor[${MainAssist}].ID}
}

function MA_Lost_Aggro()
{
 echo "MA Lost Agro, Casting a Group Ward"
 call CastSpellRange 15 0 0 0 ${Actor[${MainAssist}].ID}
}

function MA_Dead()
{

}


/*******************************************************************
BotTools v.0.02
	By Mandrake


Example:
	#include ${LavishScript.HomeDirectory}/Scripts/BotTools.iss
		function Class_Declaration()
		{
			Declare Tools BotTools script
		}

		function somewhereelse
		{
			if ${Actor[${Tools.LowestHealth}](exists)}
			{
			call CastSpellRange 1 0 0 0 ${Actor[${Tools.LowestHealth}].ID}
			}
		}



Members:
LowHealthCount(minhealth)
	- Returns the number of group members with health below ${minhealth}
LowestHealth
	- Returns the actorID of the groupmember with lowest HP
		- Later expand to include raid as a param
LowestPower
	- Same as above
ArcheType
	- Returns the archetype of the actor (broken in isxeq2)


---- Following are temporarly removed
*BuffTimer(ActorID, SpellName)
	-Returns the time left on a timer set with SetBuffTimer
		- For use on non-maintained buffs like Sow, Spirit Shards
*SetBuffTimer
	-Initiates a timer object
*DelBuffTimer
	-Destroys the timer object
*GroupChanges
	-Will return ActorID of new group members since last update
*UpdateGroup
	-Sets the groupchanges object
********************************************************************/



objectdef BotTools
{
	member:bool InGroup(int person)
	{
	variable int tmpgrp=1
	variable int grpcnt=${Me.GroupCount}
	if ${person}==${Me.ID}
	{
	 	return TRUE
	}
		do
		{
			if (${person} == ${Me.Group[${tmpgrp}].ID})
			{
			return TRUE
			}
		}
		While ${tmpgrp:Inc}<${grpcnt}
	return FALSE
	}
	member:int LowHealthCount(int minhealth)
	{
	variable int lowgrp=0
	variable int tmpgrp=1
	variable int grpcnt=${Me.GroupCount}
		do
		{
		;===============================================;
		;Loop through the group, pick the lowest one	;
		;===============================================;
			if ${Me.Group[${tmpgrp}].ToActor.Health}<=${minhealth} && ${Me.Group[${tmpgrp}].ToActor.Health}>0 && ${Me.Group[${tmpgrp}](exists)}
			{
			lowgrp:Inc
			}
		}
		While ${tmpgrp:Inc}<${grpcnt}
		if ${Me.ToActor.Health} <= ${minhealth}
		{
		lowgrp:Inc
		}
	return ${lowgrp}
	}
	member:int LowestHealth()
	{
	variable int lowest=${Me.ID}
	variable int tmpgrp=1
	variable int grpcnt=${Me.GroupCount}
		do
		{
		;===============================================;
		;Loop through the group, pick the lowest one	;
		;===============================================;
			if ${Me.Group[${tmpgrp}].ToActor.Health}<=${Actor[${lowest}].Health} && ${Me.Group[${tmpgrp}].ToActor.Health}<100 && ${Me.Group[${tmpgrp}].ToActor.Health}>0 && ${Me.Group[${tmpgrp}](exists)}
			{
			lowest:Set[${Me.Group[${tmpgrp}].ID}]
			}
		}
		While ${tmpgrp:Inc}<${grpcnt}
		Return ${lowest}
	}
	member:int LowestPower()
	{
	variable int lowest=${Me.ID}
	variable int tmpgrp=1
	variable int grpcnt=${Me.GroupCount}
		do
		{
		;===============================================;
		;Loop through the group, pick the lowest one	;
		;===============================================;
			if ${Me.Group[${tmpgrp}].ToActor.Power}<=${Actor[${lowest}].Power} && ${Me.Group[${tmpgrp}].ToActor.Power}<100 && ${Me.Group[${tmpgrp}].ToActor.Power}>0 && ${Me.Group[${tmpgrp}](exists)}
			{
			lowest:Set[${Me.Group[${tmpgrp}].ID}]
			}
		}
		While ${tmpgrp:Inc}<${grpcnt}
		Return ${lowest}
	}

	member:string ArcheType(int ActorID)
	{
		switch ${Actor[${ActorID}].Class}
		{
			case gaurdian
			case berserker
			case bruiser
			case monk
			case shadowknight
			case paladin
				return fighter
			case fury
			case templar
			case mystic
			case defiler
			case warden
			case inquisitor
				return priest
			case brigand
			case swashbuckler
			case ranger
			case dirge
			case troubador
			case assassin
				return scout
			case coercer
			case illusionist
			case conjuror
			case wizard
			case necromancer
			case warlock
				return mage
			case default
				return unknown
		}
	}

}

