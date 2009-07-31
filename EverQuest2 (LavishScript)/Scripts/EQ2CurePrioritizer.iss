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
		waitframe
	}
	while 1
}

function CureCurse(int ActorID)
{
	Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot"]
	Script[Eq2bot]:Pause

	if ${Me.InRaid}
	{
		if ${Me.Raid[id,${ActorID}](exists)}
		{
			if !${Me.Raid[id,${ActorID}].Cursed}
				return
		}
	}

	if ${Me.GroupCount}
	{
		if ${Me.Group[${Actor[id,${ActorID}].Name}](exists)}
		{
			if !${Me.Group[${Actor[id,${ActorID}].Name}].Cursed}
				return
		}
	}

	if ${Me.ID}==${ActorID}
	{
		if !${Me.Cursed}
		{
			meCursed:Set[0]
			return
		}
	}

	if !${Actor[id,${ActorID}](exists)}
		return

	if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.NotEqual[Cure Curse]}
		eq2execute /cancel_spellcast

	eq2execute /useabilityonplayer ${Actor[id,${ActorID}].Name} "Cure Curse"
	wait 4

	do
	{
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot and awaiting 'Cure Curse' to complete"]
		waitframe
	}
	while ${Me.CastingSpell}

	if ${ActorID}==${Me.ID}
		meCursed:Set[0]

	Script[Eq2bot]:Resume
	Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Resumed EQ2Bot"]
}

function gCure()
{
	Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot"]
	Script[Eq2bot]:Pause

	if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.NotEqual[${gCureName}]}
		eq2execute /cancel_spellcast

	Me.Ability[${gCureName}]:Use
	wait 4

	do
	{
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot and awaiting '${gCureName}' to complete"]
		waitframe
	}
	while ${Me.CastingSpell}

	gCureRequest:Set[0]

	Script[Eq2bot]:Resume
	Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Resumed EQ2Bot"]
}

function inqCure()
{
	Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot"]
	Script[Eq2bot]:Pause

	if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.NotEqual[Cleansing of the Soul]}
		eq2execute /cancel_spellcast

	Me.Equipment[Penitent's Absolution]:Use
	wait 4

	do
	{
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot and awaiting 'Penitent's Absolution' to complete"]
		waitframe
	}
	while ${Me.CastingSpell}

	gCureRequest:Set[0]

	Script[Eq2bot]:Resume
	Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Resumed EQ2Bot"]
}


function stCure(int ActorID)
{
	Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot"]
	Script[Eq2bot]:Pause

	if ${Me.InRaid}
	{
		if ${Me.Raid[id,${ActorID}](exists)}
		{
			if !${Me.Raid[id,${ActorID}].IsAfflicted}
				return
		}
	}

	if ${Me.GroupCount}
	{
		if ${Me.Group[${Actor[id,${ActorID}].Name}](exists)}
		{
			if !${Me.Group[${Actor[id,${ActorID}].Name}].IsAfflicted}
				return
		}
	}

	if ${Me.ID}==${ActorID}
	{
		if !${Me.IsAfflicted}
			return
	}

	if !${Actor[id,${ActorID}](exists)}
		return

	if ${Me.CastingSpell} && ${EQ2DataSourceContainer[GameData].GetDynamicData[Spells.Casting].ShortLabel.NotEqual[Cure Curse]}
		eq2execute /cancel_spellcast

	eq2execute /useabilityonplayer ${Actor[id,${ActorID}].Name} "Cure Curse"
	wait 4

	do
	{
		Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Paused EQ2Bot and awaiting 'Cure Curse' to complete"]
		waitframe
	}
	while ${Me.CastingSpell}

	Script[Eq2bot]:Resume
	Script[Eq2bot].VariableScope.CurrentAction:Set["Cure Process Handler has Resumed EQ2Bot"]
}

atom GroupAfflicted(int ActorID, int tCounter, int aCounter, int nCounter, int eCounter, int cCounter)
{
	variable int tcount 0
	variable int acount 0
	variable int ncount 0
	variable int ecount 0
	variable int temph1 1

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
					QueueCommand call CureCurse ${Me.Group[${temphl}].ID}
			}
		}
		while ${temphl:Inc} <= ${Me.GroupCount}

		switch ${gCureType1}
		{
			case Trauma
				if ${tcount}>2 && ${Me.Ability[${gCureName}].IsReady}
				{
					QueueCommand call gCure
					gCureRequest:Set[1]
				}
				break
			case Arcane
				if ${acount}>2 && ${Me.Ability[${gCureName}].IsReady}
				{
					QueueCommand call gCure
					gCureRequest:Set[1]
				}
				break
			case Noxious
				if ${ncount}>2 && ${Me.Ability[${gCureName}].IsReady}
				{
					QueueCommand call gCure
					gCureRequest:Set[1]
				}
				break
			case Elemental
				if ${ecount}>2 && ${Me.Ability[${gCureName}].IsReady}
				{
					QueueCommand call gCure
					gCureRequest:Set[1]
				}
				break
			case default
				echo something broke
				break
		}

		if !${curequeued}
		{
			switch ${gCureType2}
			{
				case Trauma
					if ${tcount}>2 && ${Me.Ability[${gCureName}].IsReady}
					{
						QueueCommand call gCure
						gCureRequest:Set[1]
					}
					break
				case Arcane
					if ${acount}>2 && ${Me.Ability[${gCureName}].IsReady}
					{
						QueueCommand call gCure
						gCureRequest:Set[1]
					}
					break
				case Noxious
					if ${ncount}>2 && ${Me.Ability[${gCureName}].IsReady}
					{
						QueueCommand call gCure
						gCureRequest:Set[1]
					}
					break
				case Elemental
					if ${ecount}>2 && ${Me.Ability[${gCureName}].IsReady}
					{
						QueueCommand call gCure
						gCureRequest:Set[1]
					}
					break
				case default
					echo something broke
					break
			}
		}

		if ${Me.SubClass.Equal[Inquisitor]} && (${Me.Equipment[1].Tier.Equal[MYTHICAL]} && ${Me.Equipment[Penitent's Absolution].IsReady})
		{
			if ${tcount}>2 || ${acount}>2 || ${ncount}>2 || ${ecount}>2
			{
				QueueCommand call inqCure
				gCureRequest:Set[1]
			}
		}
	}

	if !${gCureRequest}
		QueueCommand call stCure ${ActorID}

}

atom RaidAfflicted(int ActorID, int tCounter, int aCounter, int nCounter, int eCounter, int cCounter)
{
	variable int temph1 1
	variable int afflictedingroup 0

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

	QueueCommand call stCure ${ActorID}
}

atom MeAfflicted(int ActorID, int tCounter, int aCounter, int nCounter, int eCounter, int cCounter)
{
	if ${cCounter}
	{
		FlushQueued CureCurse
		QueueCommand call CureCurse ${Me.ID}
	}

	if ${tCounter} || ${aCounter} || ${nCounter} || ${eCounter}
	{
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

function atexit()
{
	Script[EQ2Bot]:Resume
	echo CurePrioritizer Script Ending...
}