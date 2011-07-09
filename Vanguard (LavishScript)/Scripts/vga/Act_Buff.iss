function BuffUp()
{
	if ${Group.Count} < 2
	call solobuff

	if ${Group.Count} > 1 && ${GroupStatus.Alive} && ${GroupStatus.AOEBuffClose} && ${GroupNeedsBuffs}
	call groupbuff
}

function solobuff()
{
	variable iterator anIter
	debuglog "Checking Buffs"
	Buff:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		debuglog "Checking ${anIter.Key} Buff"

		; If the buff has a time remaining of < zero, then it is a perm buff and we can forget about it.
		if (${Me.Effect[${anIter.Key}](exists)} && ${Me.Effect[${anIter.Key}].TimeRemaining} < 0)
		{
			anIter:Next
			continue
		}

		;If our buff is gone, or has less than 60 seconds, rebuff
		if !${Me.Effect[${anIter.Key}](exists)} || ${Me.Effect[${anIter.Key}].TimeRemaining} <= 60
		{
			if ${Me.Ability[${LazyBuff}](exists)}
			{
				debuglog "Buffing with Lazy ${anIter.Key}"
				Pawn[${Me}]:Target
				call checkabilitytocast "${LazyBuff}"
				if ${Return}
				{
					call executeability "${LazyBuff}" "buff" "Neither"
				}
			}
			if !${Me.Ability[${LazyBuff}](exists)}
			{
				debuglog "Buffing with ${anIter.Key}"
				Pawn[${Me}]:Target
				call checkabilitytocast "${anIter.Key}"
				if ${Return}
				{
					debuglog "Ready to Buff ${anIter.Key}"
					call executeability "${anIter.Key}" "buff" "Neither"
				}
			}
		}
		anIter:Next
	}
	Return

}

function groupbuff()
{
	variable iterator anIter

	Buff:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		; If the buff has a time remaining of < zero, then it is a perm buff and we can forget about it.
		if (${Me.Effect[${anIter.Key}](exists)} && ${Me.Effect[${anIter.Key}].TimeRemaining} < 0)
		{
			anIter:Next
			continue
		}

		;If our buff is gone, or has less than 60 seconds, rebuff
		if !${Me.Effect[${anIter.Key}](exists)} || ${Me.Effect[${anIter.Key}].TimeRemaining} <= 60
		{
			if ${Me.Ability[${LazyBuff}](exists)}
			{
				Me.ToPawn:Target
				call checkabilitytocast "${LazyBuff}"
				if ${Return}
				{
					call executeability "${LazyBuff}" "buff" "Neither"
				}
			}
			if !${Me.Ability[${LazyBuff}](exists)}
			{
				Me.ToPawn:Target
				call checkabilitytocast "${anIter.Key}"
				if ${Return}
				{
					call executeability "${anIter.Key}" "buff" "Neither"
				}
			}

		}
		anIter:Next
	}
	GroupNeedsBuffs:Set[FALSE]

	return
}

function BuffButton()
{
	variable iterator anIter

	Buff:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		if ${Me.Ability[${LazyBuff}](exists)}
		{
			Me.ToPawn:Target
			call checkabilitytocast "${LazyBuff}"
			if ${Return}
			{
				call executeability "${LazyBuff}" "buff" "Neither"
				GroupNeedsBuffs:Set[FALSE]
			}
		}
		if !${Me.Ability[${LazyBuff}](exists)}
		{
			Me.ToPawn:Target
			call checkabilitytocast "${anIter.Key}"
			if ${Return}
			{
				call executeability "${anIter.Key}" "buff" "Neither"
				GroupNeedsBuffs:Set[FALSE]
			}
		}
		anIter:Next
	}
	return
}
function StoneButton()
{
	variable int L
	for ( L:Set[1] ; ${Group[${L}].ID(exists)} ; L:Inc )
	{
		Group[${L}].ToPawn:Target
		wait 3
		call checkabilitytocast "${ResStone}"
		if ${Return} && !${Me.DTarget.Name.Equal[${Me}]}
		{
			call executeability "${ResStone}" "buff" "Neither"
		}
	}
}


