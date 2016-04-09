;*************************************************************
function functAOECrits()
{
	variable iterator anIter
	debuglog "Running AOE Crits"
	AOECrits:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		if (!${Me.Ability[${anIter.Value}].IsReady})
		{
			anIter:Next
			continue
		}
		if !${fight.ShouldIAttack}
		return


		call checkabilitytocast "${anIter.Value}"
		if ${Return}
		{
			call executeability "${anIter.Value}" "attack" "Both"
		}
		anIter:Next
	}
	return
}

;*************************************************************
function functBuffCrits()
{
	variable iterator anIter
	debuglog "Running Buff Crits"
	BuffCrits:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		if (!${Me.Ability[${anIter.Value}].IsReady})
		{
			anIter:Next
			continue
		}
		if !${fight.ShouldIAttack}
		return


		call checkabilitytocast "${anIter.Value}"
		if ${Return} && !${Me.Effect[${anIter.Value}](exists)}
		{
			call executeability "${anIter.Value}" "attack" "Both"
		}
		anIter:Next
	}
	return
}
;*************************************************************
function functDotCrits()
{
	variable iterator anIter

	debuglog "Running Dot Crits"
	DotCrits:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{
		if (!${Me.Ability[${anIter.Value}].IsReady})
		{
			anIter:Next
			continue
		}
		if !${fight.ShouldIAttack}
		return


		call checkabilitytocast "${anIter.Value}"
		if ${Return} && !${Me.TargetDebuff[${anIter.Value}](exists)}
		{
			call executeability "${anIter.Value}" "attack" "Both"
		}
		anIter:Next
	}
	return
}
;*************************************************************

;; Amadeus ssys "This function has some odd logic in it..."
function functCounterAttacks()
{
	variable iterator anIter

	debuglog "Running Counter Attacks"
	CounterAttack:GetSettingIterator[anIter]
	anIter:First

	while ( ${anIter.Key(exists)} )
	{

		call checkabilitytocast "${anIter.Value}"
		if ${Return} && ${Me.Ability[${anIter.Value}].IsReady}
		{
			if ${Me.Effect[${anIter.Value}](exists)}
			{
				anIter:Next
			}
			if ${Me.TargetDebuff[${anIter.Value}](exists)}
			{
				anIter:Next
			}
			call checkabilitytocast "${anIter.Value}"
			if ${Return}
			call executeability "${anIter.Value}" "counter" "Both"
		}
		anIter:Next
		if !${fight.ShouldIAttack}
		return
	}
	return
}
;*************************************************************
function functCombatCrits()
{
	variable iterator anIter
	variable int SafeCounter

	debuglog "Running Combat Crits"
	;echo "functCombatCrits() :: ${doCombatCrits} - ${fight.ShouldIAttack}"
	if ${doCombatCrits} && ${fight.ShouldIAttack}
	{
		;echo "functCombatCrits2()"
		CombatCrits:GetSettingIterator[anIter]
		anIter:First

		while ( ${anIter.Key(exists)} )
		{
			;echo "functCombatCrits() -- checking ${anIter.Value} [${Me.Ability[${anIter.Value}].IsChain}] [${Me.Ability[${anIter.Value}].CountdownTimer}]"
			if (${Me.Ability[${anIter.Value}].CountdownTimer} < 1)
			{
				anIter:Next
				continue
			}
			if !${fight.ShouldIAttack}
				return

			if (!${Me.Ability[${anIter.Value}].IsReady})
			{
				SafeCounter:Set[0]
				do
				{
					wait 2
					;echo "waiting! [${Me.Ability[${anIter.Value}].CountdownTimer}]"
					SafeCounter:Inc
				}
				while (!${Me.Ability[${anIter.Value}].IsReady} && ${Me.Ability[${anIter.Value}].CountdownTimer} > 0 && !${Me.Target.IsDead} && ${SafeCounter} < 7)
				;; ${SafeCounter} == 7 would mean a total wait of approximately 1.5 seconds.  This is here only to make sure we don't get in any sort of unsafe "perpetual loop" situation.
			}
			
			;echo "functCombatCrits() -- casting ${anIter.Value} [${Me.Ability[${anIter.Value}].IsChain}] (${Me.Ability[${anIter.Value}].IsReady})"
			call checkabilitytocast "${anIter.Value}"
			if ${Return}
			{
				call executeability "${anIter.Value}" "attack" "Both"
			}
			anIter:Next
		}
	}
	return
}



