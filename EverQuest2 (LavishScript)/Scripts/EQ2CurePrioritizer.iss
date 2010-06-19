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
variable string gCureType1
variable string gCureType2
variable string gCureName

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
	Event[EQ2_onRaidMemberAfflicted]:AttachAtom[RaidAfflicted]
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

	if ${Me.InRaid} && ${Me.ID}!=${ActorID}
	{
		if ${Me.Raid[id,${ActorID}](exists)}
		{
			if !${Me.Raid[id,${ActorID}].Cursed}
			{
				echo Function CureCurse Finished - ${ActorID} not cursed
				return
			}
		}
	}

	if ${Me.GroupCount} && ${Me.ID}!=${ActorID}
	{
		if ${Me.Group[${Actor[id,${ActorID}].Name}](exists)}
		{
			if !${Me.Group[${Actor[id,${ActorID}].Name}].Cursed}
			{
				echo Function CureCurse Finished - ${ActorID} not cursed
				return
			}
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

	if !${Actor[id,${ActorID}](exists)}
	{
		echo Function CureCurse Finished - ${ActorID} not found
		return
	}
	
	if ${Script[Eq2bot](exists)}
	{
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot"]
		Script[Eq2bot]:Pause
	}

	if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.NotEqual[Cure Curse]}
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

	if ${Script[Eq2bot](exists)}
	{
		Script[Eq2bot]:Resume
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Resumed EQ2Bot"]
	}
	
	echo Function CureCure Finished
}

function gCure()
{
	echo Function gCure Started
	
	if ${Script[Eq2bot](exists)}
	{
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot"]
		Script[Eq2bot]:Pause
	}

	if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.NotEqual[${gCureName}]}
	{
		echo Canceling Spell Cast to group Cure
		do
		{
			eq2execute /cancel_spellcast
			wait 3
		}
		while ${Me.CastingSpell}
	}

	Me.Ability[${gCureName}]:Use
	wait 4

	if ${Script[Eq2bot](exists)}
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot and awaiting '${gCureName}' to complete"]
	
	do
	{
		waitframe
	}
	while ${Me.CastingSpell}

	gCureRequest:Set[0]
	
	if ${Script[Eq2bot](exists)}
	{
		Script[Eq2bot]:Resume
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Resumed EQ2Bot"]
	}
	
	echo Function gCure Finished
}

function inqCure()
{
	echo Function inqCure Started

	if ${Script[Eq2bot](exists)}
	{
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot"]
		Script[Eq2bot]:Pause
	}

	if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.NotEqual[Cleansing of the Soul]}
	{
		echo Canceling Spell Cast to Myth Cure
		do
		{
			eq2execute /cancel_spellcast
			wait 3
		}
		while ${Me.CastingSpell}
	}

	Me.Equipment[Penitent's Absolution]:Use
	wait 4

	if ${Script[Eq2bot](exists)}
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot and awaiting 'Penitent's Absolution' to complete"]

	do
	{
		waitframe
	}
	while ${Me.CastingSpell}

	gCureRequest:Set[0]

	if ${Script[Eq2bot](exists)}
	{
		Script[Eq2bot]:Resume
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Resumed EQ2Bot"]
	}

	echo Function inqCure finished
}


function stCure(int ActorID)
{
	variable(local) int count = 0
	echo Function stCure Started

	if ${Me.InRaid} && ${Me.ID}!=${ActorID}
	{
		if ${Me.Raid[id,${ActorID}](exists)}
		{
			if !${Me.Raid[id,${ActorID}].IsAfflicted}
			{
				echo stCure - ${ActorID} In Raid and not afflicted
				return
			}
		}
	}

	if ${Me.GroupCount} && ${Me.ID}!=${ActorID}
	{
		if ${Me.Group[${Actor[id,${ActorID}].Name}](exists)}
		{
			if !${Me.Group[${Actor[id,${ActorID}].Name}].IsAfflicted}
			{
				echo stCure - ${ActorID} In Raid and not afflicted
				return
			}
		}
	}

	if ${Me.ID}==${ActorID}
	{
		if !${Me.IsAfflicted}
		{
			echo stCure - Me not afflicted
			return
		}
	}

	if !${Actor[id,${ActorID}](exists)}
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
	
	if ${Script[Eq2bot](exists)}
	{
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot"]
		Script[Eq2bot]:Pause
	}
	
	if ${Me.CastingSpell} && !${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.Equal[Cure]}
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
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot and awaiting 'Cure Curse' to complete"]

	do
	{
		waitframe
	}
	while ${Me.CastingSpell}

	if ${Script[Eq2bot](exists)}
	{
		Script[Eq2bot]:Resume
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Resumed EQ2Bot"]
	}
	echo Function stCure Finished
}

atom GroupAfflicted(int ActorID, int tCounter, int aCounter, int nCounter, int eCounter, int cCounter)
{
	variable(local) int tcount = 0
	variable(local) int acount = 0
	variable(local) int ncount = 0
	variable(local) int ecount = 0
	variable(local) int temph1 = 1

	echo GroupAfflicted atom fired

	if ${gCureRequest}
		return

	;determine if groupcure is required
	;check for group cures, if it is ready and we are in a large enough group
	if ${Me.GroupCount}>2 && (${Me.Ability[${gCureSpell}].IsReady} || (${Me.Equipment[1].Tier.Equal[MYTHICAL]} && ${Me.Equipment[Penitent's Absolution].IsReady}))
	{
		;check ourselves
		if ${Me.IsAfflicted}
		{
			if ${Me.Trauma}>0
				tcount:Inc
			if ${Me.Arcane}>0
				acount:Inc
			if ${Me.Noxious}>0
				ncount:Inc
			if ${Me.Elemental}>0
				ecount:Inc
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
			if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].IsAfflicted}
			{
				if ${Me.Group[${temphl}].Trauma}>0
					tcount:Inc
				if ${Me.Group[${temphl}].Arcane}>0
					acount:Inc
				if ${Me.Group[${temphl}].Noxious}>0
					ncount:Inc
				if ${Me.Group[${temphl}].Elemental}>0
					ecount:Inc
				if ${Me.Group[${temphl}].Cursed}>0 && ${Me.Ability[Cure Curse].IsAvailale}
				{
					echo queuing curse cure
					QueueCommand call CureCurse ${Me.Group[${temphl}].ID}
				}
			}
		}
		while ${temphl:Inc} <= ${Me.GroupCount}

		switch ${gCureType1}
		{
			case Trauma
				if ${tcount}>2 && ${Me.Ability[${gCureName}].IsReady}
				{
					echo queuing group cure
					QueueCommand call gCure
					gCureRequest:Set[1]
				}
				break
			case Arcane
				if ${acount}>2 && ${Me.Ability[${gCureName}].IsReady}
				{
					echo queuing group cure
					QueueCommand call gCure
					gCureRequest:Set[1]
				}
				break
			case Noxious
				if ${ncount}>2 && ${Me.Ability[${gCureName}].IsReady}
				{
					echo queuing group cure
					QueueCommand call gCure
					gCureRequest:Set[1]
				}
				break
			case Elemental
				if ${ecount}>2 && ${Me.Ability[${gCureName}].IsReady}
				{
					echo queuing group cure
					QueueCommand call gCure
					gCureRequest:Set[1]
				}
				break
			case default
				echo something broke
				break
		}

		if !${gCureRequest}
		{
			switch ${gCureType2}
			{
				case Trauma
					if ${tcount}>2 && ${Me.Ability[${gCureName}].IsReady}
					{
						echo queuing group cure
						QueueCommand call gCure
						gCureRequest:Set[1]
					}
					break
				case Arcane
					if ${acount}>2 && ${Me.Ability[${gCureName}].IsReady}
					{
						echo queuing group cure
						QueueCommand call gCure
						gCureRequest:Set[1]
					}
					break
				case Noxious
					if ${ncount}>2 && ${Me.Ability[${gCureName}].IsReady}
					{
						echo queuing group cure
						QueueCommand call gCure
						gCureRequest:Set[1]
					}
					break
				case Elemental
					if ${ecount}>2 && ${Me.Ability[${gCureName}].IsReady}
					{
						echo queuing group cure
						QueueCommand call gCure
						gCureRequest:Set[1]
					}
					break
				case default
					echo something broke
					break
			}
		}

		if !${gCureRequest} && ${Me.SubClass.Equal[Inquisitor]} && (${Me.Equipment[1].Tier.Equal[MYTHICAL]} && ${Me.Equipment[Penitent's Absolution].IsReady})
		{
			if ${tcount}>2 || ${acount}>2 || ${ncount}>2 || ${ecount}>2
			{
				echo queuing inquisitor cure
				QueueCommand call inqCure
				gCureRequest:Set[1]
			}
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
			gCureType1:Set[Trauma]
			gCureType2:Set[Arcane]
			gCureName:Set[Devoted Resolve III]
			break
		case Inquisitor
			gCureType1:Set[Elemental]
			gCureType2:Set[Arcane]
			gCureName:Set[Resolute Flagellant III]
			break
		case Mystic
			gCureType1:Set[Noxious]
			gCureType2:Set[Arcane]
			gCureName:Set[Ebbing Spirit III]
			break
		case Defiler
			gCureType1:Set[Trauma]
			gCureType2:Set[Noxious]
			gCureName:Set[Mail of Souls III]
			break
		case Warden
			gCureType1:Set[Trauma]
			gCureType2:Set[Elemental]
			gCureName:Set[Verdant Whisper III]
			break
		case Fury
			gCureType1:Set[Noxious]
			gCureType2:Set[Elemental]
			gCureName:Set[Abolishment III]
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
		if ${Me.Group[${gmember}](exists)} && ${Me.Group[${gmember}].ID}==${ActorID}
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
		if ${Me.Raid[${rmember}](exists)} && ${Me.Raid[${rmember}].ID}==${ActorID}
			return ${rmember}
	}
	while ${rmember:Inc}<24
	
	return 0

}

function atexit()
{
	if ${Script[Eq2bot](exists)}
		Script[EQ2Bot]:Resume
	
	echo CurePrioritizer Script Ending...
}