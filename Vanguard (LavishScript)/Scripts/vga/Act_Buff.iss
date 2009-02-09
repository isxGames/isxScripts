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
		;If our buff is gone, or has less than 60 seconds, rebuff
		if !${Me.Effect[${anIter.Key}](exists)} && ${Me.Effect[${anIter.Key}].TimeRemaining} <= 60
		{
			if ${Me.Ability[${LazyBuff}](exists)}
			{
				debuglog "Buffing with Lazy ${anIter.Key}"
				Pawn[Me]:Target
				call checkabilitytocast "${LazyBuff}"	
				if ${Return} && ${Me.Ability[${LazyBuff}].IsReady}
				{
					call executeability "${LazyBuff}" "buff" "Neither"
				}
			}
			if !${Me.Ability[${LazyBuff}](exists)}
			{
				debuglog "Buffing with ${anIter.Key}"
				Pawn[Me]:Target
				call checkabilitytocast "${anIter.Key}"	
				if ${Return} && ${Me.Ability[${anIter.Key}].IsReady}
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
  wait 20
	variable iterator anIter

	Buff:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		;If our buff is gone, or has less than 60 seconds, rebuff
		if !${Me.Effect[${anIter.Key}](exists)} && ${Me.Effect[${anIter.Key}].TimeRemaining} <= 60
		{
			if ${Me.Ability[${LazyBuff}](exists)}
				{
				Pawn[Me]:Target
				call checkabilitytocast "${LazyBuff}"	
				if ${Return} && ${Me.Ability[${LazyBuff}].IsReady}
					{
					call executeability "${LazyBuff}" "buff" "Neither"
					}
				}
			if !${Me.Ability[${LazyBuff}](exists)}
				{
				Pawn[Me]:Target
				call checkabilitytocast "${anIter.Key}"	
				if ${Return} && ${Me.Ability[${anIter.Key}].IsReady}
					{
					call executeability "${anIter.Key}" "buff" "Neither"
					}
				}
		}
		anIter:Next
	}
	GroupNeedsBuffs:Set[FALSE]
	Return


}
function BuffButton(int aGroupNumber)
{
	;; 1 is always "Me"
	;; Otherwise, convert number to name based on what we are using in the UI

	variable string GroupMemberName
	
	if (${aGroupNumber} == 1)
		GroupMemberName:Set[${Me.FName}]
	else
		GroupMemberName:Set[${GrpMemberNames[${aGroupNumber}]}]
	
	if !${Group[${GroupMemberName}](exists)}
	{
		debuglog "BuffButton(${aGroupNumber}) - Group Member doesn't seem to exist..."
		return
	}
	
	Group[${GroupMemberName}].ToPawn:Target
	variable iterator anIter

	Buff:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		if ${Me.Ability[${LazyBuff}](exists)}
		{
			call checkabilitytocast "${LazyBuff}"	
			if ${Return} && ${Me.Ability[${LazyBuff}].IsReady}
			{
				call executeability "${LazyBuff}" "buff" "Neither"
			}
		}
		if !${Me.Ability[${LazyBuff}](exists)}
		{
			call checkabilitytocast "${anIter.Key}"	
			if ${Return} && ${Me.Ability[${anIter.Key}].IsReady}
			{
				call executeability "${anIter.Key}" "buff" "Neither"
			}
		}
		anIter:Next
	}
}
atom(global) StoneButton(int aGroupNumber)
{
	;; 1 is always "Me"
	;; Otherwise, convert number to name based on what we are using in the UI

	variable string GroupMemberName
	
	if (${aGroupNumber} == 1)
		GroupMemberName:Set[${Me.FName}]
	else
		GroupMemberName:Set[${GrpMemberNames[${aGroupNumber}]}]
	
	if !${Group[${GroupMemberName}](exists)}
	{
		debuglog "BuffButton(${aGroupNumber}) - Group Member doesn't seem to exist..."
		return
	}
	
	
	Group[${GroupMemberName}].ToPawn:Target
	Me.Ability[${ResStone}]:Use
}
