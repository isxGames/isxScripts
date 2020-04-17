/*
EQ2CurePrioritizer.iss
--------------------------------------------------------------------------------
This script is designed to place a high priority on cure casts.  In fact it will
halt other scripts to prioritize healer cure casting above all other casting.
--------------------------------------------------------------------------------
*/

#define QUIT f7

variable string MyClass = "${Me.SubClass}"
variable bool gCureRequest = 0
variable bool meCursed = 0
variable bool stCureRequest = 0
variable string gCureName
variable string gCure2Name
variable string gCure3Name


function main()
{
	if (!${ISXEQ2.IsReady})
	{
		messagebox -ok "ISXEQ2 is not loaded or not ready. ${Script.Name} aborting."
		return
	}
	echo CurePrioritizer Running
	echo Press F7 to quit

	squelch bind quit "QUIT" "Script:End"

	ISXEQ2:EnableAfflictionEvents
	ISXEQ2:SetAfflictionEventsTimeInterval[400]

	Event[EQ2_onGroupMemberAfflicted]:AttachAtom[GroupAfflicted]
	;Event[EQ2_onRaidMemberAfflicted]:AttachAtom[RaidAfflicted]
	Event[EQ2_onMeAfflicted]:AttachAtom[MeAfflicted]

	call InitCures

	do
	{
		if ${meCursed}
			ExecuteQueued CureCurse
		if ${gCureRequest}
			ExecuteQueued gCure
		ExecuteQueued
		wait 2
	}
	while 1
}

function CureCurse(int ActorID)
{
	echo Function CureCusre Started

	if ${Me.InRaid} && ${Me.ID}!=${ActorID} && ${Me.Raid[id,${ActorID}].Name(exists)}
	{
		if !${Me.Raid[id,${ActorID}].Cursed}
		{
			echo Function CureCurse Finished - ${ActorID} not cursed
			return
		}
	}

	if ${Me.GroupCount} && ${Me.ID}!=${ActorID} && ${Me.Group[${Actor[id,${ActorID}].Name}].Name(exists)}
	{
		if !${Me.Group[${Actor[id,${ActorID}].Name}].Cursed}
		{
			echo Function CureCurse Finished - ${ActorID} not cursed
			return
		}
	}

	if ${Me.ID}==${ActorID}
	{
		if !${Me.Cursed}
		{
			meCursed:Set[0]
			echo Function CureCurse Finished - Me not cursed
			return
		}
	}

	if !${Actor[id,${ActorID}].Name(exists)}
	{
		echo Function CureCurse Finished - ${ActorID} not found
		return
	}
	
	call eq2botStop

	call NotCastingCure
	if ${Return} 
	{
		echo Canceling Spell Cast to Curse Cure
		while ${Me.CastingSpell}
		{
			eq2execute /cancel_spellcast
			wait 3
		}
	}

	eq2execute /useabilityonplayer ${Actor[id,${ActorID}].Name} "Cure Curse"
	wait 3

	if ${Script[Eq2bot](exists)}
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot and awaiting 'Cure Curse' to complete"]
	
	do
	{	
		waitframe
	}
	while ${Me.CastingSpell}

	if ${ActorID}==${Me.ID}
		meCursed:Set[0]

	call eq2botStart
	
	echo Function CureCure Finished
}

function gCure()
{
	variable(local) string gcure

	echo Function gCure Started

	if ${Me.Ability[${gCure3Name}](exists)} && ${Me.Ability[${gCure3Name}].IsReady}	
		gCure:Set[${gCure3Name}]
		
	if ${Me.Ability[${gCure2Name}](exists)} && ${Me.Ability[${gCure2Name}].IsReady}	
		gCure:Set[${gCure2Name}]

	if ${Me.Ability[${gCureName}](exists)} && ${Me.Ability[${gCureName}].IsReady}	
		gCure:Set[${gCureName}]

	if ${gCure:Length}<1
	{
		echo no group cure ready
		Me.Inventory[Crystallized Spirit]:Use
		return 0
	}	
		
	call eq2botStop

	call NotCastingCure
	if ${Return} 
	{
		echo Canceling Spell Cast to group Cure
		do
		{
			eq2execute /cancel_spellcast
			wait 3
		}
		while ${Me.CastingSpell}
	}

	Me.Ability[${gCure}]:Use
	wait 3

	if ${Script[Eq2bot](exists)}
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot and awaiting '${gCure}' to complete"]
	
	do
	{
		waitframe
	}
	while ${Me.CastingSpell}

	gCureRequest:Set[0]
	
	call eq2botStart
	
	echo Function gCure Finished
}

function stCure(int ActorID)
{
	variable(local) int count = 0
	echo Function stCure Started

	if ${Me.InRaid} && ${Me.ID}!=${ActorID} && ${Me.Raid[id,${ActorID}].Name(exists)}
	{
		if !${Me.Raid[id,${ActorID}].IsAfflicted}
		{
			echo stCure - ${ActorID} In Raid and not afflicted
			return
		}
	}

	if ${Me.GroupCount} && ${Me.ID}!=${ActorID} && ${Me.Group[${Actor[id,${ActorID}].Name}].Name(exists)}
	{
		if !${Me.Group[${Actor[id,${ActorID}].Name}].IsAfflicted}
		{
			echo stCure - ${ActorID} In group and not afflicted
			return
		}
	}

	if ${Me.ID}==${ActorID} && !${Me.IsAfflicted}
	{
		echo stCure - Me not afflicted
		return
	}

	if !${Actor[id,${ActorID}].Name(exists)}
	{
		echo stCure - ${ActorID} does not exist
		return
	}

	if ${Me.ID}==${ActorID} && (${Me.Trauma}>0 || ${Me.Elemental}>0 || ${Me.Noxious}>0 || ${Me.Arcane}>0)
		count:Inc
		
	if !${count}
	{
		call inmygroup ${ActorID}
	
		if ${Return}
		{
			if ${Me.Group[${Return}].Trauma}>0 || ${Me.Group[${Return}].Elemental}>0 || ${Me.Group[${Return}].Noxious}>0 || ${Me.Group[${Return}].Arcane}>0
				count:Inc	
		}
	}
	
	if !${count}
	{
		call inmyraid ${ActorID}

		if ${Return}
		{
			if ${Me.Raid[${Return}].Trauma}>0 || ${Me.Raid[${Return}].Elemental}>0 || ${Me.Raid[${Return}].Noxious}>0 || ${Me.Raid[${Return}].Arcane}>0
				count:Inc	
		}		
		
	}
	
	if !${count}
	{
		echo stCure - Actor not Found in Group or Raid
		return
	}
	
	if ${Actor[${ActorID}].Distance}>25
	{
		echo stCure - Actor out of range, aborting
		return
	}
	
	call eq2botStop
	
	call NotCastingCure
	if ${Return} 
	{
		echo Canceling Spell Cast to single Cure
		do
		{
			eq2execute /cancel_spellcast
			wait 3
		}
		while ${Me.CastingSpell}
	}

	eq2execute /useabilityonplayer ${Actor[id,${ActorID}].Name} "Cure"
	wait 3

	if ${Script[Eq2bot](exists)}
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot and awaiting 'Cure' to complete"]

	do
	{
		waitframe
	}
	while ${Me.CastingSpell}

	run eq2botStart
	echo Function stCure Finished
}

atom GroupAfflicted(int ActorID, int tCounter, int aCounter, int nCounter, int eCounter, int cCounter)
{
	variable(local) int acount = 0
	variable(local) int temph1 = 1

	echo GroupAfflicted atom fired

	if ${gCureRequest}
		return

	;determine if groupcure is required
	;check for group cures, if it is ready and we are in a large enough group
	if ${Me.GroupCount}>2 
	{
		;check ourselves
		if ${Me.IsAfflicted}
		{
			if ${Me.Trauma}>0
				acount:Inc
			if ${Me.Arcane}>0
				acount:Inc
			if ${Me.Noxious}>0
				acount:Inc
			if ${Me.Elemental}>0
				acount:Inc
			if ${Me.Cursed}>0 && ${Me.Ability[Cure Curse].IsAvailale}
			{
				echo queing curse cure
				QueueCommand call CureCurse ${Me.ID}
			}
		}

		;loop group members, and check for group curable afflictions
		do
		{
			;make sure they in zone and in range
			if ${Me.Group[${temphl}].Name(exists)} && ${Me.Group[${temphl}].IsAfflicted}
			{
				if ${Me.Group[${temphl}].Trauma}>0
					acount:Inc
				if ${Me.Group[${temphl}].Arcane}>0
					acount:Inc
				if ${Me.Group[${temphl}].Noxious}>0
					acount:Inc
				if ${Me.Group[${temphl}].Elemental}>0
					acount:Inc
				if ${Me.Group[${temphl}].Cursed}>0 && ${Me.Ability[Cure Curse].IsAvailale}
				{
					echo queuing curse cure
					QueueCommand call CureCurse ${Me.Group[${temphl}].ID}
				}
			}
		}
		while ${temphl:Inc} <= ${Me.GroupCount}


		if ${acount}>2
		{
			echo queuing group cure
			QueueCommand call gCure
			gCureRequest:Set[1]		
		}
	}

	if !${gCureRequest}
	{
		echo queuing single target cure
		QueueCommand call stCure ${ActorID}
	}
}

atom RaidAfflicted(int ActorID, int tCounter, int aCounter, int nCounter, int eCounter, int cCounter)
{
	variable(local) int temph1 = 1
	variable(local) int afflictedingroup = 0

	echo RaidAfflicted atom fired

	if ${ActorID}==${Me.ID}
		return

	do
	{
		if ${ActorID}==${Me.Group[${temphl}].ID}
			afflictedingroup:Set[1]
	}
	while ${temphl:Inc} <= ${Me.GroupCount}

	if ${afflictedingroup}
		return

	echo stCure Queued on ${ActorID}
	QueueCommand call stCure ${ActorID}
}

atom MeAfflicted(int ActorID, int tCounter, int aCounter, int nCounter, int eCounter, int cCounter)
{
	echo MeAfflicted atom fired

	if ${cCounter}
	{
		echo CureCurse on Me Queued
		FlushQueued CureCurse
		QueueCommand call CureCurse ${Me.ID}
	}

	if ${tCounter} || ${aCounter} || ${nCounter} || ${eCounter}
	{
		echo stCure Queued on Me
		QueueCommand call stCure ${Me.ID}
	}
}

function InitCures()
{
	switch ${Me.SubClass}
	{
		case Templar
			gCureName:Set[Devoted Resolve III]
			break
		case Inquisitor  
			gCureName:Set[Cleansing of the Soul]
			gCure2Name:Set[Resolute Flagellant III]
			break
		case Mystic
			gCureName:Set[Ebbing Spirit III]
			break
		case Defiler
			gCureName:Set[Mail of Souls III]
			break
		case Warden
			gCureName:Set[Tunare's Grace]
			gCure2Name:Set[Verdant Whisper III]
			break
		case Fury
			gCureName:Set[Tunare's Grace]
			gCure2Name:Set[Abolishment III]
			gCure3Name:Set[Natural Cleanse]
			break
		case Default
			echo Not a Healer class, no group cures
			break
	}
}

function inmygroup(uint ActorID)
{
	variable(local) int gmember = 1
	
	do
	{
		if ${Me.Group[${gmember}].Name(exists)} && ${Me.Group[${gmember}].ID}==${ActorID}
			return ${gmember}
	}
	while ${gmember:Inc}<6
	
	return 0

}

function inmyraid(uint ActorID)
{
	variable(local) int rmember = 1
	
	do
	{
		if ${Me.Raid[${rmember}].Name(exists)} && ${Me.Raid[${rmember}].ID}==${ActorID}
			return ${rmember}
	}
	while ${rmember:Inc}<24
	
	return 0

}

function NotCastingCure()
{
	variable(local) int tmpcnt = 0
	
	if !${Me.CastingSpell}
		return 1

	if ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[Cure]}
		tmpcnt:Inc

	if ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[Cure Curse]}
		tmpcnt:Inc
		
	if ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[${gCureName}]}
		tmpcnt:Inc
		
	if ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[${gCure2Name}]}
		tmpcnt:Inc

	if ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[${gCure3Name}]}
		tmpcnt:Inc
	
	if ${tmpcnt}
		return 0
	else
		return 1
}

function eq2botStart()
{
	if ${Script[Eq2bot](exists)}
	{
		ScriptScript[EQ2Bot]:QueueCommand[call PauseBot]
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Resumed EQ2Bot"]
	}
}


function eq2botStop()
{
	if ${Script[Eq2bot](exists)}
	{
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot"]
		ScriptScript[EQ2Bot]:QueueCommand[call PauseBot]
	}
}
function atexit()
{
	if ${Script[Eq2bot](exists)}
		ScriptScript[EQ2Bot]:QueueCommand[call PauseBot]
	
	echo CurePrioritizer Script Ending...
}